function hg = UIRectangle(hg, opt, varargin)
%UIRECTANGLE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   hg = UIRectangle(hg, opt, varargin)
%
%   Input:
%   hg       =
%   opt      =
%   varargin =
%
%   Output:
%   hg       =
%
%   Example
%   UIRectangle
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

% $Id: UIRectangle.m 17815 2022-03-14 08:19:19Z ormondt $
% $Date: 2022-03-14 16:19:19 +0800 (Mon, 14 Mar 2022) $
% $Author: ormondt $
% $Revision: 17815 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/plot/UIRectangle.m $
% $Keywords: $

%%

if strcmpi(get(hg,'Type'),'axes')
    ax=hg;
end

% Default values
lineColor='g';
lineWidth=1.5;
marker='';
markerEdgeColor='r';
markerFaceColor='r';
markerSize=4;
txt=[];
callback=[];
onStartCallback=[];
closed=0;

rotate=0;
movable=1;

x0=[];
y0=[];
dx=[];
dy=[];
rotation=0;
ddx=[];
ddy=[];
number=[];
snap=0;
dxsnap=0;

try
setappdata(hg,'number',number)
end

tag='';

% Not generic yet! DDB specific.
windowbuttonupdownfcn=@ddb_setWindowButtonUpDownFcn;
windowbuttonmotionfcn=@ddb_setWindowButtonMotionFcn;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'linecolor','color'}
                lineColor=varargin{i+1};
            case{'linewidth','width'}
                lineWidth=varargin{i+1};
            case{'marker'}
                marker=varargin{i+1};
            case{'markeredgecolor'}
                markerEdgeColor=varargin{i+1};
            case{'markerfacecolor'}
                markerFaceColor=varargin{i+1};
            case{'markerfacesize'}
                markerSize=varargin{i+1};
            case{'text'}
                txt=varargin{i+1};
            case{'tag'}
                tag=varargin{i+1};
            case{'callback'}
                callback=varargin{i+1};
            case{'onstart'}
                onStartCallback=varargin{i+1};
            case{'x0'}
                x0=varargin{i+1};
            case{'y0'}
                y0=varargin{i+1};
            case{'dx'}
                dx=varargin{i+1};
            case{'dy'}
                dy=varargin{i+1};
            case{'rotation'}
                rotation=varargin{i+1};
            case{'rotate'}
                rotate=varargin{i+1};
            case{'movable'}
                movable=varargin{i+1};
            case{'windowbuttonupdownfcn'}
                windowbuttonupdownfcn=varargin{i+1};
            case{'windowbuttonmotionfcn'}
                windowbuttonmotionfcn=varargin{i+1};
            case{'ddx'}
                ddx=varargin{i+1};
            case{'ddy'}
                ddy=varargin{i+1};
            case{'number'}
                number=varargin{i+1};
            case{'snap'}
                snap=1;
                dxsnap=varargin{i+1};
        end
    end
end

