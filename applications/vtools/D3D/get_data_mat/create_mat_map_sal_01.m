%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18020 $
%$Date: 2022-05-05 14:45:01 +0800 (Thu, 05 May 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_01.m 18020 2022-05-05 06:45:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal_01.m $
%
%

function create_mat_map_sal_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_map=simdef.file.map;

%% OVERWRITE

[ret,flg_loc]=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% GRID

%load grid for number of layers
create_mat_grd(fid_log,flg_loc,simdef)
load(simdef.file.mat.grd,'gridInfo')

%%
if isnan(flg_loc.layer)
    layer=gridInfo.no_layers;
else
    layer=flg_loc.layer;
end

%% LOAD TIME

[nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_map);
% nt=numel(time_dnum)-1; %if the simulation does not finish the last one may not be in all partitions. 

%% LOOP TIME

kt_v=gdm_kt_v(flg_loc,nt); %time index vector

ktc=0;
messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
for kt=kt_v
    ktc=ktc+1;
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'layer',layer);
    if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end
    
    data_sal=gdm_read_data_map(fdir_mat,fpath_map,'sal','layer',layer,'tim',time_dnum(kt));
    
    data=data_sal.val; %#ok
    save_check(fpath_mat_tmp,'data'); 
    messageOut(fid_log,sprintf('Reading %s kt %4.2f %%',tag,ktc/nt*100));
end %kt

%% JOIN

%% first time for allocating

kt=1;
fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'layer',layer);
tmp=load(fpath_mat_tmp,'data');

%constant

%time varying
nF=size(tmp.data,2);

data=NaN(nt,nF);

%% loop 

kt=0;
messageOut(fid_log,sprintf('Joining %s kt %4.2f %%',tag,kt/nt*100));
for kt=1:nt
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt),'layer',layer);
    tmp=load(fpath_mat_tmp,'data');

    data(kt,:)=tmp.data;
    messageOut(fid_log,sprintf('Joining %s kt %4.2f %%',tag,kt/nt*100));
end %kt

save_check(fpath_mat,'data');

end %function