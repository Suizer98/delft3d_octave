function varargout = vs_trim2nc(vsfile,varargin)
%VS_TRIM2NC  Convert entire or part of a Delft3D trim NEFIS file to netCDF-CF
%
%   vs_trim2nc(NEFISfile,<'keyword',value>)
%   vs_trim2nc(NEFISfile,<netCDFfile>,<'keyword',value>)
%
% converts Delft3D trim file (NEFIS file) to a netCDF-CF file in 
% the same directory, with extension replaced by nc, with all
% implemented paramters. x/y grids are converted to lat/lon based
% on keyword 'epsg' to obtain a CF compliant netCDF file. Corner
% coordinates are added via the CF-1.6 bounds convention [m n bounds].
% Work for sigma (see OET tests) as well as z layers.
% Do specify timezone and epsg code, to conform to CF standard and facilitate reuse.
%
% Example:
%
%   vs_trim2nc('P:\aproject\trim-n15.dat','epsg',28992,'time',5,'var,{'waterlevel','velocity','x','y'},...
%                                    ,'timezone',timezone_code2iso('GMT'))
%
%   vs_trim2nc(vsfile,ncfile,'var',{'waterlevel','pea','dpeadt','dpeads','x','y','grid_x','grid_y'},...
%                                    ,'timezone','+01:00')
%
% By default it converts all native delft3d output variables, but 
% you can also select only a subset with keyword 'var'. Call VS_TRIM2NC() 
% without argument to find out which CF-required, primary and derived 
% variables are available in resp. 'var_cf', 'var_primary' and 'var_derived'.
% x/y/epsg or lat/.lon are ALWAYS written to the netCDF depending on
% whether your grid is CARTESIAN or SPHERICAL.
% You can also pass the NEFIS names shown by vs_disp() and 'var_nefis', e.g.:
%
%   vs_trim2nc('P:\aproject\trim-n15.dat','var',{'S1'})
%
% Note: Works only with Matlab R2011a and higher due use of to NCWRITESCHEMA.
% Note: When using 'epsg' to project to (lat,lon), vectors are still defined in 
%       projected coordinates, so the coordinates attribute is still "x y". Vectors
%       are not reoriented to lat-lon coordinate system. This is reflected in 
%       different standard names for velocities and stresses (and transports):
%       '<east|north>ward_sea_water_velocity'      vs 'sea_water_<x|y>_velocity'
%       'surface_downward_<east|north>ward_stress' vs 'surface_downward<x|y>_stress'
% Note: For big Delft3D NEFIS 5.0 files set keyword ...,'Format','64bit',...
% Note: You can make an nc_dump cdl ascii file a char for keyword dump:
%       vs_trim2nc('tst.dat','dump','tst.cdl');
% Note: For storing statistics, you can call vs_trim2nc for 1 variable
%       and 1 time. You can then overwrite the matrix with ncwrite,
%       and you'll have a CF complaint statistics file:
%       vs_trim2nc('trim-u17aug.dat','var',{'waterlevel','velocity','salinity','temperature'},'time',1)
%
%See also: vs_trih2nc for trih-*.dat delft3d-flow history file,
%          netcdf, snctools, NCWRITESCHEMA, NCWRITE, VS_USE, DELFT3D2NC
%          delft3d_grid_image

% TO DO keep consistency up-to-date with delft3d_to_netcdf.exe of Bert Jagers
% TO DO add bedload en avg sediment
% TO DO check against sigma interperation with d3d_qp
% TO DO allow to extract (m,n) subset
% TO DO add raw U V velocities at U V points for later processing

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 www.Deltares.nl for Building with Nature
%
%       Gerben J. de Boer <gerben.deboer@deltares.nl>
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: vs_trim2nc.m 17148 2021-03-29 14:55:41Z jagers $
%  $Date: 2021-03-29 22:55:41 +0800 (Mon, 29 Mar 2021) $
%  $Author: jagers $
%  $Revision: 17148 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trim2nc.m $
%  $Keywords: $

%% keywords

   OPT.Format         = 'classic'; % '64bit','classic','netcdf4','netcdf4_classic'
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wrong dates in ncbrowse due to different calendars. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention
   OPT.institution    = '';
   OPT.timezone       = ''; %timezone_code2iso('GMT');
   OPT.epsg           = [];
   OPT.type           = 'single'; %'double'; % the nefis file is by default single precision, se better isn't useful
   OPT.debug          = 0;
   OPT.time           = 0; % subset of time indices in NEFIS file, 1-based
   OPT.empty          = 0;  % to create structure with empty time-dependenmt data matrices (spatio-temporal matrices are always added). Useful for creating template for statistics.
   OPT.dump           = 1;

   OPT.var_cf         = {'time','m','n','Layer','LayerInterf','longitude','latitude'};
   OPT.var_primary    = {'grid_m','grid_n','x','y','grid_x','grid_y','grid_longitude','grid_latitude','k',...
                         'grid_depth','depth','zactive','waterlevel','area',...
                         'velocity','velocity_z','velocity_omega',...
                         'tke','eps','tau',...
                         'salinity','temperature','density',...
                         'sediment','tracer',...
                         'viscosity_z','diffusivity_z','Ri','sedtrans'};
   OPT.var_derived    = {'pea','dpeadt','dpeads'};
   OPT.var_nefis      = {'XZ','YZ','XWAT','YWAT','XCOR','YCOR','DP','DP0',...
                         'DPS','DPSO','KCS','S1','U1','V1','WPHY','TAUKSI',...
                         'TAUETA','RTUR1','R1','RHO',...
                         'WS','RSEDEQ','SBCU','SBCV','SBWU','SBWV','SSWU',... % variables from map-sed-series
                         'SSWV','SBUU','SBVV','SSUU','SSVV','RCA','DPS','BODSED','DPSED'};
   OPT.var            = {OPT.var_cf{:},OPT.var_primary{:}};
   OPT.var_all        = {OPT.var_cf{:},OPT.var_primary{:},OPT.var_derived{:}};
   OPT.title          = ['NetCDF created from NEFIS-file ',filenameext(vsfile)];

   if nargin==0
      varargout = {OPT};
      return
   end
   
   if verLessThan('matlab','7.12.0.635')
      error('At least Matlab release R2011a is required for writing netCDF files due tue NCWRITESCHEMA.')
   end

   if ~odd(nargin)
      ncfile   = varargin{1};
      varargin = {varargin{2:end}};
   else
      ncfile   = fullfile(fileparts(vsfile),[filename(vsfile) '.nc']);
   end

   tmp=dir(vsfile);
   if isempty(tmp)
       error(['file does not exist: ',vsfile])
   end

   OPT      = setproperty(OPT,varargin{:});
   if (tmp.bytes > 2^31)  & strcmpi(OPT.Format,'classic')
      fprintf(2,'> Delft3D NEFIS files larger than 2 Gb cannot be mapped entirely to netCDF classic format, set keyword vs_trim2nc(...,''Format'',''64bit'').\n')
   end

%% map NEFIS names to sensible netCDF names
%  when adding new ones, update OPT.var_nefis, to allow for introspection

   if any(strcmp('XZ',    OPT.var)) | any(strcmp('XWAT',OPT.var))
                                    OPT.x              = 1;end
   if any(strcmp('YZ',    OPT.var)) | any(strcmp('YWAT',OPT.var))
                                    OPT.y              = 1;end
   if any(strcmp('XCOR',  OPT.var));OPT.grid_x         = 1;end
   if any(strcmp('YCOR',  OPT.var));OPT.grid_y         = 1;end
   if any(strcmp('DP',    OPT.var)) | any(strcmp('DP0',OPT.var)) | any(strcmp('DPS',OPT.var))
                                    OPT.grid_depth     = 1;
   end
   if any(strcmp('DPS0',  OPT.var));OPT.depth          = 1;end
   if any(strcmp('KCS',   OPT.var));OPT.zactive        = 1;end
   if any(strcmp('S1',    OPT.var));OPT.waterlevel     = 1;end
   
   if any(strcmp('U1',    OPT.var)) | any(strcmp('V1',OPT.var))
                                    OPT.velocity       = 1;end
   
   if any(strcmp('W',     OPT.var));OPT.velocity_omega = 1;end
   if any(strcmp('WPHY'  ,OPT.var));OPT.velocity_z     = 1;end
   
   if any(strcmp('TAUKSI',OPT.var)) | any(strcmp('TAUETA',OPT.var))
                                    OPT.tau            = 1;end
   if any(strcmp('RTUR1', OPT.var));OPT.eps            = 1;
                                    OPT.tke            = 1;end
   if any(strcmp('R1',    OPT.var));OPT.temperature    = 1;
                                    OPT.salinity       = 1;
                                    OPT.sediment       = 1;
                                    OPT.tracer         = 1;end
   if any(strcmp('RHO',   OPT.var));OPT.density        = 1;end
   if any(strcmp('VICWW', OPT.var));OPT.viscosity_z    = 1;end
   if any(strcmp('DICWW', OPT.var));OPT.diffusivity_z  = 1;end
   if any(strcmp('RICH',  OPT.var));OPT.Ri             = 1;end
   
   if any(strcmp('SBCU',    OPT.var)) | any(strcmp('SBCV',OPT.var)) | ...
       any(strcmp('SBWU',    OPT.var)) | any(strcmp('SBWV',OPT.var)) | ...
       any(strcmp('SBUU',    OPT.var)) | any(strcmp('SBVV',OPT.var)) | ...
       any(strcmp('SSUU',    OPT.var)) | any(strcmp('SSVV',OPT.var))           
                                    OPT.sedtrans       = 1;end
                                
