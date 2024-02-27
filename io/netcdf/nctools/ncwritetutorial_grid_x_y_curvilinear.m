%% Create netCDF-CF file of curvilinear x-y grid (native mathworks code)
%
%  example of how to make a netCDF file with CF conventions of a variable 
%  that is defined on a grid that is curvilinear in a lat-lon coordinate
%  system. In this case the matrix dimensions don't coincide with any coordinate axis.
%
%  Example 1: a curvi-linear (lat,lon) grid is for instance a satellite swath:
%  a digital image with a constant width in terms of number of pixels 'columns' (swath),
%  and a length 'rows' determined by how long a ground station can recieve the
%  satellite above the (electro-magnetic) horizon. This image is rectangular in
%  camara pixel space (row,col), but is warped over the earth surface.
%  This case resembles the NCWRITETUTORIAL_GRID_X_Y_ORTHOGONAL, which has as
%  special property that the (row,col) happen to be aligned with a local coordinbate system.
%
%  Example 2: a curvi-linear (lat,lon) grid is the mesh for general
%  circulations models of the ocean like Delft3D. Here the grid is rectangular
%  in matrix space (m,n) or (i,j), but is warped in (lat,lon) space to fit
%  within the coastline constraints. These are plaid that can be plotted
%  with pcolor(lon(:,:),lat(:,:),z(:,:)),
%
%  This case is described as "wo-Dimensional Latitude, Longitude, Coordinate Variables"
%  in http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#idp5559280
%
%  Note that many GIS packages and ncBrowse do not contain plot support for 
%  curvi-linear grids, so they will display the same rectangular plot as for
%  the netCDF file created by NCWRITETUTORIAL_GRID_X_Y_ORTHOGONAL, albeit
%  with different axes annotations: that the axis have no units (mere 0 or 1-based counts).
%
%    ^ latitude (degrees_north)           ^ y(m)
%    |         x                          |             x             
%    | ncols /   \                        |     ncols /   \           
%    |     /  /\   \              coordinate        /  /\   \         
%    |   /   /15\    \          transformation    /   /15\    \       
%    |  x  /10   \     \       <==============>  x  /10   \     \     
%    |    <5     14\     \                |        <5     14\     \   
%    |     \   9    \      \              |         \   9    \      \ 
%    |      \4       \      |             |          \4       \      |
%    |       \        \     |             |           \        \     |
%    |        )3  8  xx)    | nrows       |            )3  8  xx)    |
%    |       /        /     |             |           /        /     |
%    |      /2       /      |             |          /2       /      |
%    |     /   7    /      /              |         /   7    /      / 
%    |    <1     12/     /                |        <1     12/     /   
%    |     \6    /     /                  |         \6    /     /     
%    |       \11/    /                    |          \11/    /        
%    |        \/   x                      |           \/   x          
%    |                                    |                           
%    +----------------------> longitude   +----------------------> x
%                        (degrees_east)                          (m)
%
%See also: ncwritetutorial_grid_lat_lon_orthogonal

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a> under the <a href="http://www.gnu.org/licenses/gpl.html">GPL</a> license.
%  $Id: ncwritetutorial_grid_x_y_curvilinear.m 8907 2013-07-10 12:39:16Z boer_g $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwritetutorial_grid_x_y_curvilinear.m $

   ncfile         = [mfilename,'.nc'];

%% Define meta-info: global

   OPT.refdatenum = datenum(1970,1,1);
   OPT.timezone   = '+08:00';
   OPT.bounds     = 1; % add corner coordinates

   M.institution  = 'Deltares';

