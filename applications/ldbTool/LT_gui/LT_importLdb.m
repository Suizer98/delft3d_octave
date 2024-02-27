function LT_importLdb(ext)
%LT_IMPORTLDB ldbTool GUI function to import a ldb from other file formats
%
% See also: LDBTOOL

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

%% Code
[but,fig]=gcbo;

switch ext
   case 'shp'
    oriLDB =shape2ldb([],0);
    if iscell(oriLDB)
        for ii=1:length(oriLDB)-1
            oriLDB{ii} = [oriLDB{ii}; NaN NaN];
        end
        oriLDB = cell2mat(oriLDB);
    end
   case 'dxf'
    [dxfNam, dxfPat]=uigetfile('*.dxf','Select dxf-file');
    if dxfNam == 0
        return
    end
    options.txt=0;
    options.delSmall=1;
    options.delSinglePoint=0;
    options.numOfCols=2;
    oriLDB = dxf2tek_engine([dxfPat dxfNam],options);
    oriLDB(find(oriLDB(:,1)==999.999),:)=nan;
   case 'kml'
    oriLDB=kml2ldb(0);
end


if isempty(oriLDB)
    return
end

data=LT_fillStructure(oriLDB,0);

LT_setData(data);

LT_initialGuiSettings;

LT_plotLdb;

axes(findobj(fig,'tag','LT_plotWindow'));
set(gca,'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1]);
axis fill;