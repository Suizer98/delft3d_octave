function h1=muppet_plotTimeSeriesBars(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

x=data.x;

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

y=data.y;

for ii=1:length(x)-1    
    if y(ii)>0
        xx=[x(ii) x(ii+1) x(ii+1) x(ii)];
        yy=[plt.ymin plt.ymin plt.ymax plt.ymax];
        h1=patch(xx,yy,'r');
%        h1=fill(xx,yy,'r');
        set(h1,'facecolor',colorlist('getrgb','color',opt.facecolor));
        set(h1,'Linestyle',opt.linestyle);
        set(h1,'Linewidth',opt.linewidth);
        set(h1,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
    end
end