%% 0 Read raw data

      F = vs_use(vsfile,'quiet');
      
      if ~strcmp(F.SubType,'Delft3D-trim')
         error([mfilename ' works only for Delft3D-trim file, perhaps you needed vs_trih2nc for the Delft3D-trih file.'])
      end
      
      T.datenum = vs_time(F,OPT.time,'quiet');
      if OPT.time==0
      OPT.time = 1:length(T.datenum);
      end
      I = vs_get_constituent_index(F);

      M.datestr     = datestr(datenum(vs_get(F,'map-version','FLOW-SIMDAT' ,'quiet'),'yyyymmdd  HHMMSS'),31);
      M.version     =        [strtrim(vs_get(F,'map-version','FLOW-SYSTXT' ,'quiet')),', file version: ',...
                              strtrim(vs_get(F,'map-version','FILE-VERSION','quiet'))];
      M.description = vs_get(F,'map-version','FLOW-RUNTXT','quiet');

     [LSTSCI,OK]    = vs_let(F,'map-const','LSTCI' ,'quiet'); if OK==0;LSTSCI=0;end

     [LSED,OK]      = vs_let(F,'map-const','LSED'  ,'quiet'); if OK==0;LSED=0  ;end
     [LSEDBL,OK]    = vs_let(F,'map-const','LSEDBL','quiet'); if OK==0;LSEDBL=0;end
     
     NTRACER = LSTSCI - LSED;
     if NTRACER>0 && isfield(I,'salinity')
         NTRACER = NTRACER - 1;
     end
     if NTRACER>0 && isfield(I,'temperature')
         NTRACER = NTRACER - 1;
     end
      
%% 1a Create file (add all NEFIS 'map-version' group info)

      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
      nc = struct('Name','/','Format',OPT.Format);
      nc.Attributes(    1) = struct('Name','title'              ,'Value',  OPT.title);
      nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  OPT.institution);
      nc.Attributes(end+1) = struct('Name','source'             ,'Value',  'Delft3D trim file');
      nc.Attributes(end+1) = struct('Name','history'            ,'Value', ['Original filename: ',filenameext(vsfile),...
                                         ', ' ,M.version,...
                                         ', file date:',M.datestr,...
                                         ', transformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_trim2nc.m $ $Id: vs_trim2nc.m 17148 2021-03-29 14:55:41Z jagers $']);
      nc.Attributes(end+1) = struct('Name','references'         ,'Value',  'http://svn.oss.deltares.nl');
      nc.Attributes(end+1) = struct('Name','email'              ,'Value',  '');

      nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
      nc.Attributes(end+1) = struct('Name','version'            ,'Value',  M.version);

      nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6');

      nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
      nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

      nc.Attributes(end+1) = struct('Name','delft3d_description','Value',  str2line(M.description));
      
      % ISO metadata "WHEN": http://www.unidata.ucar.edu/software/netcdf-java/formats/DataDiscoveryAttConvention.html
      % https://geo-ide.noaa.gov/wiki/index.php?title=NetCDF_Attribute_Convention_for_Dataset_Discovery
      
      nc.Attributes(end+1) = struct('Name','time_coverage_start','Value',  datestr(T.datenum(  1),'yyyy-mm-ddTHH:MM'));
      nc.Attributes(end+1) = struct('Name','time_coverage_end'  ,'Value',  datestr(T.datenum(end),'yyyy-mm-ddTHH:MM'));

%% Coordinate system
%
% G.coordinates    | CART   | SPHE   |
%                  +--------+--------+
% OPT.epsg = []    |1       | 3      | 
% OPT.epsg = value |2       | 4      |
%                  +--------+--------+
% 1. (x,y) in file                                            , coords = x y
% 2. (x,y) in file, (lon,lat) in file (convertcoordinates). Yet,coords = x y to indicate 
%                                                               * coriolis isn't spatially varying, 
%                                                               * velocities/stresses aren't zonally reoriented
% 3.                (lon,lat) in file                         , coords = latitude longitude
% 4.                (lon,lat) in file                         , coords = latitude longitude
      %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
      
      G.mmax        =                 vs_let(F,'map-const','MMAX'       ,'quiet');
      G.nmax        =                 vs_let(F,'map-const','NMAX'       ,'quiet');
      G.kmax        =                 vs_let(F,'map-const','KMAX'       ,'quiet');
      G.coordinates = strtrim(permute(vs_let(F,'map-const','COORDINATES','quiet'),[1 3 2]));
      
      G.cen.mask =  vs_let_scalar(F,'map-const','KCS'   ,'quiet'); G.cen.mask(G.cen.mask~=1) = NaN; % -1/0/1/2 Non-active/Non-active/Active/Boundary water level point (fixed)
