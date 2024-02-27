function SetHisPlot(FigureProperties,SubplotProperties)

xmin = datenum(SubplotProperties.YearMin,SubplotProperties.MonthMin,SubplotProperties.DayMin,SubplotProperties.HourMin,SubplotProperties.MinuteMin,SubplotProperties.SecondMin);
xmax = datenum(SubplotProperties.YearMax,SubplotProperties.MonthMax,SubplotProperties.DayMax,SubplotProperties.HourMax,SubplotProperties.MinuteMax,SubplotProperties.SecondMax);

xtick = SubplotProperties.YearTick*365;
xtick = xtick + SubplotProperties.MonthTick*30;
xtick = xtick + SubplotProperties.DayTick;
xtick = xtick + SubplotProperties.HourTick/24;
xtick = xtick + SubplotProperties.MinuteTick/1440;
xtick = xtick + SubplotProperties.SecondTick/86400;

if strcmpi(FigureProperties.Renderer,'opengl');
    xback=xmin;
    xmin=xmin-xback;
    xmax=xmax-xback;
else
    xback=0;
end

set(gca,'Xlim',[xmin xmax],'YLim',[SubplotProperties.YMin SubplotProperties.YMax]);

if xtick>0.0
    if SubplotProperties.MonthTick==0
        xticks=floor(xmin):xtick:ceil(xmax)+2*xtick;
    else
        nm=12*(SubplotProperties.YearMax-SubplotProperties.YearMin)+SubplotProperties.MonthMax-SubplotProperties.MonthMin+1;
        for j=1:ceil(nm/SubplotProperties.MonthTick)+1;
            xticks(j)=datenum(SubplotProperties.YearMin,SubplotProperties.MonthMin+(j-1)*SubplotProperties.MonthTick,1,0,0,0);
            xticks=xticks-xback;
        end
    end
    if SubplotProperties.YearTick>0
        [y0,m0,d0,h0,mi0,s0]=datevec(floor(xmin));
        [y1,m0,d0,h0,mi0,s0]=datevec(ceil(xmax));
        yt=[y0:SubplotProperties.YearTick:y1];
        mt=zeros(size(yt))+1;
        dt=mt;
        ht=zeros(size(yt));
        mit=ht;
        st=ht;
        xticks=datenum(yt,mt,dt,ht,mit,st);
    end
    xlabls=datestr(xticks,char(SubplotProperties.DateFormat));
    set(gca,'xtick',xticks,'xticklabel',xlabls,'FontSize',8*FigureProperties.FontRed);
else
    tick(gca,'x','none');
end

if SubplotProperties.AddDate
    sz=size(xticks,2);
    scl=(SubplotProperties.YMax-SubplotProperties.YMin)/SubplotProperties.Position(4);
    ytxt=SubplotProperties.YMin-0.6*scl;
    for i=1:sz
        if xticks(i)==round(xticks(i)) && xticks(i)<=xmax;
            datetxt(i)=text(xticks(i),ytxt,datestr(xticks(i),26));
            set(datetxt(i),'FontSize',8*FigureProperties.FontRed,'HorizontalAlignment','center');
        end
    end
end

switch SubplotProperties.YScale,

    case{'linear'}
        if SubplotProperties.YTick>0
            yticks=[SubplotProperties.YMin:SubplotProperties.YTick:SubplotProperties.YMax];
            set(gca,'ytick',yticks);

            if SubplotProperties.DecimY>=0
                frmt=['%0.' num2str(SubplotProperties.DecimY) 'f'];
                for i=1:size(yticks,2)
                    val=SubplotProperties.YTickMultiply*yticks(i)+SubplotProperties.YTickAdd;
                    ylabls{i}=sprintf(frmt,val);
                end
                set(gca,'yticklabel',ylabls,'FontSize',8*FigureProperties.FontRed);
            elseif SubplotProperties.DecimY==-999.0
                for i=1:size(yticks,2)
                    ylabls{i}='';
                end
                set(gca,'yticklabel',ylabls);
            elseif SubplotProperties.DecimY==-1 && (SubplotProperties.YTickMultiply~=1 || SubplotProperties.YTickAdd~=0)
                for i=1:size(yticks,2)
                    val=SubplotProperties.YTickMultiply*yticks(i)+SubplotProperties.YTickAdd;
                    ylabls{i}=sprintf('%0.5g',val);
                end
                set(gca,'yticklabel',ylabls,'FontSize',8*FigureProperties.FontRed);
            end

        else
            tick(gca,'y','none');
        end

    case{'logarithmic'}
        
        set(gca,'YScale','log');
        
        if SubplotProperties.YTick<=0
            tick(gca,'y','none');
        end

end

if SubplotProperties.XGrid
    set(gca,'Xgrid','on');
end
if SubplotProperties.YGrid
    set(gca,'Ygrid','on');
end

if SubplotProperties.RightAxis
    set(gca,'Color','none');
end

set(gca,'FontName',SubplotProperties.AxesFont);
set(gca,'FontSize',SubplotProperties.AxesFontSize*FigureProperties.FontRed);
set(gca,'FontAngle',SubplotProperties.AxesFontAngle);
set(gca,'FontWeight',SubplotProperties.AxesFontWeight);
set(gca,'XColor',FindColor(SubplotProperties.AxesFontColor));
set(gca,'YColor',FindColor(SubplotProperties.AxesFontColor));
set(gca,'Units',FigureProperties.Units);
set(gca,'Position',SubplotProperties.Position*FigureProperties.cm2pix);
box on;
