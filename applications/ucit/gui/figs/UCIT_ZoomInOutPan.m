function UCIT_ZoomInOutPan(src,eventdata,zoommode,callback1, varargin1, callback2, varargin2) % Update Data, Figuur handle
%UCIT_ZOOMINOUTPAN  this controles what happens when pressing the zoom
%function in the UCIT transect overview plot
%
%
%   Syntax:
%   varargout = 
%
%   Input:
%   varargin  =
%   
%
%   Output:
%   none
%
%   Example
%   
%
%   See also UCIT_plotTransectOutlines

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
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
handles=guidata(gcf);

h1=findall(gcf,'ToolTipString','Zoom In');
h2=findall(gcf,'ToolTipString','Zoom Out');
h3=findall(gcf,'ToolTipString','Pan');
h4=findall(gcf,'ToolTipString','Zoom reset');

if zoommode==1 || zoommode==2 || zoommode==3
    set(h4,'State','off');
end
if zoommode==1 || zoommode==2 || zoommode==6
    set(h3,'State','off');
end
if zoommode==1 || zoommode==3 || zoommode==6
    set(h2,'State','off');
end
if zoommode==2 || zoommode==3 || zoommode==6
    set(h1,'State','off');
end

% switch(zoommode),
%     case {1,2,3}
%         h=findobj(gcf,'Tag','UIAutomaticallyRefreshBathymetry');
%         if ~isempty(h)
%             if strcmp(get(h,'State'),'off')
%                 callback1=[];
%             end
%         end
% end

pan off;

switch(zoommode),
    case 1
        if strcmp(get(h1,'State'),'on')
%            if ~isempty(callback1)
                set(gcf, 'windowbuttonmotionfcn', {@MoveMouse, callback1, varargin1});
%            end
        else
            set(gcf, 'windowbuttondownfcn', []);
            set(gcf, 'windowbuttonupfcn', []);
            set(gcf, 'windowbuttonmotionfcn', []);
        end
    case 2
        if strcmp(get(h2,'State'),'on')
%            if ~isempty(callback1)
                set(gcf, 'windowbuttonmotionfcn', {@MoveMouse, callback1, varargin1});
%            end
        else
            set(gcf, 'windowbuttondownfcn', []);
            set(gcf, 'windowbuttonupfcn', []);
            set(gcf, 'windowbuttonmotionfcn', []);
        end
    case 3
        if strcmp(get(h3,'State'),'on')
%            if ~isempty(callback1)
                set(gcf, 'windowbuttonmotionfcn', {@MoveMouse, callback1, varargin1});
%            end
        else
            set(gcf, 'windowbuttondownfcn', []);
            set(gcf, 'windowbuttonupfcn', []);
            set(gcf, 'windowbuttonmotionfcn', []);
        end
    case 4
        [xl,yl]=UCIT_CompXYLim(handles.XMaxRange,handles.YMaxRange,handles.XMaxRange,handles.YMaxRange);
        set(gca,'xlim',xl);
        set(gca,'ylim',yl);
        handles.XLim=xl;
        handles.YLim=yl;
        guidata(gcf,handles);
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
    case 6
        fh = findobj('tag','mapWindow');
        ah = get(fh,'userdata');
        axis(ah);
        if strcmp(varargin1{1}.datatypeinfo{1},'Lidar Data US')
            handles.axisOld = ah;
        else
            handles.axisOld = [0 0 0 0];
        end
        guidata(gcf,handles);
        feval(callback1, varargin2{1},ah);
        set(h4,'State','off');
end

%%
function ZoomInOut(imagefig, varargins, callback, varargin)
handles=guidata(imagefig);

leftmouse=strcmp(get(imagefig,'SelectionType'),'normal');
rightmouse=strcmp(get(imagefig,'SelectionType'),'alt');

hzoomin=findall(imagefig,'ToolTipString','Zoom In');
if strcmp(get(hzoomin,'State'),'on')
    zmin=1;
else
    zmin=0;
end

xl=get(gca,'xlim');
yl=get(gca,'ylim');