%GONE?G.cor.mask = permute(vs_let(F,'TEMPOUT'  ,'CODB'  ,'quiet'),[2 3 1]); G.cor.mask(G.cor.mask~=1) = NaN;
      G.cor.mask = ones(size(G.cen.mask)+[2 2]); % reduced later

      if any(strfind(G.coordinates,'SPHE'))
      G.cen.lon  =  vs_let_scalar(F,'map-const','XZ'    ,'quiet').*G.cen.mask;%G.cen.x = vs_let_scalar(F,'TEMPOUT','XWAT','quiet');
      G.cen.lat  =  vs_let_scalar(F,'map-const','YZ'    ,'quiet').*G.cen.mask;%G.cen.y = vs_let_scalar(F,'TEMPOUT','YWAT','quiet');
      G.cor.lon  = permute(vs_let(F,'map-const','XCOR'  ,'quiet'),[2 3 1]).*G.cor.mask;
      G.cor.lat  = permute(vs_let(F,'map-const','YCOR'  ,'quiet'),[2 3 1]).*G.cor.mask;
      G.cor.lon  = G.cor.lon(1:end-1,1:end-1);
      G.cor.lat  = G.cor.lat(1:end-1,1:end-1);
      dy = diff(G.cen.lon,[],1);
      dx = diff(G.cen.lat,[],2);
      else
      G.cen.x    =  vs_let_scalar(F,'map-const','XZ'    ,'quiet').*G.cen.mask;%G.cen.x = vs_let_scalar(F,'TEMPOUT','XWAT','quiet');
      G.cen.y    =  vs_let_scalar(F,'map-const','YZ'    ,'quiet').*G.cen.mask;%G.cen.y = vs_let_scalar(F,'TEMPOUT','YWAT','quiet');
      G.cor.x    = permute(vs_let(F,'map-const','XCOR'  ,'quiet'),[2 3 1]).*G.cor.mask;
      G.cor.y    = permute(vs_let(F,'map-const','YCOR'  ,'quiet'),[2 3 1]).*G.cor.mask;
      G.cor.x    = G.cor.x(1:end-1,1:end-1);
      G.cor.y    = G.cor.y(1:end-1,1:end-1);
      dy = diff(G.cen.x,[],1);
      dx = diff(G.cen.y,[],2);
      end
      if ~isequal(vs_get_elm_size(F,'DPS0'),0)
      G.cen.dep  =  vs_let_scalar(F,'map-const' ,'DPS0' ,'quiet').*G.cen.mask; % depth is positive down
      else % legacy
      G.cen.dep  =  vs_let_scalar(F,'map-const' ,'DP0'  ,'quiet').*G.cen.mask; % depth is positive down
      end

   %% area/depth

      G.dryflp      = strtrim(vs_get(F,'map-const','DRYFLP'     ,'quiet'));
      if strcmpi(strtrim(G.dryflp),'DP')
      G.cor.dep  = nan.*G.cor.mask; % never specified, non-existent
      else
      if ~isequal(vs_get_elm_size(F,'DP'),0) % legacy
      G.cor.dep  = permute(vs_let(F,'map-const','DP'    ,'quiet'),[2 3 1]);
      end
      end
      
      if any(strcmp('area',OPT.var))
      %GSQS in NEFIS has bug in 4.00.01
      %if vs_get_elm_size(F,'GSQS') > 0
      %G.cen.area =  permute(vs_let(F,'map-const','GSQS'  ,'quiet'),[2 3 1]);
      %G.cen
      %G.cen.area
      %G.cen.area =  G.cen.area(2:end-1,3:end).*G.cen.mask;
      %G.cen.area 
      %G.cen.areatext = 'The is the area GSQS used internally in Delft3D for mass-conservation. This is not identical to the exact area spanned geometrically by the 4 corner points!';
      %else
      if any(strfind(G.coordinates,'SPHE'))
      G.cen.area =  grid_area(G.cor.lon,G.cor.lat).*G.cen.mask;
      else
      G.cen.area =  grid_area(G.cor.x,G.cor.y).*G.cen.mask;
      end
      G.cen.areatext = 'This is the exact area spanned geometrically by the 4 corner points. This is not identical to the area GSQS used internally in Delft3D for mass-conservation!';
      %end
      end

   %% add world coordinates coordinate attribute AND as variables to file

      if any(strfind(G.coordinates,'CART')) % CARTESIAN, CARTHESIAN (old bug)
         coordinates  = 'x y';
         ind=strcmp(OPT.var,'x'        );if all(ind==0);OPT.var{end+1} = 'x'        ;end
         ind=strcmp(OPT.var,'y'        );if all(ind==0);OPT.var{end+1} = 'y'        ;end
         if isempty(OPT.epsg)
         fprintf(2,'> No EPSG code specified for CARTESIAN grid, your grid is not CF compliant:\n')
         fprintf(2,'> (latitude,longitude) cannot be calculated from (x,y)!\n')
         end
      else
         coordinates  = 'latitude longitude';
         ind=strcmp(OPT.var,'longitude');if all(ind==0);OPT.var{end+1} = 'longitude';end
         ind=strcmp(OPT.var,'latitude' );if all(ind==0);OPT.var{end+1} = 'latitude' ;end
      end
      
      if any(strfind(G.coordinates,'CART')) & ~isempty(OPT.epsg) % CARTESIAN, CARTHESIAN (old bug)
     [G.cen.lon,G.cen.lat] = convertCoordinates(G.cen.x,G.cen.y,'CS1.code',OPT.epsg,'CS2.code',4326);
     [G.cor.lon,G.cor.lat] = convertCoordinates(G.cor.x,G.cor.y,'CS1.code',OPT.epsg,'CS2.code',4326);
      end
      
      % ISO metadata "WHERE": http://www.unidata.ucar.edu/software/netcdf-java/formats/DataDiscoveryAttConvention.html
      % https://geo-ide.noaa.gov/wiki/index.php?title=NetCDF_Attribute_Convention_for_Dataset_Discovery
      
      if isfield(G.cen,'lon') & isfield(G.cen,'lat')
      nc.Attributes(end+1) = struct('Name','geospatial_lat_min'            ,'Value',  min(G.cen.lat(:)));
      nc.Attributes(end+1) = struct('Name','geospatial_lat_max'            ,'Value',  max(G.cen.lat(:)));
      nc.Attributes(end+1) = struct('Name','geospatial_lat_units'          ,'Value',  'dergees_north');
     %nc.Attributes(end+1) = struct('Name','geospatial_lat_resolution'     ,'Value',  );
      
      nc.Attributes(end+1) = struct('Name','geospatial_lon_min'            ,'Value',  min(G.cen.lon(:)));
      nc.Attributes(end+1) = struct('Name','geospatial_lon_max'            ,'Value',  max(G.cen.lon(:)));
      nc.Attributes(end+1) = struct('Name','geospatial_lon_units'          ,'Value',  'dergees_east');
     %nc.Attributes(end+1) = struct('Name','geospatial_lon_resolution'     ,'Value',  );
      end
      if isfield(G.cen,'dep')
      nc.Attributes(end+1) = struct('Name','geospatial_vertical_min'       ,'Value',  min(G.cen.dep(:)));
      nc.Attributes(end+1) = struct('Name','geospatial_vertical_max'       ,'Value',  max(G.cen.dep(:)));
      nc.Attributes(end+1) = struct('Name','geospatial_vertical_units'     ,'Value',  'm');
     %nc.Attributes(end+1) = struct('Name','geospatial_vertical_resolution','Value',  );
      nc.Attributes(end+1) = struct('Name','geospatial_vertical_positive'  ,'Value',  'down');
      end
      
   %% orthogonal ?

      % orthogonal with x = f(m) and y = f(n)
      % not necessarily equidistant
      if (all(dx(:)==0 | isnan(dx(:)))) & ...
         (all(dy(:)==0 | isnan(dy(:))))
         G.orthogonal = 1;
         if any(strfind(G.coordinates,'SPHE'))         
         cen.m = unique(G.cen.lon ,'rows') ;cen.m = cen.m(1,:); % The UNIQUE call is needed 
         cen.n = unique(G.cen.lat','rows')';cen.n = cen.n(:,1); % because some cells may be NaN
         cor.m = unique(G.cor.lon ,'rows') ;cor.m = cor.m(1,:); % for instance due to islands
         cor.n = unique(G.cor.lat','rows')';cor.n = cor.n(:,1); % represented by permanantly dry cells.
         else
         cen.m = unique(G.cen.x   ,'rows') ;cen.m = cen.m(1,:); % The UNIQUE call is needed 
         cen.n = unique(G.cen.y'  ,'rows')';cen.n = cen.n(:,1); % because some cells may be NaN
         cor.m = unique(G.cor.x   ,'rows') ;cor.m = cor.m(1,:); % for instance due to islands
         cor.n = unique(G.cor.y'  ,'rows')';cor.n = cor.n(:,1); % represented by permanantly dry cells.
         end
      else
         G.orthogonal = 0;
      end
      
   %% vertical: z/sigma

      G.layer_model = strtrim(permute(vs_let(F,'map-const','LAYER_MODEL','quiet'),[1 3 2]));

      if strmatch('SIGMA-MODEL', G.layer_model)
      G.sigma_dz      =  vs_let(F,'map-const','THICK','quiet');   
     [G.sigma_cent,...
      G.sigma_intf]   = d3d_sigma(G.sigma_dz);
      coordinatesLayer        = [coordinates]; % implicit via formula_terms att
      coordinatesLayerInterf  = [coordinates]; % implicit via formula_terms att
      elseif strmatch('Z-MODEL', G.layer_model)
      fprintf(2,'> Z-MODEL has not yet been tested.\n')
      G.ZK          =  vs_let(F,'map-const'     ,'ZK'               ,'quiet');
      coordinatesLayer        = [coordinates]; % ' Layer'
      coordinatesLayerInterf  = [coordinates]; % ' LayerInterf'
      end

%% 2 Create dimensions

      ncdimlen.time        = length(T.datenum);
      ncdimlen.m           = G.mmax; % we keep dummy rows/cols, but apply NaN mask
      ncdimlen.n           = G.nmax;
      ncdimlen.Layer       = G.kmax  ;
      ncdimlen.LayerInterf = G.kmax+1;
      ncdimlen.bounds2     = 2       ; % for corner (grid_*) indices
      ncdimlen.bounds4     = 4       ; % for corner (grid_*) coordinates
      ncdimlen.time_bounds = 2       ; % for corner (grid_*) coordinates

      nc.Dimensions(    1) = struct('Name','time'            ,'Length',ncdimlen.time       );
      nc.Dimensions(end+1) = struct('Name','m'               ,'Length',ncdimlen.m          );
      nc.Dimensions(end+1) = struct('Name','n'               ,'Length',ncdimlen.n          );
      nc.Dimensions(end+1) = struct('Name','Layer'           ,'Length',ncdimlen.Layer      );
      nc.Dimensions(end+1) = struct('Name','LayerInterf'     ,'Length',ncdimlen.LayerInterf);
      nc.Dimensions(end+1) = struct('Name','bounds2'         ,'Length',ncdimlen.bounds2    );
      nc.Dimensions(end+1) = struct('Name','bounds4'         ,'Length',ncdimlen.bounds4    );
      nc.Dimensions(end+1) = struct('Name','time_bounds'     ,'Length',ncdimlen.time_bounds);
      
      if any(strcmp('grid_depth',OPT.var))		     
      nc.Dimensions(end+1) = struct('Name','grid_m'          ,'Length',G.mmax+1);
      nc.Dimensions(end+1) = struct('Name','grid_n'          ,'Length',G.nmax+1);
      ncdimlen.grid_m      = G.mmax+1;
      ncdimlen.grid_n      = G.nmax+1;
      end
      
      useCHAR20 = false;
      if any(strcmp('sediment',OPT.var)) && LSED > 0	     
      nc.Dimensions(end+1) = struct('Name','SuspSedimentFrac','Length',LSED);
      ncdimlen.SuspSedimentFrac = LSED;
      NAMSED = permute(vs_let(F,'map-const','NAMSED'  ,'quiet'),[2 3 1]);
      useCHAR20 = true;
      end

      if any(strcmp('tracer',OPT.var)) && NTRACER > 0	     
      nc.Dimensions(end+1) = struct('Name','Tracers','Length',NTRACER);
      ncdimlen.Tracers = NTRACER;
      NAMTRACERS = permute(vs_let(F,'map-const','NAMCON','quiet'),[2 3 1]);
      NAMTRACERS(1:end-NTRACER,:) = [];
      useCHAR20 = true;
      end
      
      if useCHAR20
      nc.Dimensions(end+1) = struct('Name','CHAR20'          ,'Length',20);
      ncdimlen.CHAR20           = 20;
      end

%% 2 Create dimension combinations
%    TO DO: why is field 'Length' needed, NCWRITESCHEMA should be able to find this out itself

   % 1D
       time.dims(1) = struct('Name', 'time'            ,'Length',ncdimlen.time);
          m.dims(1) = struct('Name', 'm'               ,'Length',ncdimlen.m);
          n.dims(1) = struct('Name', 'n'               ,'Length',ncdimlen.n);
          k.dims(1) = struct('Name', 'Layer'           ,'Length',ncdimlen.Layer);
         ki.dims(1) = struct('Name', 'LayerInterf'     ,'Length',ncdimlen.LayerInterf);
						       
   % 2D						       
       mcor.dims(1) = struct('Name', 'm'               ,'Length',ncdimlen.m);
       mcor.dims(2) = struct('Name', 'bounds2'         ,'Length',ncdimlen.bounds2);
       						       
       ncor.dims(1) = struct('Name', 'n'               ,'Length',ncdimlen.n);
       ncor.dims(2) = struct('Name', 'bounds2'         ,'Length',ncdimlen.bounds2);
         					       
         nm.dims(1) = struct('Name', 'n'               ,'Length',ncdimlen.n);
         nm.dims(2) = struct('Name', 'm'               ,'Length',ncdimlen.m);
						       
   % 3D						       
      nmcor.dims(1) = struct('Name', 'bounds4'         ,'Length',ncdimlen.bounds4);
      nmcor.dims(2) = struct('Name', 'n'               ,'Length',ncdimlen.n);
      nmcor.dims(3) = struct('Name', 'm'               ,'Length',ncdimlen.m);
        					       
        nmt.dims(1) = struct('Name', 'n'               ,'Length',ncdimlen.n);
        nmt.dims(2) = struct('Name', 'm'               ,'Length',ncdimlen.m);
        nmt.dims(3) = struct('Name', 'time'            ,'Length',ncdimlen.time);
						       
   % 4D						       
       nmkt.dims(1) = struct('Name', 'n'               ,'Length',ncdimlen.n);
       nmkt.dims(2) = struct('Name', 'm'               ,'Length',ncdimlen.m);
       nmkt.dims(3) = struct('Name', 'Layer'           ,'Length',ncdimlen.Layer);
       nmkt.dims(4) = struct('Name', 'time'            ,'Length',ncdimlen.time);
      						       
      nmkit.dims(1) = struct('Name', 'n'               ,'Length',ncdimlen.n);
      nmkit.dims(2) = struct('Name', 'm'               ,'Length',ncdimlen.m);
      nmkit.dims(3) = struct('Name', 'LayerInterf'     ,'Length',ncdimlen.LayerInterf);
      nmkit.dims(4) = struct('Name', 'time'            ,'Length',ncdimlen.time);

   % 5D
      if isfield(ncdimlen,'SuspSedimentFrac')
      nmkst.dims(1) = struct('Name', 'n'               ,'Length',ncdimlen.n);
      nmkst.dims(2) = struct('Name', 'm'               ,'Length',ncdimlen.m);
      nmkst.dims(3) = struct('Name', 'Layer'           ,'Length',ncdimlen.Layer);
      nmkst.dims(4) = struct('Name', 'SuspSedimentFrac','Length',ncdimlen.SuspSedimentFrac);
      nmkst.dims(5) = struct('Name', 'time'            ,'Length',ncdimlen.time);
      end

      if isfield(ncdimlen,'Tracers')
      nmktt.dims(1) = struct('Name', 'n'               ,'Length',ncdimlen.n);
      nmktt.dims(2) = struct('Name', 'm'               ,'Length',ncdimlen.m);
      nmktt.dims(3) = struct('Name', 'Layer'           ,'Length',ncdimlen.Layer);
      nmktt.dims(4) = struct('Name', 'Tracers'         ,'Length',ncdimlen.Tracers);
      nmktt.dims(5) = struct('Name', 'time'            ,'Length',ncdimlen.time);
      end

%% time

      if isempty(OPT.timezone)
         fprintf(2,'> No model timezone supplied, timezone could NOT be added to netCDF file. This will be interpreted as GMT! \n')
      end
     
      ifld     = 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
      attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-info-series:ITMAPC map-const:ITDATE map-const:DT map-const:TUNIT');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [datestr(T.datenum(1),31),char(9),datestr(T.datenum(end),31)]);
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'time_bounds');
      nc.Variables(ifld) = struct('Name'      , 'time', ...
                                  'Datatype'  , 'double', ...
                                  'Dimensions', time.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
       
       ifld     = ifld+1;clear attr dims
       attr(    1)  = struct('Name', 'long_name'    , 'Value', 'time bounds');
       attr(end+1)  = struct('Name', 'actual_range' , 'Value', [datestr(T.datenum(1),31),char(9),datestr(T.datenum(end),31)]);
       nc.Variables(ifld) = struct('Name'      , 'time_bounds', ...
                                   'Datatype'  , 'double', ...
                                   'Dimensions',  struct('Name'  ,{'time','time_bounds'},...
                                                         'Length',{ncdimlen.time,2}), ...
                                   'Attributes' , attr,...
                                   'FillValue'  , []);
                                  
      R.time = [min(T.datenum)  max(T.datenum)]- OPT.refdatenum; % this intializes R

%% add values of dimensions (1/3)
%  dimensions are indices into matrix space when grid is curvi-linear

      ifld     = ifld+1;clear attr dims;ifldx = ifld;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:MMAX');
      nc.Variables(ifld) = struct('Name'      , 'm', ...
                                  'Datatype'  , 'int32', ...
                                  'Dimensions', m.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

      ifld     = ifld+1;clear attr dims;ifldy = ifld;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:NMAX');
      nc.Variables(ifld) = struct('Name'      , 'n', ...
                                  'Datatype'  , 'int32', ...
                                  'Dimensions', n.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

%% horizontal coordinates: (x,y) and (lon,lat), on centres and corners

   if any(strfind(G.coordinates,'CART')) % CARTESIAN, CARTHESIAN (old bug)
   
      if ~isempty(OPT.epsg)
      ifld     = ifld + 1;clear attr dims
      attr = nc_cf_grid_mapping(OPT.epsg);
      nc.Variables(ifld) = struct('Name'       , 'CRS', ...
                                  'Datatype'   , 'int32', ...
                                  'Dimensions' , [], ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

      if any(strcmp('x',OPT.var)) && any(strcmp('y',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centres, x-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.x(:)) max(G.cen.x(:))]);
      if ~isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'CRS');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:XZ map-const:KCS map-const:COORDINATES');
      if any(strcmp('grid_x',OPT.var)) && any(strcmp('grid_y',OPT.var))
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_x');
      end
      nc.Variables(ifld) = struct('Name'       , 'x', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nm.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centres, y-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36;
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.y(:)) max(G.cen.y(:))]);
      if ~isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'CRS');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:YZ map-const:KCS map-const:COORDINATES');
      if any(strcmp('grid_x',OPT.var)) && any(strcmp('grid_y',OPT.var))
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_y');
      end
      nc.Variables(ifld) = struct('Name'       , 'y', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nm.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
                                  
      %% add values of dimensions (2/3): dimensions are reduced vectors of (x,y) matrices when grid is orthogonal
      if G.orthogonal
      nc.Variables(ifldx) = nc.Variables(ifld-1);
      nc.Variables(ifldx).Name                  = 'm';
      nc.Variables(ifldx).Dimensions            = m.dims;
      nc.Variables(ifldx).Attributes(end)       = []; % remove 2D bounds, TO DO: add 1D bounds

      nc.Variables(ifldy) = nc.Variables(ifld  );
      nc.Variables(ifldy).Name                  = 'n';
      nc.Variables(ifldy).Dimensions            = n.dims;
      nc.Variables(ifldy).Attributes(end)       = []; % remove 2D bounds, TO DO: add 1D bounds
      end
      end

      if any(strcmp('grid_x',OPT.var)) && any(strcmp('grid_y',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell corners, x-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.x(:)) max(G.cor.x(:))]);
      attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'CRS');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:XCOR map-const:COORDINATES');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'OpenEarth Matlab function nc_cf_bounds2cor.m reshapes it to a regular 2D array');
      nc.Variables(ifld) = struct('Name'       , 'grid_x', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmcor.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell corners, y-coordinate');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.y(:)) max(G.cor.y(:))]);
      attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'CRS');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:YCOR map-const:COORDINATES');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'OpenEarth Matlab function nc_cf_bounds2cor.m reshapes it to a regular 2D array');
      nc.Variables(ifld) = struct('Name'       , 'grid_y', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmcor.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

   end % cartesian

   if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)

      if any(strcmp('longitude',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centers, longitude-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.lon(:)) max(G.cen.lon(:))]);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:XZ map-const:KCS map-const:CODW map-const:COORDINATES');
      if any(strcmp('grid_longitude',OPT.var)) & any(strcmp('grid_latitude',OPT.var))   
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_longitude');
      end
      nc.Variables(ifld) = struct('Name'       , 'longitude', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nm.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end
      
      if any(strcmp('latitude',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centers, latitude-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.lat(:)) max(G.cen.lat(:))]);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:YZ map-const:KCS map-const:YWAT map-const:CODW map-const:COORDINATES');
      if any(strcmp('grid_longitude',OPT.var)) & any(strcmp('grid_latitude',OPT.var))   
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_latitude');
      end
      nc.Variables(ifld) = struct('Name'       , 'latitude', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nm.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      %% add values of dimensions (2/3): dimensions are reduced vectors of (x,y) matrices when grid is orthogonal
      if G.orthogonal & ~any(strfind(G.coordinates,'CART'))
      nc.Variables(ifldx) = nc.Variables(ifld-1);
      nc.Variables(ifldx).Name                  = 'm';
      nc.Variables(ifldx).Dimensions            = m.dims;
      nc.Variables(ifldx).Attributes(end)       = []; % remove 2D bounds, TO DO: add 1D bounds

      nc.Variables(ifldy) = nc.Variables(ifld  );
      nc.Variables(ifldy).Name                  = 'n';
      nc.Variables(ifldy).Dimensions            = n.dims;
      nc.Variables(ifldy).Attributes(end)       = []; % remove 2D bounds, TO DO: add 1D bounds
      end

      end

      if any(strcmp('grid_longitude',OPT.var)) && any(strcmp('grid_latitude',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell corners, longitude-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.lon(:)) max(G.cor.lon(:))]);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:XCOR map-const:CODB map-const:COORDINATES');
      nc.Variables(ifld) = struct('Name'       , 'grid_longitude', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmcor.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell corners, latitude-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.lat(:)) max(G.cor.lat(:))]);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:YCOR map-const:CODB map-const:COORDINATES');
      nc.Variables(ifld) = struct('Name'       , 'grid_latitude', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmcor.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end
      
   end % lat,lon present

%% vertical coordinates

      if any(strcmp('k',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'layer index');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Z');
      if strmatch('SIGMA-MODEL', G.layer_model)
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
      else
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      end
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1, the bottom layer has index kmax.');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:KMAX map-const:LAYER_MODEL');
      nc.Variables(ifld) = struct('Name'       , 'k', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , k.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

      if strmatch('SIGMA-MODEL', G.layer_model)
      
      % include variables for essential z dependencies
      ind=strcmp(OPT.var,'waterlevel');if all(ind==0);OPT.var{end+1} = 'waterlevel';end
      ind=strcmp(OPT.var,'depth'     );if all(ind==0);OPT.var{end+1} = 'depth'     ;end
      
      ifld     = ifld + 1;clear attr dims;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer midpoints');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: Layer eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:KMAX map-const:LAYER_MODEL map-const:THICK');
      nc.Variables(ifld) = struct('Name'       , 'Layer', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , k.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      
      ifld     = ifld + 1;clear attr dims;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer interfaces');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: LayerInterf eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:KMAX map-const:LAYER_MODEL map-const:THICK');
      nc.Variables(ifld) = struct('Name'       , 'LayerInterf', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , ki.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      
      elseif strmatch('Z-MODEL', G.layer_model)
      
      % include variables for essential z dependencies
      ind=strcmp(OPT.var,'waterlevel');if all(ind==0);OPT.var{end+1} = 'waterlevel';end
      ind=strcmp(OPT.var,'depth'     );if all(ind==0);OPT.var{end+1} = 'depth'     ;end
      
      ifld     = ifld + 1;clear attr dims;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'z at layer midpoints');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'altitude');
%attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_z_coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
%attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'eta: var1 depth: var2 zlev: var3'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bottom layer has index k=1 and is the bottom depth, the surface layer has index kmax and is z=free water surface.');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:KMAX map-const:LAYER_MODEL map-const:ZK');
      nc.Variables(ifld) = struct('Name'       , 'Layer', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , k.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
          
      ifld     = ifld + 1;clear attr dims;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'z at layer interfaces');
%attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_z_coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
%attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'eta: var1 depth: var2 zlev: var3'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bottom layer has index k=1 and is the bottom depth, the surface layer has index kmax and is z=free water surface.');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:KMAX map-const:LAYER_MODEL map-const:ZK');
      nc.Variables(ifld) = struct('Name'       , 'LayerInterf', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , ki.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      
      end % z/sigma

%% bathymetry

      if any(strcmp('grid_depth',OPT.var))
      ifld     = ifld + 1;clear attr dims;
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_floor_depth_below_sea_level'); % sea_floor_depth
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'depth of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:DP map-const:DP0 map-const:DPS map-const:DRYFLP');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', '');
      % NB for values at corners there is no bounds matrix
      attr(end+1)  = struct('Name', 'comment'      ,  'Value', '');
     %dims(    1)  = struct('Name', 'grid_n'   ,'Length',ncdimlen.grid_n);
     %dims(    2)  = struct('Name', 'grid_m'   ,'Length',ncdimlen.grid_m);
      nc.Variables(ifld) = struct('Name'       , 'grid_depth', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , struct('Name'  ,{'grid_n','grid_m'},...
                                                        'Length',{ncdimlen.grid_n,ncdimlen.grid_m}), ... % special case
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end
          
      if any(strcmp('depth',OPT.var))
      ifld     = ifld + 1;clear attr dims;
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_floor_depth_below_sea_level'); % sea_floor_depth
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'depth of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:DPS0 map-const:KCS');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', '');
      nc.Variables(ifld) = struct('Name'       , 'depth', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nm.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

      if any(strcmp('zactive',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'active water-level point');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'zactive', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nm.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end
      
      if any(strcmp('area',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'cell_area');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'area of grid cells');
      if any(strfind(G.coordinates,'SPHE'))
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees2');
      else
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2');
      end
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:GSQS map-const:KCS');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', G.cen.areatext);
      nc.Variables(ifld) = struct('Name', 'area', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nm.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

%% 3 Create (primary) variables: momentum and mass conservation

      if any(strcmp('waterlevel',OPT.var))
      if ~isequal(vs_get_elm_size(F,'S1'),0)
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_surface_height'); % sea_surface_elevation
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'water level');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.waterlevel = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:S1 map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'waterlevel', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else
         ind=strcmp(OPT.var,'waterlevel');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: waterlevel\n')
      end
      end
      
      if any(strcmp('velocity',OPT.var))
      if ~isequal(vs_get_elm_size(F,'U1'),0) || ~isequal(vs_get_elm_size(F,'V1'),0)
      ifld     = ifld + 1;clear attr dims
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'eastward_sea_water_velocity'); % surface_geostrophic_sea_water_x_velocity_assuming_sea_level_for_geoid
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, lon-component');
      else
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_x_velocity'); % surface_geostrophic_sea_water_x_velocity_assuming_sea_level_for_geoid
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, x-component');
      end
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.velocity_x = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:U1 map-series:V1 map-const:ALFAS map-const:KCU map-const:KCV map-const:KFU map-const:KFV map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'velocity_x', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      
      ifld     = ifld + 1;clear attr dims
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'northward_sea_water_velocity'); % surface_geostrophic_sea_water_y_velocity_assuming_sea_level_for_geoid
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, lat-component');
      else
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_y_velocity'); % surface_geostrophic_sea_water_y_velocity_assuming_sea_level_for_geoid
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, y-component');
      end 
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.velocity_y = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:U1 map-series:V1 map-const:ALFAS map-const:KCU map-const:KCV map-const:KFU map-const:KFV map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'velocity_y', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else
         ind=strcmp(OPT.var,'velocity');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: velocity\n')
      end
      end
      
      if any(strcmp('velocity_omega',OPT.var))
      if ~isequal(vs_get_elm_size(F,'W'),0)
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'upward_sea_water_velocity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'relative layer velocity, z-component'); % holds for z and sigma layers
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.velocity_omega = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:W map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'velocity_omega', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkit.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else
         ind=strcmp(OPT.var,'velocity_omega');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: velocity_omega\n')
      end
      end
      
      if any(strcmp('velocity_z',OPT.var))
      if ~isequal(vs_get_elm_size(F,'WPHY'),0)
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'upward_sea_water_velocity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, z-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.velocity_z = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:WPHY map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'velocity_z', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else
         ind=strcmp(OPT.var,'velocity_z');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: velocity_z\n')
      end
      end

      if any(strcmp('tau',OPT.var))
      if ~isequal(vs_get_elm_size(F,'TAUKSI'),0) || ~isequal(vs_get_elm_size(F,'TAUETA'),0)
      ifld     = ifld + 1;clear attr dims
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_northward_stress');
      else
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_x_stress');
      end
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'bed shear stress, x-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'N/m2');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.tau_x = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:TAUKSI map-const:TAUETA map-const:ALFAS map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'tau_x', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      
      ifld     = ifld + 1;clear attr dims
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_eastward_stress');
      else
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_y_stress');
      end
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'bed shear stress, y-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'N/m2');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.tau_y = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:TAUKSI map-const:TAUETA map-const:ALFAS map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'tau_y', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else
         ind=strcmp(OPT.var,'tau');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: tau\n')
      end
      end

     
