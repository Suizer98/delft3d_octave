function varargout = ncwrite_trajectory(ncfile,varargin)
%NCWRITE_TRAJECTORY write trajectory to netCDF-CF file
%
%  Make a netCDF file with CF conventions of a variable that 
%  is a trajectory gathered by a moving vessel with FerryBox (fixex z, 2D)
%  or glider (varying z, 3D). In this special case the main dimension are:
%  * a 1D time axis
%
%  This case is described in:
%  CF:   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%  GOOS: http://www.oceansites.org/docs/oceansites_user_manual_version1.2.pdf
%  SDN:  http://www.seadatanet.org/Standards-Software/Data-Transport-Formats
%
%See also: netcdf, ncwriteschema, ncwrite, 
%          ncwritetutorial_grid_lat_lon_curvilinear
%          ncwrite_timeseries, ncwrite_profile
%          ncwrite_trajectory_tutorial

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
   
   OPT.var            = '<required 1D(t) variable matrix>';
   OPT.datenum        = '<required 1D(t) time vector>';
   OPT.lon            = '<required 1D(t) position of ship>';
   OPT.lat            = '<required 1D(t) position of ship>';
   OPT.z              = '<required 1D(t) or 0D position of sensor>';
   
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
   
   if isempty(OPT.Name)
       error('Name is empty')
   end

   nc = struct('Name','/','Format','classic');

%% CF attributes: add overall meta info: http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#description-of-file-contents
%  for ncISO extent see below

   nc.Attributes(1    ) = struct('Name','institution'        ,'Value',  OPT.institution);
   nc.Attributes(end+1) = struct('Name','history'            ,'Value',  '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwrite_timeseries.m $ $Id: ncwrite_timeseries.m 8921 2013-07-19 06:13:40Z boer_g $');
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'trajectory');
   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6, OceanSITES 1.1');
   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% mandatory oceansites atts: http://www.oceansites.org/documents/index.html
%  http://www.oceansites.org/docs/oceansites_user_manual.pdf
%  for ncISO extent see below

   nc.Attributes(end+1) = struct('Name','data_type'          ,'Value',  'OceanSITES trajectory data');
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

   ncdimlen.time        = length(OPT.var(:));
   nc.Dimensions(    1) = struct('Name','TIME'            ,'Length',ncdimlen.time      );
   extent.z   = [min(OPT.z(:))   max(OPT.z(:))  ];
   extent.lon = [min(OPT.lon(:)) max(OPT.lon(:))];
   extent.lat = [min(OPT.lat(:)) max(OPT.lat(:))];
   
%% 3a Create (primary) variables: time

   ifld     = 1;clear attr dims
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
   attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),OPT.timezone]);
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
   extent.time = [min(OPT.datenum(:)) max(OPT.datenum(:))];
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [datestr(extent.time(1),31),char(9),datestr(extent.time(2),31)]);
   
   nc.Variables(ifld) = struct('Name'       , 'TIME', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'TIME','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
%% 3b Create (primary) variables: space

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'lat lon');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lon);
   nc.Variables(ifld) = struct('Name'       , 'lon', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'TIME','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'lat lon');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.lat);
   nc.Variables(ifld) = struct('Name'       , 'lat', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'TIME','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);    

%% 3c Create (primary) variables: vertical

   variable.dims(1) = struct('Name', 'TIME','Length',ncdimlen.time);
   z0 = nanunique(OPT.z(~isnan(OPT.z)));
if length(z0)>1 % varying z
   variable.coordinates = 'lat lon z'; % z does not work in QuickPlot
   variable.coordinates = 'lat lon'  ; % does not work yet in QuickPlot
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'altitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'z');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', variable.coordinates);
   attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Z');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.z);
   nc.Variables(ifld) = struct('Name'       , 'z', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'TIME','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
else % fixed z
   OPT.z = z0; 
   ncdimlen.z           = 1;
   nc.Dimensions(    2) = struct('Name','z'               ,'Length',ncdimlen.z         );
   variable.dims(2) = struct('Name', 'z'   ,'Length',ncdimlen.z   );
   variable.coordinates = 'lat lon';
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'altitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'z');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Z');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', extent.z);
   nc.Variables(ifld) = struct('Name'       , 'z', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'z','Length',ncdimlen.z), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
end
                           
%% 3c Create (primary) variables: data
                              
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
   disp([mfilename,': NCWRITE: filling  netCDF file: ',ncfile])
      
%% 5 Fill variables

   ncwrite   (ncfile,'TIME'         , OPT.datenum(:) - OPT.refdatenum);
   ncwrite   (ncfile,'lon'          , OPT.lon(:));
   ncwrite   (ncfile,'lat'          , OPT.lat(:));
   ncwrite   (ncfile,'z'            , OPT.z(:));
   ncwrite   (ncfile,OPT.Name       , OPT.var(:));
      
%% test and check

   nc_dump(ncfile,[],strrep(ncfile,'.nc','.cdl'))
   clear variable ncdimlen nc