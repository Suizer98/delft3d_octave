%% Create netCDF-CF file of curvilinear x-y grid (snctools)
%
%  Deprecated: for native Matlab and faster performance code see ncwritetutorial_grid_lat_lon_orthogonal
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
%  This case resembles the NC_CF_GRID_WRITE_X_Y_ORTHOGONAL_TUTORIAL, which has as
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
%  the netCDF file created by NC_CF_GRID_WRITE_X_Y_ORTHOGONAL_TUTORIAL, albeit
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
%  $Id: nc_cf_grid_write_x_y_curvilinear_tutorial.m 11864 2015-04-15 14:51:13Z gerben.deboer.x $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/obsolete/nc_cf_grid_write_x_y_curvilinear_tutorial.m $

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
   
%% 1.a Create netCDF file

   nc_create_empty (ncfile)

%% 1.b Add overall meta info
%    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#description-of-file-contents
%    http://www.unidata.ucar.edu/software/netcdf-java/formats/DataDiscoveryAttConvention.html
   
   nc_attput(ncfile, nc_global, 'title'         , mfilename);
   nc_attput(ncfile, nc_global, 'institution'   , M.institution);
   nc_attput(ncfile, nc_global, 'source'        , '');
   nc_attput(ncfile, nc_global, 'history'       , '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/obsolete/nc_cf_grid_write_x_y_curvilinear_tutorial.m $ $Id: nc_cf_grid_write_x_y_curvilinear_tutorial.m 11864 2015-04-15 14:51:13Z gerben.deboer.x $');
   nc_attput(ncfile, nc_global, 'references'    , 'http://svn.oss.deltares.nl');
   nc_attput(ncfile, nc_global, 'email'         , '');
   nc_attput(ncfile, nc_global, 'featureType'   , 'grid');

   nc_attput(ncfile, nc_global, 'comment'       , '');
   nc_attput(ncfile, nc_global, 'version'       , '');

   nc_attput(ncfile, nc_global, 'Conventions'   , 'CF-1.6');

   nc_attput(ncfile, nc_global, 'terms_for_use' ,['These data can be used freely for research purposes provided that the following source is acknowledged: ',M.institution]);
   nc_attput(ncfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
   nc_attput(ncfile, nc_global, 'time_coverage_start',datestr(min(D.time(:)),'yyyy-mm-ddTHH:MM'));
   nc_attput(ncfile, nc_global, 'time_coverage_end'  ,datestr(max(D.time(:)),'yyyy-mm-ddTHH:MM'));
      
%% 2  Create matrix span dimensions
%     http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#dimensions   
   
   nc_add_dimension(ncfile, 'col'     ,size (D.lon,1)); % CF wants x last, which means 1st in Matlab
   nc_add_dimension(ncfile, 'row'     ,size (D.lon,2)); % ~ y
   nc_add_dimension(ncfile, 'time'    , 1            ); % CF wants bounds last, which means 1st in Matlab
   nc_add_dimension(ncfile, 'bounds'  , 4            ); % CF wants time 1ts, which means last in Matlab

%% 3a Create (primary) variables: time
%     http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#time-coordinate

   clear nc;ifld = 1;
   nc(ifld).Name             = 'time';   % dimension 'time' filled with variable 'time'
   nc(ifld).Nctype           = 'double'; % time should always be in doubles
   nc(ifld).Dimension        = {'time'};
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name', 'Value', 'time');
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'    , 'Value', 'time');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(end+1) = struct('Name', 'axis'         , 'Value', 'T');

%% 3b Create (primary) variables: space
%     http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#grid-mappings-and-projections

   ifld = ifld + 1;   
   nc(ifld).Name             = 'x'; % dimension 'x' is here filled with 1D variable 'x'
   nc(ifld).Nctype           = nc_type('double');
   nc(ifld).Dimension        = {'row','col'}; % 2D (col,row)
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'    , 'Value', 'Easting');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'        , 'Value', 'm');
   nc(ifld).Attribute(end+1) = struct('Name', 'axis'         , 'Value', 'X');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping' , 'Value', 'epsg');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range' , 'Value', [min(D.x(:)) max(D.x(:))]);
   nc(ifld).Attribute(end+1) = struct('Name', 'bounds'       , 'Value', 'lon_bnds');% cell boundaries for drawing 'pixels.
   
   ifld = ifld + 1;
   nc(ifld).Name             = 'y'; % dimension 'y' is here filled with 1D variable 'y'
   nc(ifld).Nctype           = nc_type('double');
   nc(ifld).Dimension        = {'row','col'}; % 2D (col,row)
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'    , 'Value', 'Northing');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'        , 'Value', 'm');
   nc(ifld).Attribute(end+1) = struct('Name', 'axis'         , 'Value', 'Y');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping' , 'Value', 'epsg');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range' , 'Value', [min(D.y(:)) max(D.y(:))]);
   nc(ifld).Attribute(end+1) = struct('Name', 'bounds'       , 'Value', 'lat_bnds');% cell boundaries for drawing 'pixels.

