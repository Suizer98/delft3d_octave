%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: plot_individual_runs.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_individual_runs.m $
%
%Plot results of a single run
    
function plot_individual_runs(fid_log,in_plot,simdef)
    
%% grid
tag_check='fig_grid_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_grid_01(fid_log,in_plot_fig,simdef)
end

%% map_sal_01
tag_check='fig_map_sal_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_map_sal_01(fid_log,in_plot_fig,simdef)
end

%% map_ls_01
tag_check='fig_map_ls_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_map_ls_01(fid_log,in_plot_fig,simdef)
end

%% map_ls_02
tag_check='fig_map_ls_02';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_map_ls_02(fid_log,in_plot_fig,simdef)
end

%% sal mass
if isfield(in_plot,'fig_map_sal_mass_01')==1
    messageOut(fid_log,'Outdated. Call <fig_map_2DH_01> with variable <clm2>')
%         plot_map_sal_mass_01(fid_log,in_plot.fig_map_sal_mass_01,simdef)

%         in_plot_loc=in_plot.fig_map_sal_mass_01;
%         in_plot_loc.tag=strcat(in_plot.fig_map_sal_mass_01.tag,'_cum');
%         in_plot_loc.tag_tim=in_plot.fig_map_sal_mass_01.tag;
% 
%         plot_tim_y(fid_log,in_plot_loc,simdef)
end

%% q
tag_check='fig_map_q_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_map_q_01(fid_log,in_plot_fig,simdef)
end

%% his sal 01
if isfield(in_plot,'fig_his_sal_01')==1
    warning('deprecate and call <his_01>')
%         plot_his_sal_01(fid_log,in_plot.fig_his_sal_01,simdef)
end

%% his 01
tag_check='fig_his_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_his_01(fid_log,in_plot_fig,simdef)
end

%% sal 3D
tag_check='fig_map_sal3D_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_map_sal3D_01(fid_log,in_plot_fig,simdef)
end

%% map_summerbed
tag_check='fig_map_summerbed_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_1D_01(fid_log,in_plot_fig,simdef);
    if isfield(in_plot_fig,'sb_pol_diff') && ~isnan(in_plot_fig.sb_pol_diff)
        plot_1D_sb_diff_01(fid_log,in_plot_fig,simdef)
    end
    if isfield(in_plot_fig,'tim_ave') && ~isnan(in_plot_fig.tim_ave)
        in_plot_fig.tag_fig=sprintf('%s_tim_ave',in_plot_fig.tag);
        plot_1D_tim_ave_01(fid_log,in_plot_fig,simdef)
    end
end

%% map 2DH
tag_check='fig_map_2DH_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_map_2DH_01(fid_log,in_plot_fig,simdef)
    plot_map_2DH_cum_01(fid_log,in_plot_fig,simdef)
end

%% map 2DH ls
tag_check='fig_map_2DH_ls_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_map_2DH_ls_01(fid_log,in_plot_fig,simdef)
end

%% his sal meteo
tag_check='fig_his_sal_meteo_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_his_sal_meteo_01(fid_log,in_plot_fig,simdef)
end

%% observation stations
tag_check='fig_his_obs_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_his_obs_01(fid_log,in_plot_fig,simdef)
end

%% map 1D
tag_check='fig_map_1D_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_map_1D_xv_01(fid_log,in_plot_fig,simdef);
    %create part to plot all simulations in one plot
end

%% his xt
tag_check='fig_his_xt_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check);
    plot_his_xt_01(fid_log,in_plot_fig,simdef)
end

end %function