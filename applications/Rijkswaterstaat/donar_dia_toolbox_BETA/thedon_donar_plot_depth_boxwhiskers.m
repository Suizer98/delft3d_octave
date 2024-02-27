%% Box and Whisker diagram for all observations in DEPTH (no function)
% thedon_donar_plot_depth_boxwhiskers Box and Whisker diagram for all observations in DEPTH
   % clear; 

OPT.diadir = 'p:\1204561-noordzee\data\svnchkout\donar_dia\';
    
if true

    thedonarfiles = { ...
        'raw_and_nc\dia_ctd\mat\CTD_2003_the_compend.mat'; ...
        'raw_and_nc\dia_ctd\mat\CTD_2004_the_compend.mat'; ...
        'raw_and_nc\dia_ctd\mat\CTD_2005_the_compend.mat'; ...
        'raw_and_nc\dia_ctd\mat\CTD_2006_the_compend.mat'; ...
        'raw_and_nc\dia_ctd\mat\CTD_2007_the_compend.mat'; ...
        'raw_and_nc\dia_ctd\mat\CTD_2008_the_compend.mat'; ...
         
        'raw_and_nc\dia_meetvis\mat\ScanFish_2003_the_compend.mat'; ...
        'raw_and_nc\dia_meetvis\mat\ScanFish_2004_the_compend.mat'; ...
        'raw_and_nc\dia_meetvis\mat\ScanFish_2005_the_compend.mat'; ...
        'raw_and_nc\dia_meetvis\mat\ScanFish_2006_the_compend.mat'; ...
        'raw_and_nc\dia_meetvis\mat\ScanFish_2007_the_compend.mat'; ...
        'raw_and_nc\dia_meetvis\mat\ScanFish_2008_the_compend.mat'; ...
        'raw_and_nc\dia_meetvis\mat\ScanFish_2009_the_compend.mat' ...
    };
    sensors = {'CTD';'FerryBox';'ScanFish'};


    thevariable = 'sea_water_salinity'
    
    cont_ctd      = 1;
    cont_scanfish = 1;
    for i=1:length(thedonarfiles)
        
        disp(['Loading: ',[OPT.diadir,filesep,thedonarfiles{i}]]);
        thefile = importdata([OPT.diadir,filesep,thedonarfiles{i}]);

        
        if strfind(lower([OPT.diadir,filesep,thedonarfiles{i}]),'ctd'),           
            
            sensor = sensors{1};
            
            if cont_ctd == 1
                ctd.(thevariable) = thefile.(thevariable);
            else
                ctd.(thevariable).data = [ctd.(thevariable).data; thefile.(thevariable).data];
            end    
            cont_ctd = cont_ctd + 1;
            
        elseif strfind(lower([OPT.diadir,filesep,thedonarfiles{i}]),'scanfish'),  
            
            
            sensor = sensors{3};
            
            if cont_scanfish == 1
                scanfish.(thevariable) = thefile.(thevariable);
            else
                scanfish.(thevariable).data = [scanfish.(thevariable).data; thefile.(thevariable).data];
            end    
            cont_scanfish = cont_scanfish + 1;
            
        end
        
        
    end
%%
    close all
    
    donar_plot_depth_boxwhiskers(ctd,'CTD',thevariable,15,20);
    %ylabel('Upoly0 [-]','fontsize',20)
    ylabel('Salinity [PSU]','fontsize',20)
    fileName = ['depth_boxw_CTD_',thevariable];
    print('-dpng',fileName);
    
    donar_plot_depth_boxwhiskers(scanfish,'Scanfish',thevariable,15,20);
    %ylabel('Upoly0 [-]','fontsize',20)
    ylabel('Salinity [PSU]','fontsize',20)
    fileName = ['depth_boxw_scanfish_',thevariable];
    print('-dpng',fileName);
    
    
end    