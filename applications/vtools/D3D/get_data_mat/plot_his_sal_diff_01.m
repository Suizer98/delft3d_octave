%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18282 $
%$Date: 2022-08-05 22:25:39 +0800 (Fri, 05 Aug 2022) $
%$Author: chavarri $
%$Id: plot_his_sal_diff_01.m 18282 2022-08-05 14:25:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_sal_diff_01.m $
%
%

function plot_his_sal_diff_01(fid_log,flg_loc,simdef_ref,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PATHS

fdir_mat_ref=simdef_ref.file.mat.dir;

nS=numel(simdef);
fdir_mat=simdef_ref.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
if nS==1
    fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
else
    fdir_fig=fullfile(simdef_ref.file.fig.dir,tag_fig,tag_serie);
end
fpath_his=simdef_ref.file.his;
mkdir_check(fdir_fig);

%%

stations=gdm_station_names(fid_log,flg_loc,fpath_his);
ns=numel(stations);
%load
% load(fpath_mat,'data');
% load(simdef.file.mat.grd,'gridInfo');
[nt,time_dnum,time_dtime]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_his);

nylim=size(flg_loc.ylims_diff,1);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.is_diff=1;

fext=ext_of_fig(in_p.fig_print);

%ldb
% if isfield(flg_loc,'fpath_ldb')
%     in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
% end

%% LOOP

ks_v=gdm_kt_v(flg_loc,ns);

fpath_file=cell(ns,nylim);
for ks=ks_v %stations
    fpath_mat_tmp_ref=mat_tmp_name(fdir_mat_ref,tag,'station',stations{ks});
    data_ref=load(fpath_mat_tmp_ref,'data');
    val_scenario=NaN(numel(data_ref.data),nS);
    for kS=1:nS %simulations
        fdir_mat=simdef(kS).file.mat.dir;
        fpath_mat_tmp    =mat_tmp_name(fdir_mat    ,tag,'station',stations{ks});
        data=load(fpath_mat_tmp    ,'data');
        val_scenario(:,kS)=data.data;
    end

    val=val_scenario-data_ref.data;
    for kylim=1:nylim
        if nS==1 %not the nicest if-else
            fname_noext=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_ylim_%02d',tag_fig,simdef.file.runid,simdef_ref.file.runid,stations{ks},kylim));
        else
            fname_noext=fullfile(fdir_fig,sprintf('%s_%s_%s_ylim_%02d',tag_fig,simdef_ref.file.runid,stations{ks},kylim));
        end
        fpath_file{ks,kylim}=sprintf('%s%s',fname_noext,fext); %for movie 
        
        in_p.fname=fname_noext;
        in_p.val=val;
        in_p.tim=time_dtime;
        in_p.station=stations{ks};
        
        ylims=flg_loc.ylims_diff(kylim,:);
        if isnan(ylims)
            in_p.ylims=[min(val(:))-eps,max(val(:))+eps];
        else
            in_p.ylims=ylims;
        end
        
        fig_his_sal_01(in_p);
    end %kclim
end %kt

%% movies

% dt_aux=diff(time_dnum);
% dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
% rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
% for kclim=1:nclim
%    make_video(fpath_file(:,kclim),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
% end

end %function
