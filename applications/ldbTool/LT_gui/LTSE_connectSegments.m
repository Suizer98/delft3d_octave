function LTSE_connectSegments
%LTSE_CONNECTSEGMENTS ldbTool GUI function to connect two ldb segments
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

b=1;
while b==1
    data=LT_getData;
    ldbCell=data(5).ldbCell;
    ldbEnd=data(5).ldbEnd;
    ldbBegin=data(5).ldbBegin;
    
    ldb=data(5).ldb;
    nanId=find(isnan(ldb(:,1)));
    
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: click start or end point of 2 segments to connect, right click to cancel');
    
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
                delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
                set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
                set(fig,'Pointer','arrow');
                return
            end
        else
            delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
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
        delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        set(fig,'Pointer','arrow');
        return
    end
    
    disStart1=sqrt((xClick-ldbBegin(:,1)).^2+(yClick-ldbBegin(:,2)).^2);
    disEnd1=sqrt((xClick-ldbEnd(:,1)).^2+(yClick-ldbEnd(:,2)).^2);
    
    if min(disStart1)<min(disEnd1);
        [dum, id1]=min(disStart1);
        axes(findobj(fig,'tag','LT_plotWindow'));
        hold on;
        hCp1=plot(ldbBegin(id1,1),ldbBegin(id1,2),'marker','o','markeredgecolor','b','markersize',12);
        connect='s';
    else
        [dum, id1]=min(disEnd1);
        axes(findobj(fig,'tag','LT_plotWindow'));
        hold on;
        hCp1=plot(ldbEnd(id1,1),ldbEnd(id1,2),'marker','o','markeredgecolor','b','markersize',12);
        connect='e';
    end
    
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
                delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
                set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
                set(fig,'Pointer','arrow');
                return
            end
        else
            delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
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
        delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        set(fig,'Pointer','arrow');
        return
    end
    
    disStart2=sqrt((xClick-ldbBegin(:,1)).^2+(yClick-ldbBegin(:,2)).^2);
    disEnd2=sqrt((xClick-ldbEnd(:,1)).^2+(yClick-ldbEnd(:,2)).^2);
    
    if min(disStart2)<min(disEnd2);
        [dum, id2]=min(disStart2);
        axes(findobj(fig,'tag','LT_plotWindow'));
        hold on;
        hCp2=plot(ldbBegin(id2,1),ldbBegin(id2,2),'marker','o','markeredgecolor','b','markersize',12);
        connect=[connect 's'];
    else
        [dum, id2]=min(disEnd2);
        axes(findobj(fig,'tag','LT_plotWindow'));
        hold on;
        hCp2=plot(ldbEnd(id2,1),ldbEnd(id2,2),'marker','o','markeredgecolor','b','markersize',12);
        connect=[connect 'e'];
    end
    
    set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: left click to confirm, right click to cancel');
    
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
                delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
                set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
                set(fig,'Pointer','arrow');
                return
            end
        else
            delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
            set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
            set(fig,'Pointer','arrow');
            return
        end
    end
    if ~isempty(action)
        b2 = action.Button;
    end
    
    delete(hCp1); delete(hCp2);delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
    
    if b2==3
        delete(findobj(fig,'markeredgecolor',[0 0 1],'Marker','o'));
        set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');
        set(fig,'Pointer','arrow');
        return
    end
    
    if id1==id2;
        % in this case, the start and end point of the same segment are selected, just close the segment
        ldbCell{id1}=[ldbCell{id1}; ldbCell{id1}(1,:)];
        ldbEnd(id1,:)=ldbCell{id1}(end,:);
        ldb=rebuildLdb(ldbCell);
    else
        switch connect
            case 'ss'
                ldbCell{id1}=[flipud(ldbCell{id1}); ldbCell{id2}];
                ldbBegin(id1,:)=[ldbEnd(id1,:)];
                ldbEnd(id1,:)=[ldbEnd(id2,:)];
                ldbCell{id2}=[];
                ldbBegin(id2,:)=[];
                ldbEnd(id2,:)=[];
                ldb(nanId(id2):nanId(id2+1)-1,:)=[-9999.9999];
                ldb=[ldb(1:nanId(id1),:) ; ldbCell{id1} ; ldb(nanId(id1+1):end,:)];
                ldb(find(ldb(:,1)==-9999.9999),:)=[];
                ldbEmpt = cellfun('isempty',ldbCell);
                ldbCell=ldbCell(ldbEmpt==0);
            case 'se'
                ldbCell{id1}=[ldbCell{id2}; ldbCell{id1}];
                ldbBegin(id1,:)=[ldbBegin(id2,:)];
                ldbCell{id2}=[];
                ldbBegin(id2,:)=[];
                ldbEnd(id2,:)=[];
                ldb(nanId(id2):nanId(id2+1)-1,:)=[-9999.9999];
                ldb=[ldb(1:nanId(id1),:) ; ldbCell{id1} ; ldb(nanId(id1+1):end,:)];
                ldb(find(ldb(:,1)==-9999.9999),:)=[];
                ldbEmpt = cellfun('isempty',ldbCell);
                ldbCell=ldbCell(ldbEmpt==0);
            case 'es'
                ldbCell{id1}=[ldbCell{id1}; ldbCell{id2}];
                ldbEnd(id1,:)=[ldbEnd(id2,:)];
                ldbCell{id2}=[];
                ldbBegin(id2,:)=[];
                ldbEnd(id2,:)=[];
                ldb(nanId(id2):nanId(id2+1)-1,:)=[-9999.9999];
                ldb=[ldb(1:nanId(id1),:) ; ldbCell{id1} ; ldb(nanId(id1+1):end,:)];
                ldb(find(ldb(:,1)==-9999.9999),:)=[];
                ldbEmpt = cellfun('isempty',ldbCell);
                ldbCell=ldbCell(ldbEmpt==0);
            case 'ee'
                ldbCell{id1}=[ldbCell{id1};flipud(ldbCell{id2})];
                ldbEnd(id1,:)=[ldbBegin(id2,:)];
                ldbCell{id2}=[];
                ldbBegin(id2,:)=[];
                ldbEnd(id2,:)=[];
                ldb(nanId(id2):nanId(id2+1)-1,:)=[-9999.9999];
                ldb=[ldb(1:nanId(id1),:) ; ldbCell{id1} ; ldb(nanId(id1+1):end,:)];
                ldb(find(ldb(:,1)==-9999.9999),:)=[];
                ldbEmpt = cellfun('isempty',ldbCell);
                ldbCell=ldbCell(ldbEmpt==0);
        end
    end
    LT_updateData(ldb,ldbCell,ldbBegin,ldbEnd);
end
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions:');

end