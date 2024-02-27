%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: NC_read_map_01.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_map_01.m $
%
%OUTPUT:
%   -z = variable (nF,nsvar)
%
%nF = number of faces
%nsvar = number of subvariables

function out=NC_read_map_01(simdef,in,grd_in)

fpath_map=simdef.file.map;
v2struct(grd_in);
is1d=simdef.flg.is1d;
ismor=simdef.flg.ismor;

switch simdef.D3D.structure
    case 2 %FM
        if is1d
            if ismor
                out=NC_read_map_get_fm1d_data('mesh1d_mor_bl',fpath_map,in,branch,offset,x_node,y_node,branch_length,branch_id);
            else
                out=NC_read_map_get_fm1d_data('mesh1d_flowelem_bl',fpath_map,in,branch,offset,x_node,y_node,branch_length,branch_id);
            end
        else
            if simdef.flg.get_EHY
                if ismor==0
                    z=NC_read_map_get_EHY(fpath_map,'mesh2d_flowelem_bl',NaN,'t',in.kt(1));
                else
                    z=NC_read_map_get_EHY(fpath_map,'mesh2d_mor_bl',NaN,'t',in.kt(1));
                end
                out=v2struct(z,face_nodes_x,face_nodes_y);
            else
                if ismor==0
                    z=ncread(fpath_map,'mesh2d_flowelem_bl',kF(1),kF(2));
                else
                    z=ncread(fpath_map,'mesh2d_mor_bl',[kF(1),kt(1)],[kF(2),kt(2)]);
                end
                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
            end
        end
    case 3 %SOBEK3
        out_wl=NC_read_map_get_sobek3_data('water_level',fpath_map,in,branch,offset,x_node,y_node,branch_length,branch_id);
        out_h=NC_read_map_get_sobek3_data('water_depth',fpath_map,in,branch,offset,x_node,y_node,branch_length,branch_id);

        out=out_wl;
        out.z=out_wl.z-out_h.z;
end
out.zlabel='bed elevation [m]';


[var_str_read,var_id,var_str_save]=D3D_var_num2str(simdef.flg.which_v);
out.zlabel=labels4all(var_str_read,1,'en');

end %function