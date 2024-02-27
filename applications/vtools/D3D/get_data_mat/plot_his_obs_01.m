%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: plot_his_obs_01.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_obs_01.m $
%
%

function plot_his_obs_01(fid_log,flg_loc,simdef)

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
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
% fpath_map=simdef.file.map;
% fpath_grd=simdef.file.mat.grd;
runid=simdef.file.runid;

%% LOAD

load(fpath_mat,'data');

%%

nxlim=size(flg_loc.xlims,1);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
    in_p.plot_ldb=1;
end

%% LOOP

in_p.data=data;

% in_p.sfact=1/1000;
in_p.sfact=1;
in_p.titles='';

for kxlim=1:nxlim
    
    if isnan(flg_loc.xlims(1))
        xy=reshape([data.obs.xy],2,[])';
        in_p.xlims=[min(xy(:,1)),max(xy(:,1))]; %we should also consider crs
        in_p.ylims=[min(xy(:,2)),max(xy(:,2))]; %we should also consider crs
    else
        in_p.xlims=flg_loc.xlims(kxlim,:);
        in_p.ylims=flg_loc.ylims(kxlim,:);
    end
    
    in_p.tiles_zoom=flg_loc.tiles_zoom(kxlim);

    fname_noext=fig_name(fdir_fig,tag,runid,kxlim);
    in_p.fname=fname_noext;
    
    fig_his_obs_01(in_p);
end

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,kxlim)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%02d',tag,runid,kxlim));

end %function