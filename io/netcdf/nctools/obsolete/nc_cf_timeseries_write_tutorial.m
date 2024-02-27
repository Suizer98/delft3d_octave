%NC_CF_TIMESERIES_WRITE_TUTORIAL tutorial for writing timeseries on disconnected stations to netCDF-CF file (legacy)
%
%  For up-to-date Matlab releases, plase see instead: ncwritetutorial_timeseries.m.
%
%  Tutorial of how to make a netCDF file with CF conventions of a 
%  variable that is a timeseries. In this special case 
%  the main dimension coincides with the time axis.
%
%  This case is described in CF: http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%
%See also: ncwritetutorial_timeseries, nc_cf_timeseries,
%          SNCTOOLS, nc_create_empty, nc_add_dimension, nc_addvar, nc_attput, netcdf, 
%          NC_CF_GRID_WRITE_LAT_LON_ORTHOGONAL_TUTORIAL, 
%          NC_CF_GRID_WRITE_LAT_LON_CURVILINEAR_TUTORIAL, 
%          NC_CF_GRID_WRITE_X_Y_ORTHOGONAL_TUTORIAL
%          NC_CF_GRID_WRITE_X_Y_CURVILINEAR_TUTORIAL

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a> under the <a href="http://www.gnu.org/licenses/gpl.html">GPL</a> license.

%% Define meta-info: global

   OPT.title                  = '';
   OPT.institution            = '';
   OPT.source                 = '';
   OPT.history                = ['tranformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/obsolete/nc_cf_timeseries_write_tutorial.m $'];
   OPT.references             = '';
   OPT.email                  = '';
   OPT.comment                = '';
   OPT.version                = '';
   OPT.acknowledge            =['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution];
   OPT.disclaimer             = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
   
%% Define dimensions/coordinates

   OPT.lon                    = 4.908893108;
   OPT.lat                    = 52.37952805;
   OPT.platform_name          = 'Hoek van Holland';
   OPT.wgs84.code             = 4326;

%% Define variable (define some data)

   OPT.val                    = [1 2 3 nan 5 6];
   OPT.datenum                = datenum(2001:2006,1,1);
   OPT.timezone               = '+01:00';  % MET=+1
   OPT.varname                = 'windspeed';   % free to choose: will appear in netCDF tree
   OPT.units                  = 'm/s';         % from UDunits package: http://www.unidata.ucar.edu/software/udunits/
   OPT.long_name              = 'wind speed '; % free to choose: will appear in plots
   OPT.standard_name          = 'wind_speed';
   OPT.val_type               = 'single';      % 'single' or 'double'
   OPT.fillvalue              = nan;
   
%% 1.a Create netCDF file

   ncfile = fullfile(fileparts(mfilename('fullpath')),[mfilename,'.nc']);

   nc_create_empty (ncfile)

%% 1.b Add overall meta info
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
   nc_attput(ncfile, nc_global, 'title'         , OPT.title);
   nc_attput(ncfile, nc_global, 'institution'   , OPT.institution);
   nc_attput(ncfile, nc_global, 'source'        , OPT.source);
   nc_attput(ncfile, nc_global, 'history'       , OPT.history);
   nc_attput(ncfile, nc_global, 'references'    , OPT.references);
   nc_attput(ncfile, nc_global, 'email'         , OPT.email);

   nc_attput(ncfile, nc_global, 'comment'       , OPT.comment);
   nc_attput(ncfile, nc_global, 'version'       , OPT.version);

   nc_attput(ncfile, nc_global, 'Conventions'   , 'CF-1.4');
   nc_attput(ncfile, nc_global, 'CF:featureType', 'timeSeries');  % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#discrete-sampling-geometries

   nc_attput(ncfile, nc_global, 'terms_for_use' , OPT.acknowledge);
   nc_attput(ncfile, nc_global, 'disclaimer'    , OPT.disclaimer);
      
%% 2   Create matrix span dimensions
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#dimensions   
   
   nc_add_dimension(ncfile, 'time'    , length(OPT.datenum));
   nc_add_dimension(ncfile, 'string'  , length(OPT.platform_name)); % you could set this to UNLIMITED, be we suggest to keep UNLIMITED for time
   
   % If you would like to include more locations of the same data, 
   % you can optionally use 'location' as a 2nd dimension.                                         
   % Here we use it for one platform too, to be able to link cordinates. 

   nc_add_dimension(ncfile, 'location', 1); 

%% 3.a Create coordinate variables: time
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate

   % For time we use "x units since reference_date + timezone", where 
   % * x              can be a character or number,
   % * units          can be any units from UDunits: e.g. days, seconds, years, ...
   % * reference_date is the moment where t-0 is defined in ISO notation
   % * timezone       offset from GMT, in format -/+  HH:00
   % For reference_date we advice to use a common epoch. Although gthis is a 
   % matlab tutorial, the matlab datenumber convention is not adviced: 
   % Here a a serial date number of 1 corresponds to Jan-1-0000. However, this 
   % epoch gives wrong dates in ncbrowse, as it uses a different calender. The
   % Excel epoch of 31-dec-1899 is too stupid to be worth  mentioning. The Apple
   % convenction of 1980 has been superseded since Apple uses unix as a basis. So
   % * 1970-01-01    is adviced to use as epoch, the very common linux datenumber 
   %                 convention (which has no calender issues).

   OPT.refdatenum             = datenum(1970,1,1); 

   clear nc;ifld = 1;
   nc(ifld).Name             = 'time';   % dimension 'time' is here filled with variable 'time'
   nc(ifld).Nctype           = 'double'; % time should always be in doubles
   nc(ifld).Dimension        = {'time'};
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.datenum(:)) max(OPT.datenum(:))]-OPT.refdatenum);