if (leftmouse==1 && zmin==1) || (rightmouse==1 && zmin==0)
    % Zoom Out
    point1 = get(gca,'CurrentPoint');
    rect = rbbox;
    point2 = get(gca,'CurrentPoint');
    if rect(3)==0
        xl=get(gca,'xlim');
        yl=get(gca,'ylim');
        point1=point1(1,1:2);
        p1(1)=point1(1)-((xl(2)-xl(1))/4);
        p1(2)=point1(2)-((yl(2)-yl(1))/4);
        offset(1)=((xl(2)-xl(1))/2);
        offset(2)=((yl(2)-yl(1))/2);
    else
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
        [xl,yl]=UCIT_CompXYLim([p1(1) p1(1)+offset(1) ],[p1(2) p1(2)+offset(2)],handles.XMaxRange,handles.YMaxRange);
    end
elseif (leftmouse==1 && zmin==0) || (rightmouse==1 && zmin==1)
    % Zoom Out
    point1 = get(gca,'CurrentPoint');
    xl=get(gca,'xlim');
    yl=get(gca,'ylim');
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
        [xl,yl]=UCIT_CompXYLim([p1(1) p1(1)+offset(1) ],[p1(2) p1(2)+offset(2)],handles.XMaxRange,handles.YMaxRange);
    end
end
set(gca,'xlim',xl,'ylim',yl);
handles.XLim=xl;
handles.YLim=yl;
guidata(imagefig,handles);
varargin = varargin{:};

h=findobj(imagefig,'Tag','UIAutomaticallyRefreshBathymetry');
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

%%
function MoveMouse(imagefig, varargins, callback, varargin)

pos = get(get(imagefig,'CurrentAxes'), 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(get(imagefig,'CurrentAxes'),'xlim');
ylim=get(get(imagefig,'CurrentAxes'),'ylim');

% h=get(0,'PointerWindow');
% get(h)
% if(h==0)
%    return;
% end 
% 
% fh = get(1,'pointerwindow')
hzoomin  = findall(imagefig,'ToolTipString','Zoom In');
hzoomout = findall(imagefig,'ToolTipString','Zoom Out');
hpan     = findall(imagefig,'ToolTipString','Pan');

% varargin = varargin{:};
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

if posx<=xlim(1) || posx>=xlim(2) || posy<=ylim(1) || posy>=ylim(2)
    set(imagefig,'Pointer','arrow');
    set(imagefig,'WindowButtonDownFcn',[]);
else
    setptr(imagefig,pntr);
    set(imagefig,'WindowButtonDownFcn',fn);
end

%%
function StartPan(imagefig, varargins, callback, varargin)
handles=guidata(imagefig);
pos0=get(get(imagefig,'CurrentAxes'),'CurrentPoint');
pos0=pos0(1,1:2);
xl0=get(get(imagefig,'CurrentAxes'),'XLim');
yl0=get(get(imagefig,'CurrentAxes'),'YLim');
set(imagefig, 'windowbuttonmotionfcn', {@PanMove,xl0,yl0,pos0,handles.XMaxRange,handles.YMaxRange});

varargin = varargin{:};
set(imagefig, 'windowbuttonupfcn', {@StopPan, callback, varargin});
setptr(imagefig,'closedhand');

%%
function PanMove(imagefig, varargins,xl0,yl0,pos0,xrange,yrange)
xl1=get(get(imagefig,'CurrentAxes'),'XLim');
yl1=get(get(imagefig,'CurrentAxes'),'YLim');
pos1=get(get(imagefig,'CurrentAxes'),'CurrentPoint');
pos1=pos1(1,1:2);
pos1(1)=xl0(1)+(xl0(2)-xl0(1))*(pos1(1)-xl1(1))/(xl1(2)-xl1(1));
pos1(2)=yl0(1)+(yl0(2)-yl0(1))*(pos1(2)-yl1(1))/(yl1(2)-yl1(1));
dpos=pos1-pos0;
xl=xl0-dpos(1);
yl=yl0-dpos(2);
[xl,yl]=UCIT_CompXYLim(xl,yl,xrange,yrange);
set(gca,'XLim',xl,'YLim',yl);

%%
function StopPan(imagefig, varargins, callback, varargin)
set(imagefig, 'windowbuttonmotionfcn', {@MoveMouse, callback, varargin{1}});
set(imagefig, 'windowbuttonupfcn',[]);
setptr(imagefig,'hand');
handles=guidata(imagefig);
handles.XLim=get(get(imagefig,'CurrentAxes'),'XLim');
handles.YLim=get(get(imagefig,'CurrentAxes'),'YLim');
guidata(imagefig,handles);
varargin = varargin{:};

h=findobj(imagefig,'Tag','UIAutomaticallyRefreshBathymetry');
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

