function jarkus_grid2netcdf(filename, grid, varargin)
%JARKUS_GRID2NETCDF  converts Jarkus grid struct to netCDF-CF file
%
%    jarkus_grid2netcdf(filename, grid)
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

% $Id: jarkus_grid2netcdf_2016.m 12339 2015-11-08 22:50:49Z santinel $
% $Date: 2015-11-09 06:50:49 +0800 (Mon, 09 Nov 2015) $
% $Author: santinel $
% $Revision: 12339 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_grid2netcdf_2016.m $

OPT = struct(...
    'publisher_name', getenv('USERNAME'),...
    'publisher_email', 'info@deltares.nl',...
    'historyatt', '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_grid2netcdf_2016.m $ $Id: jarkus_grid2netcdf_2016.m 12339 2015-11-08 22:50:49Z santinel $',...
    'origins', 1:5,...
    'msg', '',...
    'processing_level', 'preliminary');

OPT = setproperty(OPT, varargin);

datefmt = 'yyyy-mm-ddTHH:MMZ'; % date format
tzoffset = java.util.Date().getTimezoneOffset()/60/24; % time zone offset [days]
% utcnow = now+tzoffset;

%TODO: adjust stringsize to maximum length of areaname
STRINGSIZE = 100;
%% Create file    
%     make sure there's enough space for headers. This will speed up
%     putting attributes

%     nc_create_empty(filename)
%     nc_padheader ( filename, 400000 );   

    origin_codes = 1:5;
    origins = OPT.origins;
    origin_descriptions = {'beach_only' 'beach_overlap' 'interpolation' 'sea_overlap' 'sea_only'};
    origin_flagval_cell = [num2cell(origin_codes); origin_descriptions];
    
