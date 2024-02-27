function varargout = UIPolyline(h, opt, varargin)
%UIPOLYLINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = UIPolyline(h, opt, varargin)
%
%   Input:
%   h         =
%   opt       =
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   UIPolyline
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

% $Id: UIPolyline.m 12800 2016-07-06 06:21:37Z nederhof $
% $Date: 2016-07-06 14:21:37 +0800 (Wed, 06 Jul 2016) $
% $Author: nederhof $
% $Revision: 12800 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/plot/UIPolyline.m $
% $Keywords: $

%%

try
    tp=get(h,'Type');
    if strcmpi(tp,'axes')
        ax=h;
    end
catch
    return
end

% Default values
lineColor='g';
lineWidth=1.5;
marker='';
markerEdgeColor='r';
markerFaceColor='r';
markerSize=4;
maxPoints=10000;
txt=[];
callback=[];
argin=[];
doubleclickcallback=[];
closed=0;
userdata=[];

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
            case{'max'}
                maxPoints=varargin{i+1};
            case{'text'}
                txt=varargin{i+1};
            case{'tag'}
                tag=varargin{i+1};
            case{'callback'}
                callback=varargin{i+1};
            case{'argin'}
                argin=varargin{i+1};
            case{'userdata'}
                userdata=varargin{i+1};
            case{'x'}
                x=varargin{i+1};
            case{'y'}
                y=varargin{i+1};
            case{'closed'}
                closed=varargin{i+1};
            case{'windowbuttonupdownfcn'}
                windowbuttonupdownfcn=varargin{i+1};
            case{'windowbuttonmotionfcn'}
                windowbuttonmotionfcn=varargin{i+1};
            case{'doubleclickcallback'}
                doubleclickcallback=varargin{i+1};
        end
    end
end

switch lower(opt)
    case{'draw'}
        
        % Plot first (invisible) point
        
        x=0;
        y=0;
        h=plot3(x,y,9000);
        set(h,'Visible','off');
        
        set(h,'Tag',tag);
        set(h,'Color',lineColor);
        set(h,'LineWidth',lineWidth);
        
        if ~isempty(marker)
            set(h,'Marker',marker);
            set(h,'MarkerEdgeColor',markerEdgeColor);
            set(h,'MarkerFaceColor',markerFaceColor);
            set(h,'MarkerSize',markerSize);
        end
        
        setappdata(h,'x',[]);
        setappdata(h,'y',[]);
        setappdata(h,'axes',ax);
        setappdata(h,'closed',closed);
        setappdata(h,'callback',callback);
        setappdata(h,'argin',argin);
        setappdata(h,'doubleclickcallback',doubleclickcallback);
        setappdata(h,'tag',tag);
        setappdata(h,'color',lineColor);
        setappdata(h,'width',lineWidth);
        setappdata(h,'marker',marker);
        setappdata(h,'markeredgecolor',markerEdgeColor);
        setappdata(h,'markerfacecolor',markerFaceColor);
        setappdata(h,'markersize',markerSize);
        setappdata(h,'maxpoints',maxPoints);
        setappdata(h,'text',txt);
        setappdata(h,'closed',closed);
        setappdata(h,'windowbuttonupdownfcn',windowbuttonupdownfcn);
        setappdata(h,'windowbuttonmotionfcn',windowbuttonmotionfcn);
        set(h,'UserData',userdata);
        
        set(gcf, 'windowbuttondownfcn',   {@clickNextPoint,h});
        set(gcf, 'windowbuttonmotionfcn', {@moveMouse,h});
        
    case{'plot'}
        h=plot3(0,0,9000);
        setappdata(h,'callback',callback);
        setappdata(h,'doubleclickcallback',doubleclickcallback);
        set(h,'userdata',userdata);
        setappdata(h,'tag',tag);
        setappdata(h,'x',x);
        setappdata(h,'y',y);
        setappdata(h,'color',lineColor);
        setappdata(h,'width',lineWidth);
        setappdata(h,'marker',marker);
        setappdata(h,'markeredgecolor',markerEdgeColor);
        setappdata(h,'markerfacecolor',markerFaceColor);
        setappdata(h,'markersize',markerSize);
        setappdata(h,'maxpoints',maxPoints);
        setappdata(h,'text',txt);
        setappdata(h,'closed',closed);
        setappdata(h,'windowbuttonupdownfcn',windowbuttonupdownfcn);
        setappdata(h,'windowbuttonmotionfcn',windowbuttonmotionfcn);
        h=drawPolyline(h,'nocallback');
       
    case{'continudraw'}
        
        % Plot first (invisible) point
        h=plot3(0,0,9000);
        set(h,'Visible','off');
        
        set(h,'Tag',tag);
        set(h,'Color',lineColor);
        set(h,'LineWidth',lineWidth);
        
        if ~isempty(marker)
            set(h,'Marker',marker);
            set(h,'MarkerEdgeColor',markerEdgeColor);
            set(h,'MarkerFaceColor',markerFaceColor);
            set(h,'MarkerSize',markerSize);
        end
        
        setappdata(h,'x',x);
        setappdata(h,'y',y);
        setappdata(h,'axes',ax);
        setappdata(h,'closed',closed);
        setappdata(h,'callback',callback);
        setappdata(h,'argin',argin);
        setappdata(h,'doubleclickcallback',doubleclickcallback);
        setappdata(h,'tag',tag);
        setappdata(h,'color',lineColor);
        setappdata(h,'width',lineWidth);
        setappdata(h,'marker',marker);
        setappdata(h,'markeredgecolor',markerEdgeColor);
        setappdata(h,'markerfacecolor',markerFaceColor);
        setappdata(h,'markersize',markerSize);
        setappdata(h,'maxpoints',maxPoints);
        setappdata(h,'text',txt);
        setappdata(h,'closed',closed);
        setappdata(h,'windowbuttonupdownfcn',windowbuttonupdownfcn);
        setappdata(h,'windowbuttonmotionfcn',windowbuttonmotionfcn);
        set(h,'UserData',userdata);
        
        set(gcf, 'windowbuttondownfcn',   {@clickNextPoint,h});
        set(gcf, 'windowbuttonmotionfcn', {@moveMouse,h});

        
    case{'delete'}
        try
            ch=getappdata(h,'children');
            delete(h);
            delete(ch);
        end
        
