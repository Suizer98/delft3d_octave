
%thedon_donar_plot_depth_profiles_CTD (no function)

    addpath([pwd,'\utilities\'])
    clc; clear; close all, fclose all;
    
    
    % 1. Input files
    files_of_interest = { ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2003_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2004_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2005_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2006_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2007_the_compend.mat'; ...
        'p:\1204561-noordzee\data\svnchkout\donar_dia\raw_mat_nc\dia_ctd\raw\CTD_2008_the_compend.mat'; ...
    };

    warning off;
    

    % 2. Specify names of sensors:
    sensors = {'CTD';'FerryBox';'ScanFish'};
    
    
    %% 3. Make the plots
    for ifile=1:length(files_of_interest)
        if strfind(lower(files_of_interest{ifile}),'ctd')
            sensor      = sensors{1};
        elseif strfind(lower(files_of_interest{ifile}),'ferrybox')
            sensor      = sensors{2};
        elseif strfind(lower(files_of_interest{ifile}),'scanfish')
            sensor      = sensors{3};
        end
        
        disp(['Loading: ',files_of_interest{ifile}]);
        thefile = importdata(files_of_interest{ifile});
                
        fig_name = ['depth_profiles_',files_of_interest{ifile}(max(strfind(files_of_interest{ifile},'\'))+1:strfind(files_of_interest{ifile},'_the_compend.mat')-1)];
        
        donar_plot_depth_profiles(thefile,'turbidity',fig_name)
        
    end