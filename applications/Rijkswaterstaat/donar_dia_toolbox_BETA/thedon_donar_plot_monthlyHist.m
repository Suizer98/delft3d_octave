% thedon_donar_plot_monthlyHist (no function)
    clc; close all, fclose all; clear;
    addpath('d:\Dropbox\Deltares\Matlab\donar_dia_toolbox_BETA\utilities\')
    
    thedonarfiles = { ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2008_the_compend.mat'; ...

        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\FerryBox_2008_the_compend.mat'; ...

        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2008_the_compend.mat'; ...
    };

    thefontsize = 20;
        
    ctd_cont   = 1;
    ferry_cont = 1;
    scan_cont  = 1;
    
    variable = 'turbidity';
    
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
            sensor_name = 'FerryBox';
            
            if ferry_cont == 1
                ferry.(variable) = donarMat.(variable);
            else
                ferry.(variable).data = [ferry.(variable).data; donarMat.(variable).data];
            end
            
            ferry_cont = ferry_cont+1;
        elseif strfind(lower(thedonarfiles{i}),'meetvis')
            sensor_name = 'ScanFish';
            
            if scan_cont == 1
                scan.(variable) = donarMat.(variable);
            else
                scan.(variable).data = [scan.(variable).data; donarMat.(variable).data];
            end
            
            scan_cont = scan_cont+1;
        end
        
        clear donarMat
    end
    
    %%
    close all
    
    histbin = [0:110/(12-1):110];
    donar_plot_monthlyHist(ctd,'CTD',variable,12,histbin)
    legend('CTD')
    fileName = ['monthly_hist_CTD_',variable];
    disp(['Saving ',fileName])
    print('-dpng',fileName);
    
    
    histbin = [0:50/(11-1):50];
    donar_plot_monthlyHist(ferry,'FB',variable,11,histbin)
    legend('FerryBox')
    fileName = ['monthly_hist_FerryBox_',variable];
    disp(['Saving ',fileName])
    print('-dpng',fileName);
    
    
    histbin = [0:110/(12-1):110];
    donar_plot_monthlyHist(scan,'SF',variable,12,histbin)
    legend('SCanFish')
    fileName = ['monthly_hist_ScanFish_',variable];
    disp(['Saving ',fileName])
    print('-dpng',fileName);
    