function matroos_opendap_maps2series2mn2nc(D,ncfile,varargin)
%MATROOS_OPENDAP_MAPS2SERIES2MN2NC save to netCDF file
%
%  matroos_opendap_maps2series2mn2nc(D,ncfile)
%
%  saves data from MATROOS_OPENDAP_MAPS2SERIES2MN to a GETM
%  compliant netCDF-CF file for subsequent serialization to:
%  (i)   - matroos_opendap_maps2series2mn2ascii: NOOS
%  (ii)  - matroos_opendap_maps2series2mn2ascii: Delft3D *.bct
%  (iii) - matroos_opendap_maps2series2mn2bct:   Dflow-FM *.tim
%
%See also: matroos_opendap_maps2series2mn

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012
%       Dr.ir. Gerben J. de Boer, Deltares
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: matroos_opendap_maps2series2mn2nc.m 8373 2013-03-25 15:34:23Z boer_g $
% $Date: 2013-03-25 23:34:23 +0800 (Mon, 25 Mar 2013) $
% $Author: boer_g $
% $Revision: 8373 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_opendap_maps2series2mn2nc.m $
% $Keywords: $

%% keywords

   OPT.Format         = 'classic'; % '64bit','classic','netcdf4','netcdf4_classic'
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wrong dates in ncbrowse due to different calendars. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention
   OPT.institution    = 'Rijkswaterstaat';
   OPT.timezone       = timezone_code2iso('GMT');
   OPT.epsg           = 28992; % Dutch RD
   OPT.debug          = 0;
   OPT.type           = 'single'; %'double'; % the nefis file is by default single precision, se better isn't useful
   
   if nargin==0
      varargout = {OPT};return
   end

   OPT = setproperty(OPT,varargin);

%% 1a Create file

      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
      nc = struct('Name','/','Format',OPT.Format);
      nc.Attributes(    1) = struct('Name','title'              ,'Value',  'Boundary conditions for hydrodynamic model');
      nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  OPT.institution);
      nc.Attributes(end+1) = struct('Name','source'             ,'Value',  ['basePath =' char(D.basePath) ' source = '  char(D.source)]);
      nc.Attributes(end+1) = struct('Name','history'            ,'Value',  [char(D.history) ]);
      nc.Attributes(end+1) = struct('Name','references'         ,'Value',  'http://svn.oss.deltares.nl');
      nc.Attributes(end+1) = struct('Name','email'              ,'Value',  '');
      nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  'This netCDF file is in GETM convention and can be serialized to (i) NOOS ascii files, (ii) Delft3D *.bct ascii files, (iii) Dflow-FM *.tim ascii files with OpenEarthTools.');
      nc.Attributes(end+1) = struct('Name','version'            ,'Value',  'transformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/matroos/matroos_opendap_maps2series2mn2nc.m $ $Id: matroos_opendap_maps2series2mn2nc.m 8373 2013-03-25 15:34:23Z boer_g $');
      nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6');
      nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
      nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2 Create dimensions

      ncdimlen.time        = length(D.datenum);
      ncdimlen.nbdyp       = length(D.x); % same name as GETM

      nc.Dimensions(    1) = struct('Name','time'            ,'Length',ncdimlen.time );
      nc.Dimensions(end+1) = struct('Name','nbdyp'           ,'Length',ncdimlen.nbdyp);

