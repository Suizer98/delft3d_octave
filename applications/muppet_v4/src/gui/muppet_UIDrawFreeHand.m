function muppet_UIDrawFreeHand(varargin)

muppet_setPlotEdit(0);
plotedit off;

fig=getappdata(gcf,'figure');
ifig=fig.number;

n=0;
for j=1:fig.nrsubplots
    if strcmpi(fig.subplots(j).subplot.type,'map')
        n=n+1;
        h(n)=findobj(gcf,'Tag','axis','UserData',[ifig,j]);
    end
end

opt=muppet_setDefaultPlotOptions;

opt.markersize=4;
opt.fillclosedpolygons=0;
opt.fillcolor='red';

if opt.fillclosedpolygons
    facecolor=colorlist('getrgb','color',opt.fillcolor);
else
    facecolor='none';
end

switch varargin{3}
    case 1
        tp='polyline';
    case 2
        tp='spline';
    case 3
        tp='curvedarrow';
end

if n>0
    gui_polyline('draw','tag','interactivepolyline','marker','o', ...
        'createcallback',@createPolygon, ...
        'changecallback',@muppet_changeInteractivePolygon,'axis',h, ...
        'markersize',opt.markersize,'markeredgecolor',colorlist('getrgb','color',opt.markeredgecolor), ...
        'markerfacecolor',colorlist('getrgb','color',opt.markerfacecolor), ...
        'linewidth',opt.linewidth,'linecolor',colorlist('getrgb','color',opt.linecolor),'linestyle',opt.linestyle, ...
        'facecolor',facecolor, ...
        'arrowthickness',opt.arrowthickness,'headthickness',opt.headthickness,'headlength',opt.headlength, ...
        'type',tp,'closed',0);
end


%%
function createPolygon(h,x,y,nr)

fig=getappdata(gcf,'figure');
ifig=fig.number;

options=getappdata(h,'options');

% Find subplot number
hax=getappdata(h,'axis');
hh=get(hax,'UserData');
isub=hh(2);

plt=fig.subplots(isub).subplot;

plt.annotationsadded=1;

plt.nrdatasets=plt.nrdatasets+1;
nrd=plt.nrdatasets;
opt=muppet_setDefaultPlotOptions;

opt.markersize=4;
opt.fillclosedpolygons=0;
opt.fillcolor='red';
opt.type='interactivepolyline';
opt.plotroutine='interactive polyline';
opt.polylinetype=options.type;

if strcmpi(plt.coordinatesystem.type,'geographic')
    switch plt.projection
        case{'mercator'}
            y=invmerc(y);
        case{'albers'}
            [x,y]=albers(x,y,plt.labda0,plt.phi0,plt.phi1,plt.phi2,'inverse');
    end
end

opt.x=x;
opt.y=y;
opt.coordinatesystem.name='unspecified';
opt.coordinatesystem.type='unspecified';

plt.datasets(nrd).dataset=opt;

fig.subplots(isub).subplot=plt;

usd=[ifig,isub,nrd];
options.userdata=usd;
setappdata(h,'options',options);

fig.changed=1;

setappdata(gcf,'figure',fig);
