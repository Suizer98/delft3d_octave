%% 
%thedon_scatVarXdepth
clc; close all, fclose all; clear;

the_donar_files = { ...        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2008_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2009_the_compend.mat'; ...
    
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2003_the_compend.mat'; ...    
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2004_the_compend.mat'; ...    
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2005_the_compend.mat'; ...    
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2006_the_compend.mat'; ...    
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2007_the_compend.mat'; ...    
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2008_the_compend.mat'; ...    
        };
    

    ctd_cont   = 1;
    scan_cont  = 1;
    variable = 'turbidity';
    
for ifile = 1:length(the_donar_files)
    
    disp(['Loading: ',the_donar_files{ifile}]);
    donarMat = importdata(the_donar_files{ifile});
    
    if strfind(lower(the_donar_files{ifile}),'ctd')
        
        if ctd_cont == 1
            ctd.(variable) = donarMat.(variable);
        else
            ctd.(variable).data = [ctd.(variable).data; donarMat.(variable).data];
        end
        ctd_cont = ctd_cont+1;
        
    elseif strfind(lower(the_donar_files{ifile}),'meetvis')
        
        if scan_cont == 1
            scan.(variable) = donarMat.(variable);
        else
            scan.(variable).data = [scan.(variable).data; donarMat.(variable).data];
        end
        scan_cont = scan_cont+1;
    end

end

%%
close all
donar_plot_scatVarXdepth(ctd,'CTD',variable,15);
title('CTD: 2003 - 2008','fontsize',15,'fontweight','bold')
xlabel('Upoly0 [-]','fontsize',15)
fileName = ['CTD_scatVarXdepth_',variable];
print('-dpng',fileName);
%close

%%
close all
donar_plot_scatVarXdepth(scan,'ScanFish',variable,15);
title('ScanFish: 2003 - 2009','fontsize',15,'fontweight','bold')
xlabel('Upoly0 [-]','fontsize',15)
fileName = ['ScanFish_scatVarXdepth_',variable];
print('-dpng',fileName);
%close