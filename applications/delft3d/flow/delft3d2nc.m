function varargout = delft3d2nc(ncfile,varargin)
%DELFT3D2NC   saves delft3d input as netCDF file
%
%   delft3d2nc(ncfile,<keyword,value>)
%
% stores delf3d grid with depth file as netCDF file.
%
% Example:
%
%   OPT.institution    = 'Deltares';
%   OPT.description    = 'free text';
%   OPT.grd            = 'f:\unstruc\run01\wadden4.grd';
%   OPT.dep            = 'f:\unstruc\run01\wadden.dep';
%   OPT.location       = 'cor'; % or OPT.dpsopt = 'MEAN' or OPT.mdf = 'run.mdf';
%   OPT.epsg           = 28992; % Dutch RD
%
%   delft3d2nc('f:\unstruc\run01\wadden.nc',OPT)
%
%See also: snctools, delft3d, vs_trim2nc

% TO DO: align with netCDF-output of Delft3D and vs_trim2nc

%% Define

   OPT.institution    = 'Deltares';
   OPT.description    = 'free text';
   OPT.grd            = '*.grd';
   OPT.dep            = '*.dep';
   OPT.epsg           = [];
   OPT.type           = 'float'; %'double'; % even NEFIS file is by default single precision
   OPT.debug          = 0;
   OPT.location       = '';
   OPT.dpsopt         = '';
   OPT.mdf            = '';
   
   OPT = setproperty(OPT,varargin{:});
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% Load

   if ~isempty(OPT.mdf)
      MDF = delft3d_io_mdf('read',OPT.mdf);
      OPT.dpsopt = MDF.keywords.dpsopt;
   end

   G = delft3d_io_grd('read',OPT.grd);
   G = delft3d_io_dep('read',OPT.dep,G,'location',OPT.location,'dpsopt',OPT.dpsopt);
   G.coordinates = upper(G.CoordinateSystem); % same as NEFIS file

