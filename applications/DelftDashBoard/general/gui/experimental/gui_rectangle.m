function hg = gui_rectangle(varargin)
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

% $Id: UIRectangle.m 12726 2016-05-12 15:21:03Z nederhof $
% $Date: 2016-05-12 17:21:03 +0200 (Thu, 12 May 2016) $
% $Author: nederhof $
% $Revision: 12726 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/plot/UIRectangle.m $
% $Keywords: $

%%

if ischar(varargin{1})
    opt=varargin{1};
else
    hg=varargin{1};
    opt=varargin{2};
end

% Default values
options.linecolor='g';
options.linewidth=1.5;
options.linestyle='-';
options.marker='o';
options.markeredgecolor='r';
options.markerfacecolor='r';
options.markersize=4;
options.facecolor='r';
options.fillpolygon=0;
options.text=[];
options.startcallback=[];
options.startinput=[];
options.createcallback=[];
options.createinput=[];
options.changecallback=[];
options.changeinput=[];
options.doubleclickcallback=[];
options.doubleclickinput=[];
options.rightclickcallback=[];
options.rightclickinput=[];
options.selectcallback=[];
options.closed=0;
options.axis=gca;
options.tag='';
options.type='polyline';
options.arrowwidth=2;
options.headwidth=4;
options.headlength=8;
options.nrheads=1;
options.userdata=[];
options.rotatable=1;
options.movable=1;
options.dx=[];
options.dy=[];
options.number=[];

x0=[];
y0=[];
rotation=0;
lenx=[];
leny=[];

% Not generic yet! DDB specific.
options.windowbuttonupdownfcn=@ddb_setWindowButtonUpDownFcn;
options.windowbuttonmotionfcn=@ddb_setWindowButtonMotionFcn;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'x0'}
                x0=varargin{i+1};
            case{'y0'}
                y0=varargin{i+1};
            case{'lenx'}
                lenx=varargin{i+1};
            case{'leny'}
                leny=varargin{i+1};
            case{'rotation'}
                rotation=varargin{i+1};
            case{'dx'}
                options.dx=varargin{i+1};
            case{'dy'}
                options.dy=varargin{i+1};
            case{'rotatable'}
                options.rotatable=varargin{i+1};
            case{'tag'}
                options.tag=varargin{i+1};
            case{'linecolor','color'}
                options.linecolor=varargin{i+1};
            case{'linewidth','width'}
                options.linewidth=varargin{i+1};
            case{'linestyle'}
                options.linestyle=varargin{i+1};
            case{'facecolor'}
                options.facecolor=varargin{i+1};
            case{'fillpolygon'}
                options.fillpolygon=varargin{i+1};
            case{'marker'}
                options.marker=varargin{i+1};
            case{'markeredgecolor'}
                options.markeredgecolor=varargin{i+1};
            case{'markerfacecolor'}
                options.markerfacecolor=varargin{i+1};
            case{'markersize'}
                options.markersize=varargin{i+1};
            case{'text'}
                options.text=varargin{i+1};
            case{'startcallback'}
                options.startcallback=varargin{i+1};
            case{'startinput'}
                options.createinput=varargin{i+1};
            case{'createcallback'}
                options.createcallback=varargin{i+1};
            case{'createinput'}
                options.createinput=varargin{i+1};
            case{'changecallback'}
                options.changecallback=varargin{i+1};
            case{'changeinput'}
                options.changeinput=varargin{i+1};
            case{'doubleclickcallback'}
                options.doubleclickcallback=varargin{i+1};
            case{'doubleclickinput'}
                options.doubleclickinput=varargin{i+1};
            case{'rightclickcallback'}
                options.rightclickcallback=varargin{i+1};
            case{'rightclickinput'}
                options.rightclickinput=varargin{i+1};
            case{'selectcallback'}
                options.selectcallback=varargin{i+1};
            case{'windowbuttonupdownfcn'}
                options.windowbuttonupdownfcn=varargin{i+1};
            case{'windowbuttonmotionfcn'}
                options.windowbuttonmotionfcn=varargin{i+1};
            case{'axis'}
                options.axis=varargin{i+1};
            case{'type'}
                options.type=varargin{i+1};
            case{'userdata'}
                options.userdata=varargin{i+1};
            case{'number'}
                options.number=varargin{i+1};
        end
    end
end

switch lower(opt)
    case{'draw'}
        
        hg=hggroup;
        
%        set(hg,'Visible','off');
        set(hg,'Tag',options.tag);
        
        setappdata(hg,'x0',[]);
        setappdata(hg,'y0',[]);
        setappdata(hg,'lenx',[]);
        setappdata(hg,'leny',[]);
%        setappdata(hg,'dx',dx);
%        setappdata(hg,'dy',dy);
        setappdata(hg,'x',[]);
        setappdata(hg,'y',[]);
        setappdata(hg,'options',options);
        
        set(gcf, 'windowbuttondownfcn',   {@startRectangle,hg});
        set(gcf, 'windowbuttonmotionfcn', {@dragRectangle,hg});
                
    case{'plot'}

        hg=hggroup;