%% 3 Create variables: scalars

      if any(strcmp('density',OPT.var))
      if ~isequal(vs_get_elm_size(F,'RHO'),0)
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_density');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'density');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'kg/m3');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.density = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:RHO map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'density', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else % remove if not present in trim file
         ind=strcmp(OPT.var,'density');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: density\n')
      end
      end
      
      if strmatch('SIGMA-MODEL', G.layer_model)
      if any(strcmp('pea',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Potential Energy Anomaly (PEA)');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.pea = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:RHO map-series:S1 map-const:KCS');
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'pea', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

      if any(strcmp('dpeadt',OPT.var))
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'time rate of change of Potential Energy Anomaly (dPEA/dt)');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.dpeadt = [Inf -Inf];
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:RHO map-series:S1 map-const:KCS');
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'dpeadt', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

      if any(strcmp('dpeads',OPT.var))
      
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Ax term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Ax = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Ax', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Ay term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Ay = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Ay', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Sx term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Sx = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Sx', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Sy term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Sy = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Sy', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Cx term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Cx = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Cx', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Cy term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Cy = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Cy', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Nx term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Nx = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Nx', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Ny term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Ny = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Ny', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Wz term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Wz = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Wz', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'RHS Mz term of spatial gradient of verticaly integrated Potential Energy Anomaly');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Mz = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc.Variables(ifld) = struct('Name'       , 'Mz', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end
      else
         ind=strcmp(OPT.var,'pea');
         OPT.var(ind) = [];      
         ind=strcmp(OPT.var,'dpeadt');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: PEA not yet implemented for Z-MODEL.\n')
      end

      if any(strcmp('salinity',OPT.var))
      if isfield(I,'salinity')
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_salinity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'salinity');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'ppt');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.salinity = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:R1 map-const:KCS map-const:NAMCON map-const:LSTCI');
      nc.Variables(ifld) = struct('Name'       , 'salinity', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else % remove if not present in trim file
         ind=strcmp(OPT.var,'salinity');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: salinity \n')
      end
      end

      if any(strcmp('temperature',OPT.var))
      if isfield(I,'temperature')
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_temperature');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'temperature');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degree_Celsius');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.temperature = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:R1 map-const:KCS map-const:NAMCON map-const:LSTCI');
      nc.Variables(ifld) = struct('Name'       , 'temperature', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else % remove if not present in trim file
         ind=strcmp(OPT.var,'temperature');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: temperature\n')
      end
      end

      if any(strcmp('tke',OPT.var))
      if isfield(I,'turbulent_energy')
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'specific_kinetic_energy_of_sea_water'); %?
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'turbulent kinetic energy'); % not in NEFIS file
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2/s2');  % not in NEFIS file 
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.tke = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:RTUR1 map-const:KCS map-const:NAMCON map-const:LSTCI map-const:LTUR');
      nc.Variables(ifld) = struct('Name'       , 'tke', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkit.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else % remove if not present in trim file
         ind=strcmp(OPT.var,'tke');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: tke\n')
      end
      end

      if any(strcmp('eps',OPT.var))
      if isfield(I,'energy_dissipation')
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'ocean_kinetic_energy_dissipation_per_unit_area_due_to_vertical_friction'); %?
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'turbulent energy dissipation'); % not in NEFIS file
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2/s3'); % 'W m-2'); % not in NEFIS file
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.eps = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:RTUR1 map-const:KCS map-const:NAMCON map-const:LSTCI map-const:LTUR');
      nc.Variables(ifld) = struct('Name'       , 'eps', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkit.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else % remove if not present in trim file
         ind=strcmp(OPT.var,'eps');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: eps\n')
      end
      end
      
      if any(strcmp('viscosity_z',OPT.var))
      if ~isequal(vs_get_elm_size(F,'VICWW'),0)
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'ocean_vertical_momentum_diffusivity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Vertical eddy viscosity-3D');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^2/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.viscosity_z = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:VICWW map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'viscosity_z', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkit.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else
         ind=strcmp(OPT.var,'viscosity_z');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: viscosity_z\n')
      end
      end
      
      if any(strcmp('diffusivity_z',OPT.var))
      if ~isequal(vs_get_elm_size(F,'VICWW'),0)
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'ocean_vertical_tracer_diffusivity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Vertical eddy diffusivity-3D');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^2/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.diffusivity_z = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:DICWW map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'diffusivity_z', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkit.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else
         ind=strcmp(OPT.var,'diffusivity_z');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: diffusivity_z\n')
      end
      end
      
      if any(strcmp('Ri',OPT.var))
      if ~isequal(vs_get_elm_size(F,'VICWW'),0)
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'richardson_number_in_sea_water');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Richardson number');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '-');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Ri = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:RICH map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'Ri', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkit.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else
         ind=strcmp(OPT.var,'Ri');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: Ri\n')
      end
      end

