%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_map_summerbed_mat_name.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_map_summerbed_mat_name.m $
%

function fpath_mat_tmp=gdm_map_summerbed_mat_name(var_str_read,fdir_mat,tag,pol_name,time_dnum_loc,sb_pol)

switch var_str_read
    case 'ba' %variables without time dependency
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'pol',pol_name,'var',var_str_read,'sb',sb_pol);
    otherwise
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum_loc,'pol',pol_name,'var',var_str_read,'sb',sb_pol);
end

end %function