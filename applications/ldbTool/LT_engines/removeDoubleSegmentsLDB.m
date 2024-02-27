function ldb=removeDoubleSegmentsLDB(ldb)
%REMOVEDOUBLESEGMENTSLDB Remove indentical segments in a landboundary
%
% This tool looks for identical segments in a landboundary and delete one
% of them.
%
% Syntax:
% ldbOut = removeDoubleSegmentsLDB(ldbIn)
%
% ldbIn:    the landboury, which should already be specified by the 
%           function ldb=landboundary('read','landboundary')
% ldbOut:   the output landboury
%
% See also: LDBTOOL, UNIQUE

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
if ~isstruct(ldb)
    
    [ldbCell, ldbBegin, ldbEnd]=disassembleLdb(ldb);
    
else
    ldbCell=ldb.ldbCell;
    ldbBegin=ldb.ldbBegin;
    ldbEnd=ldb.ldbEnd;
    
end


hW=waitbar(0,'Removing duplicate ldb segments...');
for ii=1:length(ldbCell)
    ldbCellSum(ii)=sum(sum(ldbCell{ii}));
    waitbar(ii/length(ldbCell),hW);        
end
[dum, uniID]=unique(ldbCellSum);
ldbCell=ldbCell(uniID);
ldbBegin=ldbBegin(uniID,:);
ldbEnd=ldbEnd(uniID,:);
close(hW);


if ~isstruct(ldb)
    
    ldb=rebuildLdb(ldbCell);
    
else
    ldb.ldbCell=ldbCell;
    ldb.ldbBegin=ldbBegin;
    ldb.ldbEnd=ldbEnd;
    
end