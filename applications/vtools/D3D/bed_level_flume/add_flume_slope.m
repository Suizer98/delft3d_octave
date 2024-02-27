%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16769 $
%$Date: 2020-11-05 18:40:08 +0800 (Thu, 05 Nov 2020) $
%$Author: chavarri $
%$Id: add_flume_slope.m 16769 2020-11-05 10:40:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/bed_level_flume/add_flume_slope.m $
%

function z_out=add_flume_slope(geom,x,y,z_in)

L_flume=geom.L_flume;
s_flume=geom.s_flume;

z_out=z_in+s_flume*(L_flume-x);

end