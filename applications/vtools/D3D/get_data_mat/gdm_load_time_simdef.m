%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18189 $
%$Date: 2022-06-22 17:07:25 +0800 (Wed, 22 Jun 2022) $
%$Author: chavarri $
%$Id: gdm_load_time_simdef.m 18189 2022-06-22 09:07:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_time_simdef.m $
%
%

function [nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef)

%% PARSE

if isfield(simdef,'file') && isfield(simdef.file,'mat') && isfield(simdef.file.mat,'dir')
    fdir_mat=simdef.file.mat.dir;
else
    fdir_mat='';
end

%% CALC

if simdef.D3D.structure==4
    fpath_pass=simdef.D3D.dire_sim;
else
    fpath_pass=simdef.file.map;
end

[nt,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime,sim_idx]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_pass,fdir_mat);

end %function
