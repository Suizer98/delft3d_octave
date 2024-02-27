function LT_saveLdb(ext,layer)
%LT_SAVELDB ldbTool GUI function to save the ldb to file
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

if nargin==1
    layer=get(findobj(fig,'tag','LT_layerSelectMenu'),'value');
end

data=LT_getData(layer);
ldb=data(1,5).ldb;

% remove nan's at the firs and last line
if isnan(ldb(1,1))
    ldb(1,:)=[];
end
if isnan(ldb(end,1))
    ldb(end,:)=[];
end

switch ext
    case 'ldb'
        [filN, patN] = uiputfile('*.ldb','Save landboundary');
    case 'pol'
        [filN, patN] = uiputfile('*.pol','Save polygon');
end
if filN==0
    return
end
fullName=[patN filN];
switch ext
    case 'ldb'
        landboundary('write',fullName,ldb);
    case 'pol'
        landboundary('write',fullName,ldb,'dosplit');
end