end

if nargout==1
    varargout{1}=h;
elseif nargout==2
    varargout{1}=x;
    varargout{2}=y;
else
    varargout{1}=h;
end

%%
function h=drawPolyline(h,varargin)

opt='withcallback';
if ~isempty(varargin)
    opt=varargin{1};
end

x=getappdata(h,'x');
y=getappdata(h,'y');
z=zeros(size(x))+100;
tag=getappdata(h,'tag');
lineColor=getappdata(h,'color');
lineWidth=getappdata(h,'width');
marker=getappdata(h,'marker');
markerEdgeColor=getappdata(h,'markeredgecolor');
markerFaceColor=getappdata(h,'markerfacecolor');
markerSize=getappdata(h,'markersize');
maxPoints=getappdata(h,'maxpoints');
txt=getappdata(h,'text');
callback=getappdata(h,'callback');
argin=getappdata(h,'argin');
doubleclickcallback=getappdata(h,'doubleclickcallback');
ax=getappdata(h,'axes');
closed=getappdata(h,'closed');
userdata=get(h,'userdata');
windowbuttonupdownfcn=getappdata(h,'windowbuttonupdownfcn');
windowbuttonmotionfcn=getappdata(h,'windowbuttonmotionfcn');

ch=getappdata(h,'children');
delete(h);
delete(ch);

if ~isempty(x)
    h=plot3(x,y,z,'g');
    set(h,'Tag',tag);
    set(h,'Color',lineColor);
    set(h,'LineWidth',lineWidth);
    set(h,'HitTest','off');
    
    
    setappdata(h,'color',lineColor);
    setappdata(h,'width',lineWidth);
    setappdata(h,'marker',marker);
    setappdata(h,'markeredgecolor',markerEdgeColor);
    setappdata(h,'markerfacecolor',markerFaceColor);
    setappdata(h,'markersize',markerSize);
    setappdata(h,'maxpoints',maxPoints);
    setappdata(h,'text',txt);
    set(h,'userdata',userdata);
    setappdata(h,'callback',callback);
    setappdata(h,'argin',argin);
    setappdata(h,'doubleclickcallback',doubleclickcallback);
    setappdata(h,'x',x);
    setappdata(h,'y',y);
    setappdata(h,'tag',tag);
    setappdata(h,'axes',ax);
    setappdata(h,'closed',closed);
    setappdata(h,'windowbuttonupdownfcn',windowbuttonupdownfcn);
    setappdata(h,'windowbuttonmotionfcn',windowbuttonmotionfcn);
    setappdata(h,'type','polygon');
    
    for i=1:length(x)
        mh(i)=plot3(x(i),y(i),200,['r' marker]);
        set(mh(i),'MarkerEdgeColor',markerEdgeColor,'MarkerFaceColor',markerFaceColor,'MarkerSize',markerSize);
        set(mh(i),'ButtonDownFcn',{@moveVertex});
        set(mh(i),'Tag',tag);
        setappdata(mh(i),'parent',h);
        setappdata(mh(i),'number',i);
        setappdata(mh(i),'type','vertex');
        set(mh(i),'UserData',userdata);
    end
    setappdata(h,'children',mh);
    
    tx=[];
    if ~isempty(txt)
        for i=1:length(x)
            tx(i)=text(x(i),y(i),txt{i});
            set(tx(i),'Tag',tag,'HitTest','off','Clipping','on');
            setappdata(tx(i),'parent',h);
            setappdata(tx(i),'number',i);
        end
    end
    setappdata(h,'texthandles',tx);
    
    if ~isempty(callback) && strcmpi(opt,'withcallback')
        feval(callback,x,y,h);
    end
end

