function [ldbCell, ldbBegin, ldbEnd, ldbIn]=ITHK_disassembleLdb(ldbIn)
%ITHK_DISASSEMBLELDB Disassemble a landboundary into its segments
%
% ITHK_DISASSEMBLELDB returns the segments of a landboundary and the start and
% end points of each segment. A segment is a section in a landboundary file
% between '999.999 999.999' lines.
%
% Syntax:
% [ldbCell, ldbBegin, ldbEnd, ldbIn]=ITHK_disassembleLdb(ldbIn)
%
% ldb:      the landboury, which should already be specified by the function 
%           ldb=landboundary('read','landboundary'), [Mx2] array
% ldbCell:  Cell array with ldb segments
% ldbBegin: Array with first points of each segment
% ldbEnd:   Array with last points of each segment
%
% See also: LDBTOOL, REBUILDLDB

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
%Be sure to use 2 columns only
ldbIn=ldbIn(:,1:2);

%nannen aan begin en eind toevoegen
if ~isnan(ldbIn(1,1))
    ldbIn=[nan nan;ldbIn];
end
if ~isnan(ldbIn(end,1))
    ldbIn=[ldbIn;nan nan];
end

%opeenvolgende nannen weghalen
did=find(isnan(ldbIn(:,1)));
if ~isempty(did)
    rid=abs(did(1:end-1)-did(2:end));
    remid=find(rid==1);
    ldbIn(did(remid),:)=[];
end

%opeenvolgende indentieke punten weghalen
id1=find(diff(ldbIn(:,1))==0);
id2=find(diff(ldbIn(:,2))==0);
idBoth=intersect(id1,id2);
ldbIn(idBoth,:)=[];

id=find(isnan(ldbIn(:,1)));
tLdb=ldbIn;
tLdb(id,:)=[];
id2=id-[0:length(id)-1]';
ldbCell=mat2cell(tLdb,diff(id2),2);
ldbBegin=tLdb(id2(1:end-1),:);
ldbEnd=tLdb(id2(2:end)-1,:);

