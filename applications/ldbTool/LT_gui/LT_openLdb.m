function LT_openLdb
%LT_OPENLDB ldbTool GUI function to load a ldb from .ldb-file
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

oriLDB = landboundary('read');

if isempty(oriLDB)
    return
end

% data=LT_fillStructure(oriLDB,1);
data=LT_fillStructure(oriLDB,0);

LT_setData(data);

LT_initialGuiSettings;

LT_plotLdb;

axes(findobj(fig,'tag','LT_plotWindow'));
set(gca,'DataAspectRatioMode','manual','DataAspectRatio',[1 1 1]);

axis fill;
LT_showAll;
