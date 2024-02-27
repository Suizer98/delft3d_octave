function drifters2nc(mid,gt31)
% Matlab script generated by netCDF kickstarter
% at 2014-10-08T08:38Z
% http://publicwiki.deltares.nl/display/OET/netCDF%20kickstarter

%% MAKE VARIABLE ARRAYS
traj = 0;
maxlen = 0;
for i = 1:length(gt31)
    for j = 1:length(gt31{i})
        if length(gt31{i}(j).lon) > 0
            traj = traj+1;
            maxlen = max(maxlen,length(gt31{i}(j).lon));
        end
    end
end
traj = 1:traj;

time = nan(maxlen,traj(end));
lat = nan(maxlen,traj(end));
lon = nan(maxlen,traj(end));
x = nan(maxlen,traj(end));
y = nan(maxlen,traj(end));
uv = nan(maxlen,traj(end));
vel_dir = nan(maxlen,traj(end));
u = nan(maxlen,traj(end));
v = nan(maxlen,traj(end));
id = nan(traj(end),1);
trnum = 0;
for i = 1:length(gt31)
    for j = 1:length(gt31{i})
        if length(gt31{i}(j).lon) > 0
            trnum = trnum + 1;
            
            dx = diff(gt31{i}(j).x);
            dy = diff(gt31{i}(j).y);
            vel_dir_t = atan2(dx,dy);
            u_t = gt31{i}(j).velocity(1:end-1).*sin(vel_dir_t);
            v_t = gt31{i}(j).velocity(1:end-1).*cos(vel_dir_t);
            vel_dir_t = vel_dir_t*180/pi;
            
            time(1:length(gt31{i}(j).epoch),trnum) = gt31{i}(j).epoch;
            lat(1:length(gt31{i}(j).epoch),trnum) = gt31{i}(j).lat;
            lon(1:length(gt31{i}(j).epoch),trnum) = gt31{i}(j).lon;
            x(1:length(gt31{i}(j).epoch),trnum) = gt31{i}(j).x;
            y(1:length(gt31{i}(j).epoch),trnum) = gt31{i}(j).y;
            uv(1:length(gt31{i}(j).epoch),trnum) = gt31{i}(j).velocity;
            vel_dir(1:length(gt31{i}(j).epoch)-1,trnum) = vel_dir_t;
            u(1:length(gt31{i}(j).epoch)-1,trnum) = u_t;
            v(1:length(gt31{i}(j).epoch)-1,trnum) = v_t;
            id(trnum) = gt31{i}(j).name;
        end
    end
end

%% CREATE EMPTY NETCDF FILE
ncfile = [mid '.nc'];
nc_create_empty(ncfile);

%% ADD DIMENSIONS
nc_adddim(ncfile, 'obs', traj(end));
nc_adddim(ncfile, 'trajectory', maxlen);

