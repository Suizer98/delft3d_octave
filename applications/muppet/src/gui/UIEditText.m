function UIEditText(varargin)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

ifig=get(gcf,'UserData');

hte=findall(gcf,'Tag','UIToggleToolEditFigure');
set(hte,'State','off');
h=(findall(gcf,'TooltipString','Zoom In'));
set(h,'State','off');
h=(findall(gcf,'TooltipString','Zoom Out'));
set(h,'State','off');
h=(findall(gcf,'TooltipString','Pan'));
set(h,'State','off');
plotedit off;

if strcmp(get(gco,'Tag'),'SelectionHighlight')

    ud=get(gco,'userdata');
    usd=get(ud.Parent,'userdata');
    usd.kk=FindDatasetNr(usd.Name,data.DataProperties);
    usd.nr=ud.nr;
    usd.ifig=data.ActiveFigure;
    usd.FontRed=data.Figure(usd.ifig).FontRed;
    if data.Figure(usd.ifig).NrAnnotations>0
        nrsub=data.Figure(usd.ifig).NrSubplots-1;
    else
        nrsub=data.Figure(usd.ifig).NrSubplots;
    end
    
    nn=get(gca,'UserData');
    usd.isub=nn(2);

    Plt=squeeze(data.Figure(usd.ifig).Axis(usd.isub).Plot);
    usd.n=FindDatasetNr(usd.Name,Plt);
    Plt=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n);

    usd.Position=data.DataProperties(usd.kk).Position;
    usd.Curvature=data.DataProperties(usd.kk).Curvature;
    usd.Rotation=data.DataProperties(usd.kk).Rotation;

    if strcmp(get(gcf,'SelectionType'),'open')
        data.ActiveFigure=usd.ifig;
        data.ActiveSubplot=usd.isub;
        data.ActiveDatasetInSubplot=usd.n;
        data=PlotOptionsText('data',data);
        Plt=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n);
        delete(usd.SelectionHighlights);
        if ishandle(usd.txc(1))
            delete(usd.txc);
        end
        delete(usd.tx);
        PlotText(data.DataProperties(usd.kk),Plt,data.DefaultColors,usd.FontRed,1);
        guidata(mpt,data);
        set(0,'userdata',[]);
    elseif strcmp(get(gcf,'SelectionType'),'normal')
        set(gco,'MarkerFaceColor','r');
        set(gco,'ButtonDownFcn',[]);
        pos = get(gca, 'CurrentPoint');
        usd.tx1=text(0,0,'');
        if usd.nr==1
            if strcmp(Plt.HorAl,'right')
                usd.x0=get(usd.SelectionHighlights(3),'XData');
                usd.y0=get(usd.SelectionHighlights(3),'YData');
                set(gcf, 'windowbuttonmotionfcn', {@rotatetext});
            elseif strcmp(Plt.HorAl,'center')
                usd.x0=data.DataProperties(usd.kk).Position(1);
                usd.y0=data.DataProperties(usd.kk).Position(2);
                set(gcf, 'windowbuttonmotionfcn', {@rotatetext});
            else
                set(0,'userdata',[]);
            end
        elseif usd.nr==3
            if strcmp(Plt.HorAl,'left')
                usd.x0=get(usd.SelectionHighlights(1),'XData');
                usd.y0=get(usd.SelectionHighlights(1),'YData');
                set(gcf, 'windowbuttonmotionfcn', {@rotatetext});
            elseif strcmp(Plt.HorAl,'center')
                usd.x0=data.DataProperties(usd.kk).Position(1);
                usd.y0=data.DataProperties(usd.kk).Position(2);
                set(gcf, 'windowbuttonmotionfcn', {@rotatetext});
            else
                set(0,'userdata',[]);
            end
        else
            usd.x0=pos(1,1);
            usd.y0=pos(1,2);
            usd.Position0(1)=data.DataProperties(usd.kk).Position(1);
            usd.Position0(2)=data.DataProperties(usd.kk).Position(2);
            set(gcf, 'windowbuttonmotionfcn', {@curvetext});
        end
        set(0,'userdata',usd);
        set(gcf, 'windowbuttonupfcn', {@stoptrack});
    else
        pos = get(gca, 'CurrentPoint');
        usd.tx1=text(0,0,'');
        usd.x0=pos(1,1);
        usd.y0=pos(1,2);
        usd.Position0(1)=data.DataProperties(usd.kk).Position(1);
        usd.Position0(2)=data.DataProperties(usd.kk).Position(2);
        set(gcf, 'windowbuttonmotionfcn', {@movetext});
        set(0,'userdata',usd);
        set(gcf, 'windowbuttonupfcn', {@stoptrack});
    end