%        h=plot(0,0);
%        set(h,'Parent',hg);
        setappdata(hg,'options',options);
        set(hg,'tag',options.tag);
        setappdata(hg,'x0',x0);
        setappdata(hg,'y0',y0);
        setappdata(hg,'lenx',lenx);
        setappdata(hg,'leny',leny);
        setappdata(hg,'rotation',rotation);

        hg=plotRectangle(hg);
        
    case{'delete'}
        try
            delete(hg);
        end
        
    case{'change'}

        if ~isempty(hg)
            
            for i=1:length(varargin)
                if ischar(varargin{i})
                    switch lower(varargin{i})
                        case{'color'}
                            h=getappdata(hg,'linehandle');
                            set(h,'Color',varargin{i+1});
                        case{'markeredgecolor'}
                            ch=getappdata(hg,'markerhandles');
                            set(ch,'markeredgecolor',varargin{i+1});
                        case{'markerfacecolor'}
                            ch=getappdata(hg,'markerhandles');
                            set(ch,'markerfacecolor',varargin{i+1});
                        case{'markersize'}
                            ch=getappdata(hg,'markerhandles');
                            set(ch,'markersize',varargin{i+1});
                    end
                end
            end

        end
        
end

%%
function hg=plotRectangle(hg)

options=getappdata(hg,'options');

x0=getappdata(hg,'x0');
y0=getappdata(hg,'y0');
lenx=getappdata(hg,'lenx');
leny=getappdata(hg,'leny');
dx=getappdata(hg,'dx');
dy=getappdata(hg,'dy');
rotation=getappdata(hg,'rotation');

if ~isempty(x0)
    
    % Compute coordinates of corner points
    
    [x,y]=computeCoordinates(x0,y0,lenx,leny,rotation);
    
    h=plot(x,y,'g');
    
    set(h,'Color',options.linecolor);
    set(h,'LineWidth',options.linewidth);
    if isempty(options.selectcallback)
        set(h,'HitTest','off');
    else
        set(h,'ButtonDownFcn',{@select,hg});
    end
    
    set(h,'Parent',hg);
    
    set(hg,'Tag',options.tag);
    
    setappdata(hg,'x0',x0);
    setappdata(hg,'y0',y0);
    setappdata(hg,'lenx',lenx);
    setappdata(hg,'leny',leny);
    setappdata(hg,'dx',dx);
    setappdata(hg,'dy',dy);
    setappdata(hg,'rotation',rotation);
    setappdata(hg,'x',x);
    setappdata(hg,'y',y);
    setappdata(hg,'linehandle',h);
    
    setappdata(hg,'options',options);
    
    for i=1:length(x)-1
        if i==1
            % Origin
            mh(i)=plot3(x(i),y(i),200,['r' options.marker]);
            set(mh(i),'MarkerEdgeColor','y','MarkerFaceColor','y','MarkerSize',options.markersize+2);
        else
            mh(i)=plot3(x(i),y(i),200,['r' options.marker]);
            set(mh(i),'MarkerEdgeColor',options.markeredgecolor,'MarkerFaceColor',options.markerfacecolor,'MarkerSize',options.markersize);
        end
        set(mh(i),'ButtonDownFcn',{@changeRectangle,hg,i});
        setappdata(mh(i),'number',i);
        set(mh(i),'Parent',hg);
    end
    setappdata(hg,'markerhandles',mh);
    
end

%%
function startRectangle(imagefig, varargins,hg)

options=getappdata(hg,'options');

ax=options.axis;

if ~isempty(options.startcallback)
    feval(options.startcallback);
end

set(gcf,'CurrentAxes',ax);

pos=get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

xl=get(ax,'XLim');
yl=get(ax,'YLim');

if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
    
    x0=posx;
    y0=posy;
    
    setappdata(hg,'x0',posx);
    setappdata(hg,'y0',posy);
    setappdata(hg,'lenx',0);
    setappdata(hg,'leny',0);
    setappdata(hg,'rotation',0);
    setappdata(hg,'x',[x0 x0 x0 x0 x0]);
    setappdata(hg,'y',[y0 y0 y0 y0 y0]);
    
    hg = plotRectangle(hg);

    
