function ddb_zoomInOutPan(src, eventdata, zoommode, callback1, varargin1, callback2, varargin2)
%DDB_ZOOMINOUTPAN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_zoomInOutPan(src, eventdata, zoommode, callback1, varargin1, callback2, varargin2)
%
%   Input:
%   src       =
%   eventdata =
%   zoommode  =
%   callback1 =
%   varargin1 =
%   callback2 =
%   varargin2 =
%
%
%
%
%   Example
%   ddb_zoomInOutPan
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% Update Data, Figure handle

handles=getHandles;

h1=handles.GUIHandles.toolBar.zoomIn;
h2=handles.GUIHandles.toolBar.zoomOut;
h3=handles.GUIHandles.toolBar.pan;

if zoommode==1 || zoommode==2
    set(h3,'State','off');
end
if zoommode==1 || zoommode==3
    set(h2,'State','off');
end
if zoommode==2 || zoommode==3
    set(h1,'State','off');
end

pan off;

switch(zoommode),
    case 1
        if strcmp(get(h1,'State'),'on')
            %            if ~isempty(callback1)
            set(gcf, 'windowbuttonmotionfcn', {@MoveMouse, callback1, varargin1});
            %            end
        else
            ddb_setWindowButtonUpDownFcn;
            ddb_setWindowButtonMotionFcn;
        end
    case 2
        if strcmp(get(h2,'State'),'on')
            %            if ~isempty(callback1)
            set(gcf, 'windowbuttonmotionfcn', {@MoveMouse, callback1, varargin1});
            %            end
        else
            ddb_setWindowButtonUpDownFcn;
            ddb_setWindowButtonMotionFcn;
        end
    case 3
        if strcmp(get(h3,'State'),'on')
            %            if ~isempty(callback1)
            set(gcf, 'windowbuttonmotionfcn', {@MoveMouse, callback1, varargin1});
            %            end
        else
            ddb_setWindowButtonUpDownFcn;
            ddb_setWindowButtonMotionFcn;
        end
    case 4
        [xl,yl]=CompXYLim(handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange,handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange);
        set(handles.GUIHandles.mapAxis,'xlim',xl);
        set(handles.GUIHandles.mapAxis,'ylim',yl);
        handles.screenParameters.xLim=xl;
        handles.screenParameters.yLim=yl;
        setHandles(handles);
        if ~isempty(varargin2)
            feval(callback2, varargin2);
        else
            feval(callback2);
        end
    case 5
        if ~isempty(varargin2)
            feval(callback2, varargin2);
        else
            feval(callback2);
        end
end

%%
function ZoomInOut(imagefig, varargins, callback, varargin)

handles=getHandles;

ax=handles.GUIHandles.mapAxis;
xl=get(ax,'xlim');
yl=get(ax,'ylim');

point1 = get(ax,'CurrentPoint');
point1=point1(1,1:2);

% Check if mouse is in current axis

if point1(1)>=xl(1) && point1(1)<=xl(2) && point1(2)>=yl(1) && point1(2)<=yl(2)
    
    leftmouse=strcmp(get(gcf,'SelectionType'),'normal');
    rightmouse=strcmp(get(gcf,'SelectionType'),'alt');
    
    hzoomin=handles.GUIHandles.toolBar.zoomIn;
    
    if strcmp(get(hzoomin,'State'),'on')
        zmin=1;
    else
        zmin=0;
    end
    
    if (leftmouse==1 && zmin==1) || (rightmouse==1 && zmin==0)
        % Zoom In
        point1 = get(ax,'CurrentPoint');
        rect = rbbox;
        point2 = get(ax,'CurrentPoint');
        if rect(3)==0
            % Click zoom in
            point1=point1(1,1:2);
            p1(1)=point1(1)-((xl(2)-xl(1))/4);
            p1(2)=point1(2)-((yl(2)-yl(1))/4);
            offset(1)=((xl(2)-xl(1))/2);
            offset(2)=((yl(2)-yl(1))/2);
        else
            % Zoom box
            point1 = point1(1,1:2);
            point2 = point2(1,1:2);
            p1 = min(point1,point2);
            offset = abs(point1-point2);
        end
        if ischar(callback)
            xl(1)=p1(1);
            yl(1)=p1(2);
            xl(2)=p1(1)+offset(1);
            yl(2)=p1(2)+offset(2);
        else
            [xl,yl]=CompXYLim([p1(1) p1(1)+offset(1) ],[p1(2) p1(2)+offset(2)],handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange);
        end
    elseif (leftmouse==1 && zmin==0) || (rightmouse==1 && zmin==1)
        % Zoom Out
        point1 = get(handles.GUIHandles.mapAxis,'CurrentPoint');
        xl=get(handles.GUIHandles.mapAxis,'xlim');
        yl=get(handles.GUIHandles.mapAxis,'ylim');
        point1=point1(1,1:2);
        p1(1)=point1(1)-((xl(2)-xl(1)));
        p1(2)=point1(2)-((yl(2)-yl(1)));
        offset(1)=2*((xl(2)-xl(1)));
        offset(2)=2*((yl(2)-yl(1)));
        if ischar(callback)
            xl(1)=p1(1);
            yl(1)=p1(2);
            xl(2)=p1(1)+offset(1);
            yl(2)=p1(2)+offset(2);
        else
            [xl,yl]=CompXYLim([p1(1) p1(1)+offset(1) ],[p1(2) p1(2)+offset(2)],handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange);
        end
    end
    set(handles.GUIHandles.mapAxis,'xlim',xl,'ylim',yl);
    drawnow;
    handles.screenParameters.xLim=xl;
    handles.screenParameters.yLim=yl;
    
    setHandles(handles);
    
    varargin = varargin{:};
    
    h=findobj(gcf,'Tag','UIAutomaticallyRefreshBathymetry');
    if ~isempty(h)
        if strcmp(get(h,'State'),'on')
            if isa(callback,'function_handle')
                if ~isempty(varargin)
                    feval(callback, varargin{:});
                else
                    feval(callback);
                end
            end
        end
    else
        if isa(callback,'function_handle')
            if ~isempty(varargin)
                feval(callback, varargin{:});
            else
                feval(callback);
            end
        end
    end
    
