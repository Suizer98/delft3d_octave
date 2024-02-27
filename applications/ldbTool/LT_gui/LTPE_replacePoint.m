function LTPE_replacePoint(fig)
%LTPE_REPLACEPOINT ldbTool GUI function to move a ldb point
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

replacePoints=1;

while replacePoints==1
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click existing ldb-point, right click to cancel');
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
                replacePoints=0;
                set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
                set(fig,'Pointer','arrow');
                return
            end
        else
            replacePoints=0;
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
        replacePoints=0;
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        set(fig,'Pointer','arrow');
        return
    end
    dist=sqrt((ldb(:,1)-xClick).^2+(ldb(:,2)-yClick).^2);
    [dum, id]=min(dist);

    clear xClick
    clear yClick
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click new location, right click to cancel');

    %Move line while moving mouse
    %     curMotionFcn=get(fig,'WindowButtonMotionFcn');
    curMotionFcn='LT_winMoveFcn(gcbf);';
    set(fig,'WindowButtonMotionFcn',[curMotionFcn 'LTPE_replaceMotion(gcbf,' num2str(id) ');']);
    LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd); % beginnen met een update, zodat undo-mogelijkheid behouden blijft
    waitforbuttonpress;
    %Switch of motion
    set(fig,'WindowButtonMotionFcn',curMotionFcn);

    action = guidata(curAx); guidata(curAx,[]);
    if isempty(action)
        if ~isempty(get(fig,'ResizeFcn'));
            % This only exists in the old version, lets continue:
            if strcmp(get(fig,'SelectionType'),'normal')
                pt = get(curAx,'CurrentPoint');
                action.Button = 1;
                action.IntersectionPoint(1) = pt(1,1);
                action.IntersectionPoint(2) = pt(1,2);
            elseif strcmp(get(fig,'SelectionType'),'alt')
                b      = 3;
                xClick = NaN;
                yClick = NaN;
            end
        else
            replacePoints=0;
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

    if b~=3
        ldb(id,:)=[xClick yClick];
        tempId=find(nanId>id);
        tempId=tempId(1);
        ldbCell{tempId-1}=ldb(nanId(tempId-1)+1:nanId(tempId)-1,:);
        ldbBegin(tempId-1,:)=ldbCell{tempId-1}(1,:);
        ldbEnd(tempId-1,:)=ldbCell{tempId-1}(end,:);
        LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd,'noUndo');
        nanId=find(isnan(ldb(:,1)));
    else
        LT_undoLdb;
    end
end

replacePoints=0;
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
set(fig,'Pointer','arrow');