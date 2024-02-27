function varargout = detran_importData (varargin)
%DETRAN_IMPORTDATA Detran function to import transport data from d3d output
%
% This routine is part of the Detran and manages the data import. It is
% used by the GUI and also by the command line Detran application. For the
% latter, input and output arguments are required (see below).
%
%   Syntax:
%   detranData = detran_importData (filename, weights, dataFile, inputMode, sType, dt);
%
%   Input:
%   filename    Location of the Delft3D output file(s) (for mm or multi it 
%               is sufficient to indicate one of the trim-files/trih-files)
%   weights     File location with condition weight (tekal-file) for multi 
%               simulation type.
%   dataFile    Type of input file: 'Trim-file(s)' or 'Trih-file(s)'.
%   inputMode   Type of simulation: 'Single file', 'Multiple files' or
%               'Mormere simulation'.
%   sType       Type of transport: 'instant' or 'mean'.
%   dt          Time step to use, set to 0 to use the last available time 
%               step
%
%   Output:
%   detranData  Structure with detran data.
% 
%   See also detran

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.
%
% 

if nargin == 0
	[but,fig]=gcbo;

	detran_clearAxis;
	data=detran_createEmptyStructure;
    
    [dataFile,inputMode,sType]=detran_selectInputSettings;

	if isempty(dataFile)
	    return
    end
    
    dt = [];
	filename=[];
	weights=[];

else
    filename = varargin{1};
    weights = varargin{2};
	dataFile = varargin{3};
	inputMode = varargin{4};
	sType = varargin{5};
	dt = varargin{6};
end

switch inputMode
    case 'Single file'
        switch dataFile
            case 'Trim-file(s)'
                data.input = detran_d3dTrans_single(sType,filename,dt);
                if isempty(data.input)
                    return
                end
            case 'Trih-file(s)'
                %[namtra,data.transects,data.transectData,data.namSed]=detran_d3dTransFromHis_single(sType,filename,dt);
                [namtra,data.transects,data.input,data.namSed]=detran_d3dTransFromHis_single(sType,filename,dt);
                if isempty(data.input)
                    return
                end                
                avgTransData=nan;
        end
    case 'Multiple files'
        switch dataFile
            case 'Trim-file(s)'
                data.input=detran_d3dTrans_multi(sType,filename,weights,dt);
                if isempty(data.input)
                    return
                end                
            case 'Trih-file(s)'
            [namtra,data.transects,data.input,data.namSed]=detran_d3dTransFromHis_multi(sType,filename,weights,dt);
                avgTransData=nan;
                if isempty(data.input)
                    return
                end
        end
    case 'Mormerge simulation'
        switch dataFile
            case 'Trim-file(s)'
                data.input=detran_d3dTrans_mm(sType,filename,dt);
                if isempty(data.input)
                    return
                end
            case 'Trih-file(s)'
                [namtra,data.transects,data.input,data.namSed]=detran_d3dTransFromHis_mm(sType,filename,dt);
                if isempty(data.input)
                    return
                end                
                avgTransData=nan;
        end
end

if nargout == 0
    set(fig,'userdata',data);
    detran_setGuiObjects;
    detran_prepareTransPlot;
else
    varargout{1} = data;
end