%% Put global attributes
    Attributes = [...
    struct( 'Name', 'naming_authority', 'Value', 'deltares.nl' ),... % based on reverse DNS lookup (http://remote.12dt.com/)
    struct( 'Name', 'id', 'Value', sprintf('JarKus_release%s_origins%s', datestr(nowutc, 'yyyymmdd'), sprintf('%i', OPT.origins))),...
    struct( 'Name', 'Metadata_Conventions', 'Value', 'Unidata Dataset Discovery v1.0'),...
    struct( 'Name', 'title', 'Value', 'JarKus Data (cross-shore transects)'),...
    struct( 'Name', 'summary', 'Value', 'Cross-shore yearly transect bathymetry measurements along the Dutch coast since 1965'),...
    struct( 'Name', 'keywords', 'Value', 'Bathymetry, JarKus, Dutch coast'),...
	struct( 'Name', 'keywords_vocabulary', 'Value', 'http://www.eionet.europa.eu/gemet'),...
	struct( 'Name', 'standard_name_vocabulary', 'Value', 'http://cf-pcmdi.llnl.gov/documents/cf-standard-names/'),...
    struct( 'Name', 'history', 'Value', OPT.historyatt),...
    struct( 'Name', 'comment', 'Value', sprintf('The transects in this file are a combination of origins: %s\n%s', sprintf('%i: %s  ', origin_flagval_cell{:,origins}), OPT.msg)),...
    struct( 'Name', 'institution', 'Value', 'Rijkswaterstaat'),...
    struct( 'Name', 'source'     , 'Value', 'on shore and off shore measurements'),...
    struct( 'Name', 'references' , 'Value', 'Original source: http://www.watermarkt.nl/kustenzeebodem/'),...
    struct( 'Name', 'Conventions', 'Value', 'CF-1.6'),...
    ... % Creator Search attributes
    struct( 'Name', 'creator_name', 'Value', 'Rijkswaterstaat'),...
    struct( 'Name', 'creator_url', 'Value', 'http://www.rijkswaterstaat.nl'),...
    struct( 'Name', 'creator_email', 'Value', 'info@rijkswaterstaat.nl'),...
    struct( 'Name', 'date_created', 'Value', datestr(nowutc, datefmt)),...
    struct( 'Name', 'date_modified', 'Value', datestr(nowutc, datefmt)),...
    struct( 'Name', 'date_issued', 'Value', datestr(nowutc, datefmt)),...
    ... % Publisher Search attributes
    struct( 'Name', 'publisher_name', 'Value', OPT.publisher_name),...
    struct( 'Name', 'publisher_url', 'Value', 'http://www.deltares.nl'),...
    struct( 'Name', 'publisher_email', 'Value', OPT.publisher_email),...
    ... % Extent Search attributes
...%     % these attributes will be added in jarkus_transect2netcdf.m
...%     struct( 'Name', 'geospatial_vertical_min', 'Value', NaN)
...%     struct( 'Name', 'geospatial_vertical_max', 'Value', NaN)
    ... % Other Extent Information attributes
    struct( 'Name', 'geospatial_vertical_units', 'Value', 'm'),...
    struct( 'Name', 'geospatial_vertical_resolution', 'Value', .01),...
    struct( 'Name', 'geospatial_vertical_positive', 'Value', 'up'),...
    ...% Other attributes
	struct( 'Name', 'processing_level', 'Value', OPT.processing_level),...
	struct( 'Name', 'license', 'Value', [sprintf('These data can be used freely for research purposes provided that the following source is acknowledged: %s. ', 'RIJKSWATERSTAAT')...
                'disclaimer: This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.']),...
    struct( 'Name', 'cdm_data_type', 'Value', 'grid')];
    % spatial reference using wkt. approach used by gdal.
    % struct( 'Name', 'spatial_ref', 'Value', 'COMPD_CS["Amersfoort / RD New + NAP",PROJCS["Amersfoort / RD New",GEOGCS["Amersfoort",DATUM["Amersfoort",SPHEROID["Bessel 1841",6377397.155,299.1528128,AUTHORITY["EPSG","7004"]],TOWGS84[565.04,49.91,465.84,-0.40939438743923684,-0.35970519561431136,1.868491000350572,0.8409828680306614],AUTHORITY["EPSG","6289"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4289"]],PROJECTION["Oblique Stereographic",AUTHORITY["EPSG","9809"]],PARAMETER["central_meridian",5.387638888888891],PARAMETER["latitude_of_origin",52.15616055555556],PARAMETER["scale_factor",0.9999079],PARAMETER["false_easting",155000.0],PARAMETER["false_northing",463000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","28992"]],VERT_CS["Normaal Amsterdams Peil",VERT_DATUM["Normaal Amsterdams Peil",2005,AUTHORITY["EPSG","5109"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5709"]],AUTHORITY["EPSG","7415"]]');
    
%% Define and create dimensions
    time_dim = struct('Name', 'time', 'Length', 0, 'Unlimited', true);
    bounds2_dim = struct('Name', 'bounds2', 'Length', 2, 'Unlimited', false);
    alongshore_dim = struct('Name', 'alongshore', 'Length', length(grid.id), 'Unlimited', false);
    cross_shore_dim = struct('Name', 'cross_shore', 'Length', length(grid.crossShoreCoordinate), 'Unlimited', false);
    stringsize_dim = struct('Name', 'stringsize', 'Length', STRINGSIZE, 'Unlimited', false);
    Dimensions = [time_dim, bounds2_dim, alongshore_dim, cross_shore_dim, stringsize_dim];

%% Define and create variables
    s.Name      = 'id';
    s.Datatype    = 'int32';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name' ,'comment'},...
                         'Value',{'identifier','sum of area code (*1e6) and alongshore coordinate'});
    Variables = s;
    
    flag_values = 1:17;%unique(grid.areaCode);
    flag_meanings = rws_kustvak(flag_values);
    flag_meanings = str2line(flag_meanings,'s',', ');
    
    s.Name      = 'areacode';
    s.Datatype    = 'int32';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name','flag_values','flag_meanings','flag_comment'       ,'comment'},...
                         'Value',{'area code', flag_values , flag_meanings ,'points to: areaname','codes for the 17 coastal areas (kustvakken) as defined by Rijkswaterstaat'});
    Variables = [Variables, s];

    s.Name      = 'areaname';
    s.Datatype    = 'char';
    
    s.Dimensions = [stringsize_dim, alongshore_dim];
    s.Attributes = struct('Name' ,{'long_name','flag_comment'        ,'comment'},...
                         'Value',{'area name','indexed in: areacode','names for the 17 coastal areas (kustvakken) as defined by Rijkswaterstaat'});
    Variables = [Variables, s];

    s.Name      = 'alongshore';
    s.Datatype    = 'double';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name'             , 'units', 'comment'},...
                         'Value',{'alongshore coordinate', 'm'     , 'alongshore coordinate within the 17 coastal areas (kustvakken) as defined by Rijkswaterstaat'});
    Variables = [Variables, s];
    
    s.Name      = 'cross_shore';
    s.Datatype    = 'double';
    s.Dimensions = cross_shore_dim;
    s.Attributes = struct('Name' ,{'long_name'             , 'units', 'comment'},...
                         'Value',{'cross-shore coordinate', 'm'    , 'cross-shore coordinate relative to the rsp (rijks strand paal)'});
    Variables = [Variables, s];

    % TODO: change to days since epoch
    s.Name      = 'time';
    s.Datatype    = 'double';
    s.Dimensions = time_dim;
    s.Attributes = struct('Name' ,{'standard_name'          ,'axis' ,'units'                 ,'cell_methods','bounds'     ,'comment'         },...
                         'Value',{'time'                   ,'T'    ,'days since 1970-01-01' ,'mean'        ,'time_bounds','measurement year (date is artificially set to July, 1st); see bathy and time_topo for more detailed measurement dates'});
    Variables = [Variables, s];

    s.Name      = 'time_bounds';
    s.Datatype    = 'double';
    s.Dimensions = [bounds2_dim, time_dim];
    s.Attributes = struct('Name' ,{'standard_name'          ,'units'                },...
                         'Value',{'time'                   ,'days since 1970-01-01'});
    Variables = [Variables, s];

    % smaller variables first
    [~,~,OPT]=convertCoordinates(0,0,'CS1.code',28992,'CS2.code',4326);
    %[CoordinateSystems, Operations , CoordSysCart ,CoordSysGeo] = GetCoordinateSystems();
    epsg        = 28992;
    s.Name      = 'epsg';
    s.Datatype    = 'int32';
    s.Dimensions = struct([]);
    s.Attributes = struct('Name', ...
       {'grid_mapping_name', ...
        'semi_major_axis', ...
        'semi_minor_axis', ...
        'inverse_flattening', ...
        'latitude_of_projection_origin', ...
        'longitude_of_projection_origin', ...
        'false_easting', ...
        'false_northing', ...
        'scale_factor_at_projection_origin',...
        'comment'}, ...
        'Value', ...
        {OPT.proj_conv1.method.name,    ...
        OPT.CS1.ellips.semi_major_axis, ...
        OPT.CS1.ellips.semi_minor_axis, ...
        OPT.CS1.ellips.inv_flattening,  ...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'Latitude of natural origin'    )), ...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'Longitude of natural origin'   )),...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'False easting'                 )),...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'False northing'                )),...
        OPT.proj_conv1.param.value(strcmp(OPT.proj_conv1.param.name,'Scale factor at natural origin')),...
        'value is equal to EPSG code'});
    Variables = [Variables, s];
    
    s.Name      = 'x';
    s.Datatype    = 'double';
    s.Dimensions = [cross_shore_dim, alongshore_dim];
    s.Attributes = struct('Name' ,{'standard_name'          ,'units','axis'},...
                         'Value',{'projection_x_coordinate','m'    ,'X'});
    Variables = [Variables, s];
    
    s.Name      = 'y';
    s.Datatype    = 'double';
    s.Dimensions = [cross_shore_dim, alongshore_dim];
    s.Attributes = struct('Name' ,{'standard_name'          ,'units','axis'},...
                         'Value',{'projection_y_coordinate','m'    ,'Y'});
    Variables = [Variables, s];
    
    s.Name      = 'lat';
    s.Datatype    = 'double';
    s.Dimensions = [cross_shore_dim, alongshore_dim];
    s.Attributes = struct('Name' ,{'standard_name'          ,'units'       ,'axis'},...
                         'Value',{'latitude'               ,'degree_north','X'});
    Variables = [Variables, s];
    
    s.Name      = 'lon';
    s.Datatype    = 'double';
    s.Dimensions = [cross_shore_dim, alongshore_dim];
    s.Attributes = struct('Name' ,{'standard_name','units'      ,'axis'},...
                         'Value',{'longitude'    ,'degree_east','Y'});
    Variables = [Variables, s];
    

        
    s.Name      = 'angle';
    s.Datatype    = 'double';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name'        , 'units'  , 'comment'},...
                         'Value',{'angle of transect', 'degrees', 'positive clockwise 0 north'});
    Variables = [Variables, s];
    
    s.Name      = 'mean_high_water';
    s.Datatype    = 'double';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name'      , 'units', 'comment'},...
                         'Value',{'mean high water level', 'm'   , 'mean high water level relative to nap'});
    Variables = [Variables, s];
    
    s.Name      = 'mean_low_water';
    s.Datatype    = 'double';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name'     , 'units', 'comment'},...
                         'Value',{'mean low water level', 'm'    , 'mean low water level relative to nap'});
    Variables = [Variables, s];
    
