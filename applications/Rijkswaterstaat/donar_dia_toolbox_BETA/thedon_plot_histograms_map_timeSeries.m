%% Make time plots and histograms.
%thedon_plot_histograms_map_timeSeries Make time plots and histograms.
    clc; clear; close all, fclose all;
    addpath([pwd,'\utilities\'])
    
     files_of_interest = { ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2003_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\CTD_2004_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2005_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2006_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2007_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_ctd\CTD_2008_the_compend.mat'; ...
        
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ferry\raw\FerryBox_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ferry\raw\FerryBox_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ferry\raw\FerryBox_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ferry\raw\FerryBox_2008_the_compend.mat'; ...
        
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2003_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2004_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2005_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2006_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2007_the_compend.mat'; ...
%         'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_and_nc\dia_meetvis\ScanFish_2008_the_compend.mat'; ...
    };

    warning off;

    %% 
    for ifile = 1:1:length(files_of_interest)

        if strfind(lower(files_of_interest{ifile}),'ctd')
            sensor_name = 'CTD'; 
        elseif strfind(lower(files_of_interest{ifile}),'ferry')
            sensor_name = 'FerryBox';
        elseif strfind(lower(files_of_interest{ifile}),'meetvis')
            sensor_name = 'ScanFish';
        end
    

        year = donar_plot_histograms(files_of_interest{ifile},'turbidity',12);
        if strcmpi(sensor_name,'ctd') || strcmpi(sensor_name,'ScanFish')
            title(['Upoly0 ',datestr(year,'yyyy')],'fontweight','bold')
            legend(sensor_name,'location','northwest')
        else
            legend(sensor_name,'location','northeast')
        end
        ylabel('Number of Measurements')
        fileName = ['d:\Dropbox\Deltares\MoS-3\Garcia Report\figures\histograms\thehist_',sensor_name,'_',datestr(year,'yyyy'),'.png'];
        print('-dpng',[fileName]);
        disp(['File: ',fileName,' -> Histogram. -- SAVED'])        
        close
        


        % FERRY
        theyear =donar_plot_map(files_of_interest{ifile},'turbidity',12);
        set(gcf,'position',[234   325   886   623])
        set(gcf,'PaperPositionMode','auto')
        
        % Where to save 
        fileName = [pwd,'\themap_',sensor_name,'_',datestr(theyear,'yyyy'),'.png'];
        print('-dpng',fileName);
        disp(['File: ',fileName,' -> Map. -- SAVED'])
        close(f);
        
        
        
        
        
        % SCANFISH
        year = donar_plot_timeSeries(files_of_interest{ifile},'turbidity',12);
        title(datestr(year,'yyyy'),'fontweight','bold')
        if strcmpi(sensor_name,'ctd') || strcmpi(sensor_name,'ScanFish')
            ylabel('Upoly0')
            legend(sensor_name,'location','best')
        else
            ylabel('Turbidity')
            legend(sensor_name,'location','best')
        end
        fileName = [pwd,'\timePlot_',sensor_name,'_',datestr(year,'yyyy'),'.png'];
        print('-dpng',fileName);
        disp(['File: ',fileName,' -> Time Plot. -- SAVED']);
        close
    end