%% 3.b Create coordinate variables: longitude
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

   ifld = ifld + 1;
   nc(ifld).Name             = 'lon';
   nc(ifld).Nctype           = 'double';
   nc(ifld).Dimension        = {'location'};
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lon(:)) max(OPT.lon(:))]);
   nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

%% 3.c Create coordinate variables: latitude
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
   ifld = ifld + 1;
   nc(ifld).Name             = 'lat';
   nc(ifld).Nctype           = 'double';
   nc(ifld).Dimension        = {'location'};
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lat(:)) max(OPT.lat(:))]);
   nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

%% 3.d Create coordinate variables: coordinate system: WGS84 default
%      global ellispes: WGS 84, ED 50, INT 1924, ETRS 89 and the upcoming ETRS update etc.
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#grid-mappings-and-projections
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'wgs84'; % preferred
   nc(ifld).Nctype       = nc_int;
   nc(ifld).Dimension    = {};
   nc(ifld).Attribute    = nc_cf_grid_mapping(OPT.wgs84.code);
   var2evalstr(nc(ifld).Attribute)

%% 3.e platform number/name/code: proposed on:
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#idp8405568

        ifld = ifld + 1;
        nc(ifld).Name         = 'platform_id';
        nc(ifld).Nctype       = 'char';
        nc(ifld).Dimension    = {'location','string'};
        nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'platform identification code');
        nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'platform_id'); % standard name

%% 4   Create dependent variable
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#variables
%      Parameters with standard names:
%      http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

   ifld = ifld + 1;
   nc(ifld).Name             = OPT.varname;
   nc(ifld).Nctype           = nc_type(OPT.val_type);
   nc(ifld).Dimension        = {'location','time'};
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', OPT.long_name    );
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', OPT.units        );
   nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue    );
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.val(:)) max(OPT.val(:))]);
   nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
      
%% 5.a Create all variables with attributes
   
   for ifld=1:length(nc)
      nc_addvar(ncfile, nc(ifld));   
   end
      
%% 5.b Fill all variables

   nc_varput(ncfile, 'time'         , OPT.datenum - OPT.refdatenum);
   nc_varput(ncfile, 'lon'          , OPT.lon          );
   nc_varput(ncfile, 'lat'          , OPT.lat          );
   nc_varput(ncfile, 'wgs84'        , OPT.wgs84.code   );
   nc_varput(ncfile, 'platform_id'  , OPT.platform_name);
   nc_varput(ncfile, OPT.varname    , OPT.val          );
      
%% 6   Check file summary
   
   nc_dump(ncfile);
   fid = fopen(fullfile(fileparts(mfilename('fullpath')),[mfilename,'.cdl']),'w');
   fprintf(fid,'%s\n', '// The netCDF CF conventions for timeseries are defined here:');
   fprintf(fid,'%s\n', '// http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.5/ch05s04.html');
   fprintf(fid,'%s\n', '// and more in detail here too (NOTE: still evolving)');
   fprintf(fid,'%s\n', '// https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions');
   fprintf(fid,'%s\n', '// This timeseries file can be loaded into matlab with nc_cf_timeseries.m');
   fprintf(fid,'%s\n',['// To create this netCDF file with Matlab please see ',mfilename]');

   nc_dump(ncfile,fid);
   fclose(fid);

%% 7.a Load the data: using the variable names from nc_dump

   Da.datenum = nc_varget(ncfile,'time') + datenum(1970,1,1);
   Da.var     = nc_varget(ncfile,'windspeed');

%% 7.b Load the data: using standard_names and coordinate attribute

   Db.datenum = nc_cf_time(ncfile);

   varname    = nc_varfind(ncfile,'attributename', 'standard_name', 'attributevalue', 'wind_speed');
   Db.var     = nc_varget(ncfile,OPT.varname);

%% 7.c Load the data: using a dedicated function developed for time series

   [Dc,Mc]    = nc_cf_timeseries(ncfile,OPT.varname,'plot',1);
