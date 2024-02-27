%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: plot_differences_between_runs.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_differences_between_runs.m $
%
%Plot differences between runs

function plot_differences_between_runs(fid_log,in_plot,simdef_ref,simdef)
        
%% map_sal_01
if isfield(in_plot,'fig_map_sal_01')==1
    messageOut(fid_log,'Outdated. Call <fig_map_2DH_01> with variable <sal>')
%             in_plot_loc=in_plot_loc.fig_map_sal_01;
%             in_plot_loc.tag_fig=sprintf('%s_diff',in_plot_loc.tag);
%             plot_map_sal_diff_01(fid_log,in_plot_loc,simdef_ref,simdef)
end

%% sal mass  
if isfield(in_plot,'fig_map_sal_mass_01')==1
    messageOut(fid_log,'Outdated. Call <fig_map_2DH_01> with variable <clm2>')
%             plot_map_sal_diff_01(fid_log,in_plot.fig_map_sal_mass_01,simdef_ref,simdef)
end

%% his sal 01
if isfield(in_plot,'fig_his_sal_01')==1
    warning('deprecate and call <his_01>')
%             in_plot.fig_his_sal_01.tag_fig=sprintf('%s_diff',in_plot.fig_his_sal_01.tag);
%             plot_his_sal_diff_01(fid_log,in_plot.fig_his_sal_01,simdef_ref,simdef)
end

%% his sal 01
tag_check='fig_his_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','diff');
    plot_his_diff_01(fid_log,in_plot_fig,simdef_ref,simdef)
end

%% map 2DH
tag_check='fig_map_2DH_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','diff');
    plot_map_2DH_diff_01(fid_log,in_plot_fig,simdef_ref,simdef)
end

%% map 2DH ls
tag_check='fig_map_2DH_ls_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','diff');
    plot_map_2DH_ls_diff_01(fid_log,in_plot_fig,simdef_ref,simdef)
end

%% map 1D
tag_check='fig_map_1D_01';
if isfield(in_plot,tag_check)==1
    in_plot_fig=gmd_tag(in_plot,tag_check,'fig','diff');
    plot_map_1D_xv_diff_01(fid_log,in_plot_fig,simdef_ref,simdef);
end

end %function