function mp_zoomInOutPan(src,eventdata,zoommode)

mpt=findobj('Name','Muppet');
handles=guidata(mpt);

ifig=get(gcf,'UserData');

zoom off;
pan off;
rotate3d off;

SetPlotEdit(0);

set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf,'pointer','arrow');

h(1)=findall(gcf,'ToolTipString','Zoom In');
h(2)=findall(gcf,'ToolTipString','Zoom Out');
h(3)=findall(gcf,'ToolTipString','Pan');
h(4)=findall(gcf,'ToolTipString','Rotate 3D');

set(h(1),'State','off');
set(h(2),'State','off');
set(h(3),'State','off');
set(h(4),'State','off');

switch zoommode,
    case 1
        if strcmp(handles.Figure(ifig).Zoom,'zoomin')
            handles.Figure(ifig).Zoom='none';
        else
            set(h(1),'State','on');
            handles.Figure(ifig).Zoom='zoomin';
            set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
        end
    case 2
        if strcmp(handles.Figure(ifig).Zoom,'zoomout')
            handles.Figure(ifig).Zoom='none';
        else
            set(h(2),'State','on');
            handles.Figure(ifig).Zoom='zoomout';
            set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
        end
    case 3
        if strcmp(handles.Figure(ifig).Zoom,'pan')
            handles.Figure(ifig).Zoom='none';
        else
            set(h(3),'State','on');
            handles.Figure(ifig).Zoom='pan';
            set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
        end
    case 4
        if strcmp(handles.Figure(ifig).Zoom,'rotate3d')
            handles.Figure(ifig).Zoom='none';
        else
            set(h(4),'State','on');
            handles.Figure(ifig).Zoom='rotate3d';
            set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
        end
end        
 
guidata(mpt,handles);

%%
function ZoomInOut(imagefig, varargins,h,zoomin) 

handles=guidata(findobj('Name','Muppet'));
ifig=get(gcf,'UserData');

usd=get(h,'UserData');
j=usd(2);

if strcmp(get(gca,'Tag'),'axis') && ~isempty(usd)
    if handles.Figure(ifig).Axis(usd(2)).AxesEqual
        AxesEqual=1;
    else
        AxesEqual=0;
    end
else
    return
end

xlim=get(h,'XLim');
ylim=get(h,'YLim');
xmin=xlim(1);
xmax=xlim(2);
ymin=ylim(1);
ymax=ylim(2);

pos=get(h,'Position');
asprat=pos(4)/pos(3);

leftmouse=strcmp(get(gcf,'SelectionType'),'normal');
rightmouse=strcmp(get(gcf,'SelectionType'),'alt');

if ~strcmp(handles.Figure(ifig).Axis(j).PlotType,'3d')
    if (leftmouse && zoomin==1) || (rightmouse && zoomin==0)
        point1 = get(h,'CurrentPoint');
        rect = rbbox;
        point2 = get(h,'CurrentPoint');
        if rect(3)==0
            xl=get(h,'xlim');
            yl=get(h,'ylim');
            point1=point1(1,1:2);
            p1(1)=point1(1)-((xl(2)-xl(1))/4);
            p1(2)=point1(2)-((yl(2)-yl(1))/4);
            offset(1)=((xl(2)-xl(1))/2);
            offset(2)=((yl(2)-yl(1))/2);
        else
            if AxesEqual
                point1 = point1(1,1:2);
                point2 = point2(1,1:2);
                p1 = min(point1,point2);
                offset = abs(point1-point2);
                if offset(2)/offset(1)>asprat
                    p1(1)=p1(1)+0.5*offset(1)-0.5*offset(2)/asprat;
                    offset(1)=offset(2)/asprat;
                else
                    p1(2)=(p1(2)+0.5*offset(2))-0.5*asprat*offset(1);
                    offset(2)=asprat*offset(1);
                end
            else
                point1=point1(1,1:2);
                point2=point2(1,1:2);
                p1 = min(point1,point2);
                p2 = max(point1,point2);
                offset=p2-p1;
            end
        end
    else
        point1 = get(h,'CurrentPoint');
        xl=get(h,'xlim');
        yl=get(h,'ylim');
        point1=point1(1,1:2);
        p1(1)=point1(1)-0.66667*((xl(2)-xl(1)));
        p1(2)=point1(2)-0.66667*((yl(2)-yl(1)));
        offset(1)=1.5*(xl(2)-xl(1));
        offset(2)=1.5*(yl(2)-yl(1));
    end
    set(h,'xlim',[p1(1) p1(1)+offset(1)]);
    set(h,'ylim',[p1(2) p1(2)+offset(2)]);
else
    if (leftmouse && zoomin==1) || (rightmouse && zoomin==0)
        fac=1.5;
    else
        fac=2/3;
    end
    camzoom(h,fac);
end

%%
function StartRotateView(imagefig, varargins,h) 

[az0,el0]=view(h);
Target0=get(h,'CameraTarget');
pos0=get(gcf,'CurrentPoint');
set(gcf, 'windowbuttonmotionfcn', {@RotateView,h,az0,el0,Target0,pos0});
set(gcf, 'windowbuttonupfcn', {@StopRotateView});

%%
function RotateView(imagefig, varargins,h,az0,el0,Target0,pos0) 

pos1=get(gcf,'CurrentPoint');
dpos=pos1-pos0;
az1=az0-dpos(1)/2.5;
el1=el0-dpos(2)/2.5;
view(h,[az1,el1]);
set(h,'CameraTarget',Target0);