%% Some extra variables for convenience

    s.Name      = 'max_cross_shore_measurement';
    s.Datatype    = 'int32';
    s.Dimensions = [alongshore_dim, time_dim];
    s.Attributes = struct('Name' ,{'long_name'                            , 'comment'                                       , '_FillValue'},...
                         'Value',{'Maximum cross shore measurement index', 'Index of the cross shore measurement (0 based)',        -9999});
    Variables = [Variables, s];

    s.Name      = 'min_cross_shore_measurement';
    s.Datatype    = 'int32';
    s.Dimensions = [alongshore_dim, time_dim];
    s.Attributes = struct('Name' ,{'long_name'                            , 'comment'                                       , '_FillValue'},...
                         'Value',{'Minimum cross shore measurement index', 'Index of the cross shore measurement (0 based)',        -9999});
    Variables = [Variables, s];
    
%     s.Name      = 'has_data';
%     s.Datatype    = 'int32';
%     s.Dimensions = {'time', 'alongshore'};
%     s.Attributes = struct('Name' ,{'long_name'       , 'comment',                                'flag_values', 'flag_meanings'},...
%                          'Value',{'Has data' ,        'Data availability per year per transect', 0:1,          'false true'});
%     Variables = [Variables, s];
    
    s.Name      = 'nsources';
    s.Datatype    = 'int32';
    s.Dimensions = [alongshore_dim, time_dim];
    s.Attributes = struct('Name' ,{'long_name'              , 'comment'},...
                         'Value',{'Number of data sources' , 'Transects that are based on more than one source should be interpreted with care'});
    Variables = [Variables, s];
    
    s.Name      = 'max_altitude_measurement';
    s.Datatype    = 'double';
    s.Dimensions = [alongshore_dim, time_dim];
    s.Attributes = struct('Name' ,{'long_name'       , 'actual_range', '_FillValue'},...
                         'Value',{'Maximum altitude', [NaN NaN],             -9999});
    Variables = [Variables, s];

    s.Name      = 'min_altitude_measurement';
    s.Datatype    = 'double';
    s.Dimensions = [alongshore_dim, time_dim];
    s.Attributes = struct('Name' ,{'long_name'       , 'actual_range', '_FillValue'},...
                         'Value',{'Minimum altitude', [NaN NaN],              -9999});
    Variables = [Variables, s];

    s.Name      = 'rsp_x';
    s.Datatype    = 'double';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name'              , 'units'            , 'axis', 'comment'},...
                         'Value',{'location for beach pole', 'm'                , 'X'   ,'Location of the beach pole (rijks strand paal)'});
    Variables = [Variables, s];
    
    s.Name      = 'rsp_y';
    s.Datatype    = 'double';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name'              , 'units'            , 'axis', 'comment'},...
                         'Value',{'location for beach pole', 'm'                , 'Y'   , 'Location of the beach pole (rijks strand paal)'});
    Variables = [Variables, s];
    
    s.Name      = 'rsp_lat';
    s.Datatype    = 'double';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name'              , 'units'            , 'comment'},...
                         'Value',{'location for beach pole', 'degrees_north'    , 'Location of the beach pole (rijks strand paal)'});
    Variables = [Variables, s];
    
    s.Name      = 'rsp_lon';
    s.Datatype    = 'double';
    s.Dimensions = alongshore_dim;
    s.Attributes = struct('Name' ,{'long_name'              , 'units'            , 'comment'},...
                         'Value',{'location for beach pole', 'degrees_east'     , 'Location of the beach pole (rijks strand paal)'});
    Variables = [Variables, s];

    