else
    set(0,'userdata',[]);
end

set(gcf, 'Units', 'pixels');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rotatetext(imagefig, varargins)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

usd=get(0,'userdata');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

if usd.nr==1
    ang=atan2(-posy+usd.y0,-posx+usd.x0);
else
    ang=atan2(posy-usd.y0,posx-usd.x0);
end
usd.Rotation=180*ang/pi;

if ishandle(usd.txc(1))
    delete(usd.txc);
end
delete(usd.tx1);

DataProperties=data.DataProperties(usd.kk);
DataProperties.Rotation=usd.Rotation;
Plt=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n);
Plt.FontColor='gray70';
[usd.tx1,usd.txc]=PlotText(DataProperties,Plt,data.DefaultColors,usd.FontRed,0);

set(0,'UserData',usd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function movetext(imagefig, varargins)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

usd=get(0,'userdata');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.Position(1)=usd.Position0(1)+posx-usd.x0;
usd.Position(2)=usd.Position0(2)+posy-usd.y0;

if ishandle(usd.txc(1))
    delete(usd.txc);
end
delete(usd.tx1);

DataProperties=data.DataProperties(usd.kk);
DataProperties.Position=usd.Position;
Plt=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n);
Plt.FontColor='gray70';
[usd.tx1,usd.txc]=PlotText(DataProperties,Plt,data.DefaultColors,usd.FontRed,0);

set(0,'UserData',usd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function curvetext(imagefig, varargins)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

usd=get(0,'userdata');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

xlim=data.Figure(usd.ifig).Axis(usd.isub).XMax-data.Figure(usd.ifig).Axis(usd.isub).XMin;

x0=[posx,posy];
x1=[usd.x0 usd.y0];
x2=[usd.x0+cos(pi*usd.Rotation/180) usd.y0+sin(pi*usd.Rotation/180)];
pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
dist=det([x2-x1 ; x1-x0])/pt;

if abs(dist)<1
    dist=1;
end
usd.Curvature=xlim*xlim*0.002/dist;

if ishandle(usd.txc(1))
    delete(usd.txc);
end
delete(usd.tx1);

DataProperties=data.DataProperties(usd.kk);
DataProperties.Curvature=usd.Curvature;
Plt=data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n);
Plt.FontColor='gray70';
[usd.tx1,usd.txc]=PlotText(DataProperties,Plt,data.DefaultColors,usd.FontRed,0);

set(0,'UserData',usd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stoptrack(imagefig, varargins)
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', []);

mpt=findobj('Name','Muppet');
data=guidata(mpt);

usd=get(0,'userdata');

delete(usd.SelectionHighlights);
delete(usd.tx1);
delete(usd.tx);
if ishandle(usd.txc(1))
    delete(usd.txc);
end

data.DataProperties(usd.kk).Position=usd.Position;
data.DataProperties(usd.kk).Rotation=usd.Rotation;
data.DataProperties(usd.kk).Curvature=usd.Curvature;

PlotText(data.DataProperties(usd.kk),data.Figure(usd.ifig).Axis(usd.isub).Plot(usd.n),data.DefaultColors,usd.FontRed,1);

guidata(mpt,data);

set(0,'userdata',[]);

