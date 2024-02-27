%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 17:17:04 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: NC_read_time_0.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_time_0.m $
%
%read time 0 properties

function [t0_dtime,units,tzone,tzone_num]=NC_read_time_0(nc_map)
nci=ncinfo(nc_map);
idx=find_str_in_cell({nci.Variables.Name},{'time'});
idx_units=strcmp({nci.Variables(idx).Attributes.Name},'units');
str_time=nci.Variables(idx).Attributes(idx_units).Value;
[t0_dtime,units,tzone,tzone_num]=read_str_time(str_time);

end %function