switch lower(opt)
    case{'draw'}
        
        % Plot first (invisible) point
        
        hg = hggroup;
        
        set(hg,'Visible','off');
        
        set(hg,'Tag',tag);
        
        setappdata(hg,'x0',x0);
        setappdata(hg,'y0',y0);
        setappdata(hg,'dx',dx);
        setappdata(hg,'dy',dy);
        setappdata(hg,'rotation',rotation);
        setappdata(hg,'ddx',ddx);
        setappdata(hg,'ddy',ddy);
        setappdata(hg,'axes',ax);
        setappdata(hg,'closed',closed);
        setappdata(hg,'callback',callback);
        setappdata(hg,'onstartcallback',onStartCallback);
        setappdata(hg,'tag',tag);
        setappdata(hg,'linecolor',lineColor);
        setappdata(hg,'linewidth',lineWidth);
        setappdata(hg,'marker',marker);
        setappdata(hg,'markeredgecolor',markerEdgeColor);
        setappdata(hg,'markerfacecolor',markerFaceColor);
        setappdata(hg,'markersize',markerSize);
        setappdata(hg,'text',txt);
        setappdata(hg,'rotate',rotate);
        setappdata(hg,'movable',movable);
        setappdata(hg,'windowbuttonupdownfcn',windowbuttonupdownfcn);
        setappdata(hg,'windowbuttonmotionfcn',windowbuttonmotionfcn);
        setappdata(hg,'number',number);
        setappdata(hg,'snap',snap);
        setappdata(hg,'dxsnap',dxsnap);

        set(gcf, 'windowbuttondownfcn',   {@startRectangle,hg});
        set(gcf, 'windowbuttonmotionfcn', {@dragRectangle,hg});
        
    case{'plot'}
        hg = hggroup;
        
        setappdata(hg,'x0',x0);
        setappdata(hg,'y0',y0);
        setappdata(hg,'dx',dx);
        setappdata(hg,'dy',dy);
        setappdata(hg,'rotation',rotation);
        setappdata(hg,'ddx',ddx);
        setappdata(hg,'ddy',ddy);
        setappdata(hg,'axes',ax);
        setappdata(hg,'closed',closed);
        setappdata(hg,'callback',callback);
        setappdata(hg,'onstartcallback',onStartCallback);
        setappdata(hg,'tag',tag);
        setappdata(hg,'linecolor',lineColor);
        setappdata(hg,'linewidth',lineWidth);
        setappdata(hg,'marker',marker);
        setappdata(hg,'markeredgecolor',markerEdgeColor);
        setappdata(hg,'markerfacecolor',markerFaceColor);
        setappdata(hg,'markersize',markerSize);
        setappdata(hg,'text',txt);
        setappdata(hg,'rotate',rotate);
        setappdata(hg,'movable',movable);
        setappdata(hg,'windowbuttonupdownfcn',windowbuttonupdownfcn);
        setappdata(hg,'windowbuttonmotionfcn',windowbuttonmotionfcn);
        setappdata(hg,'number',number);
        setappdata(hg,'snap',snap);
        setappdata(hg,'dxsnap',dxsnap);

        hg=plotRectangle(hg,'nocallback');
        
    case{'delete'}
        delete(hg);
        
end

%%
function hg=plotRectangle(hg,varargin)

opt='withcallback';
if ~isempty(varargin)
    opt=varargin{1};
end

x0=getappdata(hg,'x0');
y0=getappdata(hg,'y0');
dx=getappdata(hg,'dx');
dy=getappdata(hg,'dy');
rotation=getappdata(hg,'rotation');
rotate=getappdata(hg,'rotate');
ddx=getappdata(hg,'ddx');
ddy=getappdata(hg,'ddy');

tag=getappdata(hg,'tag');
lineColor=getappdata(hg,'linecolor');
lineWidth=getappdata(hg,'linewidth');
marker=getappdata(hg,'marker');
markerEdgeColor=getappdata(hg,'markeredgecolor');
markerFaceColor=getappdata(hg,'markerfacecolor');
markerSize=getappdata(hg,'markersize');
txt=getappdata(hg,'text');
callback=getappdata(hg,'callback');
ax=getappdata(hg,'axes');
windowbuttonupdownfcn=getappdata(hg,'windowbuttonupdownfcn');
windowbuttonmotionfcn=getappdata(hg,'windowbuttonmotionfcn');

delete(hg);

