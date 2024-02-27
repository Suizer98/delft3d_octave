%% Make time plots and histograms.
% thedon_plot_campaign_map Make time plots and histograms.
    clc; clear; close all, fclose all; clear;
    % 1. Input files
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
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_meetvis\raw\ScanFish_2008_the_compend.mat'; ...
    };


    % 2. Some initializations
    warning off;
    
    ctd_cont   = 1;
    ferry_cont = 1;
    scan_cont  = 1;
    
    
    
    % 3. Variable of interest
    variable = 'turbidity';
    
    
    
    % 4. Load the information that we will be using
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
    %% MAKE THE PLOTS        
    
        ctd.turbidity.data( ctd.turbidity.data(:,5) < 60,: ) =[];
        donar_plot_campaign_maps(ctd,'turbidity',[pwd,filesep],20,20);
        title('CTD: Upoly0 [-]','fontweight','bold')
        fileName = 'themap_CTD_turbidity';
        print('-dpng',fileName);
        close;
        
        ferry.turbidity.data( ferry.turbidity.data(:,5) > 3,: ) =[];
        donar_plot_campaign_maps(ferry,'turbidity',[pwd,filesep],20,5);
        title('FerryBox: Turbidity [NTU]','fontweight','bold')
        fileName = 'themap_FerryBox_turbidity';
        print('-dpng',fileName);
        close;
        
        scan.turbidity.data( scan.turbidity.data(:,5) < 60,: ) =[];
        donar_plot_campaign_maps(scan,'turbidity',[pwd,filesep],20,20);
        title('ScanFish: Upoly0 [-]','fontweight','bold')
        fileName = 'themap_ScanFish_turbidity';
        print('-dpng',fileName);
        close;