%% Define dimensions/coordinates: lat,lon matrices
%  checkersboard to test plot with one nan-hole
   D.cor.lon = [1 3 5 7];
   D.cor.lat = [49.5:1:54.5];
  [D.cor.lon,D.cor.lat] = ndgrid(D.cor.lon,D.cor.lat);
   D.cor.lat = D.cor.lat + [-1  -2 -2 0;0 -.7 -.7  0; 0 0 0 0; 0 0 0 0;  0    .7  .7 0; 0  2  2  1]';
   D.cor.lon = D.cor.lon + [-.5 1   2 4;0  .3  .6 .9; 0 0 0 0; 0 0 0 0; -0.9 -.6 -.3 0;-4 -2 -1 .5]';
   D.lon                    = corner2center(D.cor.lon); % pixel centers
   D.lat                    = corner2center(D.cor.lat);
   D.time                   = datenum(2000,1,1);
   
   M.wgs84.code             = 4326;  % epsg code of global grid: http://www.epsg-registry.org/
   M.wgs84.proj4_params     = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs';
   M.epsg.code              = 32631; % epsg code of local projection
   M.epsg.proj4_params      = '+proj=utm +zone=31 +ellps=WGS84 +datum=WGS84 +units=m +no_defs ';
  [D.cor.x,D.cor.y,log]     = convertCoordinates(D.cor.lon,D.cor.lat,'CS1.code',M.wgs84.code,'CS2.code',M.epsg.code);
   D.x                      = corner2center(D.cor.x); % pixel centers
   D.y                      = corner2center(D.cor.y);
   
%% Define variable (define some data) checkerboard  with 1 NaN-hole

   D.val                    = [  1 102   3 104   5;...
                               106   7 108   9 110;...
                                11 112 nan 114  15]; % use ncols as 1st array dimension to get correct plot in ncBrowse (snctools swaps for us)
%% required vatriable meta-data    

   M.standard_name          = 'sea_floor_depth_below_geoid'; % or 'altitude'
   M.long_name              = 'bottom depth';% free to choose: will appear in plots
   M.units                  = 'm';           % from UDunits package: http://www.unidata.ucar.edu/software/udunits/
   M.varname                = 'depth';       % free to choose: will appear in netCDF tree

%% 1 Create file: global meta-data
%    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#description-of-file-contents
%    http://www.unidata.ucar.edu/software/netcdf-java/formats/DataDiscoveryAttConvention.html

   nc = struct('Name','/','Format','classic');

   nc.Attributes(    1) = struct('Name','title'              ,'Value',  mfilename);
   nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  M.institution);
   nc.Attributes(end+1) = struct('Name','source'             ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','history'            ,'Value',  '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwritetutorial_grid_x_y_curvilinear.m $ $Id: ncwritetutorial_grid_x_y_curvilinear.m 8907 2013-07-10 12:39:16Z boer_g $');
   nc.Attributes(end+1) = struct('Name','references'         ,'Value',  'http://svn.oss.deltares.nl');
   nc.Attributes(end+1) = struct('Name','email'              ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'grid');

   nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','version'            ,'Value',  '');

   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6');

   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',M.institution]);
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
   nc.Attributes(end+1) = struct('Name','time_coverage_start','Value',datestr(min(D.time(:)),'yyyy-mm-ddTHH:MM'));
   nc.Attributes(end+1) = struct('Name','time_coverage_end'  ,'Value',datestr(max(D.time(:)),'yyyy-mm-ddTHH:MM'));

%% 2  Create matrix span dimensions
%     http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#dimensions   

   nc.Dimensions(1) = struct('Name','col'   ,'Length',size (D.lon,1)); % CF wants x last, which means 1st in Matlab
   nc.Dimensions(2) = struct('Name','row'   ,'Length',size (D.lon,2)); % ~ y
   nc.Dimensions(3) = struct('Name','time'  ,'Length',length(D.time)); % CF wants time 1ts, which means last in Matlab
   nc.Dimensions(4) = struct('Name','bounds','Length',4             ); % CF wants bounds last, which means 1st in Matlab
      
%% 3a Create (primary) variables: time
%     http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#time-coordinate

   ifld     = 1;clear attr dims
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
   attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),OPT.timezone]);
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
   
   nc.Variables(ifld) = struct('Name'       , 'time', ...  % dimension 'time' filled with variable 'time'
                               'Datatype'   , 'double', ...% time should always be in doubles
                               'Dimensions' , nc.Dimensions(3),...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
%% 3b Create (primary) variables: space
%     http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#grid-mappings-and-projections

   ifld     = ifld + 1;clear attr % dimension 'x' is here filled with 1D variable 'x'
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Easting');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'epsg');
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.x(:)) max(D.x(:))]);
   if OPT.bounds
   attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'lon_bnds'); % cell boundaries for drawing 'pixels.
   end
   nc.Variables(ifld) = struct('Name'       , 'x', ... % name in ADAGUC code
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([1 2]), ... % 2D (col,row)
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr % dimension 'y' is here filled with 1D variable 'y'
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Northing');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'epsg');
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.y(:)) max(D.y(:))]);
   if OPT.bounds
   attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'lat_bnds');% cell boundaries for drawing 'pixels.
   end
   nc.Variables(ifld) = struct('Name'       , 'y', ... % name in ADAGUC code
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([1 2]), ... % 2D (col,row)
                               'Attributes' , attr,...
                               'FillValue'  , []);

