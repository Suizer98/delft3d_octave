function nc_cf_line(ncfile,lon,lat,varargin)
%NC_CF_LINE write  (NaN-seperated) (poly-)line (segments) to netCDF file
%
%  nc_cf_line(ncfile,lon,lat,names,<keyword,value>)
%
% This is basically a single non-time dependent trajectory.
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#idp8388800
%
% use keywords 'x','y' and 'projection' to add projected coordinates.
%
%See also: landboundary, shape, netCDF

OPT.title       = '';
OPT.time        = [];
OPT.institution = 'Deltares';
OPT.version     = [];
OPT.names       = [];
OPT.dump        = 0;

OPT.x           = [];
OPT.y           = [];
OPT.epsg        = [];

OPT = setproperty(OPT,varargin);

%% 0 Create file
   
   outputfile    = fullfile(ncfile);
   
   nc_create_empty (outputfile)
   
%% 1 Add global meta-info to file
% Add overall meta info:
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#description-of-file-contents
   
   nc_attput(outputfile, nc_global, 'title'           , OPT.title);
   nc_attput(outputfile, nc_global, 'institution'     , OPT.institution);
   nc_attput(outputfile, nc_global, 'source'          , '');
   nc_attput(outputfile, nc_global, 'history'         , ['$Id: nc_cf_line.m 9337 2013-10-04 15:56:19Z boer_g $ $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_line.m $']);
   nc_attput(outputfile, nc_global, 'references'      , 'http://www.openearth.eu');
   nc_attput(outputfile, nc_global, 'email'           , '');
   
   nc_attput(outputfile, nc_global, 'comment'         , '');
   nc_attput(outputfile, nc_global, 'version'         , OPT.version);
   
   nc_attput(outputfile, nc_global, 'Conventions'     , 'CF-1.6');
   nc_attput(outputfile, nc_global, 'featureType'     , 'trajectory');
   
   nc_attput(outputfile, nc_global, 'terms_for_use'   ,['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
   nc_attput(outputfile, nc_global, 'disclaimer'      , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
%% 2 Create dimensions
   
   if ~isempty(OPT.time)
   nc_add_dimension(outputfile, 'time'       , length(time));
   end
   if ~isempty(OPT.names)
   nc_add_dimension(outputfile, 'segments'   , size(OPT.names,1));
   nc_add_dimension(outputfile, 'name_strlen', size(OPT.names,2)); % 
   end
   nc_add_dimension(outputfile, 'points'          , length(lon))  ; % incl nan-separators
   %nc_add_dimension(outputfile, 'n'          , 1)  ; % incl nan-separators   
   
%% 3 Create variables
   
   clear nc
   ifld = 0;
   
%% Time
   
   if ~isempty(OPT.time)   
   ifld = ifld + 1;
   nc(ifld).Name         = 'time';
   nc(ifld).Nctype       = 'double';
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc_addvar(outputfile, nc(ifld));
   end
   
%% Segment name
   
   if ~isempty(OPT.names)   
   ifld = ifld + 1;
   nc(ifld).Name         = 'description';
   nc(ifld).Nctype       = 'char';
   nc(ifld).Dimension    = {'segments','name_strlen'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'description');
   nc(ifld).Attribute(2) = struct('Name', 'comment'        ,'Value', 'description of nan-separated segments');
  %nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id'); % standard name
   nc_addvar(outputfile, nc(ifld));
   end
   
%% WGS84
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'wgs84';
   nc(ifld).Nctype       = 'int';
   nc(ifld).Dimension    = {}; % no dimension, dummy variable
   nc(ifld).Attribute    = nc_cf_grid_mapping(4326);
   nc_addvar(outputfile, nc(ifld));
   
%  % Line:
%  % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#latitude-coordinate
%    
%  ifld = ifld + 1;
%  nc(ifld).Name         = 'line';
%  nc(ifld).Nctype       = 'float'; % no double needed
%  nc(ifld).Dimension    = {'points'};
%  nc(ifld).Attribute(1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
%  nc(ifld).Attribute(2) = struct('Name', 'coordinates'    ,'Value', 'lon lat'); % use lat itself as "z-variable" to link lat and lon
%  nc_addvar(outputfile, nc(ifld));   
   
   % Longitude:
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#longitude-coordinate
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'lon';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'points'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');
   nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', 'segments are separated by NaN');
   nc(ifld).Attribute(5) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
   nc(ifld).Attribute(6) = struct('Name', 'coordinates'    ,'Value', 'lon lat'); % use lon itself as "z-variable" to link lat and lon
   nc_addvar(outputfile, nc(ifld));
   
   % Latitude:
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#latitude-coordinate
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'lat';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'points'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');
   nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', 'segments are separated by NaN');
   nc(ifld).Attribute(5) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
   nc(ifld).Attribute(6) = struct('Name', 'coordinates'    ,'Value', 'lon lat'); % use lat itself as "z-variable" to link lat and lon
   nc_addvar(outputfile, nc(ifld));
   
   
%% Projected coordinate system
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#appendix-grid-mappings
   
   if ~isempty(OPT.epsg)
     ifld = ifld + 1;
   nc(ifld).Name         = 'projection';
   nc(ifld).Nctype       = 'int';
   nc(ifld).Dimension    = {}; % no dimension, dummy variable
   nc(ifld).Attribute    = nc_cf_grid_mapping(OPT.epsg);
   nc_addvar(outputfile, nc(ifld));
   
   % x:
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'x';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'points'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'x coordinate');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate');
   nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', 'segments are separated by NaN');
   nc(ifld).Attribute(5) = struct('Name', 'grid_mapping'   ,'Value', 'projection');
   nc(ifld).Attribute(6) = struct('Name', 'coordinates'    ,'Value', 'x y'); % use x itself as "z-variable" to link x and y
   nc_addvar(outputfile, nc(ifld));
   
   % y:
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'y';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'points'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'y coordinate');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate');
   nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', 'segments are separated by NaN');
   nc(ifld).Attribute(5) = struct('Name', 'grid_mapping'   ,'Value', 'projection');
   nc(ifld).Attribute(6) = struct('Name', 'coordinates'    ,'Value', 'x y'); % use x itself as "z-variable" to link x and y   
   nc_addvar(outputfile, nc(ifld));
   end

   % Parameters with standard names:
   % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table/
   
%% 4 Create variables with attibutes
%  When variable definitons are created before actually writing the
%  data in the next cell, netCDF can nicely fit all data into the
%  file without the need to relocate any info.
   
   
%% 5 Fill variables
   
   
   if ~isempty(OPT.names)
   nc_varput(outputfile, 'description'          , OPT.names);
   end
%  nc_varput(outputfile, 'line'                 , zeros(size(lon')));
   nc_varput(outputfile, 'lon'                  , lon');   
   nc_varput(outputfile, 'lat'                  , lat');
   nc_varput(outputfile, 'wgs84'                , 4326);

   if ~isempty(OPT.epsg)
   nc_varput(outputfile, 'x'                    , OPT.x);
   nc_varput(outputfile, 'y'                    , OPT.y);
   nc_varput(outputfile, 'projection'           , OPT.epsg);
   end
   
%% 6 Check
   
if isnumeric(OPT.dump) && OPT.dump==1
   nc_dump(ncfile);
else
   fid = fopen(OPT.dump,'w');
   nc_dump(ncfile,fid);
   fclose(fid);
end   
%% EOF