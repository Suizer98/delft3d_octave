%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 17:17:04 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: main_modify_index_location.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/main_modify_index_location.m $
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

load("c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\210505_rmm3d\rmm_plot\sss.mat")
load("c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\210505_rmm3d\rmm_plot\sss_model.mat")
load("c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\210505_rmm3d\rmm_plot\sss_file.mat")
ns=numel(data_stations_index);
% idx_mod=1:1:;

%%

% ns=numel(idx_mod);
for ks=1:ns

loc=data_stations_index(ks).location;
mod=true;
if ks==14
    data_stations_index(ks).location='HOEKVHLD';
elseif ks==47
    data_stations_index(ks).location='LOBH';
elseif any(ismember([2,15,16],ks))
    data_stations_index(ks).location='outdated';
    data_stations_index(ks).location_clear='outdated';
elseif ks==91
    data_stations_index(ks).location='BEERPLKOVR';
elseif ks==28
    data_stations_index(ks).location='kinderdijk';
elseif ks==29
    data_stations_index(ks).location='KRIMPADIJSL';
elseif ks==30
    data_stations_index(ks).location='KRIMPADLK';
elseif any(ismember([36:1:45],ks))
    data_stations_index(ks).location=data_stations_index(ks).location_clear;
elseif any(ismember([78,80],ks))
    data_stations_index(ks).location='TIELWL';
elseif ks==81
    data_stations_index(ks).location='WERKDBTN';
elseif any(ismember([92,93],ks))
    data_stations_index(ks).location='INLSU';
elseif numel(loc)==1
    data_stations_index(ks).location=loc{1,1};
elseif ~iscell(loc)
    data_stations_index(ks).location=loc;
else
    [~,bol]=find_str_in_cell(loc,loc(1));
    if sum(bol)==numel(loc)
        data_stations_index(ks).location=loc{1,1};
    else
        disp(loc)
        a=1;
        mod=false;
    end

end

if mod
path_mod=fullfile(path_data_stations,'separate',sprintf('%06d.mat',ks));
load(path_mod)

data_one_station.location=data_stations_index(ks).location;
data_one_station.location_clear=data_stations_index(ks).location_clear;
save(path_mod,'data_one_station');
end

end

% save(path_ds_idx,'data_stations_index');

%%

fclose all;
fid=fopen('c:\Users\chavarri\Downloads\tmp.txt','w');
nsss=numel(sss_file);
locs={data_stations_index.location};
locs_clear={data_stations_index.location_clear};
for ksss=1:nsss
    idx=find_str_in_cell(locs,sss_file(ksss));
    if isnan(idx)
        continue
    end
    if numel(idx)>1
        idx=idx(1);
    end
    fprintf(fid,'%s, ,%s,%s \n',strrep(sss_model{ksss},'.',''),sss_model{ksss},locs_clear{idx});
end
fclose(fid);