%%
function clickNextPoint(imagefig, varargins,h)

mouseclick=get(gcf,'SelectionType');

ax=getappdata(h,'axes');

buttonUpDownFcn=getappdata(h,'windowbuttonupdownfcn');
buttonMotionFcn=getappdata(h,'windowbuttonmotionfcn');

if strcmp(mouseclick,'normal')
    
    pos=get(ax, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    
    xl=get(ax,'XLim');
    yl=get(ax,'YLim');
    
    if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
        
        x=getappdata(h,'x');
        y=getappdata(h,'y');
        maxPoints=getappdata(h,'maxpoints');
        
        np=length(x);
        np=np+1;
        
        x=[x posx];
        y=[y posy];
        z=zeros(size(x))+9000;
        
        setappdata(h,'x',x);
        setappdata(h,'y',y);
        
        set(h,'XData',x,'YData',y,'ZData',z);
        set(h,'Visible','on');
        
        if np==maxPoints
            feval(buttonUpDownFcn);
            feval(buttonMotionFcn);
            drawPolyline(h);
        end
    end
    
else
    closed=getappdata(h,'closed');
    if closed
        % Add last point
        x=getappdata(h,'x');
        y=getappdata(h,'y');
        if ~isempty(x)
            x(end+1)=x(1);
            y(end+1)=y(1);
            setappdata(h,'x',x);
            setappdata(h,'y',y);
        end
    end
    feval(buttonUpDownFcn);
    feval(buttonMotionFcn);
    drawPolyline(h);
end

%%
function moveMouse(imagefig, varargins, h)

x=getappdata(h,'x');
y=getappdata(h,'y');
ax=getappdata(h,'axes');

np=length(x);

pos=get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

xl=get(ax,'XLim');
yl=get(ax,'YLim');

if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
    if np>0
        x(np+1)=posx;
        y(np+1)=posy;
        z=zeros(size(x))+9000;
        set(h,'XData',x,'YData',y,'ZData',z);
    end
end
ddb_updateCoordinateText('crosshair');

%%
function moveVertex(imagefig, varargins)

mouseclick=get(gcf,'SelectionType');
switch mouseclick
    case{'normal'}
        set(gcf, 'windowbuttonmotionfcn', {@followTrack});
        set(gcf, 'windowbuttonupfcn',     {@stopTrack});
    case{'alt'}
        h=get(gcf,'CurrentObject');
        p=getappdata(h,'parent');
        callback=getappdata(p,'doubleclickcallback');
        if ~isempty(callback)
            feval(callback,h);
        end
end

%%
function followTrack(imagefig, varargins)
h=get(gcf,'CurrentObject');
p=getappdata(h,'parent');
tx=getappdata(p,'texthandles');
x=getappdata(p,'x');
y=getappdata(p,'y');
ch=getappdata(p,'children');
nr=getappdata(h,'number');
pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);
x(nr)=xi;
y(nr)=yi;
closed=getappdata(p,'closed');
if closed
    if nr==1
        x(end)=x(1);
        y(end)=y(1);
    elseif nr==length(x)
        x(1)=x(end);
        y(1)=y(end);
    end
end
setappdata(p,'x',x);
setappdata(p,'y',y);
set(p,'XData',x,'YData',y);

if closed
    if nr==1
        set(ch(1),'XData',x(nr),'YData',y(nr));
        set(ch(end),'XData',x(nr),'YData',y(nr));
    elseif nr==length(x)
        set(ch(1),'XData',x(nr),'YData',y(nr));
        set(ch(end),'XData',x(nr),'YData',y(nr));
    else
        set(ch(nr),'XData',x(nr),'YData',y(nr));
    end
else
    set(ch(nr),'XData',x(nr),'YData',y(nr));
    if ~isempty(tx)
        set(tx(nr),'Position',[x(nr) y(nr)]);
    end
end
ddb_updateCoordinateText('arrow');

%%
function stopTrack(imagefig, varargins)
% Function is called after polyline has been changed

h=get(gcf,'CurrentObject');
p=getappdata(h,'parent');
tx=getappdata(p,'texthandles');
buttonUpDownFcn=getappdata(p,'windowbuttonupdownfcn');
buttonMotionFcn=getappdata(p,'windowbuttonmotionfcn');
feval(buttonUpDownFcn);
feval(buttonMotionFcn);
x=getappdata(p,'x');
y=getappdata(p,'y');
ch=getappdata(p,'children');
nr=getappdata(h,'number');
pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);

x(nr)=xi;
y(nr)=yi;

setappdata(p,'x',x);
setappdata(p,'y',y);

set(p,'XData',x,'YData',y);
set(ch(nr),'XData',x(nr),'YData',y(nr));
if ~isempty(tx)
    set(tx(nr),'Position',[x(nr) y(nr)]);
end

callback=getappdata(p,'callback');
argin=getappdata(p,'argin');
if ~isempty(callback)
    if isempty(argin)
        feval(callback,x,y,h);
    else
        feval(callback,argin,x,y,h);
    end
end
