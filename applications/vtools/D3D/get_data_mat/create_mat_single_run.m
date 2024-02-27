%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: create_mat_single_run.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_single_run.m $
%
%Create mat-files of a single run

function create_mat_single_run(fid_log,in_plot,simdef)

%% display time
tag_check='disp_time_map';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    disp_time_map(fid_log,in_plot_fig,simdef);
end

%% grid
tag_check='fig_grid_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_grid_01(fid_log,in_plot_fig,simdef);
end

%% sal
tag_check='fig_map_sal_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_sal_01(fid_log,in_plot_fig,simdef)
end

%% ls 
tag_check='fig_map_ls_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_ls_01(fid_log,in_plot_fig,simdef)
end

%% sal mass
if isfield(in_plot,'fig_map_sal_mass_01')==1
    messageOut(fid_log,'Outdated. Call <fig_map_2DH_01> with variable <clm2>')
%         create_mat_map_sal_mass_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
%         create_mat_map_sal_mass_cum_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)
end

%% q
tag_check='fig_map_q_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_q_01(fid_log,in_plot_fig,simdef)
end

%% his sal
if isfield(in_plot,'fig_his_sal_01')==1
    warning('deprecate and call <his_01>')
%         create_mat_his_sal_01(fid_log,in_plot.fig_his_sal_01,simdef)
end

%% his
tag_check='fig_his_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_his_01(fid_log,in_plot_fig,simdef)
end

%% sal 3D
tag_check='fig_map_sal3D_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_sal3D_01(fid_log,in_plot_fig,simdef)
end

%% map summerbed
tag_check='fig_map_summerbed_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_summerbed_01(fid_log,in_plot_fig,simdef)
    pp_sb_var_01(fid_log,in_plot_fig,simdef)
    if isfield(in_plot_fig,'tim_ave') && ~isnan(in_plot_fig.tim_ave)
        pp_sb_tim_ave_01(fid_log,in_plot_fig,simdef)
    end
%     pp_sb_var_cum_01(fid_log,in_plot_fig,simdef) %not really needed. We are already loading all the data in the plot part for the xtv plot
end

%% map 2DH
tag_check='fig_map_2DH_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_2DH_01(fid_log,in_plot_fig,simdef)
    pp_mat_map_2DH_cum_01(fid_log,in_plot_fig,simdef) %compute integrated amount over surface with time    
end

%% map 2DH ls
tag_check='fig_map_2DH_ls_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_2DH_ls_01(fid_log,in_plot_fig,simdef)
end

%% his sal meteo
tag_check='fig_his_sal_meteo_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_his_sal_meteo_01(fid_log,in_plot_fig,simdef)
end

%% observation stations
tag_check='fig_his_obs_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_his_obs_01(fid_log,in_plot_fig,simdef)
end

%% map 1D
tag_check='fig_map_1D_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_1D(fid_log,in_plot_fig,simdef)
end

%% his xt
tag_check='fig_his_xt_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_his_xt_01(fid_log,in_plot_fig,simdef)
end

%% map sedtransoff
tag_check='fig_map_sedtransoff_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    create_mat_map_sedtransoff_01(fid_log,in_plot_fig,simdef)
end

end %function