%     h=plot(x0,y0);
%     set(h,'Parent',hg);
%     
%     set(hg,'Visible','on');
%     
%     setappdata(hg,'linehandle',h);
%     
%     
%     set(h,'XData',x,'YData',y);
%     set(h,'Visible','on');
%     set(h,'LineWidth',options.linewidth);
%     set(h,'Color',options.linecolor);
%     if isempty(options.selectcallback)
%         set(h,'HitTest','off');
%     else
%         set(h,'ButtonDownFcn',{@select,hg});
%     end
%     
%     for i=1:4
%         if i==1
%             % Origin
%             mh(i)=plot(x(i),y(i),['r' options.marker]);
%             set(mh(i),'MarkerEdgeColor','y','MarkerFaceColor','y','MarkerSize',options.markersize+2);
%         else
%             mh(i)=plot(x(i),y(i),['y' options.marker]);
%             set(mh(i),'MarkerEdgeColor',options.markeredgecolor,'MarkerFaceColor',options.markerfacecolor,'MarkerSize',options.markersize);
%         end
%         if options.movable
%             set(mh(i),'ButtonDownFcn',{@changeRectangle,hg,i});
%         else
%             set(mh(i),'HitTest','off');
%         end
%         setappdata(mh(i),'number',i);
%         set(mh(i),'Parent',hg);
%     end
%     setappdata(hg,'markerhandles',mh);
    
    set(gcf, 'windowbuttonupfcn',     {@finishRectangle,hg});
    set(gcf, 'windowbuttonmotionfcn', {@dragRectangle,hg});
    
end

%%
function dragRectangle(imagefig, varargins, hg)

options=getappdata(hg,'options');
ax=options.axis;

pos=get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

xl=get(ax,'XLim');
yl=get(ax,'YLim');

if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
    
    x0=getappdata(hg,'x0');
    y0=getappdata(hg,'y0');
    dx=getappdata(hg,'dx');
    dy=getappdata(hg,'dy');
    
    if ~isempty(x0)
        
        h=getappdata(hg,'linehandle');
        mh=getappdata(hg,'markerhandles');
        
        lenx=posx-x0;
        leny=posy-y0;
        
        if lenx<0
            x0=posx;
            lenx=-lenx;
        end
        
        if leny<0
            y0=posy;
            leny=-leny;
        end
        
        % Round to cell size
        if ~isempty(dx)
            nx=max(1,round(lenx/dx));
            lenx=nx*dx;
        end
        if ~isempty(dy)
            ny=max(1,round(leny/dy));
            leny=ny*dy;
        end
        
        setappdata(hg,'lenx',lenx);
        setappdata(hg,'leny',leny);
        setappdata(hg,'rotation',0);
        rotation=0;
        
        [x,y]=computeCoordinates(x0,y0,lenx,leny,rotation);
        
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

options=getappdata(hg,'options');
feval(options.windowbuttonupdownfcn);
feval(options.windowbuttonmotionfcn);

x0=getappdata(hg,'x0');
y0=getappdata(hg,'y0');
lenx=getappdata(hg,'lenx');
leny=getappdata(hg,'leny');
rotation=0;

createcallback=options.createcallback;
if ~isempty(createcallback)
    feval(createcallback,x0,y0,lenx,leny,rotation,hg);
end

%%
function changeRectangle(imagefig, varargins,hg,i)

options=getappdata(hg,'options');
ax=options.axis;
pos = get(ax, 'CurrentPoint');
setappdata(hg,'posx0',pos(1,1));
setappdata(hg,'posy0',pos(1,2));

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
            if options.rotatable
                % Rotate rectangle
                set(gcf, 'windowbuttonmotionfcn', {@moveCornerPoint,hg,i,'rotaterectangle','busy'});
                set(gcf, 'windowbuttonupfcn', {@moveCornerPoint,hg,i,'rotaterectangle','finish'});
            end
        end
end

%%
function moveCornerPoint(imagefig, varargins,hg,i,action,opt)

options=getappdata(hg,'options');
ax=options.axis;

%ax=getappdata(hg,'axes');
pos = get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

x0=getappdata(hg,'x0');
y0=getappdata(hg,'y0');
lenx=getappdata(hg,'lenx');
leny=getappdata(hg,'leny');
rotation=getappdata(hg,'rotation');
dx=options.dx;
dy=options.dy;

x=getappdata(hg,'x');
y=getappdata(hg,'y');

posx0=getappdata(hg,'posx0');
posy0=getappdata(hg,'posy0');

[x0,y0,lenx,leny,rotation]=computeDxDy(x0,y0,lenx,leny,rotation,dx,dy,posx,posy,posx0,posy0,x,y,i,action);

[x,y]=computeCoordinates(x0,y0,lenx,leny,rotation);

h=getappdata(hg,'linehandle');
mh=getappdata(hg,'markerhandles');

set(h,'XData',x,'YData',y);

for i=1:4
    set(mh(i),'XData',x(i),'YData',y(i));
end

ddb_updateCoordinateText('arrow');

switch opt
    case{'finish'}
        
        setappdata(hg,'x0',x0);
        setappdata(hg,'y0',y0);
        setappdata(hg,'lenx',lenx);
        setappdata(hg,'leny',leny);
        setappdata(hg,'rotation',rotation);
        setappdata(hg,'x',x);
        setappdata(hg,'y',y);
        
        feval(options.windowbuttonupdownfcn);
        feval(options.windowbuttonmotionfcn);

        options=getappdata(hg,'options');

        if ~isempty(options.changecallback)
            feval(options.changecallback,x0,y0,lenx,leny,rotation,hg);
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

%%
function select(imagefig, varargins,hg)
options=getappdata(hg,'options');
options
feval(options.selectcallback,hg);