%%
function StopRotateView(imagefig, varargins) 

set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
set(gcf, 'windowbuttonupfcn',[]);

%%
function StartPan2D(imagefig, varargins,h) 

pos0=get(h,'CurrentPoint');
pos0=pos0(1,1:2);
xl0=get(h,'XLim');
yl0=get(h,'YLim');
set(gcf, 'windowbuttonmotionfcn', {@Pan2D,h,xl0,yl0,pos0});
set(gcf, 'windowbuttonupfcn', {@StopPan});
setptr(gcf,'closedhand');

%%
function Pan2D(imagefig, varargins,h,xl0,yl0,pos0) 

xl1=get(h,'XLim');
yl1=get(h,'YLim');
pos1=get(h,'CurrentPoint');
pos1=pos1(1,1:2);
pos1(1)=xl0(1)+(xl0(2)-xl0(1))*(pos1(1)-xl1(1))/(xl1(2)-xl1(1));
pos1(2)=yl0(1)+(yl0(2)-yl0(1))*(pos1(2)-yl1(1))/(yl1(2)-yl1(1));
dpos=pos1-pos0;
xl=xl0-dpos(1);
yl=yl0-dpos(2);
set(h,'XLim',xl,'YLim',yl);

%%
function StartPan3D(imagefig, varargins,h) 

Target0=get(h,'CameraTarget');
[az,el]=view(h);
pos0=get(gcf,'CurrentPoint');
xl=get(h,'XLim');
yl=get(h,'YLim');
dx=xl(2)-xl(1);
dy=yl(2)-yl(1);
d=sqrt(dx^2+dy^2);
set(gcf, 'windowbuttonmotionfcn', {@Pan3D,h,pos0,Target0,d,az});
set(gcf, 'windowbuttonupfcn', {@StopPan});
setptr(gcf,'closedhand');

%%
function Pan3D(imagefig, varargins,h,pos0,Target0,d,az) 

pos1=get(gcf,'CurrentPoint');
dpos=pos1-pos0;
Target1(1)=Target0(1)+0.001*d*dpos(2)*sin(pi*az/180)-0.001*d*dpos(1)*cos(pi*az/180);
Target1(2)=Target0(2)-0.001*d*dpos(2)*cos(pi*az/180)-0.001*d*dpos(1)*sin(pi*az/180);
Target1(3)=Target0(3);
set(h,'CameraTarget',Target1);

%%
function StopPan(imagefig, varargins) 

set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
set(gcf, 'windowbuttonupfcn',[]);
setptr(gcf,'hand');

%%
function PanMove(imagefig, varargins)

handles=guidata(findobj('Name','Muppet'));
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
xmin=xlim(1);
xmax=xlim(2);
ymin=ylim(1);
ymax=ylim(2);

xl=get(gca,'xlim');
yl=get(gca,'ylim');

if xl(2)>xmax
    xl(1)=xmax-(xl(2)-xl(1));
    xl(2)=xmax;
    set(gca,'xlim',xl);
end
if xl(1)<xmin
    xl(2)=xmin+xl(2)-xl(1);
    xl(1)=xmin;
    set(gca,'xlim',xl);
end
if yl(2)>ymax
    yl(1)=ymax-(yl(2)-yl(1));
    yl(2)=ymax;
    set(gca,'ylim',yl);
end
if yl(1)<ymin
    yl(2)=ymin+yl(2)-yl(1);
    yl(1)=ymin;
    set(gca,'ylim',yl);
end

%%
function MoveMouse(imagefig, varargins)

handles=guidata(findobj('Name','Muppet'));
ifig=get(gcf,'UserData');

posgcf = get(gcf, 'CurrentPoint')/handles.Figure(ifig).cm2pix;

typ='none';

for j=1:handles.Figure(ifig).NrSubplots
    h0=findobj(gcf,'Tag','axis','UserData',[ifig,j]);
    if ~isempty(h0)
        pos=get(h0,'Position')/handles.Figure(ifig).cm2pix;
        if posgcf(1)>pos(1) && posgcf(1)<pos(1)+pos(3) && posgcf(2)>pos(2) && posgcf(2)<pos(2)+pos(4)
            typ=handles.Figure(ifig).Axis(j).PlotType;
            h=h0;
        end
    end
end

oktypes={'2d','3d','timeseries','xy','timestack'};
ii=strmatch(lower(typ),oktypes,'exact');

if isempty(ii)
    set(gcf,'Pointer','arrow');
    set(gcf,'WindowButtonDownFcn',[]);
    return
else
    switch(handles.Figure(ifig).Zoom),
        case{'zoomin'}
            set(gcf,'WindowButtonDownFcn',{@ZoomInOut,h,1});
            setptr(gcf,'glassplus');
        case{'zoomout'}
            set(gcf,'WindowButtonDownFcn',{@ZoomInOut,h,0});
            setptr(gcf,'glassminus');
        case{'pan'}
            if strcmp(typ,'3d')
                setptr(gcf,'hand');
                set(gcf,'WindowButtonDownFcn',{@StartPan3D,h});
            else
                setptr(gcf,'hand');
                set(gcf,'WindowButtonDownFcn',{@StartPan2D,h});
            end
        case{'rotate3d'}
            if strcmp(typ,'3d')
                setptr(gcf,'rotate');
                set(gcf,'WindowButtonDownFcn',{@StartRotateView,h});
            end
        otherwise
            set(gcf,'WindowButtonDownFcn',[]);
            setptr(gcf,'arrow');
    end
end
