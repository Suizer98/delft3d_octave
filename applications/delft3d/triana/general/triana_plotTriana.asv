function s = triana_plotTriana(s);

%% preparing plots

% make directory for figures
makedir([s.outputDir '\Figures']);

% determine distances for labels and location of legend
txt_dist_hor = (s.plot.Xmax-s.plot.Xmin)/s.plot.txtHorFraq;
txt_dist_ver = (s.plot.Ymax-s.plot.Ymin)/s.plot.txtVerFraq;
X_legend =0.8*(s.plot.Xmax-s.plot.Xmin)+s.plot.Xmin;
Y_legend =0.8*(s.plot.Ymax-s.plot.Ymin)+s.plot.Ymin;

% if no constituents have been specified for plotting, take all analysed components
if ~isfield(s.plot,'const')
    s.plot.const = s.triana.Cmp;
end

% reading ldb
if isfield(s.plot,'ldb')
    ldb = landboundary('read',s.plot.ldb);
end

% retreive locations of measurements
meas.X = [s.meas.data.X];
meas.Y = [s.meas.data.Y];

for cc = 1:length(s.plot.const)
    ID_cmpTriana = NaN;
    %selecting correct components in triana field
    for cc2 = 1:length(s.triana.Cmp)
        if strcmpi(s.triana.Cmp(cc2),strtrim(s.plot.const(cc)))
            ID_cmpTriana = cc2;
        end
    end
    
    %% Plotting standard triana plots
    
    figure
    hold on
    axis equal
    set(gca,'XLim',[s.plot.Xmin s.plot.Xmax],'YLim',[s.plot.Ymin s.plot.Ymax])
    
    % plot landboundary
    if isfield(s.plot,'ldb')
        plot(ldb(:,1),ldb(:,2),'Color',[0.3 0.3 0.3])
    end
    % plot measurement and model stations
    plot(meas.X,meas.Y,'rx','Color',[0.6 0.6 0.6])
    plot(s.model.data.XAll,s.model.data.YAll,'bo','Color',[0.6 0.6 0.6],'MarkerSize',3)
    
    % plot triana results for each station
    for ll = 1:length(s.modID)
        
        % plot search radius circle around model station and plot selected measurement station with a red x
        hC = circle([s.triana.X(ll),s.triana.Y(ll)],s.selection.searchRadius,1000,'b');
        set(hC,'Color',[0.8 0.8 0.8])
        
        if ~isnan(s.measID(ll))
            plot(meas.X(s.measID(ll)),meas.Y(s.measID(ll)),'rx')
            
            % plot the observed values
            hTo(1) = text(s.triana.X(ll)-txt_dist_hor,s.triana.Y(ll)+txt_dist_ver,num2str(round(s.triana.Aobs(ID_cmpTriana,ll)*100)/100));
            hTo(2) = text(s.triana.X(ll)+txt_dist_hor,s.triana.Y(ll)+txt_dist_ver,num2str(round(s.triana.Gobs(ID_cmpTriana,ll))));
            set(hTo,'FontSize',s.plot.FontSize,'HorizontalAlignment','center','Color',[1 0 0],'FontWeight','Bold')
        end
        
        if ~isnan(s.modID(ll))
            % plot computed values
            hTc(1) = text(s.triana.X(ll)-txt_dist_hor,s.triana.Y(ll)-txt_dist_ver,num2str(round(s.triana.Acomp(ID_cmpTriana,ll)*100)/100));
            hTc(2) = text(s.triana.X(ll)+txt_dist_hor,s.triana.Y(ll)-txt_dist_ver,num2str(round(s.triana.Gcomp(ID_cmpTriana,ll))));
            set(hTc,'FontSize',s.plot.FontSize,'HorizontalAlignment','center','Color',[0 0 1],'FontWeight','Bold')
        end
        
        % plot line seperating the values
        plot([s.triana.X(ll)-txt_dist_hor s.triana.X(ll)+txt_dist_hor],[s.triana.Y(ll) s.triana.Y(ll)],'k')
        plot([s.triana.X(ll) s.triana.X(ll)],[s.triana.Y(ll)-txt_dist_ver s.triana.Y(ll)+txt_dist_ver],'k')
    end
    
    % plot legend
    hTo2(1) = text(X_legend-txt_dist_hor,Y_legend+txt_dist_ver,'Ho');
    hTo2(2) = text(X_legend+txt_dist_hor,Y_legend+txt_dist_ver,'Go');
    hTc2(1) = text(X_legend-txt_dist_hor,Y_legend-txt_dist_ver,'Hc');
    hTc2(2) = text(X_legend+txt_dist_hor,Y_legend-txt_dist_ver,'Gc');
    set(hTc2,'FontSize',s.plot.FontSize,'HorizontalAlignment','center','Color',[0 0 1],'FontWeight','Bold')
    set(hTo2,'FontSize',s.plot.FontSize,'HorizontalAlignment','center','Color',[1 0 0],'FontWeight','Bold')
    
    plot(X_legend,Y_legend-3*txt_dist_ver,'bo','Color',[0.6 0.6 0.6],'MarkerSize',3)
    text(X_legend+txt_dist_hor,Y_legend-3*txt_dist_ver,'model station','FontSize',3)
    plot(X_legend,Y_legend-5*txt_dist_ver,'rx','Color',[0.6 0.6 0.6],'MarkerSize',3)
    text(X_legend+txt_dist_hor,Y_legend-5*txt_dist_ver,'measurement station','FontSize',3)
    
    title(s.plot.const{cc})
    grid on
    if s.model.epsg == 4326
        xlabel('Longitude [^o]')
        xlabel('Latitude [^o]')
    else
        kmAxis(gca,[mean(diff(get(gca,'Xtick')))/1000 mean(diff(get(gca,'Ytick')))/1000])
        xlabel(['Easting [km; ',s.model.epsgTxT,']'])
        ylabel(['Northing [km; ',s.model.epsgTxT,']'])
    end
    set(gca,'FontSize',7)
    print(gcf,'-dpng','-r300',[s.outputDir '\Figures\Triana_',s.plot.const{cc},'_',s.description,'.png'])
    close all
    
    %%  Plotting figure showing the difference in amplitude and phase
    A_ratio = s.triana.Acomp(ID_cmpTriana,:)./s.triana.Aobs(ID_cmpTriana,:);
    IDnan = find(A_ratio == 0 | isinf(A_ratio));
    A_ratio(IDnan)=NaN;
    G_diff = mod(s.triana.Gcomp(ID_cmpTriana,:)-s.triana.Gobs(ID_cmpTriana,:),360);
    G_diff(G_diff>180) = G_diff(G_diff>180)-360;
    G_diff(IDnan) = NaN;
    
    figure
    hS(1) = subplot(2,1,1);
    hold on
    axis equal
    set(gca,'XLim',[s.plot.Xmin s.plot.Xmax],'YLim',[s.plot.Ymin s.plot.Ymax])
    
    % plot landboundary
    if isfield(s.plot,'ldb')
        plot(ldb(:,1),ldb(:,2),'k')
    end
    
    if ~isfield(s.plot,'A_ratio_limits') || length(s.plot.A_ratio_limits)~=2
        colorbarLims = [max(1-max(abs(A_ratio-1)),0):max(abs(A_ratio-1))/10:1+max(abs(A_ratio-1))];
    else
        colorbarLims  = linspace(s.plot.A_ratio_limits(1),s.plot.A_ratio_limits(2),20);
    end
    
    clrmap = jet(length(colorbarLims)-1);
    for ll = 1:length(A_ratio)
        if ~isnan(A_ratio(ll))
            IDcol = max([1 find(colorbarLims(1:end-1)<A_ratio(ll))]);
            plot(s.triana.X(ll),s.triana.Y(ll),'k.','Color',clrmap(IDcol(end),:),'MarkerSize',20)
            if A_ratio(ll) > colorbarLims(end) | A_ratio(ll)<colorbarLims(1)
                text(s.triana.X(ll)+txt_dist_hor,s.triana.Y(ll),num2str(A_ratio(ll)),'FontSize',5)
            end
        end
    end
    if ~isempty(find(isnan(colorbarLims)))
        colorbarLims = [0 1];
    end
    set(gcf,'Colormap',jet);
    hC(1) = colorbar;
    clim([colorbarLims(1) colorbarLims(end)])
    set(get(hC(1),'YLabel'),'String','Hc/Ho [-]')
    title(s.plot.const{cc})
    grid on
    if s.model.epsg == 4326
        ylabel('Longitude [^o]')
    else
        kmAxis(gca,[mean(diff(get(gca,'Xtick')))/1000 mean(diff(get(gca,'Ytick')))/1000])
        ylabel(['Northing [km; ',s.model.epsgTxT,']'])
    end
    
    hS(2) = subplot(2,1,2);
    hold on
    axis equal
    set(gca,'XLim',[s.plot.Xmin s.plot.Xmax],'YLim',[s.plot.Ymin s.plot.Ymax])
    
    % plot landboundary
    if isfield(s.plot,'ldb')
        plot(ldb(:,1),ldb(:,2),'k')
    end
    
    if ~isfield(s.plot,'G_diff_limits') || length(s.plot.G_diff_limits)~=2
        colorbarLims  = [max(abs(G_diff))*-1:max(abs(G_diff))/10:max(abs(G_diff))];
    else
        colorbarLims  = linspace(s.plot.G_diff_limits(1),s.plot.G_diff_limits(2),20);
        
    end
    clrmap = jet(length(colorbarLims)-1);
    for ll = 1:length(G_diff)
        if ~isnan(G_diff(ll))
            IDcol = max([1 find(colorbarLims(1:end-1)<G_diff(ll))]);
            plot(s.triana.X(ll),s.triana.Y(ll),'k.','Color',clrmap(IDcol(end),:),'MarkerSize',20)
            if G_diff(ll) > colorbarLims(end) | G_diff(ll)<colorbarLims(1)
                text(s.triana.X(ll)+txt_dist_hor,s.triana.Y(ll),num2str(G_diff(ll)),'FontSize',5)
            end
        end
    end
    if ~isempty(find(isnan(colorbarLims)))
        colorbarLims = [0 1];
    end
    hC(2) = colorbar;
    clim([colorbarLims(1) colorbarLims(end)])
    set(get(hC(2),'YLabel'),'String','Gc - Go [^o]')
    title(['Frequency = ',num2str(s.triana.Freq(ID_cmpTriana)),'^o/hr'])
    
    grid on
    if s.model.epsg == 4326
        xlabel('Longitude [^o]')
        ylabel('Latitude [^o]')
    else
        kmAxis(gca,[mean(diff(get(gca,'Xtick')))/1000 mean(diff(get(gca,'Ytick')))/1000])
        xlabel(['Easting [km; ',s.model.epsgTxT,']'])
        ylabel(['Northing [km; ',s.model.epsgTxT,']'])
    end
    
    set(hS(1),'FontSize',6,'Position',[0.07 0.55 0.82 0.41])
    set(hS(2),'FontSize',6,'Position',[0.07 0.08 0.82 0.41])
    set(hC(1),'Position',[0.91 0.54 0.015 0.41]);
    set(hC(2),'Position',[0.91 0.08 0.015 0.41]);
    
    print(gcf,'-dpng','-r300',[s.outputDir '\Figures\Triana_',s.plot.const{cc},'_',s.description,'_Aratio_Gdiff.png'])
    close all
    
    xlswrite([s.outputDir '\Figures\Triana_summary.xls'],[{'Station (obs)'};s.triana.statsComp],s.plot.const{cc},'A1');
    xlswrite([s.outputDir '\Figures\Triana_summary.xls'],[{'Station (comp)'};s.triana.statsObs'],s.plot.const{cc},'B1');
    xlswrite([s.outputDir '\Figures\Triana_summary.xls'],{'X','Y'},s.plot.const{cc},'C1');
    xlswrite([s.outputDir '\Figures\Triana_summary.xls'],s.triana.X,s.plot.const{cc},'C2');
    xlswrite([s.outputDir '\Figures\Triana_summary.xls'],s.triana.Y,s.plot.const{cc},'D2');
    xlswrite([s.outputDir '\Figures\Triana_summary.xls'],{'Hc','Ho','Hc/Ho','','Gc','Go','Gc-Go'},s.plot.const{cc},'E1');
    xlswrite([s.outputDir '\Figures\Triana_summary.xls'],[s.triana.Acomp(ID_cmpTriana,:)' s.triana.Aobs(ID_cmpTriana,:)' A_ratio'],s.plot.const{cc},'E2');
    xlswrite([s.outputDir '\Figures\Triana_summary.xls'],[s.triana.Gcomp(ID_cmpTriana,:)' s.triana.Gobs(ID_cmpTriana,:)' G_diff'],s.plot.const{cc},'I2');
    
end