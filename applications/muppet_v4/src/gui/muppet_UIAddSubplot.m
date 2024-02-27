function muppet_UIAddSubplot(varargin)

muppet_setPlotEdit(0);

set(gcf, 'windowbuttondownfcn', {@startTrack});
set(gcf, 'windowbuttonupfcn', {@stopTrack});
set(gcf, 'Pointer', 'fullcrosshair');

%%
function startTrack(imagefig, varargins) 

set(gcf, 'Units', 'normalized');
set(gcf, 'windowbuttonmotionfcn', {@followTrack});

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

%%
function followTrack(imagefig, varargins) 
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

%%
function stopTrack(imagefig, varargins)
set(gcf, 'Pointer', 'arrow');
set(gcf, 'Units', 'pixels');
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', []);

fig=getappdata(gcf,'figure');
fig.changed=1;

usd=get(0,'userdata');
pos=usd.Position;
delete(usd.h);
ifig=get(gcf,'UserData');
pos(1)=pos(1)*fig.width;
pos(2)=pos(2)*fig.height;
pos(3)=pos(3)*fig.width;
pos(4)=pos(4)*fig.height;
pos=round(100*pos)/100;

s.name=['Subplot ' num2str(fig.nrsubplots+1)];
s.position=pos;
hh=getHandles;
[s,ok]=gui_newWindow(s,'xmldir',hh.xmlguidir,'xmlfile','newsubplot.xml', ...
                     'iconfile',[hh.settingsdir 'icons' filesep 'deltares.gif']);
if ok
    fig.nrsubplots=fig.nrsubplots+1;
    fig.subplots(fig.nrsubplots).subplot.name=s.name;
    fig.subplots(fig.nrsubplots).subplot.position=s.position;
    fig.subplots(fig.nrsubplots).subplot.type='unknown';
    fig.subplots(fig.nrsubplots).subplot.limitschanged=0;
    fig.subplots(fig.nrsubplots).subplot.positionchanged=0;
    fig.subplots(fig.nrsubplots).subplot.annotationsadded=0;
    fig.subplots(fig.nrsubplots).subplot.annotationschanged=0;
    fig.subplots(fig.nrsubplots).subplot=muppet_setDefaultAxisProperties(fig.subplots(fig.nrsubplots).subplot);
    setappdata(gcf,'figure',fig);
    isub=fig.nrsubplots;
    ax=axes;
    muppet_setUnknownPlot(fig,isub);
    set(ax,'Tag','axis','UserData',[ifig,isub]);    
    muppet_setPlotEdit(1);
    set(gcf,'CurrentObject',ax);
    muppet_selectAxis;
end
set(0,'UserData',[]);
