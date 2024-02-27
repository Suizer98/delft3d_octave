function muppet_UIAddLine(varargin)

muppet_setPlotEdit(0);

set(gcf, 'windowbuttondownfcn', {@starttrack});
set(gcf, 'windowbuttonupfcn', {@stoptrack});
set(gcf, 'Pointer', 'crosshair');

%%
function starttrack(imagefig, varargins) 
set(gcf, 'Units', 'normalized');
set(gcf, 'Pointer', 'crosshair');

an=annotation('line');
set(an,'Tag','Single Line');

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
usd.x=max(usd.x,0);
usd.x=min(usd.x,1);
usd.y=max(usd.y,0);
usd.y=min(usd.y,1);
set(usd.h,'X',usd.x);
set(usd.h,'Y',usd.y);
set(0,'UserData',usd);

set(gcf, 'windowbuttonmotionfcn', {@followtrack});

%%
function followtrack(imagefig, varargins) 
CurPnt = get(gcf, 'CurrentPoint');
usd=get(0,'UserData');
usd.x(2)=CurPnt(1);
usd.y(2)=CurPnt(2);
set(usd.h,'X',usd.x);
set(usd.h,'Y',usd.y);
usd.x=max(usd.x,0);
usd.x=min(usd.x,1);
usd.y=max(usd.y,0);
usd.y=min(usd.y,1);
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

