%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17487 $
%$Date: 2021-09-17 17:26:01 +0800 (Fri, 17 Sep 2021) $
%$Author: chavarri $
%$Id: main_modify_data_stations.m 17487 2021-09-17 09:26:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/main_modify_data_stations.m $
%

%%

fclose all;
clear
clc

%%

path_data_stations='C:\Users\chavarri\checkouts\riv\data_stations\';
path_ds_idx=fullfile(path_data_stations,'data_stations_index.mat');
load(path_ds_idx,'data_stations_index');

%%

%single index
idx_mod=[48,49,50];

%search for index
% ks=0;

% ks=ks+1;
% [~,bol1]=find_str_in_cell({data_stations_index.location_clear},{'Tiel Waal'}); 
% [~,bol2]=find_str_in_cell({data_stations_index.grootheid},{'WATHTE'}); 
% % bol2=[data_stations_index.bemonsteringshoogte]==-9.0; 
% idx_mod(ks)=find(bol1&bol2);
% bh(ks)=-2.0;


%%

% figure
% hold on

ns=numel(idx_mod);
str_leg=cell(ns,1);
for ks=1:ns
path_mod=fullfile(path_data_stations,'separate',sprintf('%06d.mat',idx_mod(ks)));

load(path_ds_idx,'data_stations_index');
load(path_mod)

% data_one_station.location='VOLKRSZSSHLD';
% data_stations_index(idx_mod(ks)).location=data_one_station.location;

% data_one_station.waarde=data_one_station.waarde/100;
% plot(data_one_station.time,data_one_station.waarde)

data_one_station.location_clear='Middelharnis boei';
data_stations_index(idx_mod(ks)).location_clear=data_one_station.location_clear;

% data_one_station.eenheid='m3/s';
% data_stations_index(idx_mod(ks)).eenheid='m3/s';

% data_one_station.parameter='';
% data_stations_index(idx_mod(ks)).parameter='';

% data_one_station.bemonsteringshoogte=bh(ks);
% data_stations_index(idx_mod(ks)).bemonsteringshoogte=bh(ks);

% data_one_station.time=tim_s;
% data_one_station.waarde=val_s;
% data_one_station.x=data_stations(1).x;
% data_one_station.y=data_stations(1).y;
% data_one_station.epsg=data_stations(1).epsg;
% 
% data_stations_index(idx_mod(ks))=data_one_station;
% data_stations_index(idx_mod(ks)).time=[];
% data_stations_index(idx_mod(ks)).waarde=[];

save(path_mod,'data_one_station');
save(path_ds_idx,'data_stations_index');

%leg
str_leg{ks}=sprintf('%d',idx_mod(ks));

end

% ylim([0,50000])
% legend(str_leg)
