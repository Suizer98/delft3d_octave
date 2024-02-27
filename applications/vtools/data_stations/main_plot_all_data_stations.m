%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18286 $
%$Date: 2022-08-09 19:35:55 +0800 (Tue, 09 Aug 2022) $
%$Author: chavarri $
%$Id: main_plot_all_data_stations.m 18286 2022-08-09 11:35:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/main_plot_all_data_stations.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\'; %path to this folder in OET
addpath(path_add_fcn)
addOET(path_add_fcn) 

%% INPUT

paths_main_folder='C:\Users\chavarri\checkouts\riv\data_stations\'; %path to <data_stations>

%% PATHS

paths=paths_data_stations(paths_main_folder);

%% CALC

load(paths.data_stations_index);

%% PLOT

ns=numel(data_stations_index);
for ks=1:ns
    fname=fullfile(paths.figures,sprintf('%06d',ks));
    fnameext=sprintf('%s.png',fname);
    if exist(fnameext,'file')~=2
        load(fullfile(paths.separate,sprintf('%06d.mat',ks)),'data_one_station');

        in_p.fname=fname;
        in_p.data_station=data_one_station;
        in_p.fig_print=1;
        in_p.fig_visible=0;

        fig_data_station(in_p)
    end
    fprintf('done %4.2f %% \n',ks/ns*100)
end %ks


