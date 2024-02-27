%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 17:17:04 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: add_data_stations_from_donar.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/add_data_stations_from_donar.m $
%

function add_data_stations_from_donar(paths_main_folder,fpath_donar)

load(fpath_donar,'tims')

ns=numel(tims);
for ks=1:ns
% for ks=40:ns
    
    location=deblank(tims(ks).Locatiecode);
    
    [location_clear,str_found]=RWS_location_clear(location);
    if ~str_found
%         error('name not found in rwsNames')
    end
    
    grootheid=tims(ks).Parametercode;
    switch grootheid
        case 'Cl'
            parameter=grootheid;
            grootheid='CONCTTE';
        case 'WATHTE'
            parameter='';
        otherwise
            error('check')
    end
    
    eenheid=tims(ks).Parametereenheid;
    fact_conv=1;
    switch eenheid
        case 'mg/l'
        case 'cm'
            fact_conv=1/100;
            eenheid='mNAP'; 
        otherwise
            error('check')
           
    end
    
    bh=tims(ks).z;
    if bh==-999999999
        bh=NaN;
    elseif bh<-1e4
        error('check');
    end
    bh=bh./100; %to meters
    
    tim=tims(ks).daty;
    tim.TimeZone='+01:00';
    val=tims(ks).val.*fact_conv;
    
        %check! there is a differencre between NAP and WATSGL
    data_station=struct();
    
    data_station.location=location;
    if str_found
    data_station.location_clear=location_clear{1,1};
    end
    data_station.x=tims(ks).x_RD;
    data_station.y=tims(ks).y_RD;
    data_station.epsg=28992;
    data_station.grootheid=grootheid;
    data_station.eenheid=eenheid;
    data_station.parameter=parameter;
    data_station.time=tim;
    data_station.waarde=val;
    data_station.source=fpath_donar;
    data_station.bemonsteringshoogte=bh;
    
    OPT.ask=0;
    OPT.combine_type=1; %at the times there is this data, erase the existing one
    
    add_data_stations(paths_main_folder,data_station,OPT);
end %ns