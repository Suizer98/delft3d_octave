function varargout = nc_cf_grid_write(varargin)
%nc_cf_grid_write  save orthogonal/curvilinear lat-lon or x-y grid as netCDF-CF file
%
%   nc_cf_grid_write(ncfilename,<keyword,value>)
%   nc_cf_grid_write(ncfilename,<keyword,value>)
%
% To get a list of all keywords, call NC_CF_GRID_WRITE without arguments.
%
%   OPT = nc_cf_grid_write()
%
% The following keywords are required:
%
% * x           x vector of length ncols (required)
% * y           y vector of lenght nrows (required)
% * val         matrix   of size [y,x] or [nrows,ncols] (required)
%               dimension order [y,x] is default in , 
%               e.g. pcolor(x(x),y(y),val(y,x))
% * units       units of val
% * long_name   description of val as to appear in plots
%
% The following keywords are optional:
%
% * nrows       length of y vector (size(OPT.val,1))
% * ncols       length of x vector (size(OPT.val,2))
% * epsg        when supplied, the full latitude and longitude
%               matrixes are written to the netCDF file too, calculated
%               from the x and y, unless you specified them already:
% * lat         (optionally)
% * lon         (optionally)
%
% Note: in the netCDF file the order (y,x) will be used, to stay compatible 
% with the COARDS standard order, despite the fact that the CF convention 
% places no rigid restrictions on the order of dimensions.
%
%See also: ARCGISREAD, ARC_INFO_BINARY, ARCGRIDREAD (in $ mapping toolbox)
%          SNCTOOLS, NC_CF_GRID, NC_CF_GRID_MAPPING

% TO DO: add corner matrices too ?
% TO DO: allow lat and lon to be the dimension vectors
% TO DO: handle other 3 of 4 different cases:
% - add curvi-linear x,y  (dims:m,n)
% - add orthogonal lat,lon(dims:lat,lon)
% - add curvi-linear lat,lon: dims(m,n)
% - add time as 3rd dimension

%%  --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% TO DO: add latitude-longitude based on EPSG code with convertcoordinates.m

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: nc_cf_grid_write.m 8301 2013-03-08 16:29:28Z heijer $
%  $Date: 2013-03-09 00:29:28 +0800 (Sat, 09 Mar 2013) $
%  $Author: heijer $
%  $Revision: 8301 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_grid_write.m $
%  $Keywords: $

%% User defined keywords

   OPT.dump           = 1;
   OPT.disp           = 10; % stride in progres display
   OPT.convertperline = 25; % when memory limitations are present, number of line to convert at once
   OPT.debug          = 0;  % screendumps when parameters are written