%% information about measurements    
    
    
    s.Name      = 'time_topo';
    s.Datatype    = 'double';
    s.Dimensions = [alongshore_dim, time_dim];
    s.Attributes = struct('Name' ,{'long_name'                     , 'units'                    , 'comment'},...
                         'Value',{'measurement date of topography', 'days since 1970-01-01'    , 'Measurement date of the topography'});
    Variables = [Variables, s];
    s.Name      = 'time_bathy';
    s.Datatype    = 'double';
    s.Dimensions = [alongshore_dim, time_dim];
    s.Attributes = struct('Name' ,{'long_name'                     , 'units'                    , 'comment'},...
                         'Value',{'measurement date of bathymetry', 'days since 1970-01-01'    , 'Measurement date of the bathymetry'});
    Variables = [Variables, s];

    s.Name      = 'origin';
%     id=1 non-overlap     beach data
%     id=2     overlap     beach data
%     id=3     interpolation     data (between beach and off shore)
%     id=4     overlap off shore data
%     id=5 non-overlap off shore data
    s.Datatype    = 'int16';
    s.Dimensions = [cross_shore_dim, alongshore_dim, time_dim];
%     s.Attributes = struct('Name' ,{'long_name'         , 'comment'},...
%                          'Value',{'measurement method', 'Measurement method 1:TO DO, 3:TO DO, 5:TO DO used short for space considerations'});
    flag_values   = origin_codes; 
    s.Attributes = struct('Name' ,{'long_name'         , 'flag_values','flag_meanings', 'comment'},...
                         'Value',{'measurement method',  flag_values  ,strtrim(sprintf('%s ', origin_descriptions{:})), sprintf('The transects in this file are a combination of origins: %s', sprintf('%i: %s  ', origin_flagval_cell{:,origins}))});
    Variables = [Variables, s];
    


