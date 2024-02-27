function SetMapPlot(FigureProperties,SubplotProperties)

if SubplotProperties.AxesEqual
    xlim(1)=SubplotProperties.XMin; xlim(2)=xlim(1)+0.01*SubplotProperties.Position(3)*SubplotProperties.Scale;
    ylim(1)=SubplotProperties.YMin; ylim(2)=ylim(1)+0.01*SubplotProperties.Position(4)*SubplotProperties.Scale;
    axis equal;
elseif strcmpi(SubplotProperties.coordinateSystem.type,'geographic')
    xlim(1)=SubplotProperties.XMin; xlim(2)=SubplotProperties.XMax;
    ylim(1)=SubplotProperties.YMin; ylim(2)=ylim(1)+(xlim(2)-xlim(1))*cos(ylim(1)*pi/180)*SubplotProperties.Position(4)/SubplotProperties.Position(3);%^2;
else
    xlim(1)=SubplotProperties.XMin; xlim(2)=SubplotProperties.XMax;
    ylim(1)=SubplotProperties.YMin; ylim(2)=SubplotProperties.YMax;
end

view(2);

% if SubplotProperties.AxesEqual==0
%     VertScale=(SubplotProperties.YMax-SubplotProperties.YMin)/SubplotProperties.Position(4);
%     HoriScale=(SubplotProperties.XMax-SubplotProperties.XMin)/SubplotProperties.Position(3);
%     Multi=HoriScale/VertScale;
% else
%     Multi=1.0;
% end

Multi=1;

set(gca,'Xlim',xlim,'YLim',Multi*ylim);

if SubplotProperties.DrawBox
    if SubplotProperties.XTick~=-999.0
        xtickstart=SubplotProperties.XTick*floor(xlim(1)/SubplotProperties.XTick);
        xtickstop=SubplotProperties.XTick*ceil(xlim(2)/SubplotProperties.XTick);
        xtick=xtickstart:SubplotProperties.XTick:xtickstop;
        set(gca,'XTick',xtick,'FontSize',10*FigureProperties.FontRed);

        if SubplotProperties.DecimX>=0
            frmt=['%0.' num2str(SubplotProperties.DecimX) 'f'];
            for i=1:size(xtick,2)
                val=SubplotProperties.XTickMultiply*xtick(i)+SubplotProperties.XTickAdd;
                xlabls{i}=sprintf(frmt,val);
            end
            set(gca,'xticklabel',xlabls);
        elseif SubplotProperties.DecimX==-999
            for i=1:size(xtick,2)
                xlabls{i}='';
            end
            set(gca,'xticklabel',xlabls);
        elseif SubplotProperties.DecimX==-1 && (SubplotProperties.XTickMultiply~=1 || SubplotProperties.XTickAdd~=0)
            for i=1:size(xtick,2)
                val=SubplotProperties.XTickMultiply*xtick(i)+SubplotProperties.XTickAdd;
                xlabls{i}=sprintf('%0.5g',val);
            end
            set(gca,'xticklabel',xlabls);
        end

        if SubplotProperties.XGrid
            set(gca,'Xgrid','on');
        else
            set(gca,'Xgrid','off');
        end
    else
        tick(gca,'x','none');
    end

    if SubplotProperties.YTick~=-999.0
        ytickstart=SubplotProperties.YTick*floor(ylim(1)/SubplotProperties.YTick);
        ytickstop=SubplotProperties.YTick*ceil(ylim(2)/SubplotProperties.YTick);
        ytick=ytickstart:SubplotProperties.YTick:ytickstop;
        ytick=Multi*ytick;
        set(gca,'yTick',ytick,'FontSize',10*FigureProperties.FontRed);

        if SubplotProperties.DecimY>=0
            frmt=['%0.' num2str(SubplotProperties.DecimY) 'f'];
            for i=1:size(ytick,2)
                val=SubplotProperties.YTickMultiply*ytick(i)/Multi+SubplotProperties.YTickAdd;
                ylabls{i}=sprintf(frmt,val);
            end
            set(gca,'yticklabel',ylabls);
        elseif SubplotProperties.DecimY==-1 && Multi~=1
            frmt=['%0.' num2str(2) 'f'];
            for i=1:size(ytick,2)
                val=SubplotProperties.YTickMultiply*ytick(i)/Multi+SubplotProperties.YTickAdd;
                ylabls{i}=sprintf(frmt,val);
            end
            set(gca,'yticklabel',ylabls);
        elseif SubplotProperties.DecimY==-999
            for i=1:size(ytick,2)
                ylabls{i}='';
            end
            set(gca,'yticklabel',ylabls);
        elseif SubplotProperties.DecimY==-1 && (SubplotProperties.YTickMultiply~=1 || SubplotProperties.YTickAdd~=0)
            for i=1:size(ytick,2)
                val=SubplotProperties.YTickMultiply*ytick(i)/Multi+SubplotProperties.YTickAdd;
                ylabls{i}=sprintf('%0.5g',val);
            end
            set(gca,'yticklabel',ylabls);
        end

        if SubplotProperties.YGrid
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

set(gca,'FontName',SubplotProperties.AxesFont);
set(gca,'FontSize',SubplotProperties.AxesFontSize*FigureProperties.FontRed);
set(gca,'FontAngle',SubplotProperties.AxesFontAngle);
set(gca,'FontWeight',SubplotProperties.AxesFontWeight);
set(gca,'XColor',FindColor(SubplotProperties.AxesFontColor));
set(gca,'YColor',FindColor(SubplotProperties.AxesFontColor));
set(gca,'Units',FigureProperties.Units);
set(gca,'Position',SubplotProperties.Position*FigureProperties.cm2pix);
set(gca,'Layer','top');

zoom v6 on;

