function LTPE_cutPoint(fig)
%LTPE_CUTPOINT ldbTool GUI function to cut a ldb at the specified point,
%splitting the segment into two segments
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

curAx=findobj(fig,'tag','LT_plotWindow');

set(findobj(fig,'tag','LT_zoomBut'),'String','Zoom is off','value',0);
zoom off
set(gcf,'pointer','arrow');

data=LT_getData;
ldb=data(5).ldb;
nanId=find(isnan(ldb(:,1)));
ldbCell=data(5).ldbCell;
ldbEnd=data(5).ldbEnd;
ldbBegin=data(5).ldbBegin;

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: left click existing ldb-point to make cut, right click to cancel');

set(fig,'Pointer','crosshair');
waitforbuttonpress;
action = guidata(curAx); guidata(curAx,[]);
if isempty(action)
    if ~isempty(get(fig,'ResizeFcn'));
        % This only exists in the old version, lets continue:
        if strcmp(get(fig,'SelectionType'),'normal')
            pt = get(curAx,'CurrentPoint');
            action.Button = 1;
            action.IntersectionPoint(1) = pt(1,1);
            action.IntersectionPoint(2) = pt(1,2);
        else
            set(fig,'Pointer','arrow');
            set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
            return
        end
    else
        set(fig,'Pointer','arrow');
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        return
    end
end
if ~isempty(action)
    b      = action.Button;
    xClick = action.IntersectionPoint(1);
    yClick = action.IntersectionPoint(2);
    new_pt_length = (size(ldb,1)-1) - max(find(isnan(ldb(1:end-1,1))));
end

if b==3
    set(fig,'Pointer','arrow');
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
    return
end
dist=sqrt((ldb(:,1)-xClick).^2+(ldb(:,2)-yClick).^2);
[sortDist, sortId]=sort(dist);
whileLoop=0;
iid=1;

while whileLoop==0
    id=sortId(iid);
    tempId=find(nanId>id);
    tempId=tempId(1);
    if isempty(find(abs(nanId-id)==1)) %check of het geen eind of begin punten van segmenten zijn
        
        if find(sortId == id-1) < find(sortId == id+1)
            ldbCell{tempId-1}=ldb(nanId(tempId-1)+1:id-1,1:2);
            ldbBegin(tempId-1,:)=ldbCell{tempId-1}(1,:);
            ldbEnd(tempId-1,:)=ldbCell{tempId-1}(end,:);
            ldbCell{end+1}=ldb(id:nanId(tempId)-1,:);
            ldbBegin(end+1,:)=ldbCell{end}(1,:);
            ldbEnd(end+1,:)=ldbCell{end}(end,:);
            ldb=[ldb(1:id-1,1:2) ; ldb(nanId(tempId):end,1:2); ldb(id:nanId(tempId)-1,1:2) ; nan nan];    
            whileLoop=1;
        else
            ldbCell{tempId-1}=ldb(nanId(tempId-1)+1:id,1:2);
            ldbBegin(tempId-1,:)=ldbCell{tempId-1}(1,:);
            ldbEnd(tempId-1,:)=ldbCell{tempId-1}(end,:);
            ldbCell{end+1}=ldb(id+1:nanId(tempId)-1,:);
            ldbBegin(end+1,:)=ldbCell{end}(1,:);
            ldbEnd(end+1,:)=ldbCell{end}(end,:);
            ldb=[ldb(1:id,1:2) ; ldb(nanId(tempId):end,1:2); ldb(id+1:nanId(tempId)-1,1:2) ; nan nan];    
            whileLoop=1;
        end
    elseif sortDist(iid)==sortDist(iid+1); %anders kijken of er een identiek punt onder ligt en het daarmee proberen
        iid=iid+1;
    else
        whileLoop=1;
        set(fig,'Pointer','arrow');
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        warndlg('You cannot cut a start or end point of a segment','ldbTool');
        return
    end
end

set(fig,'Pointer','arrow');

LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');