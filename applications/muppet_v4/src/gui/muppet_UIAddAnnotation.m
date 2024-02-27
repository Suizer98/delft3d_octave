function muppet_UIAddAnnotation(usd)

h=usd.h;
typ=get(h,'Tag');

fig=getappdata(gcf,'figure');

fig.changed=1;
fig.annotationschanged=1;

ifig=fig.number;
j=fig.nrannotations+1;

if fig.nrannotations==0
    % New Annotation Layer
    fig.nrsubplots=fig.nrsubplots+1;
    isub=fig.nrsubplots;
    fig.subplots(isub).subplot.name='Annotations';
    fig.subplots(isub).subplot.type='annotation';
    fig.subplots(isub).subplot.position=[0 0 0 0];
    fig.subplots(isub).subplot.limitschanged=0;
    fig.subplots(isub).subplot.positionchanged=0;
    fig.subplots(isub).subplot=muppet_setDefaultAxisProperties(fig.subplots(isub).subplot);
end

isub=fig.nrsubplots;
fig.nrannotations=j;
fig.subplots(isub).subplot.nrdatasets=j;

usd.x=usd.x*fig.width;
usd.y=usd.y*fig.height;

switch(lower(typ))
    case{'arrow','double arrow','single line'}
    otherwise
        x1=min(usd.x);
        x2=max(usd.x);
        y1=min(usd.y);
        y2=max(usd.y);
        usd.x=[x1 x2];
        usd.y=[y1 y2];
end

fig.subplots(isub).subplot.datasets(j).dataset=muppet_setDefaultAnnotationOptions;
fig.subplots(isub).subplot.datasets(j).dataset.name=[typ ' ' num2str(j)];
fig.subplots(isub).subplot.datasets(j).dataset.type='annotation';
fig.subplots(isub).subplot.datasets(j).dataset.plotroutine=typ;
fig.subplots(isub).subplot.datasets(j).dataset.style=typ;
fig.subplots(isub).subplot.datasets(j).dataset.position=[usd.x(1) usd.y(1) usd.x(2)-usd.x(1) usd.y(2)-usd.y(1)];
if strcmpi(typ,'text box')
    fig.subplots(isub).subplot.datasets(j).dataset.string='Textbox';
    fig.subplots(isub).subplot.datasets(j).dataset.box=1;
end
switch(lower(typ))
    case{'arrow','double arrow'}
        fig.subplots(isub).subplot.datasets(j).dataset.linewidth=1;
    otherwise
        fig.subplots(isub).subplot.datasets(j).dataset.linewidth=0.5;
end

set(h,'Tag','annotation','UserData',[ifig j]);

h=muppet_addAnnotation(fig,ifig,isub,j);

fig.subplots(isub).subplot.nrdatasets=j;

set(0,'userdata',[]);

muppet_setPlotEdit(1);

set(gcf,'CurrentObject',h);

muppet_selectAxis;

setappdata(gcf,'figure',fig);
