function varargout = L2bin2nc(ncfile,varargin);
%L2bin2nc   create netCDF file for saving series of binned remote sensing maps
%
%   L2BIN2NC(ncfile,'lat',lat,'lon',lon,'time',time,...)
%
% where ncfile is the name of the netCDF where an empty
% schema for data is created. Required input are all
% spatio-temporal coordinates and meta-data:
% * time is a vector of datenums. The length of time
%   determines how long the time dimension will be (which
%   is not set to unlimited by default to increase performance).
% * lat, lon and mask are required matrices defined at pixel centres.
% * latbounds, lonbounds are optional pixel corner to be mapped
%   with CF bounds attribute.
% * Name, standard_name, long_name, units define the variables
%   to be added, with Attributes extra atributes can be added.
%   Use char when adding one variable (recommended), use cellstr
%   when adding more variables.
%
% NCWRITE needs to be called after L2BIN2NC to fill the data
% matrices, preferably loop-wise to avoid memory issues.
%
% L2BIN2NC creates netCDF with meta-data for storing a 
% time series of remote sensing images. Data has to be added 
% seperately, in a loop to avoid memory issues.
%
% The resulting netCDF file can readily be used in DINEOF 3.0.
%
% Example: turn directory of MERIS mat files (VU-IVM/WaterInsight) into 1 netCDF file
%
%      ncfile  = 'L3.nc';
%      matdir  = 'F:\checkouts\OpenEarthTools\matlab\applications\oceancolor\test\';
%
%      %% make inventory of files
%
%         IMAGE_names = meris_directory(matdir);
%         M = meris_name2meta(IMAGE_names);
%         [datenumsorted,ind] = sort([M.datenum]);
%         M = M(ind); % sort files on date
%
%      %% create netCDF file (no data yet, only meta-data and [x,y,t] axes )
%
%         D      = meris_WaterInsight_load([matdir,filesep,M(1).filename]);
%         D.mask = meris_mask(D.l2_flags,[13 23]);
%           L2bin2nc(ncfile,...
%                     'lon',D.lon,...
%                     'lat',D.lat,...
%                    'mask',D.msk,...
%                    'time',datenumsorted,...
%                    'epsg',4326,...
%                                  'Name','TSM',...
%                         'standard_name','concentration_of_suspended_matter_in_sea_water',...
%                             'long_name','suspended particulate matter',...
%                                 'units','g m-3');
%      %% now gradually fill netCDF file (add data) per time slice, to avoid memory issues.
%      
%         for j=1:length(M)
%          D = meris_WaterInsight_load([matdir,filesep,M(j).filename]);
%          ncwrite(ncfile,'TSM',D.TSM',[1 1 j]); % 1-based indices
%         end
%
%See also: NCWRITE, OCEANCOLOR, NETCDF, DINEOF, MERIS2NC, NCGEN, VS_TRIM2NC, DELWAQ_MAP2NC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares 4 Rijkswaterstaat: Resmon project
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: L2bin2nc.m 10626 2014-04-30 10:45:24Z boer_g $
% $Date: 2014-04-30 18:45:24 +0800 (Wed, 30 Apr 2014) $
% $Author: boer_g $
% $Revision: 10626 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/L2bin2nc.m $
% $Keywords: $

%% Required spatio-temporal fields

   OPT.title       = '';
   OPT.institution = '';
   OPT.version     = '';
   OPT.references  = '';
   OPT.email       = '';

   OPT.time        = [];
   OPT.lon         = [];
   OPT.lat         = [];
   OPT.epsg        = 4326;
   OPT.mask        = [];

   OPT.lonbounds   = [];
   OPT.latbounds   = [];

%% Required data fields
   
   OPT.Name           = '';
   OPT.standard_name  = '';
   OPT.long_name      = '';
   OPT.units          = '';
   OPT.Attributes     = {};

%% Required settings

   OPT.Format         = '64bit'; % '64bit','classic','netcdf4','netcdf4_classic'
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention
   OPT.fillvalue      = typecast(uint8([0    0    0    0    0    0  158   71]),'DOUBLE'); % ncetcdf default that is also recognized by ncBrowse % DINEOF does not accept NaNs; % realmax('single'); %
   OPT.debug          = 0;
   OPT.timezone       = timezone_code2iso('GMT');
   OPT.type           = 'double'; %'single'; % for saving disk space, but mind accuracy !

   if nargin==0
      varargout = {OPT};
      return
   end
   
   if verLessThan('matlab','7.12.0.635')
      error('At least Matlab release R2011a is required for writing netCDF files due tue NCWRITESCHEMA.')
   end

   OPT      = setproperty(OPT,varargin);

%% CF attributes: add overall meta info
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
   nc = struct('Name','/','Format',OPT.Format);
   nc.Attributes(    1) = struct('Name','title'              ,'Value',  OPT.title);
   nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  OPT.institution);
   nc.Attributes(end+1) = struct('Name','history'            ,'Value', ['Version:' OPT.version,', tranformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/L2bin2nc.m $']);
   nc.Attributes(end+1) = struct('Name','references'         ,'Value',  OPT.references);
   nc.Attributes(end+1) = struct('Name','email'              ,'Value',  OPT.email);
   nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','version'            ,'Value',  OPT.version);
   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6');
   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged:', OPT.institution]);
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2 Create dimensions

   ncdimlen.time          = length(OPT.time);
   ncdimlen.dim1          = size(OPT.lon,1); % dim1
   ncdimlen.dim2          = size(OPT.lon,2); % dim2
   ncdimlen.bounds4       = 4       ; % for corner (grid_*) coordinates

   nc.Dimensions(    1) = struct('Name','time'            ,'Length',ncdimlen.time);
   nc.Dimensions(end+1) = struct('Name','dim1'            ,'Length',ncdimlen.dim1);
   nc.Dimensions(end+1) = struct('Name','dim2'            ,'Length',ncdimlen.dim2);
   nc.Dimensions(end+1) = struct('Name','bounds4'         ,'Length',ncdimlen.bounds4);

