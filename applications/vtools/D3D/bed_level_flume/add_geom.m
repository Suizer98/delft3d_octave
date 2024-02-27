%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16769 $
%$Date: 2020-11-05 18:40:08 +0800 (Thu, 05 Nov 2020) $
%$Author: chavarri $
%$Id: add_geom.m 16769 2020-11-05 10:40:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/bed_level_flume/add_geom.m $
%

function z=add_geom(geom,x,y)

z=0;

z=add_flume_slope(geom,x,y,z);

z=add_floodplane(geom,x,y,z);

z_groyne_field=add_groyne_field(geom,x,y,z);
% z_groyne_field=0;

z_groynes=add_groynes(geom,x,y,z);
% z_groynes=0;

z=max(z_groyne_field,z_groynes);

end %function