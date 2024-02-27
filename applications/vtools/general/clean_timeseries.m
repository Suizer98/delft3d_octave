%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 21:24:14 +0800 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: clean_timeseries.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/clean_timeseries.m $
%
%clear time series

function [tim,val]=clean_timeseries(tim,val,TimeStep)

data_r=timetable(tim,val);
data_r=rmmissing(data_r);
data_r=sortrows(data_r);
tim_u=unique(data_r.tim);
data_r=retime(data_r,tim_u,'mean'); 
data_r=retime(data_r,'regular','linear','TimeStep',TimeStep);
tim=data_r.tim;
val=data_r.val;