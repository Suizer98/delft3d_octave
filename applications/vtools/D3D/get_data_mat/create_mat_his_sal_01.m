%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18282 $
%$Date: 2022-08-05 22:25:39 +0800 (Fri, 05 Aug 2022) $
%$Author: chavarri $
%$Id: create_mat_his_sal_01.m 18282 2022-08-05 14:25:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_his_sal_01.m $
%
%

function create_mat_his_sal_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_his=simdef.file.his;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD

load(simdef.file.mat.grd,'gridInfo')
[nt,time_dnum,~]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_his,fdir_mat);

%% LOAD

%% CONSTANT IN TIME

%% LOOP

stations=gdm_station_names(fid_log,flg_loc,fpath_his);

ns=numel(stations);

ks_v=gdm_kt_v(flg_loc,ns);

ksc=0;
messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
for ks=ks_v
    ksc=ksc+1;
    fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'station',stations{ks});
    if exist(fpath_mat_tmp,'file')==2 && ~flg_loc.overwrite ; continue; end
    
    %% read data
    
    layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks});
    
    fpath_sal=mat_tmp_name(fdir_mat,'sal','station',stations{ks},'layer',layer);
    if exist(fpath_sal,'file')==2
        load(fpath_sal,'data_sal')
    else
        data_sal=EHY_getmodeldata(fpath_his,stations{ks},'dfm','varName','sal','layer',layer,'t0',time_dnum(1),'tend',time_dnum(end));
        save_check(fpath_sal,'data_sal');
    end
    
    %% calc
    
    data=data_sal.val; %#ok

    %% save and disp
    save_check(fpath_mat_tmp,'data');
    messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
    
    %% BEGIN DEBUG

    %END DEBUG
end    

%% JOIN

% %% first time for allocating
% 
% kt=1;
% fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
% tmp=load(fpath_mat_tmp,'data');
% 
% %constant
% 
% %time varying
% nF=size(tmp.data,2);
% 
% data=NaN(nt,nF);
% 
% %% loop 
% 
% for kt=1:nt
%     fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,'tim',time_dnum(kt));
%     tmp=load(fpath_mat_tmp,'data');
% 
%     data(kt,:)=tmp.data;
% 
% end
% 
% save_check(fpath_mat,'data');

end %function

%% 
%% FUNCTION
%%
