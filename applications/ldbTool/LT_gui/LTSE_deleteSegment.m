function LTSE_deleteSegment(id)
%LTSE_DELETESEGMENT ldbTool GUI function to delete a ldb segment
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

if isempty(id)
    return
end

data=LT_getData;
ldbCell=data(5).ldbCell;
ldbEnd=data(5).ldbEnd;
ldbBegin=data(5).ldbBegin;
ldb=data(5).ldb;
nanId=find(isnan(ldb(:,1)));

if length(ldbCell)==1
    errordlg('Cannot delete last segment!','LdbTool');
    return
end

ldbCell(id)=[];
ldbBegin(id,:)=[];
ldbEnd(id,:)=[];

for ii=1:length(id)
    ldb(nanId(id(ii)):nanId(id(ii)+1)-1,:)=nan;  % first put nan values in, otherwise the length of the array changes
end

% remove successive nans
did=find(isnan(ldb(:,1)));
if ~isempty(did)
    rid=abs(did(1:end-1)-did(2:end));
    remid=find(rid==1);
    ldb(did(remid),:)=[];
end
LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);
