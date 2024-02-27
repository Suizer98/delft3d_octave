function varargout = detran(varargin)
%DETRAN  Calculates sediment transport through transects
%
%   This tool calculates the cumulative sediment transport through
%   cross sections on the basis of transport data from Delft3D results.
%   Both trim-files and trih-files can be used. In case of trim-files,
%   Detran calculates transport rates through arbitrarily choosen transects
%   and in case of trih-files, Detran provides the transport rates through
%   the cross sections defined in the Delft3D input file.
%
%   Detran can handle single simulations, simulations consisting of
%   multiple conditions (for example multiple wave conditions) and mormerge
%   simulations. In case of multiple conditions and mormerge simulations,
%   it takes into account the individual contribution of each condition on
%   the basis of the weight of each condition.
%
%   Detran can be used as a interactive graphical environment or as a
%   command line toolbox. The graphical environment provides a
%   user-friendly interface, various plotting options and the possibilty to
%   export the results, for example to a muppet-file. For command line use,
%   see instructions below.
%
%   Syntax (to start the graphical environment):
%   detran;
%
%   Syntax for command line use:
%   t               = detran(simType, d3dOutput, <keyword,value>);
%   [t, tPos, tNeg] = detran(simType, d3dOutput, <keyword,value>);
%
%   Input:
%   SimType     Simulation type:
%               - 'single' for single transport computation.
%               - 'multi' for transport comuputation with multiple
%                 conditions (no mormerge!).
%               - 'mm' for a mormerge transport computation.
%
%   d3dOutput   Location of the Delft3D output file(s) (for mm or multi it
%               is sufficient to indicate one of the trim-/trih-files).
%
%   Keyword / value pairs (optional):
%   transects   [M x 4] array with start and end points of
%               transects [X1 Y1 X2 Y2]. Required for trim-input.
%   weightFile  File location with condition weight (tekal-file) for multi
%               simulation type.
%   transType   [1 x 2] cell array, with in the first cell 'bed',
%               'suspended' or 'total' and in the second cell 'instant' or
%               'mean'. NB: When 'mean' is selected, the mean transport as
%               calcated by Delft3D is used, which is by default only
%               stored for the last time step of the simulation. (default:
%               {'total','mean'}).
%   fraction    [1 x 1] double, specify with fraction to use, set to 0 for
%               the sum of fractions (default: 0).
%   timeStep    [1 x 1] double, specify the time step to use, set to 0 to
%               use the last available time step (default: 0).
%
%   Output:
%   t           cumulative nett transport through transects [m3/s]
%   tPos        cumulative positive part of gross transport through
%               transects [m3/s]
%   tNeg        cumulative negative part of gross transport through
%               transects [m3/s]
%
%
%   See also detran_TransArbCSEngine, detran_plotTransportThroughTransect, detran_engines

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 May 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: detran.m 10004 2014-01-14 10:12:49Z scheel $
% $Date: 2014-01-14 18:12:49 +0800 (Tue, 14 Jan 2014) $
% $Author: scheel $
% $Revision: 10004 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/detran/detran.m $
% $Keywords: $

% GUI MODE
if nargin==0 % start GUI
    if ~isdeployed
        if str2double(datestr(datenum(version('-date')),10))<2009
            msgbox('Please use at least Matlab version 2009b');
            return
        elseif str2double(datestr(datenum(version('-date')),10))>2011
            disp(['Using matlab version ' version ' - ' mexext]);
            disp(' ');
            disp(['Please note that some panels might not work ideally with Matlab versions later than 2011']);
            disp(['A workaround was build in for some panels though, this requires you to simply press F5 again when asked']);
        end
        
        basePath=strrep(which('detran.m'),'detran.m','');
        
        addpath(basePath);
        addpath([basePath 'detran_gui']);
        addpath([basePath 'detran_engines']);

        if ~exist('vs_use.m','file')
            wlsettings;
        end
        
        if ~exist('grid_orth_getDataOnLine.m','file')
            run('p:\mctools\openearthtools\matlab\oetsettings.m');
        end
    end
    % fig=openfig('detran.fig','reuse');
    fig=detran_initiateGUI;

    % COMMAND LINE MODE
elseif nargin < 2 % more input arguments required
    error('Not enough input arguments specified...');
    return
    
else % command line use of detran
    simType     = varargin{1};
    trimFile    = varargin{2};
    
    % check input
    if ~(strcmp(simType,'multi')|strcmp(simType,'mm')|strcmp(simType,'single'))
        error('Set simType to ''single'', ''multi'' or ''mm''...');
        return
    end
    
    if ~exist(trimFile,'file')
        error('Specified trim-file not found...');
        return
    end
    
    % set default values of optional keywords
    OPT.transects   = nan;
    OPT.weightFile  = [];
    OPT.transType   = {'total','mean'};
    OPT.fraction    = 0;
    OPT.timeStep    = 0;
    
    OPT = setproperty(OPT, varargin{3:end});
    
    [pat, nam]=fileparts(trimFile);
    
    switch nam(4)
        case 'm'
            input{1} = 'Trim-file(s)';
            % check is specified transects have correct dimensions
            if size(OPT.transects,2)~=4
                error(['Transects should be [M x 4] array, but it is ' num2str(size(OPT.transects,1)) ' x ' num2str(size(OPT.transects,2)) '...']);
                return
            end
            
        case 'h'
            input{1} = 'Trih-file(s)';
    end
    
    switch simType
        case 'single'
            input{2} = 'Single file';
        case 'multi'
            input{2} = 'Multiple files';
        case 'mm'
            input{2} = 'Mormerge simulation';
    end
    
    input2 = detran_importData (trimFile,OPT.weightFile,input{1},input{2},OPT.transType{2},OPT.timeStep);
    if strcmp(input{1},'Trim-file(s)')
        input2.transects = OPT.transects;
    end
    [t, tPos, tNeg] = detran_prepareTransPlot(input2,OPT.transType{1},OPT.fraction);
    varargout={t, tPos, tNeg};
end