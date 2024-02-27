%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: uniform_data.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/filter/uniform_data.m $
%
%

function [time_uni,data_uni]=uniform_data(time_dtime,data)

% time_dnum=datenum(time_dtime); %we do operations in +00:00

% dt=diff(time_dtime);
dt_dtime_v=diff(time_dtime);
dt_dtime=dt_dtime_v(1); 
% if any(abs(dt-dt(1))>1e-8)
if any(abs(dt_dtime_v-dt_dtime)>seconds(1))
    time_uni=time_dtime(1):dt_dtime:time_dtime(end); %make input the step?
    data_uni=interpolate_timetable({time_dtime},{data},time_uni,'disp',0);
else
    time_uni=time_dtime;
    data_uni=data;
end
