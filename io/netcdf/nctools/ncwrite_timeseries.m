function varargout = ncwrite_timeseries(ncfile,varargin)
%NCWRITE_timeseries write timeseries to netCDF-CF file
%
%  Make a netCDF file with CF conventions of a variable that 
%  is a timeseries at one specific target location.
%  In this special case the main dimension are:
%  * a 1D [time] axis
%  * a 1D [stations] axis
% which allow a 2D variable [stations x time] to be written.
% The resulting files open as history files in Delft3D-QuickPlot.
%
%  This case is described in:
%  CF:   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%  GOOS: http://www.oceansites.org/docs/oceansites_user_manual_version1.2.pdf
%  SDN:  http://www.seadatanet.org/Standards-Software/Data-Transport-Formats
%
%See also: netcdf, ncwriteschema, ncwrite, 
%          ncwritetutorial_grid_lat_lon_curvilinear
%          ncwrite_trajectory, ncwrite_profile
%          ncwrite_timeseries_tutorial

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id: ncwrite_timeseries.m 8921 2013-07-19 06:13:40Z boer_g $
%  $Date: 2013-07-19 08:13:40 +0200 (Fri, 19 Jul 2013) $
%  $Author: boer_g $
%  $Revision: 8921 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwrite_timeseries.m $
%  $Keywords: $

% contant z (binned) or varying z (ragged arrays)

%% Required spatio-temporal fields

   OPT.title          = '';
   OPT.institution    = '';
   OPT.version        = '';
   OPT.references     = '';
   OPT.email          = '';
   
   OPT.platform_names = '<required 1D(t) platform matrix>';
   OPT.var            = '<required 1D(t) variable matrix [station x time]>';
   OPT.datenum        = []; % <required 1D(t) time vector [time]>
   OPT.lon            = []; % <required 1D(t) position of station [1]>
   OPT.lat            = []; % <required 1D(t) position of station [1]>
   OPT.x              = []; % <required 1D(t) position of station [1]>
   OPT.y              = []; % <required 1D(t) position of station [1]>
   
%% Required data fields
   
   OPT.Name           = 'variable_name';
   OPT.standard_name  = '<CF standard name>';
   OPT.long_name      = '<long name>';
   OPT.units          = '<units>';
   OPT.Attributes     = {'sdn_parameter_urn','','sdn_parameter_name','','sdn_uom_urn','','sdn_uom_name',''}; % SDN/BODC/EMODnet
   OPT.global         = {'title','','references','','email','','source','','comment','','version',''}; % CF

%% Required settings

   OPT.Format         = 'classic'; % '64bit','classic','netcdf4','netcdf4_classic'
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention
   OPT.fillvalue      = typecast(uint8([0    0    0    0    0    0  158   71]),'DOUBLE'); % ncetcdf default that is also recognized by ncBrowse % DINEOF does not accept NaNs; % realmax('single'); %
   OPT.timezone       = timezone_code2iso('GMT');

   if nargin==0;
       varargout = {OPT};return
   end
   OPT      = setproperty(OPT,varargin);

   if verLessThan('matlab','7.12.0.635')
      error('At least Matlab release R2011a is required for writing netCDF files due tue NCWRITESCHEMA.')
   end

   nc = struct('Name','/','Format','classic');

%% CF attributes: add overall meta info: http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#description-of-file-contents
%  for ncISO extent see below

   nc.Attributes(1    ) = struct('Name','institution'        ,'Value',  OPT.institution);
   nc.Attributes(end+1) = struct('Name','history'            ,'Value',  '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwrite_timeseries.m $ $Id: ncwrite_timeseries.m 8921 2013-07-19 06:13:40Z boer_g $');
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'TimeSeries');
   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6, OceanSITES 1.1');
   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% mandatory oceansites atts: http://www.oceansites.org/documents/index.html
