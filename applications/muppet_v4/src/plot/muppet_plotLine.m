function h1=muppet_plotLine(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

switch lower(plt.xscale),
    case{'linear','logarithmic'}
        x=data.x;
    case{'normprob'}
        x=norminv(0.01*data.x,0,1);
end

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

switch lower(plt.yscale),
    case{'linear','logarithmic'}
        y=data.y;
    case{'normprob'}
        y=norminv(0.01*data.y,0,1);
end
% % if k==2
% %     opt.rightaxis=1;
% % end
% if opt.rightaxis
%     a=(y-plt.yminright)/(plt.ymaxright-plt.yminright);
%     y=plt.ymin+a*(plt.ymax-plt.ymin);
% end

switch lower(opt.plotroutine)
    case{'spline'}
        
        dx=(xmax-xmin)/1000;
        xx=xmin:dx:xmax;
        tmp0(:,1)=x;
        tmp0(:,2)=y;
        [dum,ord]=sort(x,1);
        for ii=1:size(x,1);
            x(ii)=tmp0(ord(ii),1);
            y(ii)=tmp0(ord(ii),2);
        end
        
        kk=1;
        x1(1)=x(1);
        y1(1)=y(1);
        for ii=2:size(x,1)
            if x(ii)>x1(kk)
                kk=kk+1;
                x1(kk)=x(ii);
                y1(kk)=y(ii);
            end
        end
        
        yy = interp1(x1,y1,xx,'pchip');
        h1=plot(xx,yy);
        h2=[];
        if strcmpi(opt.marker,'none')==0
            h2=plot(x,y);
        end
    case{'line'}
        try
        h1=plot(x,y);
        catch
            h1=plot([0 0],[0 0]);
        end
    case{'area below line'}
        np=length(x);
        x=[x;flipud(x)];
        y=[y;zeros(np,1)+plt.ymin];
        x(isnan(y))=NaN;
        y(isnan(x))=NaN;
        x=x(~isnan(x));
        y=y(~isnan(y));        
        h1=patch(x,y,'r');
end
    
switch lower(opt.plotroutine)
    case{'spline'}
        if ~isempty(h1)>0
            set(h1,'color',colorlist('getrgb','color',opt.linecolor));
            set(h1,'Linestyle',opt.linestyle);
            set(h1,'Linewidth',opt.linewidth);
        end
        if ~isempty(h2)>0
            set(h2,'color',colorlist('getrgb','color',opt.linecolor));
            set(h2,'Linestyle','none');
            set(h1,'Marker',opt.marker,'MarkerSize',opt.markersize, ...
                'MarkerFaceColor',colorlist('getrgb','color',opt.markerfacecolor),'MarkerEdgeColor',colorlist('getrgb','color',opt.markeredgecolor));
        end
    case{'line'}
        set(h1,'color',colorlist('getrgb','color',opt.linecolor));
        set(h1,'Linestyle',opt.linestyle);
        set(h1,'Linewidth',opt.linewidth);
        set(h1,'Marker',opt.marker,'MarkerSize',opt.markersize, ...
            'MarkerFaceColor',colorlist('getrgb','color',opt.markerfacecolor),'MarkerEdgeColor',colorlist('getrgb','color',opt.markeredgecolor));

    case{'area below line'}
        set(h1,'facecolor',colorlist('getrgb','color',opt.facecolor));
        set(h1,'Linestyle',opt.linestyle);
        set(h1,'Linewidth',opt.linewidth);
        set(h1,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
end

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
    case{'marker'}
        xt=opt.timebar.time-xback;
        yt=interp1(x,y,xt);
        p=plot(xt,yt,'o');
        set(p,'Marker',opt.timebar.marker);
        set(p,'MarkerSize',opt.timebar.markersize);
        set(p,'MarkerFaceColor',colorlist('getrgb','color',opt.timebar.markerfacecolor));
        set(p,'MarkerEdgeColor',colorlist('getrgb','color',opt.timebar.markeredgecolor));
end

%text2line(h1,0.8,0.05,'\ksi_s = 0.01');
