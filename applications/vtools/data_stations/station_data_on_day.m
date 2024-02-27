%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 21:24:14 +0800 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: station_data_on_day.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/station_data_on_day.m $
%
%get value at station for a certain time

function [val,time_diff]=station_data_on_day(paths_main_folder,dtime,varargin)

[data_stations,~]=read_data_stations(paths_main_folder,varargin{:});
[time_diff,idx_get]=min(abs(data_stations.time-dtime));
val=data_stations.waarde(idx_get);

end