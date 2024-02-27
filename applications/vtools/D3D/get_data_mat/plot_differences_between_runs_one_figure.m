%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: plot_differences_between_runs_one_figure.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_differences_between_runs_one_figure.m $
%
%Plot differences between runs in one figure

function plot_differences_between_runs_one_figure(fid_log,in_plot,simdef_ref,simdef,leg_str)

str_fig='diff_all';

%% his sal 01
tag_check='fig_his_sal_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig',str_fig);
    in_plot_fig.leg_str=leg_str;
    plot_his_sal_diff_01(fid_log,in_plot.fig_his_sal_01,simdef_ref,simdef)
end

%% map 2DH ls
tag_check='fig_map_2DH_ls_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig',str_fig);
    in_plot_fig.leg_str=leg_str;
    plot_map_2DH_ls_diff_01(fid_log,in_plot_fig,simdef_ref,simdef)
end

%% map 1D
tag_check='fig_map_1D_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig',str_fig);
    in_plot_fig.leg_str=leg_str;
    plot_map_1D_xv_diff_01(fid_log,in_plot_fig,simdef_ref,simdef);
end

end %function 