function outLDB=closeLdbSegments(ldb)
%CLOSELDBSEGMENTS Close all segments of a landboundary
%
% CLOSELDBSEGMENTS copies for every segment of a landboundary the first
% point to the last point of the segment, so that it will be closed (i.e.
% the last point of the segement will be identical to the first point).
%
% Syntax:
% outLDB=ipGlueLDB(ldb)
%
% ldb:      the landboury, which should already be specified by the function 
%           ldb=landboundary('read','landboundary')
% outLDB:   output landboundary [Mx2]
%
% See also: LDBTOOL, ULTRAGLUELDB, IPGLUELDB

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
outLDB=[];

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

% ----- core
for ii=1:length(ldbCell)
    if ldbCell{ii}(1,1)~=ldbCell{ii}(end,1)|ldbCell{ii}(1,2)~=ldbCell{ii}(end,2)
        ldbCell{ii}(end+1,:)=ldbCell{ii}(1,:);
        ldbEnd(ii,:)=ldbCell{ii}(1,:);
    end
end
% ----- end core

if ~isstruct(ldb)
    outLDB=rebuildLdb(ldbCell);
else
    outLDB.ldbCell=ldbCell;
    outLDB.ldbBegin=ldbBegin;
    outLDB.ldbEnd=ldbEnd;
end