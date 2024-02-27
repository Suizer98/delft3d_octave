function LT_ldb2image(direction)
%LT_LDB2IMAGE ldbTool GUI function to transform from ldb coordinates to
%image coordinates
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

% read worldfile
r=readWorldFile;
T=[r(2,1) r(2,2) 0; r(1,1) r(1,2) 0; r(3,:) 1];

% read ldb data
data=LT_getData;
ldb=data(5).ldb;

% perform conversion
XY0=[ldb(:,1) ldb(:,2) ones(numel(ldb(:,1)),1)];
switch direction
    case '2image'
        UV0=XY0*pinv(T);
    case '2ldb'
        UV0=XY0/pinv(T);
end

% put data back
[ldbCell, ldbBegin, ldbEnd, ldb]=disassembleLdb([UV0(:,1:2)]);
LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);