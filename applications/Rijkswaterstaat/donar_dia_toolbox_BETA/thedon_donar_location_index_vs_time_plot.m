function thedon_donar_location_index_vs_time_plot
% thedon_donar_location_index_vs_time_plot Box and Whisker diagram for all observations in TIME (MONTHS)  

    clc; 
    close all, 
    fclose all; 
    clear;
    addpath([pwd,filesep,'utilities',filesep]);
    
    
    % 1. Input information
    thedonarfiles = { ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2008_the_compend.mat'; ...
        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ferry\raw\FerryBox_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ferry\raw\FerryBox_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ferry\raw\FerryBox_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ferry\raw\FerryBox_2008_the_compend.mat'; ...
        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_meetvis\raw\ScanFish_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_meetvis\raw\ScanFish_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_meetvis\raw\ScanFish_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_meetvis\raw\ScanFish_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_meetvis\raw\ScanFish_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_meetvis\raw\ScanFish_2008_the_compend.mat'};
    
    
    
    % 2. Some declarations
    ctd_cont   = 1;
    ferry_cont = 1;
    scan_cont  = 1;
    
    
    % 3. The variable
    variable = 'turbidity';
    
    
    % 4. Upload the information
    for i = 1:length(thedonarfiles)
        
        disp(['Loading: ',thedonarfiles{i}]);
        donarMat = importdata(thedonarfiles{i});
        
        if strfind(lower(thedonarfiles{i}),'ctd')
            sensor_name = 'CTD'; 

            if ctd_cont == 1
                ctd.(variable) = donarMat.(variable);
            else
                ctd.(variable).data = [ctd.(variable).data; donarMat.(variable).data];
            end
            
            
            ctd_cont = ctd_cont+1;
        elseif strfind(lower(thedonarfiles{i}),'ferry')
            sensor_name = 'Ferrybox';
            
            if ferry_cont == 1
                ferry.(variable) = donarMat.(variable);
            else
                ferry.(variable).data = [ferry.(variable).data; donarMat.(variable).data];
            end
            
            
            ferry_cont = ferry_cont+1;
        elseif strfind(lower(thedonarfiles{i}),'meetvis')
            sensor_name = 'Meetvis';
            
            if scan_cont == 1
                scan.(variable) = donarMat.(variable);
            else
                scan.(variable).data = [scan.(variable).data; donarMat.(variable).data];
            end
            
            
            scan_cont = scan_cont+1;
        end
        
        clear donarMat
    end
    
    ctd.(variable).data(:,4)   = ctd.(variable).data(:,4) + ctd.(variable).referenceDate;
    ferry.(variable).data(:,4) = ferry.(variable).data(:,4) + ferry.(variable).referenceDate;
    scan.(variable).data(:,4)  = scan.(variable).data(:,4) + scan.(variable).referenceDate;
        
    
    
    %% 5. MAKE THE PLOTS.
    % Once the script is run until this point. It is not necessary to re
    % run the initial part. 
    
    % CTD
    close all
    h = figure;
    thelineS = colormap;
                          
    plot_xyColor(         ctd.(variable).data(:,4), ...
                  roundto(ctd.(variable).data(:,1),5)*10e12+ roundto(ctd.(variable).data(:,2),5)*10e4, ...
                          log10(ctd.(variable).data(:,5)), ...
                          10, ...
                          flipud(thelineS))
    
    posSw = [246         132        1320         564];
    set(gcf,'PaperPositionMode','auto')
    set(gcf,'Position',posSw)
    thecb = colorbar;
    a = log10([0.3 1 10 20 40 60 90]);set(thecb,'ytick',a,'yticklabel',10.^a)
    
    xlim([datenum('01-Jan-2003') datenum('01-Jan-2009')])
    xlabel('Time (dd.mm.yy)','fontsize',13)
    datetick('x','dd.mm.yy','keeplimits')
    ylim([2.5e13 7e13])
    ylabel('Location Index','fontsize',13)
    title('CTD: Upoly0 [-] in Time and Space','fontweight','bold','fontsize',14)
    set(gca,'fontsize',13)
    
    filename = ['d:\Dropbox\Deltares\MoS-3\reporting\Garcia Report\figures\timeNspace_ctd_turbidity'];
    disp(['saving : ',filename]);
    print('-dpng',filename);
    saveas(h,filename,'fig');
    
    %
    % Ferrybox
    % close all
    h = figure;
    
    thelineS = colormap;
    %thelineS = [thelineS; repmat(thelineS(end,:),400,1)]
    
    plot_xyColor(         ferry.(variable).data(:,4), ...
                  roundto(ferry.(variable).data(:,1),5)*10e12+ roundto(ferry.(variable).data(:,2),5)*10e4, ...
                          log10(ferry.(variable).data(:,5)), ...
                          10, ...
                          thelineS)
    
    posSw = [246         132        1320         564];
    set(gcf,'PaperPositionMode','auto')
    set(gcf,'Position',posSw)
    thecb = colorbar;
    a = log10([0.3 1 10 20 40 60 90 140]);set(thecb,'ytick',a,'yticklabel',10.^a)
    
    xlim([datenum('01-Jan-2003') datenum('01-Jan-2009')])
    xlabel('Time (dd.mm.yy)','fontsize',13)
    datetick('x','dd.mm.yy','keeplimits')
    ylim([2.5e13 7e13])
    ylabel('Location Index','fontsize',13)
    title('FerryBox: Turbidity [NTU] in Time and Space','fontweight','bold','fontsize',14)
    set(gca,'fontsize',13)
    
    filename = [pwd,'\timeNspace_ferry_turbidity'];
    disp(['saving : ',filename]);
    print('-dpng',filename);
    saveas(h,filename,'fig');
    
    %%
    h = figure;
    
    thelineS = colormap;
    %thelineS = [thelineS; repmat(thelineS(end,:),400,1)]
    
    plot_xyColor(          ferry.(variable).data(ferry.(variable).data(:,5) < 3,4), ...
                   roundto(ferry.(variable).data(ferry.(variable).data(:,5) < 3 ,1),5)*10e12 + roundto(ferry.(variable).data(ferry.(variable).data(:,5) < 3 ,2),5)*10e4, ...
                           log10(ferry.(variable).data(ferry.(variable).data(:,5) < 3,5)),...
                   10,thelineS)
               
               
    posSw = [246         132        1320         564];
    set(gcf,'PaperPositionMode','auto')
    set(gcf,'Position',posSw)
    thecb = colorbar;
    a = log10([0.3 0.5 1 1.5 2 2.5]);set(thecb,'ytick',a,'yticklabel',10.^a)
    
    xlim([datenum('01-Jan-2003') datenum('01-Jan-2009')])
    datetick('x','dd.mm.yy','keeplimits')
    xlabel('Time (dd.mm.yy)','fontsize',13)
    ylim([2.5e13 7e13])
    ylabel('Location Index','fontsize',13)
    title('FerryBox: Turbidity [NTU] in Time and Space','fontweight','bold','fontsize',14)
    set(gca,'fontsize',13)
    
    
    % Where do I save the file:
    filename = [pwd,'\timeNspace_ferry_turbidity_clipped'];
    disp(['saving : ',filename]);
    print('-dpng',filename);
    saveas(h,filename,'fig');
    
    %%
    % SCANFISH
    %close all
    h = figure;
    thelineS = colormap;
    
    plot_xyColor(          scan.(variable).data(:,4), ...
                   roundto(scan.(variable).data(:,1),5)*10e12+ roundto(scan.(variable).data(:,2),5)*10e4, ...
                           log10(scan.(variable).data(:,5)), ...
                           10, ...
                           flipud(thelineS), ...
                           'clim', ...
                           [1.8 2] ...
                           )
    
    posSw = [246         132        1320         564];
    set(gcf,'PaperPositionMode','auto')
    set(gcf,'Position',posSw)
    
    thecb = colorbar;
    a = log10([65 70 80 90 100]);set(thecb,'ytick',a,'yticklabel',10.^a)
    
    xlim([datenum('01-Jan-2003') datenum('01-Jan-2009')])
    xlabel('Time (dd.mm.yy)','fontsize',13)
    datetick('x','dd.mm.yy','keeplimits')
    ylim([2.5e13 7e13])
    ylabel('Location Index','fontsize',13)
    title('ScanFish: Upoly0 [-] in Time and Space','fontweight','bold','fontsize',14)
    set(gca,'fontsize',13)
    
    filename = [pwd,'\timeNspace_scanfish_turbidity'];
    disp(['saving : ',filename]);
    print('-dpng',filename);
    saveas(h,filename,'fig');