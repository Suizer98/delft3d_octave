function muppet_setXYPlot(handles,ifig,isub)

plt=handles.figures(ifig).figure.subplots(isub).subplot;
fontred=handles.figures(ifig).figure.fontreduction;
cm2pix=handles.figures(ifig).figure.cm2pix;
units=handles.figures(ifig).figure.units;

switch plt.xscale

    case{'linear'}
        
        if isempty(plt.xtcklab)
        
            set(gca,'Xlim',[plt.xmin plt.xmax]);
            if plt.xtick>-900.0

                xticks=plt.xmin:plt.xtick:plt.xmax;
                set(gca,'xtick',xticks);

                if plt.xdecimals>=0
                    frmt=['%0.' num2str(plt.xdecimals) 'f'];
                    for i=1:size(xticks,2)
                        val=plt.xtickmultiply*xticks(i)+plt.xtickadd;
                        xlabls{i}=sprintf(frmt,val);
                    end
                    set(gca,'xticklabel',xlabls);
                elseif plt.xdecimals==-999.0
                    for i=1:size(xticks,2)
                        xlabls{i}='';
                    end
                    set(gca,'xticklabel',xlabls);
                elseif plt.xdecimals==-1 && (plt.xtickmultiply~=1 || plt.xtickadd~=0)
                    for i=1:size(xticks,2)
                        val=plt.xtickmultiply*xticks(i)+plt.xtickadd;
                        xlabls{i}=sprintf('%0.5g',val);
                    end
                    set(gca,'xticklabel',xlabls);
                end

            else
                tick(gca,'x','none');
            end
        
        else

            % Labels are given. Histogram.

            set(gca,'Xlim',[plt.xmin-0.5 plt.xmax+0.5]);
            if plt.xtick>-900.0

                xticks=1:length(plt.xtcklab);
                set(gca,'xtick',xticks);
%                xticklabel_rotate([],315,plt.xtcklab);
                xh=xticklabel_rotate([],340,plt.xtcklab);
                set(xh,'FontName',plt.font.name);
                set(xh,'FontSize',plt.font.size*fontred);
                set(xh,'FontAngle',plt.font.angle);
                set(xh,'FontWeight',plt.font.weight);
                set(xh,'Color',colorlist('getrgb','color',plt.font.color));

                
%                 xticks=plt.xmin:plt.xmax;
%                 set(gca,'xtick',xticks);
% 
%                 for i=1:(plt.xmax-plt.xmin+1);
%                     xlab{i}=plt.xtcklab{i+plt.xmin-1};
%                 end
%                 xticklabel_rotate([],315,xlab);
            else
                tick(gca,'x','none');
            end
            
            
        end
        
    case{'logarithmic'}

        set(gca,'Xlim',[plt.xmin plt.xmax]);
        set(gca,'XScale','log');

        if plt.xtick<-900.0
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

switch plt.yscale

    case{'linear'}

        set(gca,'ylim',[plt.ymin plt.ymax]);
        if plt.ytick>-900.0
            yticks=plt.ymin:plt.ytick:plt.ymax;
            set(gca,'ytick',yticks);

            if plt.ydecimals>=0
                frmt=['%0.' num2str(plt.ydecimals) 'f'];
                for i=1:size(yticks,2)
                    val=plt.ytickmultiply*yticks(i)+plt.ytickadd;
                    ylabls{i}=sprintf(frmt,val);
                end
                set(gca,'yticklabel',ylabls);
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
                set(gca,'yticklabel',ylabls);
            end
        else
            tick(gca,'y','none');
        end

    case{'logarithmic'}

        set(gca,'ylim',[plt.ymin plt.ymax]);
        set(gca,'yScale','log');

        if plt.xtick<-900.0
            tick(gca,'y','none');
        end

    case{'normprob'}
        
        ymin=norminv(0.0001);
        ymax=norminv(0.9999);
        
        set(gca,'ylim',[ymin ymax]);
        ytick0=[0.0001 0.0005 0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 0.98 0.99 0.998 0.999 0.9999];
        ytcks=norminv(ytick0,0,1);

        for i=1:size(ytick0,2)
            ylabls{i}=num2str(100*ytick0(i));
        end

        set(gca,'ytick',ytcks);
        set(gca,'yticklabel',ylabls);

end

if plt.xgrid
    set(gca,'xgrid','on');
end

if plt.ygrid
    set(gca,'ygrid','on');
end

if plt.rightaxis
    set(gca,'color','none');
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
