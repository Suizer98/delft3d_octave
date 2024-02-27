function LTSE_selectSegment
%LTSE_SELECTSEGMENT ldbTool GUI function to select a ldb segment
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

if get(but,'value')==1; % if the button 'Select segment(s)' is toggled on
    data=LT_getData;
    ldbCell=data(5).ldbCell;
    ldbEnd=data(5).ldbEnd;
    ldbBegin=data(5).ldbBegin;

    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click near start or end point of segment to show, right click stop selecting');

    idSel=[];
    hCp=[];
    b=1;

    while b==1 % keep doing this as long as left mouse button is clicked
%         set(findobj(fig,'type','uicontrol'),'Enable','inactive');
        
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
                    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
                    set(fig,'Pointer','arrow');
                    b = 3;
                end
            else
                set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
                set(fig,'Pointer','arrow');
                b = 3;
            end
        end
        if ~isempty(action)
            b      = action.Button;
            xClick = action.IntersectionPoint(1);
            yClick = action.IntersectionPoint(2);
        end
        set(findobj(fig,'type','uicontrol'),'Enable','on');
        
        if b~=3; % if the left/middle mouse button is clicked, select (or deselect) a segment and plot it blue and thick!
            disStart=sqrt((xClick(1)-ldbBegin(:,1)).^2+(yClick(1)-ldbBegin(:,2)).^2);
            disEnd=sqrt((xClick(1)-ldbEnd(:,1)).^2+(yClick(1)-ldbEnd(:,2)).^2);

            if min(disStart)<min(disEnd);
                [dum, id]=min(disStart);
            else
                [dum, id]=min(disEnd);
            end
            if ~ismember(id,idSel) % check if segments is already selected, if not:
                idSel=[idSel;id];
                axes(findobj(fig,'tag','LT_plotWindow'));
                hold on;
                hCp(end+1)=plot(ldbCell{id}(:,1),ldbCell{id}(:,2),'color','b','linewidth',2);
                set(hCp(end),'ZData',repmat(3,size(get(hCp(end),'XData'))));
            else % if it is already selected, remove it from selection:
                delete(hCp(find(idSel==id)));
                hCp(find(idSel==id))=[];
                idSel(find(idSel==id))=[];
            end

        else % if the right mouse button is clicked, enable segment edit button and put id's and plot handles in button user data
            set(fig,'Pointer','arrow');
            if isempty(hCp)
                set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
                set(but,'value',0,'enable','on');
                set(findobj(fig,'tag','LTSE_segmentEditButton'),'Enable','off');
            else
                set(findobj(fig,'tag','LTSE_segmentEditButton'),'Enable','on');
                idSel=unique(idSel);
                set(but,'userdata',{idSel,hCp});
                set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: perform action on selected segments, or click ''Select segments(s)'' button again to deselect');
            end
        end
    end
else %if the button 'Select segment(s)' is turned off, undo selection and remove plot handles
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
    LT_removeSelection
    set(findobj(fig,'tag','LTSE_segmentEditButton'),'Enable','off');
end
