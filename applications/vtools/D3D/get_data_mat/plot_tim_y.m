%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18256 $
%$Date: 2022-07-22 19:08:11 +0800 (Fri, 22 Jul 2022) $
%$Author: chavarri $
%$Id: plot_tim_y.m 18256 2022-07-22 11:08:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_tim_y.m $
%
%

function plot_tim_y(fid_log,flg_loc,simdef,var_str)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

if isfield(flg_loc,'tag_tim')==0
    tag_tim=flg_loc.tag;
else
    tag_tim=flg_loc.tag_tim;
end

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie,var_str);
fdir_mat=simdef.file.mat.dir;
% fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat=fullfile(fdir_mat,sprintf('%s_%s.mat',tag,var_str));
fpath_mat_tim=fullfile(fdir_mat,sprintf('%s.mat',tag_tim));
fpath_mat_time=strrep(fpath_mat_tim,'.mat','_tim.mat');
fpath_map=simdef.file.map;

mkdir_check(fdir_fig);

%% LOAD TIME

[nt,time_dnum,~]=gdm_load_time_simdef(fid_log,flg_loc,fpath_mat_time,simdef);

%% LOAD VARIABLE

load(fpath_mat,'data')

%% PLOT

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;

in_p.val=data.val;

fname_noext=fullfile(fdir_fig,sprintf('%s_%s',tag,simdef.file.runid));

in_p.do_title=0;
in_p.lab_str=data.unit;
in_p.fname=fname_noext;
in_p.val=data.val;
in_p.s=datetime(time_dnum,'ConvertFrom','datenum');
in_p.xlab_str='';
        
fig_1D_01(in_p)

end %function