%% User defined meta-info

   %% global

      OPT.title          = '';
      OPT.institution    = '';
      OPT.source         = '';
      OPT.history        = ['tranformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_cf_grid_write.m $'];
      OPT.references     = '';
      OPT.email          = '';
      OPT.comment        = '';
      OPT.version        = '';
      OPT.acknowledge    =['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution];
      OPT.disclaimer     = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
   
   %% dimensions/coordinates

      OPT.x              = [];
      OPT.y              = [];
      OPT.lon            = [];
      OPT.lat            = [];
      OPT.ncols          = [];
      OPT.nrows          = [];
      OPT.epsg           = []; % if specified, (lat,lon) are added
      OPT.wgs84          = 4326;
      OPT.latitude_type  = 'double'; % 'double' % 'single'
      OPT.longitude_type = 'double'; % 'double' % 'single'
      OPT.dim.val         = {};
      OPT.dim.x           = {};
      OPT.dim.y           = {};
      OPT.dim.lon         = {};
      OPT.dim.lat         = {};
      
   %% variables

      OPT.varname        = ''; % 'val' would be consistent with default ArcGisRead
      OPT.val            = []; % 'val' would be consistent with default ArcGisRead
      OPT.units          = '';
      OPT.long_name      = '';
      OPT.standard_name  = '';
      OPT.type           = []; % [] = auto, single or double

   %% handle meta-info

      if nargin==0;varargout = {OPT};return;end; % make function act as object

      OPT      = setproperty(OPT,varargin{2:end});
      
 %% errors

      if isempty(OPT.varname      );  error('For a netCDF file is required   : varname'      );end
      if isempty(OPT.units        );  error('For a netCDF file is required   : units'        );end
      if isempty(OPT.epsg         );warning('For a netCDF file is recommended: epsg'         );end

      if isempty(OPT.x        ) & isempty(OPT.lon          )
         error('For a netCDF file is required: x and/or lon');end
      if isempty(OPT.y        ) & isempty(OPT.lat          )
         error('For a netCDF file is required: y and/or lat');end
      if isempty(OPT.long_name) & isempty(OPT.standard_name);
         error('For a netCDF file is required: standard_name and/or long_name');end

      if ~isempty(OPT.val)
         OPT.nrows =   size(OPT.val,1); % ~ y
         OPT.ncols =   size(OPT.val,2); % ~ x
         % Because this dimension order is natural in matlab, e.g. pcolor with x/y sticks:
         %         x: [1x1121 double]
         %         y: [1x1301 double]
         %     depth: [1301x1121 double]
         % pcolorcorcen(D.x,D.y,D.depth)
      end
      
      if isvector(OPT.lon) & isvector(OPT.lat)
         if ~(length(OPT.lon)==OPT.ncols)
           error('dimension 2 of matrix should match length(lon)')
         end
         if ~(length(OPT.lat)==OPT.nrows)
           error('dimension 1 of matrix should match length(lat)')
         end
         OPT.dim.val   = {'lon','lat'};
      end
      
      %% 4 configurations, all with CF COARDS dimension order (y,x) see
      % a1.lon vector          : (lat,lon) nc_cf_grid_write_lat_lon_orthogonal_tutorial
      % a2.lon vector, x matrix: (lat,lon) ,,
      % b .lon matrix          : (row,col) nc_cf_grid_write_lat_lon_curvilinear_tutorial
      % c1.lon matrix, x vector: (y  ,x  ) nc_cf_grid_write_x_y_orthogonal_tutorial
      % c2.            x vector: warning
      % d1.lon matrix, x matrix: (row,col) nc_cf_grid_write_x_y_curvilinear_tutorial
      % d2.            x matrix: warning

      if     isempty (OPT.x) & isempty (OPT.y)
        if isvector(OPT.lon) & isvector(OPT.lat)
% a1
         OPT.dim.val   = {'lat','lon'};
         OPT.dim.x     = {};
         OPT.dim.y     = {};
         OPT.dim.lon   = {'lon'};
         OPT.dim.lat   = {'lat'};
         else
% b
         OPT.dim.val   = {'row','col'};
         OPT.dim.x     = {};
         OPT.dim.y     = {};
         OPT.dim.lon   = {'row','col'};
         OPT.dim.lat   = {'row','col'};
         end
      elseif isvector(OPT.x) & isvector(OPT.y)
% c1
         OPT.dim.val   = {'y','x'};
         OPT.dim.lon   = {'y','x'};
         OPT.dim.lat   = {'y','x'};
         OPT.dim.x     = {'x'};
         OPT.dim.y     = {'y'};
         if ~(length(OPT.x)==OPT.ncols)
           error('dimension 2 of matrix should match length(x)')
         end
         if ~(length(OPT.y)==OPT.nrows)
           error('dimension 1 of matrix should match length(y)')
         end
% c2
         if isempty(OPT.lon) & isempty(OPT.lat)
            warning('lat,lon required')
         end
      else
         if isvector(OPT.lon) & isvector(OPT.lat)
% a2
         OPT.dim.val   = {'lat','lon'}; % repeat
         OPT.dim.x     = {'lat','lon'};
         OPT.dim.y     = {'lat','lon'};
         OPT.dim.lon   = {'lon'};
         OPT.dim.lat   = {'lat'};
         else
% d1
         OPT.dim.val   = {'row','col'};
         OPT.dim.x     = {'row','col'};
         OPT.dim.y     = {'row','col'};
         OPT.dim.lon   = {'row','col'};
         OPT.dim.lat   = {'row','col'};
         end
% d2
         if ~isvector(OPT.lon) & ~isvector(OPT.lat)
         error('lat,lon required')
         end
      end
      
%% Type

      if isempty(OPT.type)
      OPT.type          = class(OPT.val); % single or double
      end
      OPT.fillvalue     = nan(OPT.type); % as to appear in netCDF file, not as appeared in arcgrid file
      
%% lat,lon

   if ~isempty(OPT.epsg) & (isempty(OPT.lat & OPT.lon))
      
      % calculate per row because of memory issues for large matrices
      
     [x    ,y    ] = meshgrid(OPT.x,OPT.y);
      OPT.lon      = repmat(nan,size(OPT.val));
      OPT.lat      = repmat(nan,size(OPT.val));
      
      % compromise: consider 2D matrix as 1D vector and do section by section
      
      if (OPT.convertperline > 0) & ~isinf(OPT.convertperline)
      dline = OPT.convertperline;
      for ii=1:dline:size(OPT.lat,1)
      iii = ii+(1:dline)-1;
      iii = iii(iii <= size(OPT.lat,1));
      disp(['converting coordinates to (lat,lon): ',num2str(min(iii)),'-',num2str(max(iii)),'/',num2str(size(OPT.lat,1))])
     [OPT.lon(iii,:),OPT.lat(iii,:),log] = convertCoordinates(x(iii,:),y(iii,:),'CS1.code',OPT.epsg,'CS2.code',OPT.wgs84);
      end
      else % 0 or Inf
     [OPT.lon       ,OPT.lat       ,log] = convertCoordinates(x       ,y       ,'CS1.code',OPT.epsg,'CS2.code',OPT.wgs84);
      end
      
      clear x y
      
   elseif isempty(OPT.epsg) & ~(isempty(OPT.lat & OPT.lon))

       warning('no lat,lon possible: please supply epsg code.');
       
   end

%% 1a Create file

      ncfile = varargin{1};
      
      if ~exist(fileparts(ncfile),'dir')
         mkdir(fileparts(ncfile))
      end
   
      nc_create_empty (ncfile)
      nc_padheader    (ncfile,20000);
   
   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
      nc_attput(ncfile, nc_global, 'title'         , OPT.title);
      nc_attput(ncfile, nc_global, 'institution'   , OPT.institution);
      nc_attput(ncfile, nc_global, 'source'        , OPT.source);
      nc_attput(ncfile, nc_global, 'history'       , OPT.history);
      nc_attput(ncfile, nc_global, 'references'    , OPT.references);
      nc_attput(ncfile, nc_global, 'email'         , OPT.email);
   
      nc_attput(ncfile, nc_global, 'comment'       , OPT.comment);
      nc_attput(ncfile, nc_global, 'version'       , OPT.version);
   						   
      nc_attput(ncfile, nc_global, 'Conventions'   , 'CF-1.4');
      nc_attput(ncfile, nc_global, 'CF:featureType', 'Grid');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
      nc_attput(ncfile, nc_global, 'terms_for_use' , OPT.acknowledge);
      nc_attput(ncfile, nc_global, 'disclaimer'    , OPT.disclaimer);
      
%% 2 Create x and y dimensions
   
      nc_add_dimension(ncfile, OPT.dim.val{2}, OPT.ncols); % use 'x'/'ncols' as 2nd array dimension to adhere to CF convenctions (y,x), snctools swaps for us
      nc_add_dimension(ncfile, OPT.dim.val{1}, OPT.nrows); % use 'y'/'nrows' as 1st array dimension to adhere to CF convenctions (y,x), snctools swaps for us

%% 3a Create coordinate variables
   
      clear nc
      ifld = 0;
   
   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
   %  TO DO, based on OPT.epsg
   %  Local Cartesian coordinates
   if ~isempty(OPT.x) & ~isempty(OPT.y)

        ifld = ifld + 1;
      nc(ifld).Name             = 'x';
      nc(ifld).Nctype           = nc_type(class(OPT.x));
      nc(ifld).Dimension        = OPT.dim.x;
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'x-coordinate in Cartesian system');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.x(:)) max(OPT.x(:))]);
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(end+1) = struct('Name', 'epsg'           ,'Value', OPT.epsg);
      end
   
        ifld = ifld + 1;
      nc(ifld).Name             = 'y';
      nc(ifld).Nctype           = nc_type(class(OPT.y));
      nc(ifld).Dimension        = OPT.dim.y;
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'y-coordinate in Cartesian system');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.y(:)) max(OPT.y(:))]);
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(end+1) = struct('Name', 'epsg'           ,'Value', OPT.epsg);
      end
   end

   %% Latitude-longitude
   if ~isempty(OPT.lon) & ~isempty(OPT.lat)

   %% Longitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

        ifld = ifld + 1;
      nc(ifld).Name             = 'longitude';
      nc(ifld).Nctype           = nc_type(OPT.longitude_type);
      nc(ifld).Dimension        = OPT.dim.lon;
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lon(:)) max(OPT.lon(:))]); % 
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

   %% Latitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
        ifld = ifld + 1;
      nc(ifld).Name             = 'latitude';
      nc(ifld).Nctype           = nc_type(OPT.latitude_type);
      nc(ifld).Dimension        = OPT.dim.lat;
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'latitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'latitude'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lat(:)) max(OPT.lat(:))]); % 
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
   end

   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   if ~isempty(OPT.epsg)
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'epsg';
      nc(ifld).Nctype       = nc_int;
      nc(ifld).Dimension    = {};
      nc(ifld).Attribute    = nc_cf_grid_mapping(OPT.epsg);

   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate

        ifld = ifld + 1;
      nc(ifld).Name         = 'wgs84';
      nc(ifld).Nctype       = nc_int;
      nc(ifld).Dimension    = {};
      nc(ifld).Attribute    = nc_cf_grid_mapping(OPT.wgs84);

   end

