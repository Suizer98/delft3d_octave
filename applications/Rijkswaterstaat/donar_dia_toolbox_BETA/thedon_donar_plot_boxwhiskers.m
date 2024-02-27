%% Box and Whisker diagram for all observations in TIME (MONTHS) (no function)
% thedon_donar_plot_boxwhiskers Box and Whisker diagram for all observations in TIME (MONTHS)

OPT.diadir = 'p:\1204561-noordzee\data\raw\RWS\';
OPT.diadir = 'p:\1209005-eutrotracks\raw\';

if true
    
    thedonarfiles = { ...
        'CTD\mat\CTD_2003_the_compend.mat'; ...
        'CTD\mat\CTD_2004_the_compend.mat'; ...
        'CTD\mat\CTD_2005_the_compend.mat'; ...
        'CTD\mat\CTD_2006_the_compend.mat'; ...
        'CTD\mat\CTD_2007_the_compend.mat'; ...
        'CTD\mat\CTD_2008_the_compend.mat'; ...
        
        'FerryBox\mat\FerryBox_2005_the_compend.mat'; ...
        'FerryBox\mat\FerryBox_2006_the_compend.mat'; ...
        'FerryBox\mat\FerryBox_2007_the_compend.mat'; ...
        'FerryBox\mat\FerryBox_2008_the_compend.mat'; ...
        
        'ScanFish\mat\ScanFish_2003_the_compend.mat'; ...
        'ScanFish\mat\ScanFish_2004_the_compend.mat'; ...
        'ScanFish\mat\ScanFish_2005_the_compend.mat'; ...
        'ScanFish\mat\ScanFish_2006_the_compend.mat'; ...
        'ScanFish\mat\ScanFish_2007_the_compend.mat'; ...
        'ScanFish\mat\ScanFish_2008_the_compend.mat'; ...
        'ScanFish\mat\ScanFish_2009_the_compend.mat' ...
    };

    ctd_cont   = 1;
    ferry_cont = 1;
    scan_cont  = 1;
    
    thevariable = 'turbidity';
    
    for i = 1:length(thedonarfiles)
        
        disp(['Loading: ',thedonarfiles{i}]);
        [OPT.diadir,filesep,thedonarfiles{i}]
        donarMat = importdata([OPT.diadir,filesep,thedonarfiles{i}]);
        
        if strfind(lower([OPT.diadir,filesep,thedonarfiles{i}]),'ctd')
            sensor_name = 'CTD'; 

            if ctd_cont == 1
                ctd.(thevariable) = donarMat.(thevariable);
            else
                ctd.(thevariable).data = [ctd.(thevariable).data; donarMat.(thevariable).data];
            end
            
            ctd_cont = ctd_cont+1;
        elseif strfind(lower([OPT.diadir,filesep,thedonarfiles{i}]),'ferry')
            sensor_name = 'Ferrybox';
            
            if ferry_cont == 1
                ferry.(thevariable) = donarMat.(thevariable);
            else
                ferry.(thevariable).data = [ferry.(thevariable).data; donarMat.(thevariable).data];
            end
            
            ferry_cont = ferry_cont+1;
        elseif strfind(lower([OPT.diadir,filesep,thedonarfiles{i}]),'meetvis')
            sensor_name = 'Meetvis';
            
            if scan_cont == 1
                scan.(thevariable) = donarMat.(thevariable);
            else
                scan.(thevariable).data = [scan.(thevariable).data; donarMat.(thevariable).data];
            end
            
            scan_cont = scan_cont+1;
        end
        
        clear donarMat
    end
    
%%
close all

    donar_plot_boxwhiskers(ctd,thevariable,'CTD',20);
    ylabel(['Upoly0 [-]'])
    fileName = ['boxplot_CTD_turbidity'];
    print('-dpng',fileName);
    
    donar_plot_boxwhiskers(ferry,thevariable,'FerryBox',20);
    fileName = ['boxplot_FerryBox_turbidity'];
    print('-dpng',fileName);
       
    ferry_clipped = ferry;
    ferry_clipped.(thevariable).data( ferry_clipped.(thevariable).data(:,5) > 2.9, : ) = [];
    donar_plot_boxwhiskers(ferry_clipped,thevariable,'FerryBox',20);
    fileName = ['boxplot_FerryBox_turbidity_0-3'];
    print('-dpng',fileName);
    
    donar_plot_boxwhiskers(scan,thevariable,'ScanFish',20);
    ylabel(['Upoly0 [-]'])
    fileName = ['boxplot_ScanFish_turbidity'];
    print('-dpng',fileName);
    
end