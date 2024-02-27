function outLDB=removeSinglePointsLDB(ldb)
%REMOVESINGLEPOINTSLDB Remove single points segments from a landboundary
%
% REMOVESINGLEPOINTSLDB looks for segments in a landboundary which exist of
% only 1 point and deletes these segments
%
% Syntax:
% ldbOut=removeSinglePointsLDB(ldbIn)
%
% ldbIn:    the landboury, which should already be specified by the 
%           function ldb=landboundary('read','landboundary')
% ldbOut:   the output landboury
%
% See also: LDBTOOL, REMOVEDOUBLESEGMENTSLDB

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
if nargin==0
    if isempty(which('landboundary.m'))
        wlsettings;
    end
    ldb=landboundary('read');
end

if isempty(ldb)
    return
end

if ~isstruct(ldb)
     [ldbCell, ldbBegin, ldbEnd]=disassembleLdb(ldb);
else
    ldbCell=ldb.ldbCell;
    ldbBegin=ldb.ldbBegin;
    ldbEnd=ldb.ldbEnd;
end
 

idEmpt=find(cellfun('size',ldbCell,1)==1);
if ~isempty(idEmpt)
    ldbCell(idEmpt)=[];
    ldbBegin(idEmpt,:)=[];
    ldbEnd(idEmpt,:)=[];
    ldbEmpt = cellfun('isempty',ldbCell);
    ldbCell=ldbCell(ldbEmpt==0);
end

if ~isstruct(ldb)
    outLDB=rebuildLdb(ldbCell);
else
    outLDB.ldbCell=ldbCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end