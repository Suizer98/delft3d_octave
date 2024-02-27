%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18279 $
%$Date: 2022-08-02 22:45:02 +0800 (Tue, 02 Aug 2022) $
%$Author: chavarri $
%$Id: create_mat_his_sal_meteo_01.m 18279 2022-08-02 14:45:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_his_sal_meteo_01.m $
%
%

function create_mat_his_sal_meteo_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

fdir_mat=simdef.file.mat.dir;
fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
fpath_his=simdef.file.his;
fpath_map=simdef.file.map;

%% OVERWRITE

ret=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat); if ret; return; end

%% LOAD

[nt,time_dnum,time_dtime]=gdm_load_time(fid_log,flg_loc,fpath_mat_time,fpath_his,fdir_mat);

%% LOAD

%% CONSTANT IN TIME

gridInfo=gdm_load_grid(fid_log,fdir_mat,fpath_map);

%% STATIONS

stations=gdm_station_names(fid_log,flg_loc,fpath_his);
ns=numel(stations);
ks_v=gdm_kt_v(flg_loc,ns);

ksc=0;
messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
css=NaN(nt,ns);
for ks=ks_v
    ksc=ksc+1;
    
    layer=gdm_station_layer(flg_loc,gridInfo,fpath_his,stations{ks});
        
    data_sal=gdm_read_data_his(fdir_mat,fpath_his,'sal','station',stations{ks},'layer',layer,'tim',time_dnum(1),'tim2',time_dnum(end));
    
    css(:,ks)=sal2cl(1,data_sal.val);
    messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
end    

%% add the ones with the same name

data.obs=gdm_add_same_name(flg_loc.fpath_stations,css,'cl_bottom',time_dtime);

%% CROSS SECTIONS INST

flg_loc.fpath_crs=flg_loc.fpath_crs_inst;
crs=gdm_station_names(fid_log,flg_loc,fpath_his,'obs_type',2);
ns=numel(crs);
ks_v=gdm_kt_v(flg_loc,ns);

ksc=0;
messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
css=NaN(nt,ns);
for ks=ks_v
    ksc=ksc+1;
    
    
    %<cross_section_salt> is not salt but flux salt!
%     data_sal=gdm_read_data_his(fdir_mat,fpath_his,'cross_section_salt','station',crs{ks},'tim',time_dnum(1),'tim2',time_dnum(end));
%     data_q  =gdm_read_data_his(fdir_mat,fpath_his,'cross_section_discharge','station',crs{ks},'tim',time_dnum(1),'tim2',time_dnum(end));
%     
%     css(:,ks)=sal2cl(1,data_sal.val).*data_q.val./1000; %mgCl/l*m^3/s -> kgCl/s

    data_sal=gdm_read_data_his(fdir_mat,fpath_his,'cross_section_salt','station',crs{ks},'tim',time_dnum(1),'tim2',time_dnum(end)); %psu*m^3/s
    
    css(:,ks)=sal2cl(1,data_sal.val)./1000; %mgCl/l*m^3/s -> kgCl/s
    
    messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
end    

%% add the ones with the same name

data.crs_inst=gdm_add_same_name(flg_loc.fpath_crs_inst,css,'cl_t',time_dtime);

%% filter

% tim_f=time_dtime(1):hours(25):time_dtime(end);
% nc=numel(data.crs_inst);
% for kc=1:nc
%    val_int=interpolate_timetable({time_dtime},{data.crs_inst(kc).val},tim_f,'disp',0);
%    data.crs_inst_fil(kc).val=val_int;
%    data.crs_inst_fil(kc).tim=tim_f';
%    data.crs_inst_fil(kc).name=data.crs_inst(kc).name;
%    data.crs_inst_fil(kc).unit=data.crs_inst(kc).unit;
% end

dt=diff(time_dnum);
if any(abs(dt-dt(1))>1e-8)
    error('dt should be the same')
end
window_h=25; %hours to make the window average
num_ave=round((window_h/24)/dt(1)); 
nc=numel(data.crs_inst);
for kc=1:nc
    fil=movmean(data.crs_inst(kc).val,num_ave);
    fil(1:num_ave)=NaN;
    fil(end-num_ave:end)=NaN;
    data.crs_inst_fil(kc).val=fil;
    data.crs_inst_fil(kc).tim=time_dtime;
    data.crs_inst_fil(kc).name=data.crs_inst(kc).name;
    data.crs_inst_fil(kc).unit=data.crs_inst(kc).unit;
end

%% CROSS SECTIONS CUM

flg_loc.fpath_crs=flg_loc.fpath_crs_cum;
crs=gdm_station_names(fid_log,flg_loc,fpath_his,'obs_type',2);
ns=numel(crs);
ks_v=gdm_kt_v(flg_loc,ns);

ksc=0;
messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
css=NaN(nt,ns);
for ks=ks_v
    ksc=ksc+1;
        
    data_sal=gdm_read_data_his(fdir_mat,fpath_his,'cross_section_cumulative_salt','station',crs{ks},'tim',time_dnum(1),'tim2',time_dnum(end)); %int(psu*m^3/s dt) = psu*m^3
    
    css(:,ks)=sal2cl(1,data_sal.val)./1000; %psu*m^3 -> kgCl
    messageOut(fid_log,sprintf('Reading %s ks %4.2f %%',tag,ksc/ns*100));
end  

%% add the ones with the same name

data.crs_cum=gdm_add_same_name(flg_loc.fpath_crs_cum,css,'cl_mass',time_dtime);

%% WIND

%we take it from one station
ks=1;
data_wx=gdm_read_data_his(fdir_mat,fpath_his,'windx','station',stations{ks},'tim',time_dnum(1),'tim2',time_dnum(end));
data_wy=gdm_read_data_his(fdir_mat,fpath_his,'windy','station',stations{ks},'tim',time_dnum(1),'tim2',time_dnum(end));

wind_u=hypot(data_wx.val,data_wy.val);
wind_dir=xy2north_deg(data_wx.val,data_wy.val);

data.wind.u=wind_u;
data.wind.dir=wind_dir; 
data.wind.tim=time_dtime; %#ok

%% SAVE

save_check(fpath_mat,'data');

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

function data_s=gdm_add_same_name(fpath,css,unit,tim)

crs_raw=readcell(fpath);
[crs_u,idx_1,idx_u2]=unique(crs_raw(:,2));
nu=numel(crs_u);
for ku=1:nu
    data(ku).val=sum(css(:,idx_u2==ku),2);
%     data(ku).name=crs_u{ku};
    data(ku).name=crs_raw{idx_1(ku),1};
    data(ku).unit=unit;
    data(ku).tim=tim;
end

%order as close as initial
[~,sidx2]=sort(idx_1);
data_s=data(sidx2);

end %function
