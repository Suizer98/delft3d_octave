%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18257 $
%$Date: 2022-07-22 19:19:06 +0800 (Fri, 22 Jul 2022) $
%$Author: chavarri $
%$Id: create_mat_map_q_01.m 18257 2022-07-22 11:19:06Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_q_01.m $
%
%

function create_mat_map_q_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD TIME

[nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_map,fdir_mat);

%% CONSTANT IN TIME

%load grid for number of layers
% load(simdef.file.mat.grd,'gridInfo')

% raw_ba=EHY_getMapModelData(fpath_map,'varName','mesh2d_flowelem_ba','mergePartitions',1,'disp',0);

%% LOOP

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
for kt=kt_v
    ktc=ktc+1;
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
    if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end
    
    %% read data
    
    data_uv=gdm_read_data_map(fdir_mat,fpath_map,'uv','tim',time_dnum(kt));
    data_zw=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_zw','tim',time_dnum(kt));
       
    %% calc
    
    %squeeze to take out the first (time) dimension. Then layers are in dimension 2.
    vel_x=squeeze(data_uv.vel_x); %m/s
    vel_y=squeeze(data_uv.vel_y); %m/s
    vel_mag=squeeze(data_uv.vel_mag); %m/s
    
    thk=diff(squeeze(data_zw.val),1,2); %m
    
    q_x=sum(vel_x.*thk,2,'omitnan')'; %m^2/s
    q_y=sum(vel_y.*thk,2,'omitnan')'; %m^2/s
    q_mag=sum(vel_mag.*thk,2,'omitnan')'; %m^2/s
    
    %data
    data=v2struct(q_x,q_y,q_mag); %#ok

    %% save and disp
    save_check(fpath_mat_tmp,'data');
    messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
    
    %% BEGIN DEBUG
%     figure
%     hold on
%     plot(thk)
%     plot(q)
% plot(raw_ba.val)
% plot(mass,'-*')
    %END DEBUG
end    

%% JOIN

%if creating files in parallel, another instance may have already created it.
%
%Not a good idea because of the overwriting flag. Maybe best to join it several times.
%
% if exist(fpath_mat,'file')==2
%     messageOut(fid_log,'Finished looping and mat-file already exist, not joining.')
%     return
% end

% data=struct();

%% first time for allocating

kt=1;
fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
tmp=load(fpath_mat_tmp,'data');

%constant

%time varying
nF=size(tmp.data.q_mag,2);

q_mag=NaN(nt,nF);
q_x=NaN(nt,nF);
q_y=NaN(nt,nF);

%% loop 

for kt=1:nt
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
    tmp=load(fpath_mat_tmp,'data');

    q_mag(kt,:)=tmp.data.q_mag;
    q_x(kt,:)=tmp.data.q_x;
    q_y(kt,:)=tmp.data.q_y;

end

data=v2struct(q_mag,q_x,q_y); %#ok
save_check(fpath_mat,'data');

end %function

%% 
%% FUNCTION
%%
