function muppet_changeInteractivePolygon(h,x,y,nr)

options=getappdata(h,'options');
isub=options.userdata(2);
nrd=options.userdata(3);
fig=getappdata(gcf,'figure');
fig.changed=1;

fig.subplots(isub).subplot.annotationschanged=1;

fig.subplots(isub).subplot.datasets(nrd).dataset.x=x;
fig.subplots(isub).subplot.datasets(nrd).dataset.y=y;

setappdata(gcf,'figure',fig);