%% 3b Create depdendent variable

   %% Parameters with standard names
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   
      %% Define dimensions in this order:
      %  time,z,y,x (note: snctools swaps, see getpref('SNCTOOLS')

        ifld = ifld + 1;
      nc(ifld).Name             = OPT.varname;
      nc(ifld).Nctype           = nc_type(OPT.type);
      nc(ifld).Dimension        = OPT.dim.val;
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', OPT.long_name    );
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', OPT.units        );
      nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue    );
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.val(:)) max(OPT.val(:))]);
      if ~isempty(OPT.standard_name)
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
      end
      if ~isempty(OPT.lon) & ~isempty(OPT.lat)
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude');
      end
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');
      end
      
%% 4 Create all variables with attibutes
   
      for ifld=1:length(nc)
         if OPT.debug;var2evalstr(nc(ifld));end
         nc_addvar(ncfile, nc(ifld));   
      end
      
%% 5 Fill all variables

      if ~isempty(OPT.x) & ~isempty(OPT.y)
      nc_varput(ncfile, 'x'         , OPT.x);
      nc_varput(ncfile, 'y'         , OPT.y);
      end
      if ~isempty(OPT.lon) & ~isempty(OPT.lat)
      nc_varput(ncfile, 'longitude' , OPT.lon);
      nc_varput(ncfile, 'latitude'  , OPT.lat);
      end
      if ~isempty(OPT.epsg)
      nc_varput(ncfile, 'wgs84'     , OPT.wgs84);
      nc_varput(ncfile, 'epsg'      , OPT.epsg);
      end

      nc_varput(ncfile, OPT.varname , OPT.val); 
      % saving x/lon/col as first dimension so ensure correct default 
      % plotting in ncBrowse (you can swap x,y manually in ncBrowse)
      % but saving y/lat/row as first dimension is in line 
      % with CF convetions and ADAGUC
      
%% 6 Check
   
      if OPT.dump
      nc_dump(ncfile);
      end

      if nargout==1
         varargout = {D};
      end

%% EOF
