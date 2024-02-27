%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17302 $
%$Date: 2021-05-20 20:22:49 +0800 (Thu, 20 May 2021) $
%$Author: chavarri $
%$Id: paths_data_stations.m 17302 2021-05-20 12:22:49Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/paths_data_stations.m $
%

function paths=paths_data_stations(paths_main_folder)

paths.main_folder=paths_main_folder;
paths.data_stations=fullfile(paths.main_folder,'data_stations.mat');
paths.data_stations_index=fullfile(paths.main_folder,'data_stations_index.mat');
paths.separate=fullfile(paths.main_folder,'separate');
paths.figures=fullfile(paths.main_folder,'figures');

end