% TO DO
%-------------------------------------------------------------------------------
%[Delft3D-trim:Virtual:spiralflow]
%[Delft3D-trim:Element:UMNLDF]
%[Delft3D-trim:Element:VMNLDF]
%[Delft3D-trim:Element:VICUV]
%[Delft3D-trim:Element:VORTIC]
%[Delft3D-trim:Element:ENSTRO]
%[Delft3D-trim:Element:HYDPRES]
%-------------------------------------------------------------------------------

%% tracers

   if any(strcmp('tracer',OPT.var)) && NTRACER > 0
   
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'tracer names');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '-');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:NAMCON');
      dims(1)  = struct('Name', 'CHAR20'          ,'Length',ncdimlen.CHAR20);
      dims(2)  = struct('Name', 'Tracers'         ,'Length',ncdimlen.Tracers);
      nc.Variables(ifld) = struct('Name'       , 'TracerNames', ...
                                  'Datatype'   , 'char', ...
                                  'Dimensions' , dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'tracer concentration');
      %attr(end+1)  = struct('Name', 'standard_name', 'Value', '<undefined>');
      %attr(end+1)  = struct('Name', 'units'        , 'Value', '<undefined>');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.tracerconc = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:R1 map-const:KCS map-const:NAMCON map-const:LSTCI');
      nc.Variables(ifld) = struct('Name'       , 'tracerconc', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmktt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

   else
      ind=strcmp(OPT.var,'tracer');
      OPT.var(ind) = [];      
      fprintf(2,'> Variable not in trim file, skipped: tracer\n')
   end % isfield

%% sediments

   if any(strcmp('sediment',OPT.var)) && LSED > 0	        
   
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'suspended sediment fraction names');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '-');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:NAMCON map-const:NAMSED');
      dims(1)  = struct('Name', 'CHAR20'          ,'Length',ncdimlen.CHAR20);
      dims(2)  = struct('Name', 'SuspSedimentFrac','Length',ncdimlen.SuspSedimentFrac);
      nc.Variables(ifld) = struct('Name'       , 'SuspSedimentFracNames', ...
                                  'Datatype'   , 'char', ...
                                  'Dimensions' , dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'concentration_of_suspended_matter_in_sea_water'); % mass_concentration_of_suspended_matter_in_sea_water
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'suspended sediment concentration');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'mg/l');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.suspsedconc = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:R1 map-const:KCS map-const:NAMCON map-const:NAMSED map-const:LSTCI map-const:LSED');
      nc.Variables(ifld) = struct('Name'       , 'suspsedconc', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkst.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

   else
      ind=strcmp(OPT.var,'sediment');
      OPT.var(ind) = [];      
      fprintf(2,'> Variable not in trim file, skipped: sediment\n')
   end % isfield

         % map-sed-series

         % Bed-load transport
      if any(strcmp('sedtrans',OPT.var))
      if ~isequal(vs_get_elm_size(F,'SBUU'),0) || ~isequal(vs_get_elm_size(F,'SBVV'),0)
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'bedload_sediment_transport_x_component'); % no standard name exist
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'bedload_sediment_transport, x-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^3/s/m');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.bedload_sediment_transport_x = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-sed-series:SBUU map-sed-series:SBVV map-const:ALFAS map-const:KCU map-const:KCV map-const:KFU map-const:KFV map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'bedload_sediment_transport_x', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkst.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'bedload_sediment_transport_y_component'); % no standard name exist
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'bedload_sediment_transport, y-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^3/s/m');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.bedload_sediment_transport_y = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-sed-series:SBUU map-sed-series:SBVV map-const:ALFAS map-const:KCU map-const:KCV map-const:KFU map-const:KFV map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'bedload_sediment_transport_y', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkst.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      
      % suspended load sediment transport
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'suspendedload_sediment_transport_x_component'); % no standard name exist
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'suspendedload_sediment_transport, x-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^3/s/m');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.suspended_load_sediment_transport_x = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-sed-series:SSUU map-sed-series:SSVV map-const:ALFAS map-const:KCU map-const:KCV map-const:KFU map-const:KFV map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'suspended_load_sediment_transport_x', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkst.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'suspendedload_sediment_transport_y_component'); % no standard name exist
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'suspendedload_sediment_transport, y-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^3/s/m');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayer);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.suspended_load_sediment_transport_y = [Inf -Inf];
      attr(end+1)  = struct('Name', 'cell_methods' , 'Value', 'time: point             '); % add spaces to allow for overwriting with longest method one: standard_deviation
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-sed-series:SSUU map-sed-series:SSVV map-const:ALFAS map-const:KCU map-const:KCV map-const:KFU map-const:KFV map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'suspended_load_sediment_transport_y', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmkst.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      else
         ind=strcmp(OPT.var,'sedtrans');
         OPT.var(ind) = [];      
         fprintf(2,'> Variable not in trim file, skipped: sedtrans\n')
      end
      end
      
      
   
% TO DO: 
%-------------------------------------------------------------------------------
% [Delft3D-trim:Group:map-infsed-serie]
% [Delft3D-trim:Group:map-sed-series]
% [Delft3D-trim:Group:map-infavg-serie]
% [Delft3D-trim:Group:map-avg-series]
%-------------------------------------------------------------------------------

%% 4 Create netCDF file

      if OPT.debug
      ls(ncfile)
      var2evalstr(nc)
      end

      try;delete(ncfile);end
      disp(['vs_trim2nc: NCWRITESCHEMA: creating netCDF file: ',ncfile])
      ncwriteschema(ncfile, nc);			        
      disp(['vs_trim2nc: NCWRITE: filling  netCDF file: ',ncfile])

      if OPT.debug
      fid = fopen([filepathstrname(ncfile),'.cdl'],'w');
      nc_dump(ncfile,fid);
      fclose(fid);
      end
      