%% altitude is big therefor done seperately
%     Some timer routines here to test performance. This can become a bit
%     slow. 
    s.Name      = 'altitude';
    s.Datatype    = 'double';
    s.Dimensions = [cross_shore_dim, alongshore_dim, time_dim];
    s.Attributes = struct('Name', {'standard_name'   , 'units', 'actual_range', 'comment'                   , 'coordinates', 'grid_mapping', '_FillValue'}, ...
                        'Value', {'surface_altitude', 'm'    , [NaN NaN],      'altitude above geoid (NAP)', 'lat lon'    , 'epsg'        , -9999       });
    Variables = [Variables, s];

%% write schema to file        
    ncSchema = struct(...'Filename', strrep(filename, '.nc', 'test.nc'),...
        'Name', '/',...
        'Dimensions', Dimensions,...
        'Variables', Variables,...
        'Attributes', Attributes,...
        'Groups', [],...
        'Format', 'classic');
    ncwriteschema(filename, ncSchema)

%% Store index variables

    ncwrite(filename, 'time'        , grid.time    );
    ncwrite(filename, 'time_bounds' , grid.timelims');

    ncwrite(filename, 'id'          , grid.id);
    ncwrite(filename, 'areacode'    , grid.areaCode);
%    TODO: Hack to store whole array
    areanames = grid.areaName;
    areanames(:, size(areanames,2)+1:STRINGSIZE) = ' ';
    ncwrite(filename, 'areaname', areanames');

    ncwrite(filename, 'alongshore', grid.alongshoreCoordinate);

    ncwrite(filename, 'cross_shore', grid.crossShoreCoordinate);
    ncwrite(filename, 'x'          , grid.X');
    ncwrite(filename, 'y'          , grid.Y');
    
    ncwrite(filename, 'rsp_x'      , grid.x_0);
    ncwrite(filename, 'rsp_y'      , grid.y_0);
    
% add WGS84 [lat,lon]
    
    [lon, lat]=convertCoordinates(grid.X, grid.Y, 'CS1.code', 28992,'CS2.code',4326);
    ncwrite(filename, 'lat', lat');
    ncwrite(filename, 'lon', lon');

    [rsplon, rsplat] = convertCoordinates(grid.x_0, grid.y_0, 'CS1.code', 28992, 'CS2.code', 4326);
    ncwrite(filename, 'rsp_lat', rsplat)
    ncwrite(filename, 'rsp_lon', rsplon)
    
    
    if isfield(grid, 'angle')
        ncwrite(filename, 'angle', grid.angle);
    end
    if isfield(grid, 'meanHighWater')
        ncwrite(filename, 'mean_high_water', grid.meanHighWater);
    end
    if isfield(grid, 'meanLowWater')
        ncwrite(filename, 'mean_low_water', grid.meanLowWater);
    end

%% Print header    
%     try	
%     disp('Will try to run ncdump, no problem if command is not found')
%     system(['ncdump -vyear,id,cross_shore_distance ' filename]); % system will not be catched by try in this way, RPN 22-11-2012

      nc_dump(strrep(filename, '.nc', 'test.nc'))

%     catch
%         disp('can not find the ncdump command, not a problem');
%     end

end % function jarkus_grid2netcdf
