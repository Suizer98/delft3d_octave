function h=muppet_plotStatsText(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

x=data.x;
y=data.y;

rmse=rms(y-x);
stdev=std(x,y);
cc=corrcoef(x,y);
r2=cc(2,1)^2;
bias=mean(y-x);

opt.statstext.trendline.include=1;

ntxt=0;
if opt.statstext.rmse.include
    ntxt=ntxt+1;
end
if opt.statstext.r2.include
    ntxt=ntxt+1;
end
if opt.statstext.stdev.include
    ntxt=ntxt+1;
end
if opt.statstext.bias.include
    ntxt=ntxt+1;
end
if opt.statstext.trendline.include
    ntxt=ntxt+1;
end

pos=plt.position;
x0=plt.xmin;
x1=plt.xmax;
y0=plt.ymin;
y1=plt.ymax;
dx=x1-x0;
dy=y1-y0;
szx=pos(3);
szy=pos(4);
dxb=(0.1/szx)*dx; % distance from border
dyb=(0.2/szy)*dy; % distance from border
%dxx=(0.2/szx)*dx; % distance from border
dyy=(0.4/szy)*dy; % distance from border

% txt positions
switch opt.statstext.position
    case{'upper-left'}
        xt=x0+dxb;
        for it=1:ntxt
            yt(it)=y1-dyb-(it-1)*dyy;
        end
        horal='left';
    case{'upper-right'}
        xt=x1-dxb;
        for it=1:ntxt
            yt(it)=y1-dyb-(it-1)*dyy;
        end
        horal='right';
    case{'lower-left'}
        xt=x0+dxb;
        for it=1:ntxt
            yt(it)=y0+dyb+(ntxt-1)*dyy-(it-1)*dyy;
        end
        horal='left';
    case{'lower-right'}
        xt=x1-dxb;
        for it=1:ntxt
            yt(it)=y0+dyb+(ntxt-1)*dyy-(it-1)*dyy;
        end
        horal='right';
end
        
ntxt=0;
if opt.statstext.r2.include
    ntxt=ntxt+1;
    str=['R^2 : ' num2str(r2,['%0.' num2str(opt.statstext.r2.nrdecimals) 'f'] )];
    h(ntxt)=text(xt,yt(ntxt),str);
    set(h(ntxt),'HorizontalAlignment',horal);
    set(h(ntxt),'FontName',opt.statstext.font.name);
    set(h(ntxt),'FontWeight',opt.statstext.font.weight);
    set(h(ntxt),'FontAngle',opt.statstext.font.angle);
    set(h(ntxt),'FontSize',opt.statstext.font.size*handles.figures(i).figure.fontreduction)
    set(h(ntxt),'Color',colorlist('getrgb','color',opt.statstext.font.color));
end
if opt.statstext.rmse.include
    ntxt=ntxt+1;
    str=['RMSE : ' num2str(rmse,['%0.' num2str(opt.statstext.rmse.nrdecimals) 'f'] )];
    h(ntxt)=text(xt,yt(ntxt),str);
    set(h(ntxt),'HorizontalAlignment',horal);
    set(h(ntxt),'FontName',opt.statstext.font.name);
    set(h(ntxt),'FontWeight',opt.statstext.font.weight);
    set(h(ntxt),'FontAngle',opt.statstext.font.angle);
    set(h(ntxt),'FontSize',opt.statstext.font.size*handles.figures(i).figure.fontreduction)
    set(h(ntxt),'Color',colorlist('getrgb','color',opt.statstext.font.color));
end
if opt.statstext.bias.include
    ntxt=ntxt+1;
    str=['Bias : ' num2str(bias,['%0.' num2str(opt.statstext.bias.nrdecimals) 'f'] )];
    h(ntxt)=text(xt,yt(ntxt),str);
    set(h(ntxt),'HorizontalAlignment',horal);
    set(h(ntxt),'FontName',opt.statstext.font.name);
    set(h(ntxt),'FontWeight',opt.statstext.font.weight);
    set(h(ntxt),'FontAngle',opt.statstext.font.angle);
    set(h(ntxt),'FontSize',opt.statstext.font.size*handles.figures(i).figure.fontreduction)
    set(h(ntxt),'Color',colorlist('getrgb','color',opt.statstext.font.color));
end
if opt.statstext.stdev.include
    ntxt=ntxt+1;
    str=['StDev : ' num2str(stdev,['%0.' num2str(opt.statstext.stdev.nrdecimals) 'f'] )];
    h(ntxt)=text(xt,yt(ntxt),str);
    set(h(ntxt),'HorizontalAlignment',horal);
    set(h(ntxt),'FontName',opt.statstext.font.name);
    set(h(ntxt),'FontWeight',opt.statstext.font.weight);
    set(h(ntxt),'FontAngle',opt.statstext.font.angle);
    set(h(ntxt),'FontSize',opt.statstext.font.size*handles.figures(i).figure.fontreduction)
    set(h(ntxt),'Color',colorlist('getrgb','color',opt.statstext.font.color));
end
opt.statstext.trendline.include=1;
if opt.statstext.trendline.include
    ppp=polyfitZero(x,y,1);
    xxx=[plt.xmin plt.xmax];
    yyy=xxx*ppp(1);
    plot(xxx,yyy,'k:');
    ntxt=ntxt+1;
    str=['y = ' num2str(ppp(1),'%0.3f') ' x'];
    h(ntxt)=text(xt,yt(ntxt),str);
    set(h(ntxt),'HorizontalAlignment',horal);
    set(h(ntxt),'FontName',opt.statstext.font.name);
    set(h(ntxt),'FontWeight',opt.statstext.font.weight);
    set(h(ntxt),'FontAngle',opt.statstext.font.angle);
    set(h(ntxt),'FontSize',opt.statstext.font.size*handles.figures(i).figure.fontreduction)
    set(h(ntxt),'Color',colorlist('getrgb','color',opt.statstext.font.color));
end

% if opt.statstext.unity.include
    xxx=[plt.xmin plt.xmax];
    yyy=[plt.ymin plt.ymax];
    plot(xxx,yyy,'k--');
% end


