function ldb=rebuildLdb(ldbCell)
%REBUILDLDB Rebuild a landboundary from segments
%
% REBUILDLDB returns a landboundary on the basis of ldb segments. A segment 
% is a section in a landboundary file between '999.999 999.999' lines.
%
% Syntax:
% ldb=rebuildLdb(ldbCell)
%
% ldbCell:  Cell array with ldb segments
% ldb:      the landboury, which should already be specified by the function 
%           ldb=landboundary('read','landboundary'), [Mx2] array
%
% See also: LDBTOOL, DISASSEMBLELDB

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
ldbCell=ldbCell(:); %Ensure correct direction
lengthCell=cellfun('size',ldbCell,1);
ldb=repmat([nan nan],[1+sum(lengthCell+1),1]);
nanId=[1; 1+cumsum(lengthCell)+[1:length(lengthCell)]'];
allId=[1:length(ldb)];
ldb(setdiff(allId,nanId),:)=cell2mat(ldbCell);