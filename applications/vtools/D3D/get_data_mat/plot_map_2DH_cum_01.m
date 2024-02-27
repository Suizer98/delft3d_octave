%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: plot_map_2DH_cum_01.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_cum_01.m $
%
%

function plot_map_2DH_cum_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

% fdir_mat=simdef.file.mat.dir;
% fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
% fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% DIMENSIONS

nvar=numel(flg_loc.var);

%% LOOP VAR
for kvar=1:nvar
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef);
    
    switch var_str
        case 'clm2'
            flg_loc_2=flg_loc;
            flg_loc_2.tag=strcat(flg_loc.tag,'_cum');
            flg_loc_2.tag_tim=flg_loc.tag;

            plot_tim_y(fid_log,flg_loc_2,simdef,var_str)

        otherwise %no cummulative value over surface
    end
            
end %kvar


end %function

%% 
%% FUNCTION
%%