%  http://www.oceansites.org/docs/oceansites_user_manual.pdf
%  for ncISO extent see below

   nc.Attributes(end+1) = struct('Name','data_type'          ,'Value',  'OceanSITES time-series data');
   nc.Attributes(end+1) = struct('Name','format_version'     ,'Value',  '1.1');
   nc.Attributes(end+1) = struct('Name','platform_code'      ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','date_update'        ,'Value',  '$Date$');
   nc.Attributes(end+1) = struct('Name','site_code'          ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','data_mode'          ,'Value',  'D');
   nc.Attributes(end+1) = struct('Name','area'               ,'Value',  'North Sea');

%% user-defined

   for iatt=1:2:length(OPT.global)
   nc.Attributes(end+1)  = struct('Name', OPT.global{iatt}, 'Value', OPT.global{iatt+1});
   end

%% 2 Create dimensions

   if ischar(OPT.platform_names);OPT.platform_names = cellstr(OPT.platform_names);end

   ncdimlen.time        = length(OPT.datenum);
   ncdimlen.location    = length(OPT.platform_names);
   ncdimlen.string_len  = size(char(OPT.platform_names),2);
   
   extent.lon = [min(OPT.lon(:)) max(OPT.lon(:))];
   extent.lat = [min(OPT.lat(:)) max(OPT.lat(:))];

   nc.Dimensions(    1) = struct('Name','time'            ,'Length',ncdimlen.time      );
   nc.Dimensions(end+1) = struct('Name','location'        ,'Length',ncdimlen.location  );
   nc.Dimensions(end+1) = struct('Name','string_len'      ,'Length',ncdimlen.string_len);
      
%% 3a Create (primary) variables: time

   ifld     = 1;clear attr dims
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
   attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),OPT.timezone]);
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
   extent.time = [min(OPT.datenum(:)) max(OPT.datenum(:))];
   
   nc.Variables(ifld) = struct('Name'       , 'time', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'time','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
%% 3b Create (primary) variables: space

   if ~(isempty(OPT.lon) | isempty(OPT.lat))
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude of platform');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lon);
   nc.Variables(ifld) = struct('Name'       , 'lon', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'location','Length',ncdimlen.location), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude of platform');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lat);
   nc.Variables(ifld) = struct('Name'       , 'lat', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'location','Length',ncdimlen.location), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   end                           
                           
   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'platform_name');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'platform name');
   dims(    1)  = struct('Name', 'string_len','Length',ncdimlen.string_len);
   dims(    2)  = struct('Name', 'location'  ,'Length',ncdimlen.location);
   nc.Variables(ifld) = struct('Name'      , 'platform_name', ...
                               'Datatype'  , 'char', ...
                               'Dimensions', dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'platform_id');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'platform id');
   attr(end+1)  = struct('Name', 'cf_role'      , 'Value', 'timeseries_id');
   % Where feasible a variable with the attribute cf_role should be included.
   % The only acceptable values of cf_role for Discrete Geometry CF data sets
   % are timeseries_id, profile_id, and trajectory_id.The variable carrying
   % the cf_role attribute may have any data type. When a variable is assigned
   % this attribute, it must provide a unique identifier for each feature instance.
   % CF files that contain timeSeries, profile or trajectory featureTypes,
   % should include only a single occurrence of a cf_role attribute;
   % CF files that contain timeSeriesProfile or trajectoryProfile may
   % contain two occurrences, corresponding to the two levels of structure
   % in these feature types: cf_role	timeseries_id
   dims(    1)  = struct('Name', 'string_len','Length',ncdimlen.string_len);
   dims(    2)  = struct('Name', 'location'  ,'Length',ncdimlen.location);
   nc.Variables(ifld) = struct('Name'      , 'platform_id', ...
                               'Datatype'  , 'char', ...
                               'Dimensions', dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           

   if ~(isempty(OPT.x) | isempty(OPT.y))
                           ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'x of platform');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lon);
   nc.Variables(ifld) = struct('Name'       , 'x', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'location','Length',ncdimlen.location), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'y of platform');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lat);
   nc.Variables(ifld) = struct('Name'       , 'y', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'location','Length',ncdimlen.location), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   end                  
                              
%% 3c Create (primary) variables: data
                              
   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name', 'Value', OPT.standard_name);
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', OPT.long_name);
   attr(end+1)  = struct('Name', 'units'        , 'Value', OPT.units);
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'lat lon platform_name'); % platform_name needed to sdhow up in QuickPlot
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.var(:)) max(OPT.var(:))]);
      
   for iatt=1:2:length(OPT.Attributes)
   attr(end+1)  = struct('Name', OPT.Attributes{iatt}, 'Value', OPT.Attributes{iatt+1});
   end

   dims(1) = struct('Name', 'location','Length',ncdimlen.location);
   dims(2) = struct('Name', 'time'    ,'Length',ncdimlen.time    );
   nc.Variables(ifld) = struct('Name'       , OPT.Name, ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);                              
                              
%% 4 Create netCDF file

%% ISO extent discovery meta-data: http://wiki.esipfed.org/index.php/Attribute_Convention_for_Data_Discovery_%28ACDD%29
   
   nc.Attributes(end+1) = struct('Name','time_coverage_start'    ,'Value',  datestr(extent.time(1),30));
   nc.Attributes(end+1) = struct('Name','time_coverage_end'      ,'Value',  datestr(extent.time(2),30));
   if ~isempty(OPT.lon)
   nc.Attributes(end+1) = struct('Name','geospatial_lat_min'     ,'Value',  extent.lon(1));
   nc.Attributes(end+1) = struct('Name','geospatial_lat_max'     ,'Value',  extent.lon(2));
   nc.Attributes(end+1) = struct('Name','geospatial_lon_min'     ,'Value',  extent.lat(1));
   nc.Attributes(end+1) = struct('Name','geospatial_lon_max'     ,'Value',  extent.lat(2));
   end

   try;if exist(ncfile);delete(ncfile);end;end
   disp([mfilename,': NCWRITESCHEMA: creating netCDF file: ',ncfile])
   %var2evalstr(nc)
   ncwriteschema(ncfile, nc);			        
   disp([mfilename,': NCWRITE: filling  netCDF file: ',ncfile])
      
%% 5 Fill variables

   ncwrite   (ncfile,'time'         , OPT.datenum - OPT.refdatenum);
   
   if ~(isempty(OPT.lon) | isempty(OPT.lat))
   ncwrite   (ncfile,'lon'          , OPT.lon);
   ncwrite   (ncfile,'lat'          , OPT.lat);
   end
   if ~(isempty(OPT.x) | isempty(OPT.y))
   ncwrite   (ncfile,'x'            , OPT.x);
   ncwrite   (ncfile,'y'            , OPT.y);
   end
   ncwrite   (ncfile,'platform_name', char(OPT.platform_names)');
   ncwrite   (ncfile,'platform_id'  , char(OPT.platform_names)');
   ncwrite   (ncfile,OPT.Name       , OPT.var);
      
%% test and check

   nc_dump(ncfile,[],strrep(ncfile,'.nc','.cdl'))
   clear variable ncdimlen nc
