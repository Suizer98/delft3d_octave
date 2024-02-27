function UIAddSubplot(varargin)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

SetPlotEdit(0);

set(gcf, 'windowbuttondownfcn', {@StartTrack});
set(gcf, 'windowbuttonupfcn', {@StopTrack});
set(gcf, 'Pointer', 'fullcrosshair');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function StartTrack(imagefig, varargins) 
set(gcf, 'Units', 'normalized');
set(gcf, 'windowbuttonmotionfcn', {@FollowTrack});

mouseclick=get(gcf,'SelectionType');

if strcmp(mouseclick,'normal')
    an=annotation('rectangle');
    set(an,'Tag','rectangle');
    usd.h=an;
    usd.x=[0.5 0.6];
    usd.y=[0.5 0.6];
    set(0,'UserData',usd);
    set(usd.h,'Visible','on');
    CurPnt = get(gcf, 'CurrentPoint');
    usd.x(1)=CurPnt(1);
    usd.x(2)=CurPnt(1);
    usd.y(1)=CurPnt(2);
    usd.y(2)=CurPnt(2);
    pos(1)=max(min(usd.x),0);
    pos(2)=max(min(usd.y),0);
    pos(3)=min(abs(usd.x(2)-usd.x(1)),1-pos(1))+1e-6;
    pos(4)=min(abs(usd.y(2)-usd.y(1)),1-pos(2))+1e-6;
    usd.Position=pos;
    set(usd.h,'Position',pos);
    set(0,'UserData',usd);
else
    set(gcf, 'Units', 'pixels');
    set(gcf, 'Pointer', 'arrow');
    set(gcf, 'windowbuttonupfcn', []);
    set(gcf, 'windowbuttondownfcn', []);
    set(gcf, 'windowbuttonmotionfcn', []);
end

function FollowTrack(imagefig, varargins) 
CurPnt = get(gcf, 'CurrentPoint');
usd=get(0,'UserData');
usd.x(2)=CurPnt(1);
usd.y(2)=CurPnt(2);
pos(1)=max(min(usd.x),0);
pos(2)=max(min(usd.y),0);
pos(3)=min(abs(usd.x(2)-usd.x(1)),1-pos(1))+1e-6;
pos(4)=min(abs(usd.y(2)-usd.y(1)),1-pos(2))+1e-6;
usd.Position=pos;
set(usd.h,'Position',pos);
set(0,'UserData',usd);
drawnow;

function StopTrack(imagefig, varargins)
set(gcf, 'Pointer', 'arrow');
set(gcf, 'Units', 'pixels');
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', []);

mpt=findobj('Name','Muppet');
data=guidata(mpt);
usd=get(0,'userdata');
pos=usd.Position;
delete(usd.h);
ifig=get(gcf,'UserData');
i0=data.Figure(ifig).NrSubplots;
pos(1)=pos(1)*data.Figure(ifig).PaperSize(1);
pos(2)=pos(2)*data.Figure(ifig).PaperSize(2);
pos(3)=pos(3)*data.Figure(ifig).PaperSize(1);
pos(4)=pos(4)*data.Figure(ifig).PaperSize(2);
pos=round(100*pos)/100;
data.Pos=pos;
data.AddSubplotAnnotations=0;
data=AddSubplot(data);
i1=data.Figure(ifig).NrSubplots;
if i1>i0
    figure(data.Figure(ifig).Handle);
    isub=data.ActiveSubplot;
    ax=axes;
    SetUnknownPlot(data.Figure(ifig),data.Figure(ifig).Axis(isub));
    set(ax,'Tag','axis','UserData',[ifig,isub]);
end
guidata(mpt,data);
SetPlotEdit(1);
set(gcf,'CurrentObject',ax);
SelectAxis;
set(0,'UserData',[]);



