%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18412 $
%$Date: 2022-10-07 22:37:21 +0800 (Fri, 07 Oct 2022) $
%$Author: chavarri $
%$Id: main_read_csv_data.m 18412 2022-10-07 14:37:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/main_read_csv_data.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn)

%% INPUT

paths_main_folder='C:\Users\chavarri\checkouts\riv\data_stations\';

%%
load(fullfile(paths_main_folder,'data_stations_index.mat'))

%% SEVERAL FILES SAME DATA

% fdir_data='C:\Users\chavarri\temporal\q\';
% 
% dire=dir(fdir_data);
% nf=numel(dire)-2;
% for kf=1:nf
%     fpath_data=fullfile(dire(kf+2).folder,dire(kf+2).name);
%     data_stations(kf)=read_csv_data(fpath_data,'flg_debug',0);
% end
% 
% %%
% tim=[];
% val=[];
% for kf=1:nf
%   tim=cat(1,tim,data_stations(kf).time);  
%   val=cat(1,val,data_stations(kf).waarde); 
% end
% 
% %%
% 
% figure
% hold on
% plot(tim,val,'*-')
% 
% %%
% 
% tt=timetable(tim,val);
% tt2=rmmissing(tt);
% tt3=sortrows(tt2);
% [tt4,idx_u,idx_u2]=unique(tt3);
% 
% % vidx=1:1:numel(tt3);
% % idxnu=find(~ismember(vidx,idx_u));
% % tt3.tim(idxnu(3))
% 
% dupTimes=sort(tt4.tim);
% tf=(diff(dupTimes)==0);
% dupTimes=dupTimes(tf);
% dupTimes=unique(dupTimes);
% if ~isempty(dupTimes)
%     warning('problem with duplicates')
% end
% 
% ttres=retime(tt4,'daily','mean');
% ttres_y=retime(tt4,'yearly','mean');
% 
% %%
% 
% figure
% plot(ttres.tim,ttres.val,'-*')
% 
% %%
% figure
% plot(ttres_y.tim,ttres_y.val,'-*')

%% SINGLE FILE SEVERAL STATIONS

% fpath_data='c:\Users\chavarri\temporal\210805_HvH_sal\20210819_006.csv';
% 
% data_stations=read_csv_data(fpath_data,'flg_debug',0);
% location_clear_v={'Inloop Spui';'Inloop Spui';'Volkeraksluizen';'Volkeraksluizen'};
% 
% ns=numel(data_stations);
% for ks=1:4
%     data_stations(ks).location_clear=location_clear_v{ks};
%     add_data_stations(paths_main_folder,data_stations(ks))
% end

%% SINGLE FILE 

% fpath_data='c:\Users\chavarri\temporal\data\20220829_026.csv';
% data_stations=read_csv_data(fpath_data,'flg_debug',0);

%%
% ns=numel(data_stations);
% for ks=1:ns
% %     data_stations(ks).location_clear=location_clear_v{ks};
%     data_stations(ks).location_clear='Lobith';
%     data_stations(ks).location='LOBH';
%     data_stations(ks).bemonsteringshoogte=NaN;
%     add_data_stations(paths_main_folder,data_stations(ks))
% end

%% FROM NC FILE

% fdir_nc='p:\11205259-004-dcsm-fm\waterlevel_data\RWS_data-distributielaag\ncFiles';
% add_data_stations_from_nc(paths_main_folder,fdir_nc)

%% FROM DONAR

% fpath_donar='p:\11206813-007-kpp2021_rmm-3d\C_Work\02_data\01_received\210907\vanSacha\mtg.mat';
% add_data_stations_from_donar(paths_main_folder,fpath_donar);

%% FROM HbR

% clc
% fdir_hbr='d:\temporal\210402_RMM3D\C_Work\02_data\16_waterlevel_HbR\';
% 
% [dir_paths,~,dir_fnames]=dirwalk(fdir_hbr);
% np=numel(dir_paths);
% 
% % for kp=1:np
% for kp=3:np
%     nf=numel(dir_fnames{kp});
%     for kf=1:nf
% 		if ~isempty(dir_fnames{kp,1})
% 			fpaths_file=fullfile(dir_paths{kp},dir_fnames{kp,1}{kf,1});
%             [~,fname,fext]=fileparts(fpaths_file);
%             if strcmp(fname,'Observations')
%                 data_stations=read_csv_data(fpaths_file,'flg_debug',0);
%                 [location_clear,str_found]=RWS_location_clear(data_stations.location);
%                 if ~str_found
%                     error('not found %s',data_stations.location)
%                 end
%                 data_stations.location_clear=location_clear{1,1};
%                 add_data_stations(paths_main_folder,data_stations,'ask',0)
%                 fprintf('%s \n',fpaths_file)
%             end
% 			
% 		end
%     end %kf
% end %kf

%% RAW READ

fpath_data='c:\Users\chavarri\Downloads\data.txt';

data_raw=readcell(fpath_data);
data_raw_m=readmatrix(fpath_data);

%%
t=[data_raw{:,1}];
val=data_raw_m(:,2);

figure; hold on; plot(t,val)

%%
data_stations.location='Baton Rouge (01160)';
data_stations.x=-91.20694444;
data_stations.y=30.42916667;
data_stations.raai=228.4*1.60934;
data_stations.grootheid='WATHTE';
data_stations.parameter='';
data_stations.eenheid='m';
data_stations.time=reshape(t,[],1);
data_stations.waarde=reshape(val*0.3048,[],1);
data_stations.epsg=4326;
data_stations.bemonsteringshoogte=NaN;
data_stations.location_clear='Baton Rouge';
data_stations.branch='mississippi';
data_stations.dist_mouth=228.4*1.60934;
data_stations.source='https://rivergages.mvr.usace.army.mil/WaterControl/stationinfo2.cfm?sid=01160&fid=BTRL1';

add_data_stations(paths_main_folder,data_stations,'ask',1)



