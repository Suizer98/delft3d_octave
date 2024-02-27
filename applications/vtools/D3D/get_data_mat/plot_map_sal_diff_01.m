%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18185 $
%$Date: 2022-06-21 19:23:15 +0800 (Tue, 21 Jun 2022) $
%$Author: chavarri $
%$Id: plot_map_sal_diff_01.m 18185 2022-06-21 11:23:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_sal_diff_01.m $
%
%

function plot_map_sal_diff_01(fid_log,flg_loc,simdef_ref,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PATHS

%reference
fdir_mat_ref=simdef_ref.file.mat.dir;

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
fpath_grd=simdef.file.mat.grd;

%% LOAD

load(fpath_grd,'gridInfo');
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

if ~isfield(flg_loc,'layer')
    is_layer=0;
else
    is_layer=1;
    if isnan(flg_loc.layer)
        layer=gridInfo.no_layers;
    else
        layer=flg_loc.layer;
    end
end

%% 

nt=numel(time_dnum);
nclim=size(flg_loc.clims,1);
nref=2; 

xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.xlims=xlims;
in_p.ylims=ylims;
in_p.gridInfo=gridInfo;
in_p.is_diff=1;

fext=ext_of_fig(in_p.fig_print);

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

fpath_file=cell(nt,nclim);

%first time
kt=1;
if is_layer
    fpath_mat_tmp_ref=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum(kt),'layer',layer);
    fpath_mat_tmp    =mat_tmp_name(fdir_mat    ,tag,'tim',time_dnum(kt),'layer',layer);
else
    fpath_mat_tmp_ref=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum(kt));
    fpath_mat_tmp    =mat_tmp_name(fdir_mat    ,tag,'tim',time_dnum(kt));
end

data_ref_0=load(fpath_mat_tmp_ref,'data');

data_0    =load(fpath_mat_tmp    ,'data');
    
for kt=kt_v
    
    %load data
    if is_layer
        fpath_mat_tmp_ref=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum(kt),'layer',layer);
        fpath_mat_tmp    =mat_tmp_name(fdir_mat    ,tag,'tim',time_dnum(kt),'layer',layer);
    else
        fpath_mat_tmp_ref=mat_tmp_name(fdir_mat_ref,tag,'tim',time_dnum(kt));
        fpath_mat_tmp    =mat_tmp_name(fdir_mat    ,tag,'tim',time_dnum(kt));
    end
    
    data_ref=load(fpath_mat_tmp_ref,'data');
    
    data    =load(fpath_mat_tmp    ,'data');
    
    for kclim=1:nclim
        for kref=1:nref
            if kref==1
                val=data.data-data_ref.data;
                in_p.is_background=0;
            elseif kref==2
                val=(data.data-data_ref.data)-(data_0.data-data_ref_0.data);
                in_p.is_background=1;
            end
            
            fname_noext=fullfile(fdir_fig,sprintf('%s_%s_%s_%s_clim_%02d_ref_%02d',tag_fig,simdef.file.runid,simdef_ref.file.runid,datestr(time_dnum(kt),'yyyymmddHHMM'),kclim,kref));
            fpath_file{kt,kclim,kref}=sprintf('%s%s',fname_noext,fext); %for movie 

            in_p.fname=fname_noext;
            in_p.val=val;
            in_p.tim=time_dnum(kt);

            clims=flg_loc.clims_diff(kclim,:);

            in_p.clims=clims;

            fig_map_sal_01(in_p);
        end %kref
    end %kclim
end %kt

%% movies

if isfield(flg_loc,'do_movie')==0
    flg_loc.do_movie=1;
end

if flg_loc.do_movie
    dt_aux=diff(time_dnum);
    dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
    rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
    for kclim=1:nclim
        for kref=1:nref
           make_video(fpath_file(:,kclim,kref),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
        end
    end
end

end %function