%% ADD GLOBAL ATTRIBUTES
% see http://www.unidata.ucar.edu/software/thredds/current/netcdf-java/formats/DataDiscoveryAttConvention.html
nc_attput(ncfile, nc_global, 'Conventions', 'CF-1.6');
nc_attput(ncfile, nc_global, 'Metadata_Conventions', 'Unidata Dataset Discovery v1.0');
nc_attput(ncfile, nc_global, 'featureType', 'trajectory');
nc_attput(ncfile, nc_global, 'cdm_data_type', 'Trajectory');
nc_attput(ncfile, nc_global, 'standard_name_vocabulary', 'CF-1.6');
nc_attput(ncfile, nc_global, 'title', 'drifter data megapex 2014');
nc_attput(ncfile, nc_global, 'summary', 'drifter data as measured during the megapex 2014 field campaign at the Sand Motor, Netherlands.');
nc_attput(ncfile, nc_global, 'source', 'GPS-tracked drifters');
nc_attput(ncfile, nc_global, 'platform', 'drifter');
nc_attput(ncfile, nc_global, 'instrument', 'GT31 gps');
nc_attput(ncfile, nc_global, 'uuid', '');
nc_attput(ncfile, nc_global, 'sea_name', 'North Sea');
nc_attput(ncfile, nc_global, 'id', '');
nc_attput(ncfile, nc_global, 'naming_authority', '');
nc_attput(ncfile, nc_global, 'time_coverage_start', datestr(min(min(time))/3600/24+datenum(1970,1,1)));
nc_attput(ncfile, nc_global, 'time_coverage_end', datestr(min(min(time))/3600/24+datenum(1970,1,1)));
nc_attput(ncfile, nc_global, 'time_coverage_resolution', '1 second');
nc_attput(ncfile, nc_global, 'geospatial_lat_min', num2str(min(min(lat))));
nc_attput(ncfile, nc_global, 'geospatial_lat_max', num2str(max(max(lat))));
nc_attput(ncfile, nc_global, 'geospatial_lat_units', 'degrees_north');
nc_attput(ncfile, nc_global, 'geospatial_lat_resolution', '-');
nc_attput(ncfile, nc_global, 'geospatial_lon_min', num2str(min(min(lon))));
nc_attput(ncfile, nc_global, 'geospatial_lon_max', num2str(max(max(lat))));
nc_attput(ncfile, nc_global, 'geospatial_lon_units', 'degrees_east');
nc_attput(ncfile, nc_global, 'geospatial_lon_resolution', '-');
nc_attput(ncfile, nc_global, 'institution', 'Delft University of Technology');
nc_attput(ncfile, nc_global, 'creator_name', 'Max Radermacher');
nc_attput(ncfile, nc_global, 'creator_url', 'http://www.naturecoast.nl/');
nc_attput(ncfile, nc_global, 'creator_email', 'm.radermacher@tudelft.nl');
nc_attput(ncfile, nc_global, 'project', 'STW NatureCoast');
nc_attput(ncfile, nc_global, 'processing_level', 'prelim');
nc_attput(ncfile, nc_global, 'references', '');
nc_attput(ncfile, nc_global, 'keywords_vocabulary', '');
nc_attput(ncfile, nc_global, 'keywords', '');
nc_attput(ncfile, nc_global, 'acknowledgment', 'STW NatureCoast');
nc_attput(ncfile, nc_global, 'comment', '');
nc_attput(ncfile, nc_global, 'contributor_name', 'Wilmar Zeelenberg');
nc_attput(ncfile, nc_global, 'contributor_role', 'Performing drifter deployments');
nc_attput(ncfile, nc_global, 'date_created', '2014-10-08T08:38Z');
nc_attput(ncfile, nc_global, 'date_modified', '2014-10-08T08:38Z');
nc_attput(ncfile, nc_global, 'date_issued', '2014-10-08T08:38Z');
nc_attput(ncfile, nc_global, 'publisher_name', 'Max Radermacher');
nc_attput(ncfile, nc_global, 'publisher_email', 'm.radermacher@tudelft.nl');
nc_attput(ncfile, nc_global, 'publisher_url', 'http://www.naturecoast.nl/');
nc_attput(ncfile, nc_global, 'history', ['Data collected on ' datestr(floor(min(min(time))/3600/24+datenum(1970,1,1)),'dd-mmm-yyyy') '. Processed with script process_drifterlog.m on ' datestr(now,'dd-mmm-yyyy') '. Netcdf file created ' datestr(now) '.']);
nc_attput(ncfile, nc_global, 'license', '-');
nc_attput(ncfile, nc_global, 'metadata_link', '0');