%% 2 Create dimension combinations
%    TO DO: why is field 'Length' needed, NCWRITESCHEMA should be able to find this out itself

   % 1D
       time.dims(1) = struct('Name', 'time'            ,'Length',ncdimlen.time);
      nbdyp.dims(1) = struct('Name', 'nbdyp'           ,'Length',ncdimlen.nbdyp);

   % 2D						       
       data.dims(1) = struct('Name', 'time'            ,'Length',ncdimlen.time);
       data.dims(2) = struct('Name', 'nbdyp'           ,'Length',ncdimlen.nbdyp);
						       
   %% time
     
      ifld     = 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
      attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [datestr(D.datenum(1),31) char(9) datestr(D.datenum(end),31)]);
      nc.Variables(ifld) = struct('Name'      , 'time', ...
                                  'Datatype'  , 'double', ...
                                  'Dimensions', time.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
                                  
   %% fill nbdyp dimension with distance along polygon for easy
   %  realistic (for non-uniform grid spacing) plotting in for instance ncBrowse

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'distance along boundary');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36;
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.pathdistance(:)) max(D.pathdistance(:))]);
      if ~isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'CRS');
      end
      nc.Variables(ifld) = struct('Name'       , 'nbdyp', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nbdyp.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
   %% coordinates

      if ~isfield(D,'lon') & ~isfield(D,'lat') & ~isempty(OPT.epsg)
         [D.lon,D.lat] = convertCoordinates(D.x,D.y,'CS1.code',OPT.epsg,'CS2.code',4326);
      end
      if isfield(D,'x') & isfield(D,'y') 
         coordinates = 'x y';
      end
      if isfield(D,'lon') & isfield(D,'lat') 
         coordinates = 'lon lat';
      end
      
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'lon. of interpolation-point');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.lon(:)) max(D.lon(:))]);
      nc.Variables(ifld) = struct('Name'       , 'lon', ... % same name as GETM
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nbdyp.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'lat. of interpolation-point');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.lat(:)) max(D.lat(:))]);
      nc.Variables(ifld) = struct('Name'       , 'lat', ... % same name as GETM
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nbdyp.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything


      if isfield(D,'x') && isfield(D,'y')
      
      ifld     = ifld + 1;clear attr dims
      attr         = nc_cf_grid_mapping(OPT.epsg);      
      nc.Variables(ifld) = struct('Name'       , 'CRS', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , [], ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'x of interpolation-point');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.x(:)) max(D.x(:))]);
      if ~isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'CRS');
      end
      nc.Variables(ifld) = struct('Name'       , 'x', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nbdyp.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'y of interpolation-point');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36;
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.y(:)) max(D.y(:))]);
      if ~isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'CRS');
      end
      nc.Variables(ifld) = struct('Name'       , 'y', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nbdyp.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end
      
      if isfield(D,'m')
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'm index of source model');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.m(:)) max(D.m(:))]);
      attr(end+1)  = struct('Name', 'source'       , 'Value', [char(D.basePath) ' : '  char(D.source)]);
      nc.Variables(ifld) = struct('Name'       , 'm', ...
                                  'Datatype'   , 'int32', ...
                                  'Dimensions' , nbdyp.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

      if isfield(D,'n')
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'n index of source model');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.n(:)) max(D.n(:))]);
      attr(end+1)  = struct('Name', 'source'       , 'Value', [char(D.basePath) ' : '  char(D.source)]);
      nc.Variables(ifld) = struct('Name'       , 'n', ...
                                  'Datatype'   , 'int32', ...
                                  'Dimensions' , nbdyp.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

      if isfield(D,'ind')
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sequence index of segment from source model');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.ind(:)) max(D.ind(:))]);
      attr(end+1)  = struct('Name', 'source'       , 'Value', [char(D.basePath) ' : '  char(D.source)]);
      if isfield(D,'mcor') && isfield(D,'ncor')
      attr(end+1)  = struct('Name', 'mcor'         , 'Value', D.mcor);
      attr(end+1)  = struct('Name', 'ncor'         , 'Value', D.ncor);
      end
      nc.Variables(ifld) = struct('Name'       , 'ind', ...
                                  'Datatype'   , 'int32', ...
                                  'Dimensions' , nbdyp.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

%% 3 Create variables

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_surface_height'); % sea_surface_elevation
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'water level');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN(OPT.type)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'valid_min'    , 'Value', -15);           % for GETM(?)
      attr(end+1)  = struct('Name', 'valid_max'    , 'Value', +15);           % for GETM(?)
      attr(end+1)  = struct('Name', 'missing_value', 'Value', NaN(OPT.type)); % for GETM(?)
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.elev = [Inf -Inf];
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:S1 map-const:KCS');
      nc.Variables(ifld) = struct('Name'       , 'elev', ... % same name as GETM
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , data.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

%% 4 Create netCDF file

      if OPT.debug
         ls(ncfile)
         var2evalstr(nc)
      end

      delete(ncfile);
      disp(['vs_trim2nc: NCWRITESCHEMA: creating netCDF file: ',ncfile])
      ncwriteschema(ncfile, nc);			        
      disp(['vs_trim2nc: NCWRITE: filling  netCDF file: ',ncfile])

      fid = fopen([filepathstrname(ncfile),'.cdl'],'w');
      nc_dump(ncfile,fid);
      fclose(fid);

%% 5 Fill variables (always)
%    Data is initialized as NaN due to attribute '_FillValue' in ncwriteschema.
%    This means can just fill only the active Delft3D cells m=[2:end-1] & n=[2:end-1]
%    and leave the inactive dummy cells at =[1 end] & n=[1 end]

      ncwrite   (ncfile,'time'          , D.datenum - OPT.refdatenum);
      ncwrite   (ncfile,'nbdyp'         , D.pathdistance);
      if isfield(D,'x') & isfield(D,'y')
      ncwrite   (ncfile,'x'             , D.x);
      ncwrite   (ncfile,'y'             , D.y);
      end
      if isfield(D,'lon') & isfield(D,'lat')
      ncwrite   (ncfile,'lon'           , D.lon);
      ncwrite   (ncfile,'lat'           , D.lat);
      end
      ncwrite   (ncfile,'m'             , D.m);
      ncwrite   (ncfile,'n'             , D.n);
      ncwrite   (ncfile,'ind'           , D.ind);
      ncwrite   (ncfile,'elev'          , D.elev');

%               x: [554x1 double]
%               y: [554x1 double]
%               m: [554x1 double]
%               n: [554x1 double]
%             ind: [554x1 double]
%    pathdistance: [554x1 double]
%         datenum: [252x1 double]
%            data: [554x252 double]
%          source: {'hmcn_kustfijn'}
%        basePath: {[1x49 char]}
%            mcor: [4x1 double]
%            ncor: [4x1 double]
%         history: {[1x262 char]}      