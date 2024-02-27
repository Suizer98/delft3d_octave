function SetXYPlot(FigureProperties,SubplotProperties)

switch SubplotProperties.XScale,

    case{'linear'}
        
        if length(SubplotProperties.xtcklab)==0
        
            set(gca,'Xlim',[SubplotProperties.XMin SubplotProperties.XMax]);
            if SubplotProperties.XTick>-900.0

                xticks=[SubplotProperties.XMin:SubplotProperties.XTick:SubplotProperties.XMax];
                set(gca,'xtick',xticks);

                if SubplotProperties.DecimX>=0
                    frmt=['%0.' num2str(SubplotProperties.DecimX) 'f'];
                    for i=1:size(xticks,2)
                        val=SubplotProperties.XTickMultiply*xticks(i)+SubplotProperties.XTickAdd;
                        xlabls{i}=sprintf(frmt,val);
                    end
                    set(gca,'xticklabel',xlabls);
                elseif SubplotProperties.DecimX==-999.0
                    for i=1:size(xticks,2)
                        xlabls{i}='';
                    end
                    set(gca,'xticklabel',xlabls);
                elseif SubplotProperties.DecimX==-1 & (SubplotProperties.XTickMultiply~=1 | SubplotProperties.XTickAdd~=0)
                    for i=1:size(xticks,2)
                        val=SubplotProperties.XTickMultiply*xticks(i)+SubplotProperties.XTickAdd;
                        xlabls{i}=sprintf('%0.5g',val);
                    end
                    set(gca,'xticklabel',xlabls);
                end

            else
                tick(gca,'x','none');
            end
        
        else
            
            set(gca,'Xlim',[SubplotProperties.XMin-0.5 SubplotProperties.XMax+0.5]);
            if SubplotProperties.XTick>-900.0
                
                xticks=SubplotProperties.XMin:SubplotProperties.XMax;
                set(gca,'xtick',xticks);

                for i=1:(SubplotProperties.XMax-SubplotProperties.XMin+1);
                    xlab{i}=SubplotProperties.xtcklab{i+SubplotProperties.XMin-1};
                end
                xticklabel_rotate([],315,xlab);
            else
                tick(gca,'x','none');
            end
            
            
        end
        
    case{'logarithmic'}

        set(gca,'Xlim',[SubplotProperties.XMin SubplotProperties.XMax]);
        set(gca,'XScale','log');

        if SubplotProperties.XTick<-900.0
            tick(gca,'x','none');
        end

    case{'normprob'}
        
        xmin=norminv(0.0001);
        xmax=norminv(0.9999);
        
        set(gca,'Xlim',[xmin xmax]);
        xtick0=[0.0001 0.0005 0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 0.98 0.99 0.998 0.999 0.9999];
        xtcks=norminv(xtick0,0,1);

        for i=1:size(xtick0,2)
            xlabls{i}=num2str(100*xtick0(i));
        end

        set(gca,'xtick',xtcks);
        set(gca,'xticklabel',xlabls);

end

switch SubplotProperties.YScale,

    case{'linear'}

        set(gca,'Ylim',[SubplotProperties.YMin SubplotProperties.YMax]);
        if SubplotProperties.YTick>-900.0
            yticks=[SubplotProperties.YMin:SubplotProperties.YTick:SubplotProperties.YMax];
            set(gca,'ytick',yticks);

            if SubplotProperties.DecimY>=0
                frmt=['%0.' num2str(SubplotProperties.DecimY) 'f'];
                for i=1:size(yticks,2)
                    val=SubplotProperties.YTickMultiply*yticks(i)+SubplotProperties.YTickAdd;
                    ylabls{i}=sprintf(frmt,val);
                end
                set(gca,'yticklabel',ylabls);
            elseif SubplotProperties.DecimY==-999.0
                for i=1:size(yticks,2)
                    ylabls{i}='';
                end
                set(gca,'yticklabel',ylabls);
            elseif SubplotProperties.DecimY==-1 & (SubplotProperties.YTickMultiply~=1 | SubplotProperties.YTickAdd~=0)
                for i=1:size(yticks,2)
                    val=SubplotProperties.YTickMultiply*yticks(i)+SubplotProperties.YTickAdd;
                    ylabls{i}=sprintf('%0.5g',val);
                end
                set(gca,'yticklabel',ylabls);
            end
        else
            tick(gca,'y','none');
        end

    case{'logarithmic'}

        set(gca,'Ylim',[SubplotProperties.YMin SubplotProperties.YMax]);
        set(gca,'YScale','log');

        if SubplotProperties.XTick<-900.0
            tick(gca,'y','none');
        end

    case{'normprob'}
        
        ymin=norminv(0.0001);
        ymax=norminv(0.9999);
        
        set(gca,'Ylim',[ymin ymax]);
        ytick0=[0.0001 0.0005 0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 0.98 0.99 0.998 0.999 0.9999];
        ytcks=norminv(ytick0,0,1);

        for i=1:size(ytick0,2)
            ylabls{i}=num2str(100*ytick0(i));
        end

        set(gca,'ytick',ytcks);
        set(gca,'yticklabel',ylabls);

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
