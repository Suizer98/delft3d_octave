function varargout = ncgen_writeFcn_surface(OPT,data)

% input must be a data structure with fields x,y and z.
% x and y are one dimensional
% z is two dimensional, with dimension order x,y (matlab default
% dimensionorder is y,x)

if nargin == 0 || isempty(OPT)
    % return OPT structure with options specific to this function
    OPT.write.schema        = struct([]); %nccreateSchema(dimstruct,varstruct);
    OPT.write.filenameFcn   = @(x,y) sprintf('x%07.0fy%07.0f.nc',min(x),min(y));
    OPT.write.timeDependant = true;
    varargout               = {OPT.write};
    return
else
    if datenum(version('-date'), 'mmmm dd, yyyy') < 734729
        % version 2011a and older
        error(nargchk(2,2,nargin))
    else
        % version 2011b and newer
        narginchk(2,2)
    end
end


%% check input
required_fields = {'x','y','time','z','source_file_hash'};

assert(isstruct(data)                                 ,'data input must be a struture');
assert(all(ismember(required_fields,fieldnames(data))),'data input must contain all these fields: %s',str2line(required_fields,'s',', '));

%% make nc file if it does not exist
ncfile = fullfile(OPT.main.path_netcdf,OPT.write.filenameFcn(data.x,data.y));

if ~exist(ncfile,'file')
    ncwriteschema(ncfile,OPT.write.schema);
    
    % write x and y
    ncwrite(ncfile,'x',data.x)
    ncwrite(ncfile,'y',data.y)
    
    % update actual range of x and y
    ncwriteatt(ncfile,'x','actual_range',[min(data.x) max(data.x)])
    ncwriteatt(ncfile,'y','actual_range',[min(data.y) max(data.y)])
    
    % update geospatial attributes
    ncwriteatt(ncfile,'/','projectionCoverage_x',[min(data.x) max(data.x)] + [-.5 .5]*OPT.schema.grid_cellsize(1))
    ncwriteatt(ncfile,'/','projectionCoverage_y',[min(data.y) max(data.y)] + [-.5 .5]*OPT.schema.grid_cellsize(end))
    
    [y,x] = meshgrid(data.y,data.x); % reverse y and x to keep dimension order x,y
    if ~isempty(OPT.schema.EPSGcode)
        ncwrite(ncfile,'crs',OPT.schema.EPSGcode);
        if OPT.schema.includeLatLon
            % calculate lat and lon
            [lon,lat] = convertCoordinates(x,y,'persistent','CS1.code',OPT.schema.EPSGcode,'CS2.code',4326);
            
            % write lat and lon variables
            ncwrite(ncfile,'lat',lat);
            ncwrite(ncfile,'lon',lon);
            
            % write attributes
            %  first calculate coordinates of corner points of bounding box (half cell size larger than min/max coordinates)
            [x_bounds,y_bounds]     = meshgrid(ncreadatt(ncfile,'/','projectionCoverage_x'),ncreadatt(ncfile,'/','projectionCoverage_y'));
            [lon_bounds,lat_bounds] = convertCoordinates(x_bounds,y_bounds,'persistent','CS1.code',OPT.schema.EPSGcode,'CS2.code',4326);
            
            % update actual range of lat and lon
            ncwriteatt(ncfile,'lat','actual_range',[min(lat_bounds(:)) max(lat_bounds(:))])
            ncwriteatt(ncfile,'lon','actual_range',[min(lon_bounds(:)) max(lon_bounds(:))])
            
            % write attributes
            ncwriteatt(ncfile,'/','geospatialCoverage_northsouth',[min(lat_bounds(:)) max(lat_bounds(:))]);
            ncwriteatt(ncfile,'/','geospatialCoverage_eastwest'  ,[min(lon_bounds(:)) max(lon_bounds(:))]);
            ncwriteatt(ncfile,'/','geospatial_lat_min', min(lat_bounds(:)));
            ncwriteatt(ncfile,'/','geospatial_lat_max', max(lat_bounds(:)));
            ncwriteatt(ncfile,'/','geospatial_lon_min', min(lon_bounds(:)));
            ncwriteatt(ncfile,'/','geospatial_lon_max', max(lon_bounds(:)));
        end
    end
    isource = 0;
else
    isource = length(ncreadatt(ncfile, 'isource', 'flag_values'));
end

%% get already available timesteps in nc file
    timestamps_in_nc = [];
    time_info = ncinfo(ncfile, 'time');
    if time_info.Size > 0
        timestamps_in_nc  = ncread(ncfile,'time'); % not Matlab datenums, but in udunits
    end

