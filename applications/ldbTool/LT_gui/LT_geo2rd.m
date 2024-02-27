function LT_geo2rd
%LT_GEO2RD ldbTool GUI function to perform coordinate transformation from
%geo to rd
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
if isempty(which('geo2rd'))
    warndlg('For this option, routines from mctools (Deltares'' internal repository) are required. Use the epsg-transformation method instead')
    return;
end

[but,fig]=gcbo; 

data=LT_getData;
ldb=data(5).ldb;

ldbOut=geo2rd([ldb(:,1) ldb(:,2)]);
[ldbCell, ldbBegin, ldbEnd, ldb]=disassembleLdb(ldbOut);
LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);