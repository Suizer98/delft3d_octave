function zoomInOutPan(src, eventdata, zoommode, callback1, varargin1, callback2, varargin2)
%DDB_zoomInOutPAN  One line description goes here.
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

% $Id: zoomInOutPan.m 8190 2013-02-26 11:53:14Z ormondt $
% $Date: 2013-02-26 19:53:14 +0800 (Tue, 26 Feb 2013) $
% $Author: ormondt $
% $Revision: 8190 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/plot/mouse/zoomInOutPan.m $
% $Keywords: $

%% Update Data, Figure handle

h1=getappdata(gcf,'zoominhandle');
h2=getappdata(gcf,'zoomouthandle');
h3=getappdata(gcf,'panhandle');

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

switch(zoommode)
    case 1
        if strcmp(get(h1,'State'),'on')
            set(gcf, 'windowbuttonmotionfcn', {@moveMouse, callback1, varargin1});
        else
            ddb_setWindowButtonUpDownFcn;
            ddb_setWindowButtonMotionFcn;
        end
    case 2
        if strcmp(get(h2,'State'),'on')
            set(gcf, 'windowbuttonmotionfcn', {@moveMouse, callback1, varargin1});
        else
            ddb_setWindowButtonUpDownFcn;
            ddb_setWindowButtonMotionFcn;
        end
    case 3
        if strcmp(get(h3,'State'),'on')
            set(gcf, 'windowbuttonmotionfcn', {@moveMouse, callback1, varargin1});
        else
            ddb_setWindowButtonUpDownFcn;
            ddb_setWindowButtonMotionFcn;
        end
    case 4
        [xl,yl]=CompXYLim(-1e6,1e6,-1e6,1e6);
        set(gca,'xlim',xl);
        set(gca,'ylim',yl);
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
function zoomInOut(imagefig, varargins, callback, varargin)

h1=getappdata(gcf,'zoominhandle');

ax=gca;
xl=get(ax,'xlim');
yl=get(ax,'ylim');

point1 = get(ax,'CurrentPoint');
point1=point1(1,1:2);

% Check if mouse is in current axis

if point1(1)>=xl(1) && point1(1)<=xl(2) && point1(2)>=yl(1) && point1(2)<=yl(2)
    
    leftmouse=strcmp(get(gcf,'SelectionType'),'normal');
    rightmouse=strcmp(get(gcf,'SelectionType'),'alt');
    
    if strcmp(get(h1,'State'),'on')
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
        xl(1)=p1(1);
        yl(1)=p1(2);
        xl(2)=p1(1)+offset(1);
        yl(2)=p1(2)+offset(2);
    elseif (leftmouse==1 && zmin==0) || (rightmouse==1 && zmin==1)
        % Zoom Out
        point1 = get(ax,'CurrentPoint');
        xl=get(ax,'xlim');
        yl=get(ax,'ylim');
        point1=point1(1,1:2);
        p1(1)=point1(1)-((xl(2)-xl(1)));
        p1(2)=point1(2)-((yl(2)-yl(1)));
        offset(1)=2*((xl(2)-xl(1)));
        offset(2)=2*((yl(2)-yl(1)));
        xl(1)=p1(1);
        yl(1)=p1(2);
        xl(2)=p1(1)+offset(1);
        yl(2)=p1(2)+offset(2);
    end
    set(ax,'xlim',xl,'ylim',yl);
    datetick('x','keeplimits');

    varargin = varargin{:};
        
end


%%
function moveMouse(imagefig, varargins, callback, varargin)

hzoomin=getappdata(gcf,'zoominhandle');
hzoomout=getappdata(gcf,'zoomouthandle');
hpan=getappdata(gcf,'panhandle');

if strcmp(get(hzoomin,'State'),'on')
    pntr='glassplus';
    fn={@zoomInOut, callback, varargin{:}};
elseif strcmp(get(hzoomout,'State'),'on')
    pntr='glassminus';
    fn={@zoomInOut, callback, varargin{:}};
elseif strcmp(get(hpan,'State'),'on')
    pntr='hand';
    fn={@startPan, callback, varargin{:}};
else
    pntr='arrow';
    fn=[];
end

ddb_setWindowButtonUpDownFcn(fn,[]);

%%
function startPan(imagefig, varargins, callback, varargin)

ax=gca;
xl=get(ax,'xlim');
yl=get(ax,'ylim');
point = get(ax,'CurrentPoint');
point = point(1,1:2);
% Check if mouse is in current axis
if point(1)>=xl(1) && point(1)<=xl(2) && point(2)>=yl(1) && point(2)<=yl(2)
    set(gcf, 'windowbuttonmotionfcn', {@panMove,xl,yl,point});
    varargin = varargin{:};
    set(gcf, 'windowbuttonupfcn', {@stopPan, callback, varargin});
    setptr(gcf,'closedhand');
end

%%
function panMove(imagefig, varargins,xl0,yl0,pos0)
xl1=get(gca,'XLim');
yl1=get(gca,'YLim');
pos1=get(gca,'CurrentPoint');
pos1=pos1(1,1:2);
pos1(1)=xl0(1)+(xl0(2)-xl0(1))*(pos1(1)-xl1(1))/(xl1(2)-xl1(1));
pos1(2)=yl0(1)+(yl0(2)-yl0(1))*(pos1(2)-yl1(1))/(yl1(2)-yl1(1));
dpos=pos1-pos0;
xl=xl0-dpos(1);
yl=yl0-dpos(2);
set(ax,'XLim',xl,'YLim',yl);

%%
function stopPan(imagefig, varargins, callback, varargin)

set(gcf, 'windowbuttonmotionfcn', {@moveMouse, callback, varargin{1}});
set(gcf, 'windowbuttonupfcn',[]);
setptr(gcf,'hand');
