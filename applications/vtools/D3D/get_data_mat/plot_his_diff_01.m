%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: plot_his_diff_01.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_diff_01.m $
%
%

function plot_his_diff_01(fid_log,flg_loc,simdef_ref,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag,'do_s'); if ret; return; end

%% PATHS

fdir_mat_ref=simdef_ref.file.mat.dir;

nS=numel(simdef);
fdir_mat=simdef_ref.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_his=simdef_ref.file.his;
fpath_map=simdef_ref.file.map;

if nS==1
    fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
else
    fdir_fig=fullfile(simdef_ref.file.fig.dir,tag_fig,tag_serie);
end
mkdir_check(fdir_fig,NaN,1,0);  %break and no display

%% LOAD

if simdef.D3D.structure~=3
    gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);
else
    gridInfo=NaN;
end

[nt,time_dnum,time_dtime]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_his);

stations=gdm_station_names(fid_log,flg_loc,fpath_his);

%% DIMENSIONS

ns=numel(stations);
nvar=numel(flg_loc.var);
nylim=size(flg_loc.ylims_diff,1);

%% FIGURE

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
for kvar=1:nvar

    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef);
    
    fdir_fig_loc=fullfile(fdir_fig,var_str);
    mkdir_check(fdir_fig_loc,NaN,1,0);  %break and no display
    in_p.unit=flg_loc.unit{kvar};
    
    for ks=ks_v %stations
            
        layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks});
        fpath_mat_tmp_ref=mat_tmp_name(fdir_mat_ref,tag,'station',stations{ks},'var',var_str,'layer',layer);
        data_ref=load(fpath_mat_tmp_ref,'data');
        
        val_scenario=NaN(numel(data_ref.data),nS);
        
        for kS=1:nS %simulations
            fdir_mat=simdef(kS).file.mat.dir;
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations{ks},'var',var_str,'layer',layer);
            data=load(fpath_mat_tmp    ,'data');
            
            val_scenario(:,kS)=data.data;
        end

        val=val_scenario-data_ref.data;
        for kylim=1:nylim
            
            if nS==1 %not the nicest if-else
                fname_noext=fullfile(fdir_fig_loc,sprintf('%s_%s_%s_%s_ylim_%02d',tag_fig,simdef.file.runid,simdef_ref.file.runid,stations{ks},kylim));
            else
                fname_noext=fullfile(fdir_fig_loc,sprintf('%s_%s_%s_ylim_%02d',tag_fig,simdef_ref.file.runid,stations{ks},kylim));
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
    end %ks
end %nvar

%% movies

% dt_aux=diff(time_dnum);
% dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
% rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
% for kclim=1:nclim
%    make_video(fpath_file(:,kclim),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
% end

end %function