%% 5 Fill variables (always)
%    Data is initialized as NaN due to attribute '_FillValue' in ncwriteschema.
%    This means can just fill only the active Delft3D cells m=[2:end-1] & n=[2:end-1]
%    and leave the inactive dummy cells at =[1 end] & n=[1 end]

      ncwrite   (ncfile,'time'          , T.datenum - OPT.refdatenum);
      ncwrite   (ncfile,'time_bounds'   , repmat(T.datenum - OPT.refdatenum,[1 2]));
      if ~G.orthogonal
      ncwrite   (ncfile,'m'             , [1:G.mmax    ]');
      ncwrite   (ncfile,'n'             , [1:G.nmax    ]');
      else
      ncwrite   (ncfile,'m'             , [cen.m(1); cen.m(:);cen.m(end)]); % leading and trailing NaN values make ncbrowse ...
      ncwrite   (ncfile,'n'             , [cen.n(1); cen.n(:);cen.n(end)]); % ... crash so replicate adjacent values
      end

      if strmatch('SIGMA-MODEL', G.layer_model)
      data = vs_let(F,'map-const','THICK','quiet');
     [sigma,sigmaInterf] = d3d_sigma(data); % [0 .. 1]
      ncwrite   (ncfile,'Layer'         ,sigma-1);
      ncwriteatt(ncfile,'Layer'         ,'actual_range',[min(sigma(:)-1) max(sigma(:)-1)]);
      
      ncwrite   (ncfile,'LayerInterf'   ,sigmaInterf-1);
      ncwriteatt(ncfile,'LayerInterf'   ,'actual_range',[min(sigmaInterf(:)-1) max(sigmaInterf(:)-1)]); % [-1 0]
      elseif strmatch('Z-MODEL', G.layer_model)

      Layer = corner2center1(G.ZK);
      ncwrite   (ncfile,'Layer'         ,Layer);
      ncwriteatt(ncfile,'Layer'         ,'actual_range',[min(Layer(:)) max(Layer(:))]);
      
      ncwrite   (ncfile,'LayerInterf'   ,G.ZK);
      ncwriteatt(ncfile,'LayerInterf'   ,'actual_range',[min(G.ZK(:)) max(G.ZK(:))]);
      end

%% 5 Fill variables (optional)

      if     any(strcmp('x',OPT.var)) & isfield(G.cen,'x')
      ncwrite   (ncfile,'x'             ,    G.cen.x,[2 2]);
      ncwriteatt(ncfile,'x'             ,'actual_range',[min(G.cen.x(:)) max(G.cen.x(:))]);
      if ~isempty(OPT.epsg)
      ncwrite   (ncfile,'CRS'           ,    OPT.epsg);
      end
      end
      
      if     any(strcmp('y',OPT.var)) & isfield(G.cen,'y')
      ncwrite   (ncfile,'y'             ,    G.cen.y,[2 2]);
      ncwriteatt(ncfile,'y'             ,'actual_range',[min(G.cen.y(:)) max(G.cen.y(:))]);
      end

      if     any(strcmp('grid_x',OPT.var)) & isfield(G.cor,'x')
      ncwrite   (ncfile,'grid_x'        , permute(nc_cf_cor2bounds(addrowcol(G.cor.x,[-1 1],[-1 1],nan)'),[3 2 1])); % addrowcol makes sure nc_cf_bounds2cor is inverse of nc_cf_cor2bounds
      ncwriteatt(ncfile,'grid_x'        ,'actual_range',[min(G.cor.x(:)) max(G.cor.x(:))]);
      end

      if     any(strcmp('grid_y',OPT.var)) & isfield(G.cor,'y')
      ncwrite   (ncfile,'grid_y'        , permute(nc_cf_cor2bounds(addrowcol(G.cor.y,[-1 1],[-1 1],nan)'),[3 2 1])); % addrowcol makes sure nc_cf_bounds2cor is inverse of nc_cf_cor2bounds
      ncwriteatt(ncfile,'grid_y'        ,'actual_range',[min(G.cor.y(:)) max(G.cor.y(:))]);
      end

      if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      if     any(strcmp('longitude',OPT.var))
      ncwrite   (ncfile,'longitude'     ,G.cen.lon,[2 2]);
      ncwriteatt(ncfile,'longitude'     ,'actual_range',[min(G.cen.lon(:)) max(G.cen.lon(:))]);
      end
      if     any(strcmp('latitude',OPT.var))
      ncwrite   (ncfile,'latitude'      ,G.cen.lat,[2 2]);
      ncwriteatt(ncfile,'latitude'      ,'actual_range',[min(G.cen.lat(:)) max(G.cen.lat(:))]);
      end

      if     any(strcmp('grid_longitude',OPT.var))
      ncwrite   (ncfile,'grid_longitude',permute(nc_cf_cor2bounds(addrowcol(G.cor.lon,[-1 1],[-1 1],nan)'),[3 2 1])); % addrowcol makes sure nc_cf_bounds2cor is inverse of nc_cf_cor2bounds
      ncwriteatt(ncfile,'grid_longitude','actual_range',[min(G.cor.lon(:)) max(G.cor.lon(:))]);
      end      

      if     any(strcmp('grid_latitude',OPT.var))
      ncwrite   (ncfile,'grid_latitude' ,permute(nc_cf_cor2bounds(addrowcol(G.cor.lat,[-1 1],[-1 1],nan)'),[3 2 1])); % addrowcol makes sure nc_cf_bounds2cor is inverse of nc_cf_cor2bounds
      ncwriteatt(ncfile,'grid_latitude' ,'actual_range',[min(G.cor.lat(:)) max(G.cor.lat(:))]);
      end      
      end

      if     any(strcmp('k',OPT.var))
      ncwrite   (ncfile,'k'          ,1:G.kmax);
      end

      if     any(strcmp('depth'     ,OPT.var))
      ncwrite   (ncfile,'depth'     ,G.cen.dep,[2 2]); % positive down !
      ncwriteatt(ncfile,'depth'     ,'actual_range',[min(-G.cen.dep(:)) max(-G.cen.dep(:))]);
      end      

      if     any(strcmp('grid_depth',OPT.var)) && isfield(G.cor,'dep')
      ncwrite   (ncfile,'grid_depth',G.cor.dep,[2 2]); % positive down !
      ncwriteatt(ncfile,'grid_depth','actual_range',[min(-G.cor.dep(:)) max(-G.cor.dep(:))]);
      end      

      if     any(strcmp('zactive'   ,OPT.var))
      ncwrite   (ncfile,'zactive'   ,G.cen.mask,[2 2]); % already applied to all variables before writing to netCDF
      ncwriteatt(ncfile,'zactive'   ,'actual_range',[0 1]);
      end      

      if     any(strcmp('area'      ,OPT.var))
      ncwrite   (ncfile,'area'      ,G.cen.area,[2 2]);
      ncwriteatt(ncfile,'area'      ,'actual_range',[nanmin(G.cen.area(:)) nanmax(G.cen.area(:))]);
      end      

      if any(strcmp('sediment',OPT.var)) && LSED > 0	        
      ncwrite   (ncfile, 'SuspSedimentFracNames',NAMSED');
      end

      if any(strcmp('tracer',OPT.var)) && NTRACER > 0	        
      ncwrite   (ncfile, 'TracerNames',NAMTRACERS');
      end

      i = 0;
      
%% add data per time slice (to save memory for laarge files)

if ~(OPT.empty)

      for it = OPT.time % it is index in NEFIS file
      i = i + 1;        % i  is index in netCDF file
      
         disp(['processing timestep ',num2str(i),' of ',num2str(length(OPT.time)),' (# ',num2str(it),')'])
          
         if any(strcmp('waterlevel',OPT.var)) | any(strcmp('pea',OPT.var))
         G.cen.zwl = apply_mask(vs_let_scalar(F,'map-series' ,{it},'S1'      , {0 0},'quiet'),G.cen.mask);
         end
         
         if any(strcmp('waterlevel',OPT.var))
         ncwrite   (ncfile,'waterlevel'     , G.cen.zwl.*G.cen.mask,[2,2,i],[1 1 1]); % 1-based, size(D.u) =   [y x], shape(waterlevel) = [t x y]
         R.waterlevel = [min(R.waterlevel(1),min(G.cen.zwl(:))) max(R.waterlevel(2),max(G.cen.zwl(:)))];
         end
          
         if any(strcmp('velocity',OPT.var))
        [D.u,D.v] = vs_let_vector_cen(F, 'map-series',{it},{'U1','V1'}, {0,0,0},'quiet');
         D.u      = apply_mask(permute(D.u,[2 3 4 1]),G.cen.mask); % y x z
         D.v      = apply_mask(permute(D.v,[2 3 4 1]),G.cen.mask); % y x z
         ncwrite   (ncfile,'velocity_x',D.u,[2,2,1,i]); % 1-based, size(D.u)         =   [y x k]
         ncwrite   (ncfile,'velocity_y',D.v,[2,2,1,i]); % 1-based, shape(velocity_*) = [t k x y]
         R.velocity_x   = [min(R.velocity_x(1),min(D.u(:))) max(R.velocity_x (2),max(D.u(:)))];  
         R.velocity_y   = [min(R.velocity_y(1),min(D.v(:))) max(R.velocity_y (2),max(D.v(:)))];  
         end
         
         % sediment transport
         if any(strcmp('sedtrans',OPT.var))
        [D.u,D.v] = vs_let_vector_cen(F, 'map-sed-series',{it},{'SBUU','SBVV'}, {0,0,0},'quiet');
         D.u      = apply_mask(permute(D.u,[2 3 4 1]),G.cen.mask); % y x z
         D.v      = apply_mask(permute(D.v,[2 3 4 1]),G.cen.mask); % y x z
         D.u      = permute(D.u,[1 2 4 3 5]);
         D.v      = permute(D.v,[1 2 4 3 5]);
         ncwrite   (ncfile,'bedload_sediment_transport_x',D.u,[2,2,1,1,i]); % 1-based, size(D.u)         =   [y x k]
         ncwrite   (ncfile,'bedload_sediment_transport_y',D.v,[2,2,1,1,i]); % 1-based, shape(velocity_*) = [t k x y]
         R.bedload_sediment_transport_x   = [min(R.bedload_sediment_transport_x(1),min(D.u(:))) max(R.bedload_sediment_transport_x (2),max(D.u(:)))];  
         R.bedload_sediment_transport_y   = [min(R.bedload_sediment_transport_y(1),min(D.v(:))) max(R.bedload_sediment_transport_y (2),max(D.v(:)))];  
         
        [D.u,D.v] = vs_let_vector_cen(F, 'map-sed-series',{it},{'SSUU','SSVV'}, {0,0,0},'quiet');
         D.u      = apply_mask(permute(D.u,[2 3 4 1]),G.cen.mask); % y x z
         D.v      = apply_mask(permute(D.v,[2 3 4 1]),G.cen.mask); % y x z
         D.u      = permute(D.u,[1 2 4 3 5]);
         D.v      = permute(D.v,[1 2 4 3 5]);
         ncwrite   (ncfile,'suspended_load_sediment_transport_x',D.u,[2,2,1,1,i]); % 1-based, size(D.u)         =   [y x k]
         ncwrite   (ncfile,'suspended_load_sediment_transport_y',D.v,[2,2,1,1,i]); % 1-based, shape(velocity_*) = [t k x y]
         R.suspended_load_sediment_transport_x   = [min(R.suspended_load_sediment_transport_x(1),min(D.u(:))) max(R.suspended_load_sediment_transport_x (2),max(D.u(:)))];  
         R.suspended_load_sediment_transport_y   = [min(R.suspended_load_sediment_transport_y(1),min(D.v(:))) max(R.suspended_load_sediment_transport_y (2),max(D.v(:)))];  
         end         
         
         
         if any(strcmp('velocity_omega',OPT.var))
         matrix      = apply_mask(vs_let_scalar(F, 'map-series',{it},'W'     , {0,0,0},'quiet'),G.cen.mask);
         ncwrite   (ncfile,'velocity_omega', matrix,[2,2,1,i]); % 1-based
         R.velocity_z   = [min(R.velocity_omega(1),min(matrix(:))) max(R.velocity_omega(2),max(matrix(:)))];
         end
         
         if any(strcmp('velocity_z',OPT.var))
         matrix      = apply_mask(vs_let_scalar(F, 'map-series',{it},'WPHY'     , {0,0,0},'quiet'),G.cen.mask);
         ncwrite   (ncfile,'velocity_z', matrix,[2,2,1,i]); % 1-based
         R.velocity_z   = [min(R.velocity_z(1),min(matrix(:))) max(R.velocity_z(2),max(matrix(:)))];
         end
         
         if any(strcmp('tau',OPT.var)) & ~isequal(vs_get_elm_size(F,'TAUKSI'),0) & ~isequal(vs_get_elm_size(F,'TAUETA'),0)
        [D.tau_x,D.tau_y] = vs_let_vector_cen(F, 'map-series',{it},{'TAUKSI','TAUETA'}, {0,0,0},'quiet');
         D.tau_x = permute(D.tau_x,[2 3 1]).*G.cen.mask;
         D.tau_y = permute(D.tau_y,[2 3 1]).*G.cen.mask;
         ncwrite   (ncfile,'tau_x'       , D.tau_x      ,[2,2,i]);
         ncwrite   (ncfile,'tau_y'       , D.tau_y      ,[2,2,i]);
         R.tau_x   = [min(R.tau_x  (1),min(D.tau_x(:))) max(R.tau_x(2),max(D.tau_x(:)))];  
         R.tau_y   = [min(R.tau_y  (1),min(D.tau_y(:))) max(R.tau_y(2),max(D.tau_y(:)))];  
         end

         if any(strcmp('salinity',OPT.var))
         if isfield(I,'salinity')
         matrix    = apply_mask(vs_let_scalar(F,'map-series' ,{it},'R1'       , {0 0 0 I.salinity.index   },'quiet'),G.cen.mask);
         ncwrite   (ncfile,'salinity'   , matrix,[2,2,1,i]); % 1-based
         R.salinity = [min(R.salinity(1),min(matrix(:))) max(R.salinity(2),max(matrix(:)))];
         end
         end
         
         if any(strcmp('temperature',OPT.var))
         if isfield(I,'temperature')
         matrix = apply_mask(vs_let_scalar(F,'map-series' ,{it},'R1'       , {0 0 0 I.temperature.index},'quiet'),G.cen.mask);
         ncwrite   (ncfile,'temperature', matrix,[2,2,1,i]); % 1-based
         R.temperature = [min(R.temperature(1),min(matrix(:))) max(R.temperature(2),max(matrix(:)))];
         end
         end
         
         if any(strcmp('tke',OPT.var))
         if isfield(I,'turbulent_energy')
         matrix = apply_mask(vs_let_scalar(F,'map-series' ,{it},'RTUR1', {0 0 0 I.turbulent_energy.index},'quiet'),G.cen.mask);
         ncwrite   (ncfile,'tke', matrix,[2,2,1,i]);
         R.tke = [min(R.tke(1),min(matrix(:))) max(R.tke(2),max(matrix(:)))];
         end
         end
         
         if any(strcmp('eps',OPT.var))
         if isfield(I,'energy_dissipation')
         matrix = apply_mask(vs_let_scalar(F,'map-series' ,{it},'RTUR1', {0 0 0 I.energy_dissipation.index},'quiet'),G.cen.mask);
         ncwrite   (ncfile,'eps', matrix,[2,2,1,i]);
         R.eps = [min(R.eps(1),min(matrix(:))) max(R.eps(2),max(matrix(:)))];
         end
         end

         if any(strcmp('sediment',OPT.var)) && LSED > 0
         
         substances = fieldnames(I);
         pointers = find(ismember(substances,lower(NAMSED)));
         
         for ised = 1:length(pointers)
          substance = substances{pointers(ised)};
          matrix    = apply_mask(vs_let_scalar(F,'map-series' ,{it},'R1', {0 0 0 I.(substance).index},'quiet'),G.cen.mask);
          ncwrite     (ncfile,'suspsedconc', matrix,[2,2,1,ised,i]);
          R.suspsedconc = [min(R.suspsedconc(1),min(matrix(:))) max(R.suspsedconc(2),max(matrix(:)))];
         end
         end
         
         if any(strcmp('tracer',OPT.var)) && NTRACER > 0
         
         substances = fieldnames(I);
         pointers = find(ismember(substances,lower(NAMTRACERS)));
         
         for itrc = 1:length(pointers)
          substance = substances{pointers(itrc)};
          matrix    = apply_mask(vs_let_scalar(F,'map-series' ,{it},'R1', {0 0 0 I.(substance).index},'quiet'),G.cen.mask);
          ncwrite     (ncfile,'tracerconc', matrix,[2,2,1,itrc,i]);
          R.tracerconc = [min(R.tracerconc(1),min(matrix(:))) max(R.tracerconc(2),max(matrix(:)))];
         end
         end
         
         if any(strcmp('viscosity_z',OPT.var)) &  ~isequal(vs_get_elm_size(F,'VICWW'),0)
         matrix = apply_mask(vs_let_scalar(F,'map-series' ,{it},'VICWW','quiet'),G.cen.mask);
         ncwrite   (ncfile,'viscosity_z', matrix,[2,2,1,i]);
         R.viscosity_z = [min(R.viscosity_z(1),min(matrix(:))) max(R.viscosity_z(2),max(matrix(:)))];
         end
         
         if any(strcmp('diffusivity_z',OPT.var)) & ~isequal(vs_get_elm_size(F,'DICWW'),0)
         matrix = apply_mask(vs_let_scalar(F,'map-series' ,{it},'DICWW','quiet'),G.cen.mask);
         ncwrite   (ncfile,'diffusivity_z', matrix,[2,2,1,i]);
         R.diffusivity_z = [min(R.diffusivity_z(1),min(matrix(:))) max(R.diffusivity_z(2),max(matrix(:)))];
         end
         
         if any(strcmp('Ri',OPT.var)) & ~isequal(vs_get_elm_size(F,'RICH'),0)
         matrix = apply_mask(vs_let_scalar(F,'map-series' ,{it},'RICH','quiet'),G.cen.mask);
         ncwrite   (ncfile,'Ri', matrix,[2,2,1,i]);
         R.Ri = [min(R.Ri(1),min(matrix(:))) max(R.Ri(2),max(matrix(:)))];
         end

         if (any(strcmp('density',OPT.var)) | any(strcmp('pea',OPT.var))) & ~isequal(vs_get_elm_size(F,'RHO'),0)
         matrix = apply_mask(vs_let_scalar(F,'map-series' ,{it},'RHO'      , {0 0 0},'quiet'),G.cen.mask);
         if any(strcmp('density',OPT.var))
         ncwrite   (ncfile,'density', matrix,[2,2,1,i]); % 1-based
         R.density = [min(R.density(1),min(matrix(:))) max(R.density(2),max(matrix(:)))];
         end
         % Note density should be treated right before PEA
         if strmatch('SIGMA-MODEL', G.layer_model)

            if any(strcmp('pea',OPT.var))
            G.cen.intf.z  = zeros(G.nmax-2,G.mmax-2,G.kmax+1);
            for k = 1:G.kmax+1
               G.cen.intf.z(:,:,k) = G.sigma_intf(k).*(G.cen.zwl + G.cen.dep) - G.cen.dep; % dep is positive down
            end
            if OPT.debug
            disp([min(G.cen.intf.z(:)) max(G.cen.intf.z(:))])
            end
            matrix = pea_simpson_et_al_1990(G.cen.intf.z,matrix,3,'weights',G.sigma_dz);
            ncwrite   (ncfile,'pea', matrix,[2,2,i]); % 1-based
            R.pea = [min(R.pea(1),min(matrix(:))) max(R.pea(2),max(matrix(:)))];
            end

            if any(strcmp('dpeads',OPT.var))
            tmp = vs_dpeads(F,it);
            ncwrite   (ncfile,'Ax', tmp.Ax,[2,2,i]);R.Ax = [min(R.Ax(1),min(tmp.Ax(:))) max(R.Ax(2),max(tmp.Ax(:)))];
            ncwrite   (ncfile,'Ay', tmp.Ay,[2,2,i]);R.Ay = [min(R.Ay(1),min(tmp.Ay(:))) max(R.Ay(2),max(tmp.Ay(:)))];
            ncwrite   (ncfile,'Sx', tmp.Sx,[2,2,i]);R.Sx = [min(R.Sx(1),min(tmp.Sx(:))) max(R.Sx(2),max(tmp.Sx(:)))];
            ncwrite   (ncfile,'Sy', tmp.Sy,[2,2,i]);R.Sy = [min(R.Sy(1),min(tmp.Sy(:))) max(R.Sy(2),max(tmp.Sy(:)))];
            ncwrite   (ncfile,'Cx', tmp.Cx,[2,2,i]);R.Cx = [min(R.Cx(1),min(tmp.Cx(:))) max(R.Cx(2),max(tmp.Cx(:)))];
            ncwrite   (ncfile,'Cy', tmp.Cy,[2,2,i]);R.Cy = [min(R.Cy(1),min(tmp.Cy(:))) max(R.Cy(2),max(tmp.Cy(:)))];
            ncwrite   (ncfile,'Nx', tmp.Nx,[2,2,i]);R.Nx = [min(R.Nx(1),min(tmp.Nx(:))) max(R.Nx(2),max(tmp.Nx(:)))];
            ncwrite   (ncfile,'Ny', tmp.Ny,[2,2,i]);R.Ny = [min(R.Ny(1),min(tmp.Ny(:))) max(R.Ny(2),max(tmp.Ny(:)))];
            ncwrite   (ncfile,'Wz', tmp.Wz,[2,2,i]);R.Wz = [min(R.Wz(1),min(tmp.Wz(:))) max(R.Wz(2),max(tmp.Wz(:)))];
            ncwrite   (ncfile,'Mz', tmp.Mz,[2,2,i]);R.Mz = [min(R.Mz(1),min(tmp.Mz(:))) max(R.Mz(2),max(tmp.Mz(:)))];
            end

         elseif strmatch('Z-MODEL', G.layer_model)
         
            % not yet implemented for z-layers.
            
         end % z/sigma
         end % density
         
      end % time    
      
%% update data
%  dpeadt central difference in time

      if any(strcmp('dpeadt',OPT.var))
      R.dpeadt = [Inf -Inf];
      for i = 2:(time.dims.Length-1)
      
         disp(['processing timestep ',num2str(i),' of ',num2str(length(time.dims.Length)),' dpeadt']);
         matrix = ncread(ncfile,'pea', [1,1,i-1],[Inf Inf 2],[1 1 2]); % 1-based
         dt     = (T.datenum(i+1) - T.datenum(i-1)); % = 2*dt_flow, calculate dt inside time loop allow for non-equidistant times
         matrix = diff(matrix,1,3)./dt./24./3600; % over 2 time steps including already in dt
         R.dpeadt = [min(R.dpeadt(1),min(matrix(:))) max(R.dpeadt(2),max(matrix(:)))];
         ncwrite   (ncfile,'dpeadt', matrix,[1,1,i]); % 1-based
         ncwriteatt(ncfile,'dpeadt','actual_range',R.dpeadt);
         
      end         
      end         
      
%% update actual ranges

      if exist('R','var')
        varnames = fieldnames(R);
        
        for ivar=1:length(varnames)
           varname = varnames{ivar};
           ncwriteatt(ncfile,varname  ,'actual_range',R.(varname));
        end
      end

end % if ~(OPT.empty)
        
if isnumeric(OPT.dump) && OPT.dump==1
   nc_dump(ncfile);
else
   fid = fopen(OPT.dump,'w');
   nc_dump(ncfile,fid);
   fclose(fid);
end

%% EOF      


function matrix = apply_mask(matrix,mask)

   for k=1:size(matrix,3)
      matrix(:,:,k) = matrix(:,:,k).*mask;
   end