%% add time if it is not already in nc file and determine index
   if any(timestamps_in_nc == data.time)
       iTimestamp = find(timestamps_in_nc == data.time,1);
       existing_z = true;
   else
       iTimestamp = length(timestamps_in_nc)+1;
       ncwrite(ncfile,'time',data.time,iTimestamp);
       existing_z = false;
       
       % read dates and timezone from ncfile
       [dates,zone] = nc_cf_time(ncfile,'time');

       % update actual range of time
       ncwriteatt(ncfile,'time','actual_range', sprintf('%s%s - %s%s',...
           datestr(min(dates),'yyyy-mm-ddTHH:MM:SS'),zone{1},...
           datestr(max(dates),'yyyy-mm-ddTHH:MM:SS'),zone{1}));
        
       % write timeCoverage in yyyy-mm-ddTHH:MM:SS Timezone 
       ncwriteatt(ncfile,'/','timeCoverage',sprintf('%s%s - %s%s',...
           datestr(min(dates),'yyyy-mm-ddTHH:MM:SS'),zone{1},...
           datestr(max(dates),'yyyy-mm-ddTHH:MM:SS'),zone{1}));
   end

%% Merge Z data with existing data if it exists
if existing_z % then existing nc file already has data
    % read Z data
    z0       = ncread(ncfile,'z',[1 1 iTimestamp],[inf inf 1]);
    isource0 = ncread(ncfile,'isource',[1 1 iTimestamp],[inf inf 1]);
    zNotnan  = ~isnan(data.z);
    z0Notnan = ~isnan(z0);
    notnan   = zNotnan&z0Notnan;
    % check if data will be overwritten
    % if any(notnan) % some values are not nan in both existing and new data
    if any(any(notnan)) % notnan is a matrix, so it requires a better statement    
        if isequal(z0(notnan),data.z(notnan))
            % this is ok
            returnmessage(1,'in %s, NOTICE: %d values are overwritten by identical values from a different source at %s \n',...
                ncfile,sum(notnan(:)),datestr(udunits2datenum(data.time,OPT.schema.time_units),'yyyy-mm-dd HH:MM:SS'))
        else 
            % this is (most likely) not ok   
            returnmessage(2,'in %s, WARNING: %d values are overwritten by different values from a different source at %s \n',...
                ncfile,sum(notnan(:)),datestr(udunits2datenum(data.time,OPT.schema.time_units),'yyyy-mm-dd HH:MM:SS'))
        end
    end
    z0(zNotnan) = data.z(zNotnan);
    isource0(zNotnan) = isource * data.source(zNotnan);
    isource = isource0;
    
    data.z = z0;
else
    isource = isource * data.source;
    isource(isnan(data.z)) = nan;
    
end

%% Write z data
try
    ncwrite(ncfile,'z',data.z,[1 1 iTimestamp]);
    ncwrite(ncfile,'isource',isource,[1 1 iTimestamp]);
    flag_values = ncreadatt(ncfile, 'isource', 'flag_values');
    flag_meanings = ncreadatt(ncfile, 'isource', 'flag_meanings');
    source = ncreadatt(ncfile, 'isource', 'source');
    
    ncwriteatt(ncfile, 'isource', 'flag_values', [flag_values length(flag_values)])
    if isempty(flag_values)
        ncwriteatt(ncfile, 'isource', 'flag_meanings', data.filename)
        if isempty(OPT.main.projectFcn(data.filename))
            ncwriteatt(ncfile, 'isource', 'source', OPT.main.project);
        else
            ncwriteatt(ncfile, 'isource', 'source', char(OPT.main.projectFcn(data.filename)))
        end
    else
        ncwriteatt(ncfile, 'isource', 'flag_meanings', [flag_meanings ' ' data.filename])
        if isempty(OPT.main.projectFcn(data.filename))
            ncwriteatt(ncfile, 'isource', 'source', [source ' ' OPT.main.project])
        else
            ncwriteatt(ncfile, 'isource', 'source', [source ' ' char(OPT.main.projectFcn(data.filename))])
        end
    end

    if isfield(data, 'message')
        if ~isempty(data.message)
            comm = ncreadatt(ncfile,'/','comment');
            ncwriteatt(ncfile,'/','comment', sprintf('%s\n%s', comm, data.message))
        end
    end
catch
    max(data.z(:))
    min(data.z(:))
    iTimestamp
end
% read current actual range of z
z_actual_range = ncreadatt(ncfile, 'z', 'actual_range');

% update actual range of z
z_actual_range = [nanmin([data.z(:); z_actual_range']) nanmax([data.z(:); z_actual_range'])];
ncwriteatt(ncfile, 'z', 'actual_range',...
    z_actual_range);

ncwriteatt(ncfile,'/','geospatial_vertical_min', min(z_actual_range));
ncwriteatt(ncfile,'/','geospatial_vertical_max', max(z_actual_range));

%% add source file path and hash
if OPT.main.hash_source
    source_file_hash = [];
    source_file_hash_info = ncinfo(ncfile,'source_file_hash');
    if source_file_hash_info.Size(2) > 0
        source_file_hash = ncread(ncfile,'source_file_hash')';
    end
    source_file_hash = unique([source_file_hash; data.source_file_hash],'rows');
    ncwrite(ncfile,'source_file_hash',source_file_hash');
end

