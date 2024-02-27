%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18185 $
%$Date: 2022-06-21 19:23:15 +0800 (Tue, 21 Jun 2022) $
%$Author: chavarri $
%$Id: plot_map_q_01.m 18185 2022-06-21 11:23:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_q_01.m $
%
%

function plot_map_q_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%%

%% DEFAULTS

% if isfield(flg_loc,'background')==0
%     flg_loc.background=NaN
% end
if isfield(flg_loc,'load_all')==0
    flg_loc.load_all=0;
end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
% fpath_map=simdef.file.map;
fpath_grd=simdef.file.mat.grd;
runid=simdef.file.runid;

%% LOAD

if flg_loc.load_all
    load(fpath_mat,'data'); 
end
create_mat_grd(fid_log,flg_loc,simdef)
load(fpath_grd,'gridInfo');
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%%

nt=size(time_dnum,1);
nclim=size(flg_loc.clims_mag,1);

if flg_loc.load_all
    max_tot=max(data(:));
else
    max_tot=NaN;
end
xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.unit={'qsp','qxsp','qysp'};
in_p.xlims=xlims;
in_p.ylims=ylims;
in_p.gridInfo=gridInfo;
in_p.kr_tit=1;
in_p.kc_tit=2;
in_p.fig_size=[0,0,25,14];

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

fext=ext_of_fig(in_p.fig_print);

%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

fpath_file=cell(nt,nclim);
for kt=kt_v
    if flg_loc.load_all==0
        fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
        if exist(fpath_mat_tmp,'file')~=2; flg_loc.do_movie=0; continue; end
        load(fpath_mat_tmp,'data');
%         in_p.val=data.q_mag;
        
        %for vector plotting
%         in_p.vec_x=data.q_x;
%         in_p.vec_y=data.q_y;

        %for several plots
        in_p.val{1,1}=data.q_mag;
        in_p.val{1,2}=data.q_x;
        in_p.val{1,3}=data.q_y;
    else
        error('obsolete')
        in_p.val=data(kt,:);
    end
    
    in_p.tim=time_dnum(kt);
    for kclim=1:nclim
%         clims=flg_loc.clims(kclim,:);
        
        fname_noext=fig_name(fdir_fig,tag,runid,kt,kclim,time_dnum);
        fpath_file{kt,kclim}=sprintf('%s%s',fname_noext,fext); %for movie 

        in_p.fname=fname_noext;

        in_p.clims={};
%         if all(isnan(clims)==[0,1]) %[0,NaN]
%             in_p.clims{1,1}=[clims(1),max_tot];
%             in_p.clims{1,2}=[clims(1),max_tot];
%             in_p.clims{1,3}=[clims(1),max_tot];
%         else
            in_p.clims{1,1}=flg_loc.clims_mag(kclim,:);
            in_p.clims{1,2}=flg_loc.clims_x(kclim,:);
            in_p.clims{1,3}=flg_loc.clims_y(kclim,:);
%         end
        
%         fig_map_sal_01(in_p);
        fig_map_several(in_p);
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
       make_video(fpath_file(:,kclim),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
    end
end

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,kt,kclim,time_dnum)

fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_clim_%02d',tag,runid,datestr(time_dnum(kt),'yyyymmddHHMM'),kclim));

end %function