function h=muppet_plotHistogram(handles,i,j,k)

fig=handles.figures(i).figure;
plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

if opt.barnr==1
    if strcmpi(plt.type,'timeseries') && strcmpi(fig.renderer,'opengl');
        xback = datenum(plt.yearmin,plt.monthmin,plt.daymin,plt.hourmin,plt.minutemin,plt.secondmin);
    else
        xback=0;
    end
    x=data.x-xback;
    h=bar(x,plt.bary,'group');hold on;
    set(h,'Tag','bar');
end

ii=opt.barnr;
hh=sort(findobj(gca,'Tag','bar'));
set(hh(ii),'FaceColor',colorlist('getrgb','color',opt.facecolor),'EdgeColor',colorlist('getrgb','color',opt.linecolor));
set(hh(ii),'LineStyle',opt.linestyle);
set(hh(ii),'LineWidth',opt.linewidth);

% Invisible patch object for legend
x00=[0 1 1];y00=[0 0 1];
h=patch(x00,y00,'k');
set(h,'FaceColor',colorlist('getrgb','color',opt.facecolor));
set(h,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
set(h,'LineStyle',opt.linestyle);
set(h,'LineWidth',opt.linewidth);
set(h,'Visible','off');
