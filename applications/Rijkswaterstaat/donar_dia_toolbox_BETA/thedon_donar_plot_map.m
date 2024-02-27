function thedon_donar_plot_map
% thedon_donar_plot_map Box and Whisker diagram for all observations in TIME (MONTHS)  
    
    thedonarfiles = { ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\mat\CTD_2008_the_compend.mat'; ...
        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ferry\mat\FerryBox_2008_the_compend.mat'; ...
        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\mat\ScanFish_2008_the_compend.mat'}

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

    ctd.(variable).data(:,5)   = ctd.(variable).data(:,5);
    ferry.(variable).data(:,5) = ferry.(variable).data(:,5);
    scan.(variable).data(:,5)  = scan.(variable).data(:,5);
%%    
        close all;
        clc;
        thefontsize = 12;
        
        % CTD
        fctd = figure
        thelineS = flipud(colormap);
        plot_map('lonlat','color',[0.5,0.5,0.5]);
        hold on
        plot_xyColor(ctd.(variable).data(:,1),ctd.(variable).data(:,2),ctd.(variable).data(:,5),20,thelineS,'clim',[70 105]);
        h2 = colorbar('south','fontsize',thefontsize);
        initpos = get(h2,'Position');
        set(gcf,'position',[745   569   375   379]);
        set(gcf,'PaperPositionMode','auto');
        set(h2, 'Position',[initpos(1)+0.05, initpos(2) + 0.02, initpos(3)*0.7, initpos(4)*0.2], 'fontsize',8);
        title(['CTD: Upoly0 [-] 2003 - 2008'],'fontweight','bold');
        set(gca,'FontSize',thefontsize);
        fileName = ['d:\Dropbox\Deltares\MoS-3\reporting\Garcia Report\figures\themap_ctd_2003-2008.png'];
        print('-dpng',fileName);
        disp(['File: ',fileName,' -> Map. -- SAVED']);
        close all
        clear h2 
        
        % Ferrybox
        figure
        thelineS = colormap;
        plot_map('lonlat','color',[0.5,0.5,0.5]);
        hold on
        plot_xyColor(ferry.(variable).data(:,1),ferry.(variable).data(:,2),log10(ferry.(variable).data(:,5)),20,thelineS);
        h2 = colorbar('south','fontsize',thefontsize);
        initpos = get(h2,'Position');
        set(h2, 'Position',[initpos(1)+0.05, initpos(2) + 0.02, initpos(3)*0.7, initpos(4)*0.2], 'fontsize',8);
        a = [0.3 1 3 10 30 100];
        set(h2,'xtick',log10(a),'xticklabel',a)
        set(gcf,'position',[745   569   375   379])
        set(gcf,'PaperPositionMode','auto')
        title(['Ferrybox: Turbidity [NTU] 2003 - 2008'],'fontweight','bold')
        fileName = ['d:\Dropbox\Deltares\MoS-3\reporting\Garcia Report\figures\themap_ferrybox_2003-2008.png'];
        print('-dpng',fileName);
        disp(['File: ',fileName,' -> Map. -- SAVED'])
        close all
        clear h2 
        
        % Scanfish
        figure
        thelineS = flipud(colormap);
        plot_map('lonlat','color',[0.5,0.5,0.5]);
        hold on
        plot_xyColor(scan.(variable).data(:,1),scan.(variable).data(:,2),scan.(variable).data(:,5),20,thelineS,'clim',[70 100]);
        h2 = colorbar('south','fontsize',thefontsize);
        initpos = get(h2,'Position');
        set(h2, 'Position',[initpos(1)+0.05, initpos(2) + 0.02, initpos(3)*0.7, initpos(4)*0.2], 'fontsize',8);
        set(gcf,'position',[745   569   375   379])
        set(gcf,'PaperPositionMode','auto')
        title(['Scanfish: Upoly0 [-] 2003 - 2008'],'fontweight','bold')
        fileName = ['d:\Dropbox\Deltares\MoS-3\reporting\Garcia Report\figures\themap_scanfish__2003-2008.png'];
        print('-dpng',fileName);
        disp(['File: ',fileName,' -> Map. -- SAVED'])
        close all
        clear h2 