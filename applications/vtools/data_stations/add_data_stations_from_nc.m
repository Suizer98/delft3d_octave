%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 17:17:04 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: add_data_stations_from_nc.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/add_data_stations_from_nc.m $
%

function add_data_stations_from_nc(paths_main_folder,fdir_nc)

dire=dir(fdir_nc);
nf=numel(dire);
for kf=1:nf
    fpath=fullfile(dire(kf).folder,dire(kf).name);
    [~,~,ext]=fileparts(fpath);
    if strcmp(ext,'.nc')==0
        continue
    end
    station_name=ncread(fpath,'station_name')';
    platform_name=ncread(fpath,'platform_name')';
    platform_id=ncread(fpath,'platform_id')';
    xco=ncread(fpath,'station_x_coordinate');
    yco=ncread(fpath,'station_y_coordinate');
    val=ncread(fpath,'waterlevel');
    
    tim=NC_read_time(fpath,[1,Inf]);
    
    nci=ncinfo(fpath);
    if strcmp(nci.Variables(5).Attributes(1).Value,'latitude')==0
        error('solve')
    else
        epsg=4326;
    end
    
    data_station.location=deblank(platform_id);
    data_station.location_clear=deblank(station_name);
    data_station.x=xco;
    data_station.y=yco;
    data_station.epsg=epsg;
    data_station.grootheid='WATHTE';
    data_station.eenheid='mNAP';
    data_station.time=tim;
    data_station.waarde=val;
    
    OPT.ask=0;
    add_data_stations(paths_main_folder,data_station,OPT);

end