if ~isempty(x0)
    
    % Compute coordinates of corner points
    
    [x,y]=computeCoordinates(x0,y0,dx,dy,rotation);
    
    h=plot(x,y,'g');
    
    set(h,'Color',lineColor);
    set(h,'LineWidth',lineWidth);
    set(h,'HitTest','off');
    
    hg = hggroup;
    set(h,'Parent',hg);
    set(hg,'Tag',tag);
    
    setappdata(hg,'line',h);
    setappdata(hg,'color',lineColor);
    setappdata(hg,'width',lineWidth);
    setappdata(hg,'marker',marker);
    setappdata(hg,'markeredgecolor',markerEdgeColor);
    setappdata(hg,'markerfacecolor',markerFaceColor);
    setappdata(hg,'markersize',markerSize);
    setappdata(hg,'rotate',rotate);
    setappdata(hg,'text',txt);
    setappdata(hg,'callback',callback);
    setappdata(hg,'x0',x0);
    setappdata(hg,'y0',y0);
    setappdata(hg,'dx',dx);
    setappdata(hg,'dy',dy);
    setappdata(hg,'ddx',ddx);
    setappdata(hg,'ddy',ddy);
    setappdata(hg,'x',x);
    setappdata(hg,'y',y);
    setappdata(hg,'rotation',rotation);
    setappdata(hg,'tag',tag);
    setappdata(hg,'axes',ax);
    setappdata(hg,'windowbuttonupdownfcn',windowbuttonupdownfcn);
    setappdata(hg,'windowbuttonmotionfcn',windowbuttonmotionfcn);

    for i=1:length(x)-1
        if i==1
            % Origin
            mh(i)=plot3(x(i),y(i),200,['r' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor','y','MarkerSize',markerSize+2);
        else
            mh(i)=plot3(x(i),y(i),200,['r' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor',markerFaceColor,'MarkerSize',markerSize);
        end
        set(mh(i),'ButtonDownFcn',{@changeRectangle,hg,i});
        setappdata(mh(i),'number',i);
        set(mh(i),'Parent',hg);
    end
    setappdata(hg,'markers',mh);
    
    if ~isempty(callback) && strcmpi(opt,'withcallback')
        feval(callback,x,y,hg);
    end
end

%%
function startRectangle(imagefig, varargins,hg)

onstart=getappdata(hg,'onstartcallback');
if ~isempty(onstart)
    feval(onstart);
end

ax=getappdata(hg,'axes');

set(gcf,'CurrentAxes',ax);

pos=get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

snap=getappdata(hg,'snap');
dxsnap=getappdata(hg,'dxsnap');

if snap
    posx=roundnearest(posx,dxsnap);
    posy=roundnearest(posy,dxsnap);
end

xl=get(ax,'XLim');
yl=get(ax,'YLim');

if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
    
    x0=posx;
    y0=posy;
    
    setappdata(hg,'x0',posx);
    setappdata(hg,'y0',posy);
    
    h=plot(x0,y0);
    set(h,'Parent',hg);
    
    set(hg,'Visible','on');
    
    setappdata(hg,'line',h);
    lineWidth=getappdata(hg,'linewidth');
    lineColor=getappdata(hg,'linecolor');
    marker=getappdata(hg,'marker');
    markerEdgeColor=getappdata(hg,'markeredgecolor');
    markerFaceColor=getappdata(hg,'markerfacecolor');
    markerSize=getappdata(hg,'markersize');
    movable=getappdata(hg,'movable');
    
    x=[x0 x0 x0 x0 x0];
    y=[y0 y0 y0 y0 y0];
    
    set(h,'XData',x,'YData',y);
    set(h,'Visible','on');
    set(h,'LineWidth',lineWidth);
    set(h,'Color',lineColor);
    
    for i=1:4
        if i==1
            % Origin
            mh(i)=plot(x(i),y(i),['r' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor','y','MarkerSize',markerSize+2);
        else
            mh(i)=plot(x(i),y(i),['y' marker]);
            set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor',markerFaceColor,'MarkerSize',markerSize);
        end
        if movable
            set(mh(i),'ButtonDownFcn',{@changeRectangle,hg,i});
        else
            set(mh(i),'HitTest','off');
        end
        setappdata(mh(i),'number',i);
        set(mh(i),'Parent',hg);
    end
    setappdata(hg,'markers',mh);
    
    set(gcf, 'windowbuttonupfcn',     {@finishRectangle,hg});
    set(gcf, 'windowbuttonmotionfcn', {@dragRectangle,hg});
    
end

%%
function dragRectangle(imagefig, varargins, hg)

ax=getappdata(hg,'axes');

pos=get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

snap=getappdata(hg,'snap');
dxsnap=getappdata(hg,'dxsnap');

if snap
    posx=roundnearest(posx,dxsnap);
    posy=roundnearest(posy,dxsnap);
end

xl=get(ax,'XLim');
yl=get(ax,'YLim');


if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
    
    
    
    x0=getappdata(hg,'x0');
    y0=getappdata(hg,'y0');
    ddx=getappdata(hg,'ddx');
    ddy=getappdata(hg,'ddy');
    
    if ~isempty(x0)
        
        h=getappdata(hg,'line');
        mh=getappdata(hg,'markers');
        
        dx=posx-x0;
        dy=posy-y0;
        
        if dx<0
            x0=posx;
            dx=-dx;
        end
        
        if dy<0
            y0=posy;
            dy=-dy;
        end
        
        % Round to cell size
        if ~isempty(ddx)
            nx=max(1,round(dx/ddx));
            dx=nx*ddx;
        end
        if ~isempty(ddy)
            ny=max(1,round(dy/ddy));
            dy=ny*ddy;
        end
        
        setappdata(hg,'dx',dx);
        setappdata(hg,'dy',dy);
        rotation=0;
        
        [x,y]=computeCoordinates(x0,y0,dx,dy,rotation);
        
        setappdata(hg,'x',x);
        setappdata(hg,'y',y);
        
        set(h,'XData',x,'YData',y);
        for i=1:4
            set(mh(i),'XData',x(i),'YData',y(i));
        end
        
    end
    
end

ddb_updateCoordinateText('crosshair');

%%
function finishRectangle(imagefig, varargins,hg)

buttonUpDownFcn=getappdata(hg,'windowbuttonupdownfcn');
buttonMotionFcn=getappdata(hg,'windowbuttonmotionfcn');
feval(buttonUpDownFcn);
feval(buttonMotionFcn);
x0=getappdata(hg,'x0');
y0=getappdata(hg,'y0');
ddx=getappdata(hg,'ddx');
ddy=getappdata(hg,'ddy');
pos = get(gca, 'CurrentPoint');

x=pos(1,1);
y=pos(1,2);

snap=getappdata(hg,'snap');
dxsnap=getappdata(hg,'dxsnap');

if snap
    x=roundnearest(x,dxsnap);
    y=roundnearest(y,dxsnap);
end

dx=x-x0;
dy=y-y0;

if dx<0
    x0=x;
    dx=-dx;
end

if dy<0
    y0=y;
    dy=-dy;
end

% Round to cell size
if ~isempty(ddx)
    nx=max(1,round(dx/ddx));
    dx=nx*ddx;
end
if ~isempty(ddy)
    ny=max(1,round(dy/ddy));
    dy=ny*ddy;
end

h=getappdata(hg,'line');
mh=getappdata(hg,'markers');

setappdata(hg,'x0',x0);
setappdata(hg,'y0',y0);
setappdata(hg,'dx',dx);
setappdata(hg,'dy',dy);
rotation=0;

[x,y]=computeCoordinates(x0,y0,dx,dy,rotation);

setappdata(hg,'x',x);
setappdata(hg,'y',y);
setappdata(hg,'rotation',rotation);

set(h,'XData',x,'YData',y);
for i=1:4
    set(mh(i),'XData',x(i),'YData',y(i));
end

callback=getappdata(hg,'callback');
if ~isempty(callback)
    feval(callback,x0,y0,dx,dy,rotation,hg);
end

%%
function changeRectangle(imagefig, varargins,hg,i)

ax=getappdata(hg,'axes');
pos = get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

snap=getappdata(hg,'snap');
dxsnap=getappdata(hg,'dxsnap');

if snap
    posx=roundnearest(posx,dxsnap);
    posy=roundnearest(posy,dxsnap);
end


setappdata(hg,'posx0',posx);
setappdata(hg,'posy0',posy);

switch get(gcf,'SelectionType')
    case{'normal'}
        % Move corner point
        set(gcf, 'windowbuttonmotionfcn', {@moveCornerPoint,hg,i,'movecornerpoint','busy'});
        set(gcf, 'windowbuttonupfcn',     {@moveCornerPoint,hg,i,'movecornerpoint','finish'});
    case{'alt'}
        if i==1
            % Move rectangle
            set(gcf, 'windowbuttonmotionfcn', {@moveCornerPoint,hg,i,'moverectangle','busy'});
            set(gcf, 'windowbuttonupfcn', {@moveCornerPoint,hg,i,'moverectangle','finish'});
        else
            rotate=getappdata(hg,'rotate');
            if rotate
                % Rotate rectangle
                set(gcf, 'windowbuttonmotionfcn', {@moveCornerPoint,hg,i,'rotaterectangle','busy'});
                set(gcf, 'windowbuttonupfcn', {@moveCornerPoint,hg,i,'rotaterectangle','finish'});
            end
        end
end

%%
function moveCornerPoint(imagefig, varargins,hg,i,action,opt)

ax=getappdata(hg,'axes');
pos = get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

snap=getappdata(hg,'snap');
dxsnap=getappdata(hg,'dxsnap');

if snap
    posx=roundnearest(posx,dxsnap);
    posy=roundnearest(posy,dxsnap);
end

x0=getappdata(hg,'x0');
y0=getappdata(hg,'y0');
dx=getappdata(hg,'dx');
dy=getappdata(hg,'dy');
ddx=getappdata(hg,'ddx');
ddy=getappdata(hg,'ddy');
rotation=getappdata(hg,'rotation');

x=getappdata(hg,'x');
y=getappdata(hg,'y');

posx0=getappdata(hg,'posx0');
posy0=getappdata(hg,'posy0');

[x0,y0,dx,dy,rotation]=computeDxDy(x0,y0,dx,dy,rotation,ddx,ddy,posx,posy,posx0,posy0,x,y,i,action);

[x,y]=computeCoordinates(x0,y0,dx,dy,rotation);

h=getappdata(hg,'line');
mh=getappdata(hg,'markers');

set(h,'XData',x,'YData',y);

for i=1:4
    set(mh(i),'XData',x(i),'YData',y(i));
end

ddb_updateCoordinateText('arrow');

switch opt
    case{'finish'}
        
        setappdata(hg,'x0',x0);
        setappdata(hg,'y0',y0);
        setappdata(hg,'dx',dx);
        setappdata(hg,'dy',dy);
        setappdata(hg,'rotation',rotation);
        setappdata(hg,'x',x);
        setappdata(hg,'y',y);
        
        buttonUpDownFcn=getappdata(hg,'windowbuttonupdownfcn');
        buttonMotionFcn=getappdata(hg,'windowbuttonmotionfcn');
        feval(buttonUpDownFcn);
        feval(buttonMotionFcn);
        callback=getappdata(hg,'callback');
        if ~isempty(callback)
            feval(callback,x0,y0,dx,dy,rotation,hg);
        end
end


%%
function [x0,y0,dx,dy,rotation]=computeDxDy(x0,y0,dx,dy,rotation,ddx,ddy,posx,posy,posx0,posy0,x,y,i,opt)

switch opt
    case{'movecornerpoint'}
        
        dposx=posx0-x(i);
        dposy=posy0-y(i);
        posx=posx-dposx;
        posy=posy-dposy;
        
        switch i
            case 1
                
                x00=[posx posy];
                
                x1=[x(3) y(3)];
                x2=[x(2) y(2)];
                pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
                dx=det([x2-x1 ; x1-x00])/pt;
                
                x1=[x(4) y(4)];
                x2=[x(3) y(3)];
                pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
                dy=det([x2-x1 ; x1-x00])/pt;
                
                x0=posx;
                y0=posy;
                
            case 2
                dx=sqrt((posx-x0)^2 + (posy-y0)^2);
                
            case 3
                
                x00=[posx posy];
                
                x1=[x(1) y(1)];
                x2=[x(4) y(4)];
                pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
                dx=det([x2-x1 ; x1-x00])/pt;
                
                x1=[x(2) y(2)];
                x2=[x(1) y(1)];
                pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
                dy=det([x2-x1 ; x1-x00])/pt;
                
            case 4
                dy=sqrt((posx-x0)^2 + (posy-y0)^2);
                
        end
        
        dx=max(dx,0);
        dy=max(dy,0);
        
        if ~isempty(ddx)
            nx=max(1,round(dx/ddx));
            dx=nx*ddx;
        end
        if ~isempty(ddy)
            ny=max(1,round(dy/ddy));
            dy=ny*ddy;
        end
        
    case{'moverectangle'}
        dposx=posx-posx0;
        dposy=posy-posy0;
        x0=x0+dposx;
        y0=y0+dposy;
    case{'rotaterectangle'}
        rot0=180*atan2(posy0-y0,posx0-x0)/pi;
        rot=180*atan2(posy-y0,posx-x0)/pi;
        drot=rot-rot0;
        rotation=rotation+drot;
        
end

%%
function [x,y]=computeCoordinates(x0,y0,dx,dy,rotation)
x(1)=x0;
y(1)=y0;
x(2)=x(1)+dx*cos(pi*rotation/180);
y(2)=y(1)+dx*sin(pi*rotation/180);
x(3)=x(2)+dy*cos(pi*(rotation+90)/180);
y(3)=y(2)+dy*sin(pi*(rotation+90)/180);
x(4)=x(3)+dx*cos(pi*(rotation+180)/180);
y(4)=y(3)+dx*sin(pi*(rotation+180)/180);
x(5)=x0;
y(5)=y0;


