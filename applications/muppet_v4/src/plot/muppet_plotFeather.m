function h1=muppet_plotFeather(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

if strcmpi(plt.type,'timeseries')
    xmin = datenum(plt.yearmin,plt.monthmin,plt.daymin,plt.hourmin,plt.minutemin,plt.secondmin);
    xmax = datenum(plt.yearmax,plt.monthmax,plt.daymax,plt.hourmax,plt.minutemax,plt.secondmax);
    if strcmpi(handles.figures(i).figure.renderer,'opengl');
        xback=xmin;
        xmin=xmin-xback;
        xmax=xmax-xback;
        x=x-xback;
    else
        xback=0;
    end
else
    xmin=plt.xmin;
    xmax=plt.xmax;
    xback=0;
end
    
scalex=(xmax-xmin)/plt.position(3);
scaley=(plt.ymax-plt.ymin)/plt.position(4);
rat=scalex/scaley;
f=1;
for ii=1:opt.thinning:length(data.x)
    x=[data.x(ii) data.x(ii)+data.u(ii)*f*rat];
    y=[0 data.v(ii)*f];
    h1=line(x,y);
    set(h1,'color',colorlist('getrgb','color',opt.linecolor));
    set(h1,'Linestyle',opt.linestyle);
    set(h1,'Linewidth',opt.linewidth);
    hold on;
end

set(h1,'color',colorlist('getrgb','color',opt.linecolor));
set(h1,'Linestyle',opt.linestyle);
set(h1,'Linewidth',opt.linewidth);

switch opt.timebar.type
    case{'line'}
        xt(1)=opt.timebar.time-xback;
        xt(2)=opt.timebar.time-xback;
        yt(1)=plt.ymin;
        yt(2)=plt.ymax;
        p=plot(xt,yt);
        set(p,'Linewidth',opt.timebar.linewidth);
        set(p,'LineStyle',opt.timebar.linestyle);
        set(p,'Color',colorlist('getrgb','color',opt.timebar.linecolor));
end