%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#longitude-coordinate

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'projection');
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.lon(:)) max(D.lon(:))]);
   if OPT.bounds
   attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'lon_bnds'); % cell boundaries for drawing 'pixels.
   end
   nc.Variables(ifld) = struct('Name'       , 'lon', ... % name in ADAGUC code
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([1 2]), ... % 2D (col,row)
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#latitude-coordinate

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'projection');
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.lat(:)) max(D.lat(:))]);
   if OPT.bounds
   attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'lat_bnds');% cell boundaries for drawing 'pixels.
   end
   nc.Variables(ifld) = struct('Name'       , 'lat', ... % name in ADAGUC code
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([1 2]), ... % 2D (col,row)
                               'Attributes' , attr,...
                               'FillValue'  , []);

%% 3.c Create coordinate variables: coordinate system: WGS84 default
%      global ellispes: WGS 84, ED 50, INT 1924, ETRS 89 and the upcoming ETRS update etc.
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#grid-mappings-and-projections
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#appendix-grid-mappings
   
                           
   ifld     = ifld + 1;clear attr
   attr     = nc_cf_grid_mapping(M.epsg.code);
   attr(end+1) = struct('Name', 'proj4_params'   ,'Value', M.epsg.proj4_params); % http://adaguc.knmi.nl/
   nc.Variables(ifld) = struct('Name'       , 'epsg', ...
                               'Datatype'   , 'int32', ...
                               'Dimensions' , {[]}, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);                           

   ifld     = ifld + 1;clear attr
   attr     = nc_cf_grid_mapping(M.wgs84.code);
   attr(end+1) = struct('Name', 'proj4_params'   ,'Value', M.wgs84.proj4_params); % http://adaguc.knmi.nl/
   nc.Variables(ifld) = struct('Name'       , 'projection',... % ADAGUC NAME
                               'Datatype'   , 'int32', ...
                               'Dimensions' , {[]}, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);

%% 3.d Bounds (optional)
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#cell-boundaries

   if OPT.bounds
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Easting bounds');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.cor.x(:)) max(D.cor.x(:))]);
   nc.Variables(ifld) = struct('Name'       , 'x_bnds', ... % name in ADAGUC code
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([4 1 2]), ... % CF wants bounds last, i.e 1st in Matlab
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Northing bounds');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.cor.y(:)) max(D.cor.y(:))]);
   nc.Variables(ifld) = struct('Name'       , 'y_bnds', ... % name in ADAGUC code
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([4 1 2]), ... % CF wants bounds last, i.e 1st in Matlab
                               'Attributes' , attr,...
                               'FillValue'  , []);

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude bounds');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.cor.lon(:)) max(D.cor.lon(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lon_bnds', ... % name in ADAGUC code
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([4 1 2]), ... % CF wants bounds last, i.e 1st in Matlab
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude bounds');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.cor.lat(:)) max(D.cor.lat(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lat_bnds', ... % name in ADAGUC code
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([4 1 2]), ... % CF wants bounds last, i.e 1st in Matlab
                               'Attributes' , attr,...
                               'FillValue'  , []);
   end % bounds

