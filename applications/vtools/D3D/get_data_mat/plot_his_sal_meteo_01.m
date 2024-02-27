%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18185 $
%$Date: 2022-06-21 19:23:15 +0800 (Tue, 21 Jun 2022) $
%$Author: chavarri $
%$Id: plot_his_sal_meteo_01.m 18185 2022-06-21 11:23:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_sal_meteo_01.m $
%
%

function plot_his_sal_meteo_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% DEFAULTS

% if isfield(flg_loc,'background')==0
%     flg_loc.background=NaN
% end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
% fpath_map=simdef.file.map;
% fpath_grd=simdef.file.mat.grd;
runid=simdef.file.runid;

%% LOAD

load(fpath_mat,'data');
% load(fpath_mat_time,'tim');
% v2struct(tim); %time_dnum, time_dtime

%%

nxlim=size(flg_loc.xlims,1);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;

%% LOOP

in_p.data=data;
% in_p.tim=datetime(time_dnum,'ConvertFrom','datenum');

for kxlim=1:nxlim
    in_p.xlims=datetime(flg_loc.xlims(kxlim,:),'ConvertFrom','datenum','TimeZone',data.obs(1).tim.TimeZone);
    
    fname_noext=fig_name(fdir_fig,tag,runid,flg_loc.xlims(kxlim,1),flg_loc.xlims(kxlim,2));
    in_p.fname=fname_noext;
    
    fig_his_sal_meteo_01(in_p);
end

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum_1,time_dnum_2)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s-%s',tag,runid,datestr(time_dnum_1,'yyyymmddHHMM'),datestr(time_dnum_2,'yyyymmddHHMM')));

end %function