%% ADD VARIABLES
var = struct(...
    'Name', 'trajectory',...
    'Datatype', 'int32',...
    'Dimension', {{'trajectory'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'trajectory', 'long_name', 'Unique identifier for each feature instance');
nc_attput(ncfile, 'trajectory', 'cf_role', 'trajectory_id');
nc_varput(ncfile, 'trajectory', traj);

var = struct(...
    'Name', 'time',...
    'Datatype', 'double',...
    'Dimension', {{'trajectory','obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'time', 'long_name', 'epoch time');
nc_attput(ncfile, 'time', 'standard_name', 'time');
nc_attput(ncfile, 'time', 'units', 'seconds since 1970-01-01 00:00:00 0:00');
nc_attput(ncfile, 'time', 'calendar', 'julian');
nc_attput(ncfile, 'time', 'axis', 'T');
nc_attput(ncfile, 'time', 'ancillary_variables', '');
nc_attput(ncfile, 'time', 'comment', '');
nc_varput(ncfile, 'time', time);

var = struct(...
    'Name', 'lat',...
    'Datatype', 'double',...
    'Dimension', {{'trajectory','obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'lat', 'long_name', 'latitude');
nc_attput(ncfile, 'lat', 'standard_name', 'latitude');
nc_attput(ncfile, 'lat', 'units', 'degrees_north');
nc_attput(ncfile, 'lat', 'axis', 'Y');
nc_attput(ncfile, 'lat', 'valid_min', nc_attget(ncfile, nc_global, 'geospatial_lat_min'));
nc_attput(ncfile, 'lat', 'valid_max', nc_attget(ncfile, nc_global, 'geospatial_lat_max'));
nc_attput(ncfile, 'lat', 'ancillary_variables', '');
nc_attput(ncfile, 'lat', 'comment', '');
nc_varput(ncfile, 'lat', lat);

var = struct(...
    'Name', 'lon',...
    'Datatype', 'double',...
    'Dimension', {{'trajectory','obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'lon', 'long_name', 'longitude');
nc_attput(ncfile, 'lon', 'standard_name', 'longitude');
nc_attput(ncfile, 'lon', 'units', 'degrees_east');
nc_attput(ncfile, 'lon', 'axis', 'X');
nc_attput(ncfile, 'lon', 'valid_min', nc_attget(ncfile, nc_global, 'geospatial_lon_min'));
nc_attput(ncfile, 'lon', 'valid_max', nc_attget(ncfile, nc_global, 'geospatial_lon_max'));
nc_attput(ncfile, 'lon', 'ancillary_variables', '');
nc_attput(ncfile, 'lon', 'comment', '');
nc_varput(ncfile, 'lon', lon);

var = struct(...
    'Name', 'x',...
    'Datatype', 'double',...
    'Dimension', {{'trajectory','obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'x', 'long_name', 'x RD');
nc_attput(ncfile, 'x', 'standard_name', 'projection_x_coordinate');
nc_attput(ncfile, 'x', 'units', 'm');
nc_attput(ncfile, 'x', 'axis', 'X');
nc_attput(ncfile, 'x', 'valid_min', min(min(x)));
nc_attput(ncfile, 'x', 'valid_max', max(max(x)));
nc_attput(ncfile, 'x', 'ancillary_variables', '');
nc_attput(ncfile, 'x', 'comment', '');
nc_varput(ncfile, 'x', x);

var = struct(...
    'Name', 'y',...
    'Datatype', 'double',...
    'Dimension', {{'trajectory','obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'y', 'long_name', 'y RD');
nc_attput(ncfile, 'y', 'standard_name', 'projection_y_coordinate');
nc_attput(ncfile, 'y', 'units', 'm');
nc_attput(ncfile, 'y', 'axis', 'Y');
nc_attput(ncfile, 'y', 'valid_min', min(min(y)));
nc_attput(ncfile, 'y', 'valid_max', max(max(y)));
nc_attput(ncfile, 'y', 'ancillary_variables', '');
nc_attput(ncfile, 'y', 'comment', '');
nc_varput(ncfile, 'y', y);

var = struct(...
    'Name', 'uv',...
    'Datatype', 'double',...
    'Dimension', {{'trajectory','obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'uv', 'long_name', 'velocity magnitude');
nc_attput(ncfile, 'uv', 'standard_name', 'None');
nc_attput(ncfile, 'uv', 'units', 'm s^-1');
nc_attput(ncfile, 'uv', 'scale_factor', 1.0);
nc_attput(ncfile, 'uv', 'add_offset', 0.0);
nc_attput(ncfile, 'uv', 'valid_min', min(min(uv)));
nc_attput(ncfile, 'uv', 'valid_max', max(max(uv)));
nc_attput(ncfile, 'uv', 'coordinates', 'time y x');
nc_attput(ncfile, 'uv', 'grid_mapping', 'crs');
nc_attput(ncfile, 'uv', 'source', 'GT31 GPS logger');
nc_attput(ncfile, 'uv', 'references', '');
nc_attput(ncfile, 'uv', 'cell_methods', '');
nc_attput(ncfile, 'uv', 'ancillary_variables', '');
nc_attput(ncfile, 'uv', 'comment', '');
nc_varput(ncfile, 'uv', uv);

var = struct(...
    'Name', 'vel_dir',...
    'Datatype', 'double',...
    'Dimension', {{'trajectory','obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'vel_dir', 'long_name', 'velocity direction');
nc_attput(ncfile, 'vel_dir', 'standard_name', 'direction_of_sea_water_velocity');
nc_attput(ncfile, 'vel_dir', 'units', 'degree');
nc_attput(ncfile, 'vel_dir', 'scale_factor', 1.0);
nc_attput(ncfile, 'vel_dir', 'add_offset', 0.0);
nc_attput(ncfile, 'vel_dir', 'valid_min', -180);
nc_attput(ncfile, 'vel_dir', 'valid_max', 180);
nc_attput(ncfile, 'vel_dir', 'coordinates', 'time y x');
nc_attput(ncfile, 'vel_dir', 'grid_mapping', 'crs');
nc_attput(ncfile, 'vel_dir', 'source', '');
nc_attput(ncfile, 'vel_dir', 'references', '');
nc_attput(ncfile, 'vel_dir', 'cell_methods', '');
nc_attput(ncfile, 'vel_dir', 'ancillary_variables', '');
nc_attput(ncfile, 'vel_dir', 'comment', 'Determined from displacements in x and y. Direction at t = n is determined from offset between x(n) and x(n+1). Last entry is set to nan.');
nc_varput(ncfile, 'vel_dir', vel_dir);

var = struct(...
    'Name', 'u',...
    'Datatype', 'double',...
    'Dimension', {{'trajectory','obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'u', 'long_name', 'u velocity');
nc_attput(ncfile, 'u', 'standard_name', 'sea_water_x_velocity');
nc_attput(ncfile, 'u', 'units', 'm s^-1');
nc_attput(ncfile, 'u', 'scale_factor', 1.0);
nc_attput(ncfile, 'u', 'add_offset', 0.0);
nc_attput(ncfile, 'u', 'valid_min', min(min(u)));
nc_attput(ncfile, 'u', 'valid_max', max(max(u)));
nc_attput(ncfile, 'u', 'coordinates', 'time y x');
nc_attput(ncfile, 'u', 'grid_mapping', 'crs');
nc_attput(ncfile, 'u', 'source', '');
nc_attput(ncfile, 'u', 'references', '');
nc_attput(ncfile, 'u', 'cell_methods', '');
nc_attput(ncfile, 'u', 'ancillary_variables', '');
nc_attput(ncfile, 'u', 'comment', 'Determined from velocity magnitude and velocity direction.');
nc_varput(ncfile, 'u', u);

var = struct(...
    'Name', 'v',...
    'Datatype', 'double',...
    'Dimension', {{'trajectory','obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'v', 'long_name', 'v velocity');
nc_attput(ncfile, 'v', 'standard_name', 'sea_water_y_velocity');
nc_attput(ncfile, 'v', 'units', 'm s^-1');
nc_attput(ncfile, 'v', 'scale_factor', 1.0);
nc_attput(ncfile, 'v', 'add_offset', 0.0);
nc_attput(ncfile, 'v', 'valid_min', min(min(v)));
nc_attput(ncfile, 'v', 'valid_max', max(max(v)));
nc_attput(ncfile, 'v', 'coordinates', 'time y x');
nc_attput(ncfile, 'v', 'grid_mapping', 'crs');
nc_attput(ncfile, 'v', 'source', '');
nc_attput(ncfile, 'v', 'references', '');
nc_attput(ncfile, 'v', 'cell_methods', '');
nc_attput(ncfile, 'v', 'ancillary_variables', '');
nc_attput(ncfile, 'v', 'comment', 'Determined from velocity magnitude and velocity direction.');
nc_varput(ncfile, 'v', v);

var = struct(...
    'Name', 'id',...
    'Datatype', 'double',...
    'Dimension', {{'obs'}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'id', 'long_name', 'drifter number');
nc_attput(ncfile, 'id', 'standard_name', 'None');
nc_attput(ncfile, 'id', 'units', 'None');
nc_attput(ncfile, 'id', 'scale_factor', 1.0);
nc_attput(ncfile, 'id', 'add_offset', 0.0);
nc_attput(ncfile, 'id', 'valid_min', min(id));
nc_attput(ncfile, 'id', 'valid_max', max(id));
nc_attput(ncfile, 'id', 'coordinates', 'time y x');
nc_attput(ncfile, 'id', 'grid_mapping', 'crs');
nc_attput(ncfile, 'id', 'source', '');
nc_attput(ncfile, 'id', 'references', '');
nc_attput(ncfile, 'id', 'cell_methods', '');
nc_attput(ncfile, 'id', 'ancillary_variables', '');
nc_attput(ncfile, 'id', 'comment', '');
nc_varput(ncfile, 'id', id);

var = struct(...
    'Name', 'crs',...
    'Datatype', 'int32',...
    'Dimension', {{}}); % note the double brackets
nc_addvar(ncfile, var);
nc_attput(ncfile, 'crs', 'grid_mapping_name', 'oblique_stereographic');
nc_attput(ncfile, 'crs', 'epsg_code', 'EPSG:28992');
nc_attput(ncfile, 'crs', 'semi_major_axis', 6377397.155);
nc_attput(ncfile, 'crs', 'semi_minor_axis', 6356078.96282);
nc_attput(ncfile, 'crs', 'inverse_flattening', 299.1528128);
nc_attput(ncfile, 'crs', 'latitude_of_projection_origin', 52.0922178);
nc_attput(ncfile, 'crs', 'longitude_of_projection_origin', 5.23155);
nc_attput(ncfile, 'crs', 'scale_factor_at_projection_origin', 0.9999079);
nc_attput(ncfile, 'crs', 'false_easting', 155000.0);
nc_attput(ncfile, 'crs', 'false_northing', 463000.0);
nc_attput(ncfile, 'crs', 'proj4_params', '+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +towgs84=565.4174,50.3319,465.5542,-0.398957388243134,0.343987817378283,-1.87740163998045,4.0725 +no_defs');

end