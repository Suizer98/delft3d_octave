%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18185 $
%$Date: 2022-06-21 19:23:15 +0800 (Tue, 21 Jun 2022) $
%$Author: chavarri $
%$Id: plot_map_sal_01.m 18185 2022-06-21 11:23:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_sal_01.m $
%
%

function plot_map_sal_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);

%%

%load
load(fpath_mat,'data');
create_mat_grd(fid_log,flg_loc,simdef)
load(simdef.file.mat.grd,'gridInfo')
[nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,'');

nclim=size(flg_loc.clims,1);

max_tot=max(data(:));
xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
in_p.xlims=xlims;
in_p.ylims=ylims;

fext=ext_of_fig(in_p.fig_print);

%ldb
if isfield(flg_loc,'fpath_ldb')
    in_p.ldb=D3D_read_ldb(flg_loc.fpath_ldb);
end

%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

fpath_file=cell(nt,nclim);
for kt=kt_v
    for kclim=1:nclim
        fname_noext=fullfile(fdir_fig,sprintf('sal_map_01_%s_%s_clim_%02d',simdef.file.runid,datestr(time_dnum(kt),'yyyymmddHHMM'),kclim));
        fpath_file{kt,kclim}=sprintf('%s%s',fname_noext,fext); %for movie 
        
        in_p.fname=fname_noext;
        in_p.gridInfo=gridInfo;
        in_p.val=data(kt,:);
        in_p.tim=time_dnum(kt);
        
        clims=flg_loc.clims(kclim,:);
        if all(isnan(clims)==[0,1]) %[0,NaN]
            in_p.clims=[clims(1),max_tot];
        else
            in_p.clims=clims;
        end
        
        fig_map_sal_01(in_p);
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
