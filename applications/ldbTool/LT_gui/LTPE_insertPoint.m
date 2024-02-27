function LTPE_insertPoint(fig)
%LTPE_INSERTPOINT ldbTool GUI function to insert a new point in the ldb
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

set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click existing ldb-point');

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
            insertPoints=0;
            set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
            set(fig,'Pointer','arrow');
            return
        end
    else
        insertPoints=0;
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        set(fig,'Pointer','arrow');
        return
    end
end
if ~isempty(action)
    b      = action.Button;
    xClick = action.IntersectionPoint(1);
    yClick = action.IntersectionPoint(2);
end
if b==3
    insertPoints=0;
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
    set(fig,'Pointer','arrow');
    return
end

dist=sqrt((ldb(:,1)-xClick).^2+(ldb(:,2)-yClick).^2);
[sortDist, sortId]=sort(dist);
id = sortId(1);

if ~isnan(dist(id-1)) && ~isnan(dist(id+1))
    if find(sortId == id-1) < find(sortId == id+1)
        id = id - 1;
    end
end

clear xClick
clear yClick
insertPoints=1;
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click location of new points, right click when done');

while insertPoints==1
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
                insertPoints=0;
                set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
                set(fig,'Pointer','arrow');
                return
            end
        else
            insertPoints=0;
            set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
            set(fig,'Pointer','arrow');
            return
        end
    end
    if ~isempty(action)
        b      = action.Button;
        xClick = action.IntersectionPoint(1);
        yClick = action.IntersectionPoint(2);
    end
    if b==3
        insertPoints=0;
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        set(fig,'Pointer','arrow');
        return
    end

    if b~=3
        if id<size(ldb,1)
            tempId=find(nanId>id);
            tempId=tempId(1);
            ldb=[ldb(1:id,1:2) ; xClick yClick ; ldb(id+1:end,1:2)];
            nanId=find(isnan(ldb(:,1)));
            ldbCell{tempId-1}=ldb(nanId(tempId-1)+1:nanId(tempId)-1,:);
            ldbBegin(tempId-1,:)=ldbCell{tempId-1}(1,:);
            ldbEnd(tempId-1,:)=ldbCell{tempId-1}(end,:);
            id=id+1;
        end
        LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);
    end

end

insertPoints=0;
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
set(fig,'Pointer','arrow');