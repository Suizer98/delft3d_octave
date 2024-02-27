%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 17:17:04 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: data_stations_get_file_name.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/data_stations_get_file_name.m $
%

function fname=data_stations_get_file_name(paths_main_folder,idx)
paths=paths_data_stations(paths_main_folder);
fname=fullfile(paths.separate,sprintf('%06d.mat',idx));
