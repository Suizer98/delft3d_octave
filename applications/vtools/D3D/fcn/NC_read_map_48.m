%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: NC_read_map_48.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_map_48.m $
%
%OUTPUT:
%   -z = variable (nF,nsvar)
%
%nF = number of faces
%nsvar = number of subvariables

function out=NC_read_map_48(simdef,in,grd_in)

fpath_map=simdef.file.map;
v2struct(grd_in);
is1d=simdef.flg.is1d;
ismor=simdef.flg.ismor;

switch simdef.D3D.structure
    case 2 %FM
        if is1d
            error('do')
            out=get_fm1d_data('mesh1d_thlyr',fpath_map,in,branch,offset,x_node,y_node,branch_length,branch_id);
        else
            if simdef.flg.get_EHY
                zx=NC_read_map_get_EHY(fpath_map,'mesh2d_sxtot',NaN,'t',in.kt(1));
                zy=NC_read_map_get_EHY(fpath_map,'mesh2d_sytot',NaN,'t',in.kt(1));
                z=hypot(sum(zx,2),sum(zy,2)); %second dimension is fractions
                out=v2struct(z,face_nodes_x,face_nodes_y);
            else
                error('do')
                z=ncread(fpath_map,'mesh2d_thlyr',[1,kF(1),kt(1)],[Inf,kF(2),kt(2)]);
                out=v2struct(z,x_node,y_node,x_face,y_face,faces);
            end
        end
end

[var_str_read,var_id,var_str_save]=D3D_var_num2str(simdef.flg.which_v);
out.zlabel=labels4all(var_str_read,1,'en');

end %function