%% 1a Create file (add all NEFIS 'map-version' group info)

      nc_create_empty (ncfile)

      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
      %------------------
   
      nc_attput(ncfile, nc_global, 'title'         , '');
      nc_attput(ncfile, nc_global, 'institution'   , OPT.institution);
      nc_attput(ncfile, nc_global, 'source'        , 'Delft3D input file');
      nc_attput(ncfile, nc_global, 'history'       ,['Original filenames: *.grd:',OPT.grd,'Original filenames: *.dep:',OPT.dep,' '...
                                                     ', tranformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/flow/delft3d2nc.m $']);
      nc_attput(ncfile, nc_global, 'references'    , '');
      nc_attput(ncfile, nc_global, 'email'         , '');
   
      nc_attput(ncfile, nc_global, 'comment'       , '');
      nc_attput(ncfile, nc_global, 'version'       , '');
   						   
      nc_attput(ncfile, nc_global, 'Conventions'   , 'CF-1.4');
      nc_attput(ncfile, nc_global, 'CF:featureType', 'Grid');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
      nc_attput(ncfile, nc_global, 'terms_for_use' ,['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
      nc_attput(ncfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
      nc_attput(ncfile, nc_global, 'description'   , str2line(OPT.description));

%% Add discovery information (test):

      %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
   
      if (strcmpi(G.coordinates,'CARTESIAN') & ~isempty(OPT.epsg)) | ...
          strcmpi(G.coordinates,'SPHERICAL')
     [G.cen.lon,G.cen.lat] = convertcoordinates(G.cen.x,G.cen.y,'CS1.code',OPT.epsg,'CS2.code',4326);
     [G.cor.lon,G.cor.lat] = convertcoordinates(G.cor.x,G.cor.y,'CS1.code',OPT.epsg,'CS2.code',4326);

      nc_attput(ncfile, nc_global, 'geospatial_lat_min'  , min(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lat_max'  , max(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lon_min'  , min(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lon_max'  , max(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lat_units', 'degrees_north');
      nc_attput(ncfile, nc_global, 'geospatial_lon_units', 'degrees_east' );
      end

%% 2 Create dimensions

      nc_add_dimension(ncfile, 'm'    , G.mmax-2);
      nc_add_dimension(ncfile, 'n'    , G.nmax-2);
      nc_add_dimension(ncfile, 'm_cor', G.mmax-1);
      nc_add_dimension(ncfile, 'n_cor', G.nmax-1);

      ifld = 0;

   %% dimensions

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m = 1 and m = mmax removed.');
      nc(ifld) = struct('Name', 'm', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'m'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ n = 1 and n = nmax removed.');
      nc(ifld) = struct('Name', 'n', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'n'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m = 1 removed.');
      nc(ifld) = struct('Name', 'm_cor', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'m_cor'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ n = 1 removed.');
      nc(ifld) = struct('Name', 'n_cor', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'n_cor'}}, ...
          'Attribute', attr);

   %% coordinates

   if any(strfind(G.coordinates,'CARTESIAN'))
   
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'x of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XWAT,XZ');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('single'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.x(:)) max(G.cen.x(:))]);
      nc(ifld) = struct('Name', 'x', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'y of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'YWAT,YZ');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('single'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.y(:)) max(G.cen.y(:))]);
      nc(ifld) = struct('Name', 'y', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'x of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('single'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.x(:)) max(G.cor.x(:))]);
      nc(ifld) = struct('Name', 'x_cor', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'y of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'YCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('single'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.y(:)) max(G.cor.y(:))]);
      nc(ifld) = struct('Name', 'y_cor', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
   end

   if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))

      if ~isempty(G.cen.dep)
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'longitude of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XWAT,XZ');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('double'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.lon(:)) max(G.cen.lon(:))]);
      nc(ifld) = struct('Name', 'longitude', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'latitude of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'YWAT,YZ');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('double'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.lat(:)) max(G.cen.lat(:))]);
      nc(ifld) = struct('Name', 'latitude', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      end

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'longitude of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('double'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.lon(:)) max(G.cor.lon(:))]);
      nc(ifld) = struct('Name', 'longitude_cor', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'latitude of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'YCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('double'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.lat(:)) max(G.cor.lat(:))]);
      nc(ifld) = struct('Name', 'latitude_cor', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
   end

%% 3 Create variables

      if ~isempty(G.cen.dep)
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'altitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'depth');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'DEP');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('single'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.dep(:)) max(G.cen.dep(:))]);
      nc(ifld) = struct('Name', 'depth', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      end
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'altitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'depth of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x_cor y_cor');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude_cor longitude_cor');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'DEP');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN('single'));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.dep(:)) max(G.cor.dep(:))]);
      nc(ifld) = struct('Name', 'depth_cor', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
          
%% 4 Create variables with attibutes
   
      for ifld=1:length(nc)
         if OPT.debug
            disp(var2evalstr(nc(ifld)))
         end
         nc_addvar(ncfile, nc(ifld));   
      end

%% 5 Fill variables

      nc_varput(ncfile, 'm'            , [2:G.mmax-1  ]');
      nc_varput(ncfile, 'n'            , [2:G.nmax-1  ]');
      nc_varput(ncfile, 'm_cor'        , [1:G.mmax-1  ]');
      nc_varput(ncfile, 'n_cor'        , [1:G.nmax-1  ]');
      nc_varput(ncfile, 'x'            ,    G.cen.x);
      nc_varput(ncfile, 'y'            ,    G.cen.y);
      nc_varput(ncfile, 'x_cor'        ,    G.cor.x);
      nc_varput(ncfile, 'y_cor'        ,    G.cor.y);
      if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))
      if ~isempty(G.cen.dep)
      nc_varput(ncfile, 'longitude'    ,G.cen.lon);
      nc_varput(ncfile, 'latitude'     ,G.cen.lat);
      end
      nc_varput(ncfile, 'longitude_cor',G.cor.lon);
      nc_varput(ncfile, 'latitude_cor' ,G.cor.lat);
      end      
      if ~isempty(G.cen.dep)
      nc_varput(ncfile, 'depth'       , G.cen.dep);
      end
      nc_varput(ncfile, 'depth_cor'   , G.cor.dep);
