function LTPE_replaceMotion(fig,id)
%LTPE_REPLACEMOTION ldbTool GUI function to perform replace motion while
%moving a ldb point
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
persistent count
if isempty(count)
    count=0;
end

count=count+1;
if count>5
    count=0;

    cPos=get(findobj(fig,'tag','LT_plotWindow'),'currentPoint');

    data=LT_getData;
    ldb=data(5).ldb;
    ldbCell=data(5).ldbCell;
    ldbBegin=data(5).ldbBegin;
    ldbEnd=data(5).ldbEnd;
    nanId=find(isnan(ldb(:,1)));

    ldb(id,:)=[cPos(1,1) cPos(1,2)];
    tempId=find(nanId>id);
    tempId=tempId(1);
    ldbCell{tempId-1}=ldb(nanId(tempId-1)+1:nanId(tempId)-1,:);
    ldbBegin(tempId-1,:)=ldbCell{tempId-1}(1,:);
    ldbEnd(tempId-1,:)=ldbCell{tempId-1}(end,:);

    LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd,'noUndo');
    drawnow;

else
    return
end