%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#longitude-coordinate

   ifld = ifld + 1;   
   nc(ifld).Name             = 'lon'; % dimension 'lon' is here filled with variable 'lon'
   nc(ifld).Nctype           = nc_type('double');
   nc(ifld).Dimension        = {'row','col'}; % 2D (col,row)
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name', 'Value', 'longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'    , 'Value', 'Longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'        , 'Value', 'degrees_east');
   nc(ifld).Attribute(end+1) = struct('Name', 'axis'         , 'Value', 'X');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping' , 'Value', 'projection');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range' , 'Value', [min(D.lon(:)) max(D.lon(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'bounds'       , 'Value', 'lon_bnds');% cell boundaries for drawing 'pixels.

%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#latitude-coordinate
   
   ifld = ifld + 1;
   nc(ifld).Name             = 'lat'; % dimension 'lat' is here filled with variable 'lat'
   nc(ifld).Nctype           = nc_type('double');
   nc(ifld).Dimension        = {'row','col'}; % 2D (col,row)
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name', 'Value', 'latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'    , 'Value', 'Latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'        , 'Value', 'degrees_north');
   nc(ifld).Attribute(end+1) = struct('Name', 'axis'         , 'Value', 'Y');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping' , 'Value', 'projection');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range' , 'Value', [min(D.lat(:)) max(D.lat(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'bounds'       , 'Value', 'lat_bnds');% cell boundaries for drawing 'pixels.

%% 3.c Create coordinate variables: coordinate system: WGS84 default
%      global ellispes: WGS 84, ED 50, INT 1924, ETRS 89 and the upcoming ETRS update etc.
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#grid-mappings-and-projections
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#appendix-grid-mappings
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'epsg'; % preferred
   nc(ifld).Nctype       = nc_int;
   nc(ifld).Dimension    = {};
   nc(ifld).Attribute    = nc_cf_grid_mapping(M.epsg.code);
   nc(ifld).Attribute(end+1) = struct('Name', 'proj4_params'   ,'Value', M.epsg.proj4_params);% http://adaguc.knmi.nl/
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'projection'; % ADAGUC NAME
   nc(ifld).Nctype       = nc_int;
   nc(ifld).Dimension    = {};
   nc(ifld).Attribute    = nc_cf_grid_mapping(M.wgs84.code);
   nc(ifld).Attribute(end+1) = struct('Name', 'proj4_params'   ,'Value', M.wgs84.proj4_params);% http://adaguc.knmi.nl/

%% 3.d Bounds (optional)
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#cell-boundaries


   if OPT.bounds
   ifld = ifld + 1;
   nc(ifld).Name             = 'x_bnds';% name in ADAGUC code
   nc(ifld).Nctype           = nc_type('double');
   nc(ifld).Dimension        = {'row','col','bounds'};
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'    , 'Value', 'Easting bounds');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'        , 'Value', 'm');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range' , 'Value', [min(D.cor.lon(:)) max(D.cor.lon(:))]);

   ifld = ifld + 1;
   nc(ifld).Name             = 'y_bnds';% name in ADAGUC code
   nc(ifld).Nctype           = nc_type('double');
   nc(ifld).Dimension        = {'row','col','bounds'};
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate');
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'      ,'Value', 'Northing bounds');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(D.cor.lat(:)) max(D.cor.lat(:))]);

   ifld = ifld + 1;
   nc(ifld).Name             = 'lon_bnds';% name in ADAGUC code
   nc(ifld).Nctype           = nc_type('double');
   nc(ifld).Dimension        = {'row','col','bounds'};
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name', 'Value', 'longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'    , 'Value', 'Longitude bounds');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'        , 'Value', 'degrees_east');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range' , 'Value', [min(D.cor.lon(:)) max(D.cor.lon(:))]);

   ifld = ifld + 1;
   nc(ifld).Name             = 'lat_bnds';% name in ADAGUC code
   nc(ifld).Nctype           = nc_type('double');
   nc(ifld).Dimension        = {'row','col','bounds'};
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name'  ,'Value', 'latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'      ,'Value', 'Latitude bounds');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(D.cor.lat(:)) max(D.cor.lat(:))]);
   end

%% 4   Create dependent variable
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#variables
%      Parameters with standard names:
%      http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

   ifld = ifld + 1;
   nc(ifld).Name             = M.varname;
   nc(ifld).Nctype           = nc_type('double');
   nc(ifld).Dimension        = {'time','row','col'}; % CF wants time 1st
   nc(ifld).Attribute(    1) = struct('Name', 'standard_name'  ,'Value', M.standard_name);
   nc(ifld).Attribute(end+1) = struct('Name', 'long_name'      ,'Value', M.long_name    );
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', M.units        );
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(D.val(:)) max(D.val(:))]);
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'projection epsg');
   nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'x y');
   % coordinates is ESSENTIAL CF attribute to connect 2D (lat,lon) matrices to data
   nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', realmax('single')); % SNCTOOLS replaces NaN with _FillValue under the hood
      
%% 5.a Create all variables with attributes
   
   for ifld=1:length(nc)
      nc_addvar(ncfile, nc(ifld));   
   end
      
%% 5.b Fill all variables

   nc_varput(ncfile, 'x'         , D.x'        );
   nc_varput(ncfile, 'y'         , D.y'        );
   nc_varput(ncfile, 'lon'       , D.lon'      );
   nc_varput(ncfile, 'lat'       , D.lat'      );
   nc_varput(ncfile, 'projection', M.wgs84.code);
   nc_varput(ncfile, 'time'      , D.time - OPT.refdatenum);
   nc_varput(ncfile, M.varname   , permute(D.val,[3 2 1])); % mind Matlab reverses dimensions compared to regular tools
   if OPT.bounds
   nc_varput(ncfile, 'x_bnds'    , permute(nc_cf_cor2bounds(D.cor.x'  ),[1 2 3]));
   nc_varput(ncfile, 'y_bnds'    , permute(nc_cf_cor2bounds(D.cor.y'  ),[1 2 3]));
   nc_varput(ncfile, 'lon_bnds'  , permute(nc_cf_cor2bounds(D.cor.lon'),[1 2 3]));
   nc_varput(ncfile, 'lat_bnds'  , permute(nc_cf_cor2bounds(D.cor.lat'),[1 2 3]));
   end
   nc_varput(ncfile,'epsg'       , M.epsg.code);
      
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