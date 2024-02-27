%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18185 $
%$Date: 2022-06-21 19:23:15 +0800 (Tue, 21 Jun 2022) $
%$Author: chavarri $
%$Id: plot_map_sal3D_01.m 18185 2022-06-21 11:23:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_sal3D_01.m $
%
%

function plot_map_sal3D_01(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE


%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fdir_fig=fullfile(simdef.file.fig.dir,tag_fig,tag_serie);
mkdir_check(fdir_fig);
runid=simdef.file.runid;

%% LOAD

create_mat_grd(fid_log,flg_loc,simdef)
load(fpath_mat_time,'tim');
v2struct(tim); %time_dnum, time_dtime

%%

nt=size(time_dnum,1);
% nclim=size(flg_loc.clims,1);
niso=numel(flg_loc.isoval);
npol=numel(flg_loc.pol);

%figures
in_p=flg_loc;
in_p.fig_print=1; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
in_p.fig_visible=0;
% in_p.unit={'qsp','qxsp','qysp'};

in_p.fig_size=[0,0,14,14];

fext=ext_of_fig(in_p.fig_print);

%% LOOP

for kpol=1:npol
    
    kt_v=gdm_kt_v(flg_loc,nt); %time index vector
    fpath_file=cell(nt,niso); 
    
    %polygon name
    [~,pol_name]=gdm_read_pol(flg_loc.pol{kpol});
    
    %bed level
    fpath_bl_pol=mat_tmp_name(fdir_mat,'bl','pol',pol_name);
    load(fpath_bl_pol,'bl_pol')
    
    %grid
    fpath_gridInfo_pol=mat_tmp_name(fdir_mat,'gridInfo','pol',pol_name);
    load(fpath_gridInfo_pol,'gridInfo')
    
    xlims=[min(gridInfo.face_nodes_x(:)),max(gridInfo.face_nodes_x(:))];
    ylims=[min(gridInfo.face_nodes_y(:)),max(gridInfo.face_nodes_y(:))];
    zlims=[min(bl_pol),flg_loc.maxz(kpol)];
    
    fpath_bl_cor=mat_tmp_name(fdir_mat,'bl_cor','pol',pol_name);
    load(fpath_bl_cor,'bl_cor')
    
    in_p.bl=bl_pol;
    in_p.z=bl_cor;
    in_p.gridInfo=gridInfo;
    in_p.xlims=xlims;
    in_p.ylims=ylims;
    in_p.zlims=zlims;
    in_p.views=flg_loc.view(kpol,:);

    ktc=0;
    for kt=kt_v
        ktc=ktc+1;
        for kiso=1:niso
            fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'iso',num2str(flg_loc.isoval(kiso)));
            if exist(fpath_mat_tmp,'file')~=2; flg_loc.do_movie=0; continue; end
            load(fpath_mat_tmp,'data');
            
            %clean iso
            %maybe better to move to the point of getting the data
            
            in_p.tim=time_dnum(kt);
            in_p.iso=data;
            
%             for kclim=1:nclim
%                 in_p.clims=flg_loc.clims(kclim,:);

                fname_noext=fig_name(fdir_fig,tag,runid,time_dnum(kt),num2str(flg_loc.isoval(kiso)));
                fpath_file{kt,kiso}=sprintf('%s%s',fname_noext,fext); %for movie 

                in_p.fname=fname_noext;
                
                %BEGIN DEBUG

                %END DEBUG
                
                fig_map_sal3D_01(in_p);
                
                messageOut(fid_log,sprintf('Done printing figure time %4.2f %% iso %4.2f %%',ktc/nt*100,kiso/niso*100));

%             end %kclim
        end %kiso
    end %kt

    %% movies

    if isfield(flg_loc,'do_movie')==0
        flg_loc.do_movie=1;
    end

    if flg_loc.do_movie
        dt_aux=diff(time_dnum);
        dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
        rat=flg_loc.rat; %[s] we want <rat> model seconds in each movie second
        for kiso=1:niso
           make_video(fpath_file(:,kiso),'frame_rate',1/dt*rat,'overwrite',flg_loc.fig_overwrite);
        end
    end

end %kpol

end %function

%% 
%% FUNCTION
%%

function fpath_fig=fig_name(fdir_fig,tag,runid,time_dnum,iso)

% fprintf('fdir_fig: %s \n',fdir_fig);
% fprintf('tag: %s \n',tag);
% fprintf('runid: %s \n',runid);
% fprintf('time_dnum: %f \n',time_dnum);
% fprintf('iso: %s \n',iso);
                
fpath_fig=fullfile(fdir_fig,sprintf('%s_%s_%s_iso_%s',tag,runid,datestr(time_dnum,'yyyymmddHHMM'),iso));

% fprintf('fpath_fig: %s \n',fpath_fig);
end %function