%% 3c Create (primary) variables: data
                              
   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name' , 'Value', M.standard_name);
   attr(end+1)  = struct('Name', 'long_name'     , 'Value', M.long_name);
   attr(end+1)  = struct('Name', 'units'         , 'Value', M.units);
   attr(end+1)  = struct('Name', 'positive'      , 'Value', 'up');
   attr(end+1)  = struct('Name', '_FillValue'    , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range'  , 'Value', [min(D.val(:)) max(D.val(:))]);
   attr(end+1)  = struct('Name', 'grid_mapping'  , 'Value', 'projection epsg'); % 'epsg wgs84'
   attr(end+1)  = struct('Name', 'coordinates'   , 'Value', 'lat lon');
   % coordinates is ESSENTIAL CF attribute to connect 2D (lat,lon) matrices to data   
   nc.Variables(ifld) = struct('Name'       , M.varname, ...
                               'Datatype'   , 'double', ...
                               'Dimensions' ,nc.Dimensions(1:3), ... % CF wants time 1st, i.e last in Matlab
                               'Attributes' , attr,...
                               'FillValue'  , []);                              
                              
%% 4 Create netCDF file

   try;delete(ncfile);end
   disp([mfilename,': NCWRITESCHEMA: creating netCDF file: ',ncfile])
   ncwriteschema(ncfile, nc);			        
   disp([mfilename,': NCWRITE: filling  netCDF file: ',ncfile])
      
%% 5 Fill variables

   ncwrite   (ncfile,'time'     , D.time - OPT.refdatenum);
   ncwrite   (ncfile,'x'        , D.x  );
   ncwrite   (ncfile,'y'        , D.y  );
   ncwrite   (ncfile,'lon'      , D.lon);
   ncwrite   (ncfile,'lat'      , D.lat);
   ncwrite   (ncfile,M.varname  , D.val);
   if OPT.bounds
   ncwrite   (ncfile,'x_bnds'   , permute(nc_cf_cor2bounds(D.cor.x'  ),[3 2 1])); % CF polygon orientation requires transpose
   ncwrite   (ncfile,'y_bnds'   , permute(nc_cf_cor2bounds(D.cor.y'  ),[3 2 1])); % CF polygon orientation requires transpose
   ncwrite   (ncfile,'lon_bnds' , permute(nc_cf_cor2bounds(D.cor.lon'),[3 2 1])); % CF polygon orientation requires transpose
   ncwrite   (ncfile,'lat_bnds' , permute(nc_cf_cor2bounds(D.cor.lat'),[3 2 1])); % CF polygon orientation requires transpose
   end
   ncwrite   (ncfile,'epsg'     , M.epsg.code);
   ncwrite   (ncfile,'projection', M.wgs84.code);
      
%% 6 test and check

   nc_dump(ncfile);
   fid = fopen(strrep(ncfile,'.nc','.cdl'),'w');
   fprintf(fid,'%s\n', '// The netCDF-CF conventions for grids are defined here:');
   fprintf(fid,'%s\n', '// http://cf-pcmdi.llnl.gov/documents/cf-conventions/');
   fprintf(fid,'%s\n', '// This grid file can be loaded into matlab with QuickPlot (d3d_qp.m) and ADAGUC.knmi.nl.');
   fprintf(fid,'%s\n',['// To create this netCDF file with Matlab please see ',mfilename]);
   nc_dump(ncfile,[],fid,'h',false);
   fclose(fid);
   
%% 7 Load the data: using the variable names from nc_dump

   Da.dep   = permute(nc_varget(ncfile,'depth'),[2 3 1]);
   Da.lon   = nc_varget(ncfile,'lon');
   Da.lat   = nc_varget(ncfile,'lat');
   if OPT.bounds
   Da.lonc  = nc_cf_bounds2cor(nc_varget(ncfile,'lon_bnds'));
   Da.latc  = nc_cf_bounds2cor(nc_varget(ncfile,'lat_bnds'));
   pcolorcorcen(Da.lonc,Da.latc,Da.dep,'k')
   title(mktex({[mfilename,' showing same data twice:'],...
                'checkerboard: bounded pixel corners, stripes connecting centers: connected points'}))
   end
   hold on
   pcolorcorcen(Da.lon ,Da.lat ,Da.dep,[.5 .5 .5])
   axislat;tickmap('ll')
   
   print2screensizeoverwrite(mfilename);close
