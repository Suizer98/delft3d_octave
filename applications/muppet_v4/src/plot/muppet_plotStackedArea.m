function htmp=muppet_plotStackedArea(handles,i,j,k)

fig=handles.figures(i).figure;
plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

if opt.areanr==1
    if strcmpi(plt.type,'timeseries') && strcmpi(fig.renderer,'opengl');
        xback = datenum(plt.yearmin,plt.monthmin,plt.daymin,plt.hourmin,plt.minutemin,plt.secondmin);
    else
        xback=0;
    end
    x=data.x-xback;
    h=area(x,plt.stackedareay);hold on;
    h2=area(x,plt.stackedareayneg);hold on;
    set(h,'Tag','stackedarea');
end

ii=opt.areanr;
hh=sort(findobj(gca,'Tag','stackedarea'));
set(hh(ii),'FaceColor',colorlist('getrgb','color',opt.facecolor),'EdgeColor',colorlist('getrgb','color',opt.linecolor));
set(hh(ii),'LineStyle',opt.linestyle);
set(hh(ii),'LineWidth',opt.linewidth);

% Invisible patch object for legend
x00=[0 1 1];y00=[0 0 1];
htmp=patch(x00,y00,'k');
set(htmp,'FaceColor',colorlist('getrgb','color',opt.facecolor));
set(htmp,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
set(htmp,'LineStyle',opt.linestyle);
set(htmp,'LineWidth',opt.linewidth);
set(htmp,'Visible','off');