end


%%
function MoveMouse(imagefig, varargins, callback, varargin)

handles=getHandles;

hzoomin  = handles.GUIHandles.toolBar.zoomIn;
hzoomout = handles.GUIHandles.toolBar.zoomOut;
hpan     = handles.GUIHandles.toolBar.pan;

if strcmp(get(hzoomin,'State'),'on')
    pntr='glassplus';
    fn={@ZoomInOut, callback, varargin{:}};
elseif strcmp(get(hzoomout,'State'),'on')
    pntr='glassminus';
    fn={@ZoomInOut, callback, varargin{:}};
elseif strcmp(get(hpan,'State'),'on')
    pntr='hand';
    fn={@StartPan, callback, varargin{:}};
else
    pntr='arrow';
    fn=[];
end

ddb_setWindowButtonUpDownFcn(fn,[]);
try
ddb_updateCoordinateText(pntr);
end

%%
function StartPan(imagefig, varargins, callback, varargin)
handles=getHandles;
ax=handles.GUIHandles.mapAxis;
xl=get(ax,'xlim');
yl=get(ax,'ylim');
point = get(ax,'CurrentPoint');
point = point(1,1:2);
% Check if mouse is in current axis
if point(1)>=xl(1) && point(1)<=xl(2) && point(2)>=yl(1) && point(2)<=yl(2)
    set(gcf, 'windowbuttonmotionfcn', {@PanMove,xl,yl,point,handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange});
    varargin = varargin{:};
    set(gcf, 'windowbuttonupfcn', {@StopPan, callback, varargin});
    setptr(gcf,'closedhand');
end

%%
function PanMove(imagefig, varargins,xl0,yl0,pos0,xrange,yrange)
handles=getHandles;
xl1=get(handles.GUIHandles.mapAxis,'XLim');
yl1=get(handles.GUIHandles.mapAxis,'YLim');
pos1=get(handles.GUIHandles.mapAxis,'CurrentPoint');
pos1=pos1(1,1:2);
pos1(1)=xl0(1)+(xl0(2)-xl0(1))*(pos1(1)-xl1(1))/(xl1(2)-xl1(1));
pos1(2)=yl0(1)+(yl0(2)-yl0(1))*(pos1(2)-yl1(1))/(yl1(2)-yl1(1));
dpos=pos1-pos0;
xl=xl0-dpos(1);
yl=yl0-dpos(2);
[xl,yl]=CompXYLim(xl,yl,xrange,yrange);
set(handles.GUIHandles.mapAxis,'XLim',xl,'YLim',yl);
try
ddb_updateCoordinateText('closedhand');
end

%%
function StopPan(imagefig, varargins, callback, varargin)

set(gcf, 'windowbuttonmotionfcn', {@MoveMouse, callback, varargin{1}});
set(gcf, 'windowbuttonupfcn',[]);
setptr(gcf,'hand');

handles=getHandles;

handles.screenParameters.xLim=get(handles.GUIHandles.mapAxis,'XLim');
handles.screenParameters.yLim=get(handles.GUIHandles.mapAxis,'YLim');

setHandles(handles);

h=handles.GUIHandles.toolBar.autoRefreshBathymetry;

if ~isempty(h)
    if strcmp(get(h,'State'),'on')
        if isa(callback,'function_handle')
            if ~isempty(varargin)
                feval(callback, varargin{:});
            else
                feval(callback);
            end
        end
    end
else
    if isa(callback,'function_handle')
        if ~isempty(varargin)
            feval(callback, varargin{:});
        else
            feval(callback);
        end
    end
end


