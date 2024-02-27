function varargout = ncwrite_profile(ncfile,varargin)
%NCWRITE_PROFILE write (ADCP) timeSeriesProfile to netCDF-CF file
%
%  Make a netCDF file with CF conventions of a variable that 
%  is a timeSeriesProfile at one specific target location.
%  In this special case the main dimension are:
%  * a 1D z axis which can usually differs per profile. Therefore
%    a 2D array [t,z] of z values is stored, with the same size as the data.
%  * a 1D time axis or unique profile counter axis. For profiles
%    that take very long to gather, i.e. when a CTD is dangling under
%    a vessel for a while, the time vector is 2D [t,z] too, with the same
%   size as the data.
%
%  This case is described in:
%  CF:   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%  GOOS: http://www.oceansites.org/docs/oceansites_user_manual_version1.2.pdf
%  SDN:  http://www.seadatanet.org/Standards-Software/Data-Transport-Formats
%
%See also: netcdf, ncwriteschema, ncwrite, 
%          ncwritetutorial_grid_lat_lon_curvilinear
%          ncwrite_timeseries, ncwrite_trajectory
%          ncwrite_profile_tutorial

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
   
   OPT.var            = '<required 2D(t,z) variable (ragged) matrix>';
   OPT.datenum1       = '<required 1D(  t) time vector>';
   OPT.z1             = '<required either 1D(  z) z vector>';
   OPT.z2             = '<required ... or 2D(t,z) z ragged matrix, with unique values per profile>';

   OPT.lon0           = '<required either 0D(1) nominal position>';
   OPT.lon1           = '<required and/or 1D(t) drift position of ship>';

   OPT.lat0           = '<required either 0D(1) nominal position>';
   OPT.lat1           = '<required and/or 1D(t) drift position of ship>';
   
   % Recording the time and position during lowering of a CTD is usually neglected,
   % even for deep ocean CTD cast covering a few km in a few hours.
   % However, when a CTD frame is used as a glider or FerryBox, e.g. for
   % cross calibration purposes, . dangling for a long time (datenum2) under a moored ship 
   % or even dangling behind a moving ship (lon2, lat2) these matrices can be recorded too. 
   % The Dutch Rijkswatwerstaat DONAR database keeps these values, so we copy them to allow
   % lossless 2-way mapping between DONAR and netCDF.

   OPT.datenum2       = '<not-recommended 2D(t,z) time position, unique values per profile registering free fall time>';
   OPT.lon2           = '<not-recommended 2D(t,z) drift and fall position of ship>';
   OPT.lat2           = '<not-recommended 2D(t,z) drift and fall position of ship>';

%% Required data fields
   
   OPT.Name           = 'variable name';
   OPT.standard_name  = '<CF standard name>';
   OPT.long_name      = '<long name>';
   OPT.units          = '<units>';
   OPT.Attributes     = {'sdn_parameter_urn','','sdn_parameter_name','','sdn_uom_urn','','sdn_uom_name',''};
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
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'timeSeriesProfile');
   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6, OceanSITES 1.1');
   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% mandatory oceansites atts: http://www.oceansites.org/documents/index.html
%  http://www.oceansites.org/docs/oceansites_user_manual.pdf
%  for ncISO extent see below

   nc.Attributes(end+1) = struct('Name','data_type'          ,'Value',  'OceanSITES profile data');
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
%    Standard names for OceanSITES dimensions should be in upper case: TIME and DEPTH for profiles

   ncdimlen.time        = length(OPT.datenum1);
   nc.Dimensions(1)     = struct('Name','TIME'      ,'Length', ncdimlen.time);
   nc.Dimensions(2)     = struct('Name','LATITUDE'  ,'Length', 1); % oceansites
   nc.Dimensions(3)     = struct('Name','LONGITUDE' ,'Length', 1); % oceansites
   variable.coordinates = 'LATITUDE LONGITUDE';
   
