function muppet_setTimeStackPlot(handles,ifig,isub)

plt=handles.figures(ifig).figure.subplots(isub).subplot;
fontred=handles.figures(ifig).figure.fontreduction;
cm2pix=handles.figures(ifig).figure.cm2pix;
units=handles.figures(ifig).figure.units;

xmin = datenum(plt.yearmin,plt.monthmin,plt.daymin,plt.hourmin,plt.minutemin,plt.secondmin);
xmax = datenum(plt.yearmax,plt.monthmax,plt.daymax,plt.hourmax,plt.minutemax,plt.secondmax);

xtick = plt.yeartick*365;
xtick = xtick + plt.monthtick*30;
xtick = xtick + plt.daytick;
xtick = xtick + plt.hourtick/24;
xtick = xtick + plt.minutetick/1440;
xtick = xtick + plt.secondtick/86400;

if strcmpi(handles.figures(ifig).figure.renderer,'opengl');
    xback=xmin;
    xmin=xmin-xback;
    xmax=xmax-xback;
else
    xback=0;
end

ylim(1)=plt.ymin; ylim(2)=plt.ymax;

view(2);

multi=1;

set(gca,'Xlim',[xmin xmax],'YLim',multi*ylim);

if plt.drawbox
    
    if xtick>0.0
        if plt.monthtick==0
            xticks=floor(xmin):xtick:ceil(xmax)+2*xtick;
        else
            nm=12*(plt.yearmax-plt.yearmin)+plt.monthmax-plt.monthmin+1;
            for j=1:ceil(nm/plt.monthtick)+1;
                xticks(j)=datenum(plt.yearmin,plt.monthmin+(j-1)*plt.monthtick,1,0,0,0);
                xticks=xticks-xback;
            end
        end
        if plt.yeartick>0
            [y0,m0,d0,h0,mi0,s0]=datevec(floor(xmin));
            [y1,m0,d0,h0,mi0,s0]=datevec(ceil(xmax));
            yt=[y0:plt.yeartick:y1];
            mt=zeros(size(yt))+1;
            dt=mt;
            ht=zeros(size(yt));
            mit=ht;
            st=ht;
            xticks=datenum(yt,mt,dt,ht,mit,st);
        end
%        xlabls=datestr(xticks,char(plt.dateformat));
        xlabls=datestr(xticks,plt.datetickformat);
        set(gca,'xtick',xticks,'xticklabel',xlabls,'FontSize',8*fontred);
    else
        tick(gca,'x','none');
    end

    if plt.adddate
        sz=size(xticks,2);
        scl=(plt.ymax-plt.ymin)/plt.position(4);
        ytxt=plt.ymin-0.6*scl;
        for i=1:sz
            if xticks(i)==round(xticks(i)) && xticks(i)<=xmax;
                datetxt(i)=text(xticks(i),ytxt,datestr(xticks(i),26));
                set(datetxt(i),'FontSize',8*fontred,'HorizontalAlignment','center');
            end
        end
    end

    if plt.ytick~=-999.0
        ytickstart=plt.ytick*floor(ylim(1)/plt.ytick);
        ytickstop=plt.ytick*ceil(ylim(2)/plt.ytick);
        ytick=ytickstart:plt.ytick:ytickstop;
        ytick=multi*ytick;
        set(gca,'ytick',ytick,'FontSize',10*fontred);

        if plt.ydecimals>=0
            frmt=['%0.' num2str(plt.ydecimals) 'f'];
            for i=1:size(ytick,2)
                val=plt.ytickmultiply*ytick(i)/multi+plt.ytickadd;
                ylabls{i}=sprintf(frmt,val);
            end
            set(gca,'yticklabel',ylabls);
        elseif plt.ydecimals==-1 && multi~=1
            frmt=['%0.' num2str(2) 'f'];
            for i=1:size(ytick,2)
                val=plt.ytickmultiply*ytick(i)/multi+plt.ytickadd;
                ylabls{i}=sprintf(frmt,val);
            end
            set(gca,'yticklabel',ylabls);
        elseif plt.ydecimals==-999
            for i=1:size(ytick,2)
                ylabls{i}='';
            end
            set(gca,'yticklabel',ylabls);
        elseif plt.ydecimals==-1 && (plt.ytickmultiply~=1 || plt.ytickadd~=0)
            for i=1:size(ytick,2)
                val=plt.ytickmultiply*ytick(i)/multi+plt.ytickadd;
                ylabls{i}=sprintf('%0.5g',val);
            end
            set(gca,'yticklabel',ylabls);
        end

        if plt.ygrid
            set(gca,'Ygrid','on');
        else
            set(gca,'Ygrid','off');
        end
    else
        tick(gca,'y','none');
    end
    box on;
else
    axis off;
    box off;
end

set(gca,'FontName',plt.font.name);
set(gca,'FontSize',plt.font.size*fontred);
set(gca,'FontAngle',plt.font.angle);
set(gca,'FontWeight',plt.font.weight);
set(gca,'XColor',colorlist('getrgb','color',plt.font.color));
set(gca,'YColor',colorlist('getrgb','color',plt.font.color));
set(gca,'Units',units);
set(gca,'Position',plt.position*cm2pix);
set(gca,'Layer','top');

zoom v6 on;

