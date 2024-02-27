function muppet_setTimeSeriesPlot(handles,ifig,isub)

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

set(gca,'Xlim',[xmin xmax],'yLim',[plt.ymin plt.ymax]);

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
    if ~strcmpi(plt.datetickformat,'none')
        xlabls=datestr(xticks+xback,plt.datetickformat);
    else
        for jj=1:length(xticks)
            xlabls{jj}='';
        end        
    end
    set(gca,'xtick',xticks,'xticklabel',xlabls,'FontSize',8*fontred);
else
    tick(gca,'x','none');
end

if plt.adddate
    sz=size(xticks,2);
    scl=(plt.ymax-plt.ymin)/plt.position(4);
    ytxt=plt.ymin-0.6*scl;

    if xmax-xmin<365
        % Dates
        for i=1:sz
            if xticks(i)==round(xticks(i)) && xticks(i)<=xmax && xticks(i)>=xmin;
                datetxt(i)=text(xticks(i),ytxt,datestr(xticks(i),26));
                set(datetxt(i),'FontSize',plt.font.size*fontred,'HorizontalAlignment','center');
            end
        end
    else
        % Years
        for i=1:sz
            dv=datevec(xticks(i));
            if dv(2)==1 && dv(3)==1 && xticks(i)<=xmax && xticks(i)>=xmin;
                datetxt(i)=text(xticks(i),ytxt,datestr(xticks(i),10));
                set(datetxt(i),'FontSize',plt.font.size*fontred,'HorizontalAlignment','center');
            end
        end
    end
    
end

switch plt.yscale,

    case{'linear'}
        if plt.ytick>0
            yticks=[plt.ymin:plt.ytick:plt.ymax];
            set(gca,'ytick',yticks);

            if plt.ydecimals>=0
                frmt=['%0.' num2str(plt.ydecimals) 'f'];
                for i=1:size(yticks,2)
                    val=plt.ytickmultiply*yticks(i)+plt.ytickadd;
                    ylabls{i}=sprintf(frmt,val);
                end
                set(gca,'yticklabel',ylabls,'FontSize',8*fontred);
            elseif plt.ydecimals==-999.0
                for i=1:size(yticks,2)
                    ylabls{i}='';
                end
                set(gca,'yticklabel',ylabls);
            elseif plt.ydecimals==-1 && (plt.ytickmultiply~=1 || plt.ytickadd~=0)
                for i=1:size(yticks,2)
                    val=plt.ytickmultiply*yticks(i)+plt.ytickadd;
                    ylabls{i}=sprintf('%0.5g',val);
                end
                set(gca,'yticklabel',ylabls,'FontSize',8*fontred);
            end

        else
            tick(gca,'y','none');
        end

    case{'logarithmic'}
        
        set(gca,'yscale','log');
        
        if plt.ytick<=0
            tick(gca,'y','none');
        end

end

if plt.timegrid
    set(gca,'Xgrid','on');
end
if plt.ygrid
    set(gca,'ygrid','on');
end

if plt.rightaxis
    set(gca,'Color','none');
end

if ~plt.drawbox
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

box on;

if ~strcmpi(plt.font.color,'black')
    muppet_dummyplot(gca);
end
