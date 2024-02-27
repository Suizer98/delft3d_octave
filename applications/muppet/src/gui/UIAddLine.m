function UIAddLine(varargin)

mpt=findobj('Name','Muppet');
data=guidata(mpt);

SetPlotEdit(0);

set(gcf, 'windowbuttondownfcn', {@starttrack});
set(gcf, 'windowbuttonupfcn', {@stoptrack});
set(gcf, 'Pointer', 'crosshair');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function starttrack(imagefig, varargins) 
set(gcf, 'Units', 'normalized');
set(gcf, 'Pointer', 'crosshair');
set(gcf, 'windowbuttonmotionfcn', {@followtrack});

an=annotation('line');
set(an,'Tag','line');

usd.h=an;
usd.x=[0.5 0.6];
usd.y=[0.5 0.6];

AnnOpt.Box=0;
AnnOpt.LineColor='black';
AnnOpt.BackgroundColor='white';
AnnOpt.FontColor='black';

set(usd.h,'UserData',AnnOpt);

set(0,'UserData',usd);

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

function stoptrack(imagefig, varargins)
set(gcf, 'Pointer', 'arrow');
set(gcf, 'Units', 'pixels');
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', []);

usd=get(0,'userdata');
UIAddAnnotation(usd);
set(0,'UserData',[]);

