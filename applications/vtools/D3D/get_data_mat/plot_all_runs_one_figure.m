%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: plot_all_runs_one_figure.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_all_runs_one_figure.m $
%
%Plot all runs in one figure

function plot_all_runs_one_figure(fid_log,in_plot,simdef,leg_str)

%% map_summerbed
tag_check='fig_map_summerbed_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig.leg_str=leg_str;
    plot_1D_01(fid_log,in_plot_fig,simdef)
end

%% his xt
tag_check='fig_his_xt_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig.leg_str=leg_str;
    plot_his_xt_01(fid_log,in_plot_fig,simdef)
end
    
%% his sal 01
tag_check='fig_his_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','all');
    in_plot_fig.leg_str=leg_str;
    plot_his_01(fid_log,in_plot_fig,simdef)
end

end %function