%% 2 Create dimension combinations for schema
%    TO DO: why is field 'Length' needed, NCWRITESCHEMA should be able to find this out itself

   % 1D: time
   time.dims(1)  = struct('Name', 'time'           ,'Length',ncdimlen.time);
      m.dims(1)  = struct('Name', 'dim1'           ,'Length',ncdimlen.dim1);
      n.dims(1)  = struct('Name', 'dim2'           ,'Length',ncdimlen.dim2);
						       
   % 2D: lat,lon centers					       
   nm.dims(1)    = struct('Name', 'dim2'             ,'Length',ncdimlen.dim2);
   nm.dims(2)    = struct('Name', 'dim1'             ,'Length',ncdimlen.dim1);

   % 3D: grid corners
   nmcor.dims(1) = struct('Name', 'bounds4'       ,'Length',ncdimlen.bounds4);
   nmcor.dims(2) = struct('Name', 'dim2'          ,'Length',ncdimlen.dim2);
   nmcor.dims(3) = struct('Name', 'dim1'          ,'Length',ncdimlen.dim1);

   % 3D: data product
   nmt.dims(1)   = struct('Name', 'dim2'            ,'Length',ncdimlen.dim2);
   nmt.dims(2)   = struct('Name', 'dim1'            ,'Length',ncdimlen.dim1);
   nmt.dims(3)   = struct('Name', 'time'            ,'Length',ncdimlen.time);

   %% time
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
   %  time is a dimension, so there are two options:
   %  * the variable name needs the same as the dimension
   %    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
   %  * there needs to be an indirect mapping through the coordinates attribute
   %    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
     
      ifld     = 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
      attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc.Variables(ifld) = struct('Name'      , 'time', ...
                                  'Datatype'  , 'double', ...  % !!!! % float not sufficient as datenums are big: double
                                  'Dimensions', time.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);
                                  
   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
   
      ifld     = ifld + 1;clear attr dims
      attr = nc_cf_grid_mapping(OPT.epsg); % will also add KNMI ADAGUC proj4_params
      nc.Variables(ifld) = struct('Name'      , 'crs', ...
                                  'Datatype'  , 'int32', ...
                                  'Dimensions', [], ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []);

   %% Longitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'pixel center longitude');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'lat lon');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lon(:)) max(OPT.lon(:))]);
      if ~(isempty(OPT.lonbounds) | isempty(OPT.latbounds))
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'lonbounds');
      end
      nc.Variables(ifld) = struct('Name'       , 'lon', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nm.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

   %% Latitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'pixel center latitude');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'lat lon');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value',  OPT.fillvalue);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lat(:)) max(OPT.lat(:))]);
      if ~(isempty(OPT.lonbounds) | isempty(OPT.latbounds))
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'latbounds');
      end
      nc.Variables(ifld) = struct('Name'       , 'lat', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nm.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

      if ~(isempty(OPT.lonbounds) | isempty(OPT.latbounds))

   %% Longitude bounds

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'pixel corner longitude');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lon(:)) max(OPT.lon(:))]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'OpenEarth Matlab function nc_cf_bounds2cor.m reshapes it to a regular 2D array');
      nc.Variables(ifld) = struct('Name'       , 'lonbounds', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmcor.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything

   %% Latitude bounds

      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'pixel corner latitude');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value',  OPT.fillvalue);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lat(:)) max(OPT.lat(:))]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'OpenEarth Matlab function nc_cf_bounds2cor.m reshapes it to a regular 2D array');
      nc.Variables(ifld) = struct('Name'       , 'latbounds', ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmcor.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end

%% 3 Create variables

   %% Parameters with standard names
   %  * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   
   %% Define dimensions in this order:
   %  time,z,y,x
   
      if ~isempty(OPT.Name)
      
      OPT.Name          = cellstr(OPT.Name);
      OPT.standard_name = cellstr(OPT.standard_name);
      OPT.long_name     = cellstr(OPT.long_name    );
      OPT.units         = cellstr(OPT.units        );
      
      for ivar=1:length(OPT.Name)
      ifld     = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', OPT.standard_name{ivar}); % sea_surface_elevation
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', OPT.long_name{ivar});
      attr(end+1)  = struct('Name', 'units'        , 'Value', OPT.units{ivar});
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'lat lon time');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
      attr(end+1)  = struct('Name', 'missing_value', 'Value', OPT.fillvalue); % this keyword is required by DINEOF, which does allow NaNs
      attr(end+1)  = struct('Name', 'missing_value_comment', 'Value', 'attr missing_value needed or DINEOF 3.0');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [NaN(OPT.type) NaN(OPT.type)]);
      attr(end+1)  = struct('Name', 'grid_mapping' , 'Value', 'crs');
      
      for iatt=1:2:length(OPT.Attributes)
      attr(end+1)  = struct('Name', OPT.Attributes{iatt}, 'Value', OPT.Attributes{iatt+1});
      end
      
      nc.Variables(ifld) = struct('Name'       , OPT.Name{ivar}, ...
                                  'Datatype'   , OPT.type, ...
                                  'Dimensions' , nmt.dims, ...
                                  'Attributes' , attr,...
                                  'FillValue'  , []); % this doesn't do anything
      end
      end
      
      ifld = ifld + 1;clear attr dims
      attr(    1)  = struct('Name', 'long_name'      ,'Value', 'mask');
      attr(end+1)  = struct('Name', 'units'          ,'Value', '1');
      attr(end+1)  = struct('Name', 'actual_range'   ,'Value', [0 1]);
      attr(end+1)  = struct('Name', 'coordinates'    ,'Value', 'lat lon');
      attr(end+1)  = struct('Name', 'grid_mapping'   ,'Value', 'crs');
      attr(end+1)  = struct('Name', 'flag_values'    ,'Value', [0 1]);
      attr(end+1)  = struct('Name', 'flag_meanings'  ,'Value', 'inactive active');
      attr(end+1)  = struct('Name', '_FillValue'     , 'Value', intmax('int32'));

      nc.Variables(ifld) = struct('Name'       , 'mask', ...
                                  'Datatype'   , 'int32', ...
                                  'Dimensions' , nm.dims, ...
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

      if OPT.debug
      fid = fopen([filepathstrname(ncfile),'.cdl'],'w');
      nc_dump(ncfile,fid);
      fclose(fid);
      end
      
%% 5 Fill variables (always)
%    Data is initialized as NaN due to attribute '_FillValue' in ncwriteschema.
%    This means can just fill only the active Delft3D cells m=[2:end-1] & n=[2:end-1]
%    and leave the inactive dummy cells at =[1 end] & n=[1 end]

      if ~isempty(OPT.time)
      ncwrite   (ncfile,'time'          , OPT.time - OPT.refdatenum);
      end

%% 5 Fill variables (optional)

      ncwrite   (ncfile,'lon'       , double(OPT.lon)');
      ncwrite   (ncfile,'lat'       , double(OPT.lat)');
      ncwriteatt(ncfile,'lon'       ,'actual_range',[min(OPT.lon(:)) max(OPT.lon(:))]);
      ncwriteatt(ncfile,'lat'       ,'actual_range',[min(OPT.lat(:)) max(OPT.lat(:))]);

      ncwrite   (ncfile,'mask'      , double(OPT.mask)');

      if ~(isempty(OPT.lonbounds) | isempty(OPT.latbounds))
      ncwrite   (ncfile,'lonbounds' , permute(nc_cf_cor2bounds(double(OPT.lonbounds)),[3 2 1]));
      ncwrite   (ncfile,'latbounds' , permute(nc_cf_cor2bounds(double(OPT.latbounds)),[3 2 1]));
      ncwriteatt(ncfile,'lonbounds' ,'actual_range',[min(OPT.lonbounds(:)) max(OPT.lonbounds(:))]);
      ncwriteatt(ncfile,'latbounds' ,'actual_range',[min(OPT.latbounds(:)) max(OPT.latbounds(:))]);
      end

      if OPT.debug
        nc_dump(ncfile)
      end