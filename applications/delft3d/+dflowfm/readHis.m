function hisdata = readHis(varargin)
%readHis    Read timeseries data from a D-Flow FM history file.
%   hisdata = unstruc.readHis(filename) reads all station names, locations
%       and waterlevel data into a struct.
%   hisdata = unstruc.readHis(filename, stationname) reads only one
%       specific station into a similar struct.

%   $Id: readHis.m 23738 2012-09-03 12:14:47Z pijl $
%   Edited: 2014-03-24 19:03:00Z martyr
%           Added ability to process cross section data;
%           Added ability to process croos section data with different position
%                 from station data

filename = varargin{1};

if nargin >= 2
    statname = varargin{2};
else
    statname = [];
end


hisdata=struct();
hisdata.time       = nc_cf_time(filename, 'time');

station_name       = nc_varget(filename, 'station_name');
station_x_coord    = nc_varget(filename, 'station_x_coordinate');
station_y_coord    = nc_varget(filename, 'station_y_coordinate');
cross_section_name = nc_varget(filename, 'cross_section_name');

if isempty(statname)
    hisdata.station_name    = station_name;
    hisdata.station_x_coord = station_x_coord;
    hisdata.station_y_coord = station_y_coord;
    hisdata.waterlevel      = nc_varget(filename, 'waterlevel');
    hisdata.x_velocity      = nc_varget(filename, 'x_velocity');
    hisdata.y_velocity      = nc_varget(filename, 'y_velocity');
    
    hisdata.cross_section_name  = cross_section_name;
    hisdata.cross_section_discharge = nc_varget(filename, 'cross_section_discharge');
    hisdata.cross_section_discharge_int = nc_varget(filename, 'cross_section_cumulative_discharge');
    hisdata.cross_section_area      = nc_varget(filename, 'cross_section_area');
    hisdata.cross_section_velocity  = nc_varget(filename, 'cross_section_velocity');
    
    extras={'salinity','temperature','Weir crest level (via general structure)','cross_section_discharge_avg'};
    for extra=extras
        if nc_isvar(filename, extra{1})
            hisdata.(extra{1})=nc_varget(filename, extra{1});
        end
    end
    
else
    idx = [];
    jdx = [];
    for i=1:size(station_name,1)
        if strcmpi(deblank(station_name(i,:)), statname)
            idx = i;
        end
    end
    
    for j=1:size(cross_section_name,1)
        if strcmpi(deblank(cross_section_name(j,:)), statname)
            jdx = j;
        end
    end
    
    if isempty(idx)
        
        warning('Station ''%s'' not found.', char(statname));
    else
        waterlevel      = nc_varget(filename, 'waterlevel');
        x_velocity      = nc_varget(filename, 'x_velocity');
        y_velocity      = nc_varget(filename, 'y_velocity');
        if nc_isvar(filename, 'salinity')
            salinity        = nc_varget(filename, 'salinity');
        end        
        hisdata.station_name    = deblank(station_name(idx,:));
        hisdata.station_x_coord = station_x_coord(idx);
        hisdata.station_y_coord = station_y_coord(idx);
        hisdata.waterlevel      = waterlevel(:,idx);
        hisdata.x_velocity      = x_velocity(:,idx,:);
        hisdata.y_velocity      = y_velocity(:,idx,:);
        if(~isempty(salinity))
            hisdata.salinity        = salinity(:,idx,:);
        else
            warning('Salinity for station ''%'' not found.',char(statname));
        end
    end
    
    if(isempty(jdx))
        warning('Cross section ''%s'' not found.', char(statname));
    else
        cross_section_discharge = nc_varget(filename, 'cross_section_discharge');
        cross_section_discharge_int = nc_varget(filename, 'cross_section_discharge_int');
        cross_section_discharge_avg = nc_varget(filename, 'cross_section_discharge_avg');        
        cross_section_area      = nc_varget(filename, 'cross_section_area');
        cross_section_velocity  = nc_varget(filename, 'cross_section_velocity');
        
        hisdata.cross_section_name    = deblank(cross_section_name(jdx,:));
        hisdata.cross_section_discharge = cross_section_discharge(:,jdx);
        hisdata.cross_section_discharge_int = cross_section_discharge_int(:,jdx);
        hisdata.cross_section_discharge_avg = cross_section_discharge_avg(:,jdx);
        hisdata.cross_section_area = cross_section_area(:,jdx);
        hisdata.cross_section_velocity = cross_section_velocity(:,jdx);
    end
end


end