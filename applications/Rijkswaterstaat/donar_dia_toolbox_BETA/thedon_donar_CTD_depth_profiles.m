function thedon_donar_CTD_depth_profiles
%thedon_donar_CTD_depth_profiles wrapper for donar_depth_profiles
%
%See also: donar_depth_profiles

OPT.diadir = 'p:\1204561-noordzee\data\raw\RWS\';
OPT.diadir = 'p:\1209005-eutrotracks\raw\';

thedonarfiles = { ...
    'CTD\mat\CTD_2003_the_compend.mat'; ...
    'CTD\mat\CTD_2004_the_compend.mat'; ...
    'CTD\mat\CTD_2005_the_compend.mat'; ...
    'CTD\mat\CTD_2006_the_compend.mat'; ...
    'CTD\mat\CTD_2007_the_compend.mat'; ...
    'CTD\mat\CTD_2008_the_compend.mat'; ...
};

warning off;
    
%% Specify names of sensors to be processed

    sensors = {'CTD';'FerryBox';'ScanFish'};
    
    for i=1:length(thedonarfiles)
        if strfind(lower(thedonarfiles{i}),'ctd')
            sensor      = sensors{1};
        elseif strfind(lower(thedonarfiles{i}),'ferrybox')
            sensor      = sensors{2};
        elseif strfind(lower(thedonarfiles{i}),'scanfish')
            sensor      = sensors{3};
        end
        
        disp(['Loading: ',OPT.diadir,filesep,thedonarfiles{i}]);
        thefile = importdata([OPT.diadir,filesep,thedonarfiles{i}]);
                
        fig_name = ['depth_profiles_',thedonarfiles{i}(max(strfind(thedonarfiles{i},'\'))+1:strfind(thedonarfiles{i},'_the_compend.mat')-1)];
        
        donar_depth_profiles(thefile,'turbidity',fig_name)
        
    end