%% 3a Create (primary) variables: time

   ifld     = 1;clear attr dims
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
   attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),OPT.timezone]);
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
   
   nc.Variables(ifld) = struct('Name'       , 'TIME', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'TIME','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
%% 3a Create (primary) variables: vertical

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'altitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Z');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'reference'    , 'Value', 'sea_level'); % oceansites: is "sea_level","mean_sea_level","mean_lower_low_water","wgs84_geoid"
   
if (isempty(OPT.z2) | ischar(OPT.z2)) & ...
   (isempty(OPT.z1) | ischar(OPT.z1))

   error('specify either 1D or 2D z matrix')

elseif (isempty(OPT.z2) | ischar(OPT.z2)) | ...% constant (binned) z per profile, 
       size(OPT.z2,2)==1                       % or contains just 1 profile
       
   if size(OPT.z2,2)==1
      OPT.z1 = OPT.z2;
   end

   ncdimlen.z           = length(OPT.z1);
   nc.Dimensions(4)     = struct('Name','DEPTH','Length', ncdimlen.z);
   variable.dims(1)     = nc.Dimensions(4); % CF: time as 1st dimension (= last in native matlab)
   variable.dims(2)     = nc.Dimensions(1);
   
   extent.z = [min(OPT.z1(:)) max(OPT.z1(:))];
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'z bins');
   attr(end+1)  = struct('Name', 'actual_range'  ,'Value' , extent.z);
   nc.Variables(ifld) = struct('Name'       , 'DEPTH', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'DEPTH','Length',ncdimlen.z), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
else % unique z per profile: ragged-array: dimension(z)=just an index

   ncdimlen.z           = size(OPT.z2,1);
   nc.Dimensions(4)     = struct('Name','DEPTH'     ,'Length', ncdimlen.z);
   variable.dims(1)     = nc.Dimensions(4); % CF: time as 1st dimension (= last in native matlab)
   variable.dims(2)     = nc.Dimensions(1);

   variable.coordinates = [variable.coordinates ' DEPTH2'];
   extent.z = [min(OPT.z2(:)) max(OPT.z2(:))];
   attr(end+1)  = struct('Name', 'long_name'    ,'Value', 'z');
   attr(end+1)  = struct('Name', 'actual_range' ,'Value' , extent.z);
   attr(end+1)  = struct('Name', 'coordinates'  ,'Value' , variable.coordinates);
   nc.Variables(ifld) = struct('Name'       , 'DEPTH2', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , variable.dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);   

end

