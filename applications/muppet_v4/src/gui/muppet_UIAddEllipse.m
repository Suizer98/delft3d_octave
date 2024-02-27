function muppet_UIAddEllipse(varargin)

muppet_setPlotEdit(0);

set(gcf, 'windowbuttondownfcn', {@starttrack});
set(gcf, 'windowbuttonupfcn', {@stoptrack});
set(gcf, 'Pointer', 'crosshair');

%%
function starttrack(imagefig, varargins) 
set(gcf, 'Units', 'normalized');
set(gcf, 'Pointer', 'crosshair');

an=annotation('ellipse');
set(an,'Tag','Ellipse');

usd.h=an;
usd.x=[0.5 0.6];
usd.y=[0.5 0.6];

AnnOpt.Box=0;
AnnOpt.LineColor='black';
AnnOpt.BackgroundColor='white';
AnnOpt.FontColor='black';
set(usd.h,'UserData',AnnOpt);

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
set(usd.h,'Position',pos);
set(0,'UserData',usd);

set(gcf, 'windowbuttonmotionfcn', {@followtrack});

%%
function followtrack(imagefig, varargins) 
CurPnt = get(gcf, 'CurrentPoint');
usd=get(0,'UserData');
usd.x(2)=CurPnt(1);
usd.y(2)=CurPnt(2);
pos(1)=max(min(usd.x),0);
pos(2)=max(min(usd.y),0);
pos(3)=min(abs(usd.x(2)-usd.x(1)),1-pos(1))+1e-6;
pos(4)=min(abs(usd.y(2)-usd.y(1)),1-pos(2))+1e-6;
set(usd.h,'Position',pos);
set(0,'UserData',usd);
drawnow;

%%
function stoptrack(imagefig, varargins)
set(gcf, 'Pointer', 'arrow');
set(gcf, 'Units', 'pixels');
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', []);

usd=get(0,'userdata');
muppet_UIAddAnnotation(usd);
set(0,'UserData',[]);

