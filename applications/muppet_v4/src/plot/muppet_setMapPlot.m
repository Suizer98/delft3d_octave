function muppet_setMapPlot(handles,ifig,isub)

plt=handles.figures(ifig).figure.subplots(isub).subplot;
fontred=handles.figures(ifig).figure.fontreduction;
cm2pix=handles.figures(ifig).figure.cm2pix;
units=handles.figures(ifig).figure.units;

view(2);

plt=muppet_updateLimits(plt,'setprojectionlimits');
set(gca,'xlim',[plt.xminproj plt.xmaxproj],'ylim',[plt.yminproj plt.ymaxproj]);

xlim(1)=plt.xmin;
xlim(2)=plt.xmax;
ylim(1)=plt.ymin;
ylim(2)=plt.ymax;

if plt.drawbox
    
    % X Axis
    
    if plt.xtick~=-999.0
        xtickstart=plt.xtick*floor(xlim(1)/plt.xtick);
        xtickstop=plt.xtick*ceil(xlim(2)/plt.xtick);
        xtick=xtickstart:plt.xtick:xtickstop;
        set(gca,'xtick',xtick,'FontSize',10*fontred);

        if plt.xdecimals>=0
            frmt=['%0.' num2str(plt.xdecimals) 'f'];
            for i=1:size(xtick,2)
                val=plt.xtickmultiply*xtick(i)+plt.xtickadd;
                xlabls{i}=sprintf(frmt,val);
            end
            set(gca,'xticklabel',xlabls);
        elseif plt.xdecimals==-999
            for i=1:size(xtick,2)
                xlabls{i}='';
            end
            set(gca,'xticklabel',xlabls);
        elseif plt.xdecimals==-1 && (plt.xtickmultiply~=1 || plt.xtickadd~=0)
            for i=1:size(xtick,2)
                val=plt.xtickmultiply*xtick(i)+plt.xtickadd;
                xlabls{i}=sprintf('%0.5g',val);
            end
            set(gca,'xticklabel',xlabls);
        end

        if plt.xgrid
            switch lower(plt.projection)
                case{'albers'}
                    % Meridians
                    for ii=plt.xmin-plt.xtick:plt.xtick:plt.xmax+plt.xtick
                        yy=plt.ymin-plt.ytick:0.1:plt.ymax+plt.ytick;
                        xx=zeros(size(yy))+ii;
                        [mx,my]=albers(xx,yy,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
                        p=plot(mx,my);
                        set(p,'LineStyle',':','Color','k');
                        hold on;
                    end
                otherwise
                    set(gca,'xgrid','on');
            end
        else
            set(gca,'xgrid','off');
        end
    else
        tick(gca,'x','none');
    end

    % Y Axis
    
    if plt.ytick~=-999.0
        ytickstart=plt.ytick*floor(ylim(1)/plt.ytick);
        ytickstop=plt.ytick*ceil(ylim(2)/plt.ytick);
        ytick=ytickstart:plt.ytick:ytickstop;
        ytickproj=ytick;
        switch plt.projection
            case{'mercator'}
                ytickproj=merc(ytick);
            otherwise
        end
        set(gca,'ytick',ytickproj,'FontSize',10*fontred);

        if plt.ydecimals>=0
            % Fixed decimals
            frmt=['%0.' num2str(plt.ydecimals) 'f'];
            for i=1:size(ytick,2)
                val=plt.ytickmultiply*ytick(i)+plt.ytickadd;
                ylabls{i}=sprintf(frmt,val);
            end
            set(gca,'yticklabel',ylabls);
        elseif plt.ydecimals==-999
            % No labels
            for i=1:size(ytick,2)
                ylabls{i}='';
            end
            set(gca,'yticklabel',ylabls);
        elseif plt.ydecimals==-1 && (plt.ytickmultiply~=1 || plt.ytickadd~=0 || ...
                ~strcmpi(plt.projection,'equirectangular'))
            % Automatic
            for i=1:size(ytick,2)
                val=plt.ytickmultiply*ytick(i)+plt.ytickadd;
                ylabls{i}=sprintf('%0.5g',val);
            end
            set(gca,'yticklabel',ylabls);
        end

        if plt.ygrid
            switch lower(plt.projection)
                case{'albers'}
                    % Parallels
                    for ii=plt.ymin-plt.ytick:plt.ytick:plt.ymax+plt.ytick
                        xx=plt.xmin-plt.xtick:0.1:plt.xmax+plt.xtick;
                        yy=zeros(size(xx))+ii;
                        [mx,my]=albers(xx,yy,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
                        p=plot(mx,my);
                        set(p,'LineStyle',':','Color','k');
                        hold on;
                    end
                otherwise
                    set(gca,'ygrid','on');
            end
        end
        
    else
        tick(gca,'y','none');
    end
    box on;




else
    axis off;
    box off;
end

set(gca,'xlim',[plt.xminproj plt.xmaxproj],'ylim',[plt.yminproj plt.ymaxproj]);

set(gca,'FontName',plt.font.name);
set(gca,'FontSize',plt.font.size*fontred);
set(gca,'FontAngle',plt.font.angle);
set(gca,'FontWeight',plt.font.weight);
set(gca,'XColor',colorlist('getrgb','color',plt.font.color));
set(gca,'YColor',colorlist('getrgb','color',plt.font.color));
set(gca,'Units',units);
set(gca,'Position',plt.position*cm2pix);
set(gca,'Layer','top');


if ~strcmpi(plt.font.color,'black')
    muppet_dummyplot(gca);
end