if ~(isempty(OPT.datenum2) | ischar(OPT.datenum2))                           
                           
   variable.coordinates = [variable.coordinates ' time2'];                           
                           
   extent.time = [min(OPT.datenum2(:)) max(OPT.datenum2(:))];
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
   attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),OPT.timezone]);
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', variable.coordinates);
   
   nc.Variables(ifld) = struct('Name'       , 'time2', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , variable.dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
else
   extent.time = [min(OPT.datenum1(:)) max(OPT.datenum1(:))];

end
                           
%% 3c Create (primary) variables: space

if ~isempty(OPT.lon0) & ~isempty(OPT.lat0)
   extent.lon = [min(OPT.lon0(:)) max(OPT.lon0(:))];    
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'nominal Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lon);
   nc.Variables(ifld) = struct('Name'       , 'LONGITUDE', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , {[]}, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   extent.lat = [min(OPT.lat0(:)) max(OPT.lat0(:))];
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'nominal Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lat);
   nc.Variables(ifld) = struct('Name'       , 'LATITUDE', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , {[]}, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);    
end

if ~isempty(OPT.lon1) & ~isempty(OPT.lat1)
    
   extent.lon = [min(OPT.lon1(:)) max(OPT.lon1(:))];
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'drift Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lon);
   nc.Variables(ifld) = struct('Name'       , 'lon1', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'TIME','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
   extent.lat = [min(OPT.lat1(:)) max(OPT.lat1(:))];
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'drift Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lat);
   nc.Variables(ifld) = struct('Name'       , 'lat1', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'TIME','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);    
end

if ~(isempty(OPT.lon2)| ischar(OPT.lon2)) & ...
   ~(isempty(OPT.lat2)| ischar(OPT.lon2)) % needs OPT.z2 ?

   extent.lon = [min(OPT.lon2(:)) max(OPT.lon2(:))];
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'drift and fall Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lon);
   nc.Variables(ifld) = struct('Name'       , 'lon2', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , variable.dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
   extent.lat = [min(OPT.lat2(:)) max(OPT.lat2(:))];
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'drift and fall Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lat);
   nc.Variables(ifld) = struct('Name'       , 'lat2', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , variable.dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
end                               
                           
%% 3d Create (primary) variables: data

   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name', 'Value', OPT.standard_name);
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', OPT.long_name);
   attr(end+1)  = struct('Name', 'units'        , 'Value', OPT.units);
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', variable.coordinates);
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.var(:)) max(OPT.var(:))]);
      
   for iatt=1:2:length(OPT.Attributes)
   attr(end+1)  = struct('Name', OPT.Attributes{iatt}, 'Value', OPT.Attributes{iatt+1});
   end
   
   nc.Variables(ifld) = struct('Name'       , OPT.Name, ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , variable.dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);                              
                              
%% 4 Create netCDF file


%% ISO extent discovery meta-data: http://wiki.esipfed.org/index.php/Attribute_Convention_for_Data_Discovery_%28ACDD%29
   
   nc.Attributes(end+1) = struct('Name','time_coverage_start'    ,'Value',  datestr(extent.time(1),30));
   nc.Attributes(end+1) = struct('Name','time_coverage_end'      ,'Value',  datestr(extent.time(2),30));
   nc.Attributes(end+1) = struct('Name','geospatial_lat_min'     ,'Value',  extent.lon(1));
   nc.Attributes(end+1) = struct('Name','geospatial_lat_max'     ,'Value',  extent.lon(2));
   nc.Attributes(end+1) = struct('Name','geospatial_lon_min'     ,'Value',  extent.lat(1));
   nc.Attributes(end+1) = struct('Name','geospatial_lon_max'     ,'Value',  extent.lat(2));
   nc.Attributes(end+1) = struct('Name','geospatial_vertical_min','Value',  extent.z(1));
   nc.Attributes(end+1) = struct('Name','geospatial_vertical_max','Value',  extent.z(2));

   try;delete(ncfile);end
   disp([mfilename,': NCWRITESCHEMA: creating netCDF file: ',ncfile])
   %var2evalstr(nc)
   ncwriteschema(ncfile, nc);			        
   disp([mfilename,': NCWRITE      : filling  netCDF file: ',ncfile])
      
%% 5 Fill variables

   ncwrite   (ncfile,OPT.Name       , OPT.var);
   ncwrite   (ncfile,'TIME'         , OPT.datenum1 - OPT.refdatenum);

if     isempty(OPT.z2) | ischar(OPT.z2) | size(OPT.z2,2)==1
   ncwrite   (ncfile,'DEPTH'        , OPT.z1(:));
else
   ncwrite   (ncfile,'DEPTH2'       , OPT.z2  );
end

%% 0D target
if     ~ischar(OPT.lon0) | ~ischar(OPT.lon0)
   ncwrite   (ncfile,'LONGITUDE'    , OPT.lon0(:));
   ncwrite   (ncfile,'LATITUDE'     , OPT.lat0(:));
end

%% 1D realized profile start position
if     ~isempty(OPT.lon1) | ~ischar(OPT.lon1)
   ncwrite   (ncfile,'lon1'         , OPT.lon1(:));
   ncwrite   (ncfile,'lat1'         , OPT.lat1(:));
end

%% 2D ferrybox/scanfish coordinates
if ~(isempty(OPT.lon2)| ischar(OPT.lon2)) & ...
   ~(isempty(OPT.lat2)| ischar(OPT.lon2))
   ncwrite   (ncfile,'lon2'         , OPT.lon2);
   ncwrite   (ncfile,'lat2'         , OPT.lat2);
end

      
%% test and check

   nc_dump(ncfile,[],strrep(ncfile,'.nc','.cdl'))
   clear variable ncdimlen nc
