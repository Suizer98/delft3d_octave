function LT_addLdb
%LT_ADDLDB ldbTool GUI function to add another ldb to the current ldb
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

[namLdb, patLdb]=uigetfile('*.ldb','Select landboundary to add');

data=LT_getData;
ldb=data(5).ldb;

addLdb=landboundary('read',[patLdb, namLdb]);

if size(addLdb,2)>2
    addLdb = addLdb(:,1:2);
end

ldb=[ldb; addLdb];

[ldbCell, ldbBegin, ldbEnd, ldb]=disassembleLdb(ldb);

LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);