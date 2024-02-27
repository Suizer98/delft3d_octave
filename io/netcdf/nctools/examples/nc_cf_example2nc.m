function nc_cf_example2nc(varargin)
%%NC_CF_EXAMPLE2NC   example script to make a netCDF file according to CF convention
%
%   Creates an example netCDF file 'nc_cf_example2nc' that allows one to
%   assess the advantages of netCDF with: nc_dump(.m) and <a href="http://www.epic.noaa.gov/java/ncBrowse/">ncBrowse</a>
%
%See also: NC_CF_EXAMPLE2NCPLOT
%          time series:  knmi_potwind2nc, knmi_etmgeg2nc, getWaterbase2nc
%          grids:        knmi_noaapc2nc
%          points:      
%          linesegments:
%          transects:

%% Define copyright of this script
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben J. de Boer
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

%% Add SVN keyword and store this script in a repository
%  $Id: nc_cf_example2nc.m 2616 2010-05-26 09:06:00Z geer $
%  $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
%  $Author: geer $
%  $Revision: 2616 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/examples/nc_cf_example2nc.m $
%  $Keywords$

%% Set default options, and overrule with user defined keyword,value pairs
   OPT.refdatenum = datenum(1970,1,1);
   OPT.fillvalue  = nan;
   OPT.filename   = 'nc_cf_example2nc.inp';
   
   OPT = setproperty(OPT,varargin);

%% 0. Read raw data
% Make a function that returns all data + meta-data in one struct, e.g.:
%
%  * D             = knmi_potwind(OPT.filename);
%  * D             = knmi_etmgeg (OPT.filename);
%  * D             = donar_read  (OPT.filename);
%  
% Below is just a example taht creates soem ranodm ata:

   D.datenum     = floor(now) + [0:2:24]./24;
   D.version     = 0;
   D.lat         = [ 4  5  6];
   D.lon         = [52 53 54 55];
   D.temperature = repmat(nan,[length(D.datenum) length(D.lat) length(D.lon)]);
   for i=1:length(D.datenum)
   for j=1:length(D.lat)
   for k=1:length(D.lon)
      D.temperature(i,j,k) = i.^2 + (D.lat(j).^2 + D.lon(k));
   end
   end
   end
   D.timezone    = '+00:00';

%% 1. Create file
   outputfile = [filename(OPT.filename),'.nc'];
   nc_create_empty (outputfile); % only change extension with respect to input file

%% 2. Add overall meta info

   %%  CF convention   
   % <http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents>

   nc_attput(outputfile, nc_global, 'title'         , '');
   nc_attput(outputfile, nc_global, 'institution'   , 'Deltares');
   nc_attput(outputfile, nc_global, 'source'        , '');
   % Insert SVN keyword $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/examples/nc_cf_example2nc.m $ that will list the url of this mfile. This
   % approach automatically ensures that the name of the script that made
   % the netCDF file is included in the netCDF file itself.
   nc_attput(outputfile, nc_global, 'history'       , ['tranformation to NetCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/examples/nc_cf_example2nc.m $']);
   % Provide web-link to originator of dataset (can be url in OpenEarthRawData).
   nc_attput(outputfile, nc_global, 'references'    , '<http://openearth.deltares.nl>');
   nc_attput(outputfile, nc_global, 'email'         , '');
   
   nc_attput(outputfile, nc_global, 'comment'       , '');
   nc_attput(outputfile, nc_global, 'version'       , D.version);
						    
   nc_attput(outputfile, nc_global, 'Conventions'   , 'CF-1.4');
   nc_attput(outputfile, nc_global, 'CF:featureType', 'stationTimeSeries');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
   %%  OpenEarth convention

   nc_attput(outputfile, nc_global, 'terms_for_use' , 'These data can be used freely for research purposes provided that the following source is acknowledged: KNMI.');
   nc_attput(outputfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2. Create dimensions

   nc_add_dimension(outputfile, 'time'  , length(D.datenum))
   nc_add_dimension(outputfile, 'lat'   , length(D.lat))
   nc_add_dimension(outputfile, 'lon'   , length(D.lon))

%% 3. Create variables

   clear nc
   ifld = 0;
   
   %%% Define dimensions in this order: [time,z,y,x]
   %
   % * For standard names vocabulary by CF group see:
   %   <http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table>
   %   From this list the following quantities are used in this mfule:
   %   contains: latitude, longitude
   % * For standard units vocabulary UDUNITS by UNIDATA see:
   %   <http://www.unidata.ucar.edu/software/udunits/>

   %%% Latitude
   % Prescribed as dimension associated with variable by CF convention in:
   % <http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate>
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lat';   % This name is required when extracing the data with nc_varget(,'lat').
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'lat'}; % Should conform with dimension lat defined above
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');      % Name free of choice, will appear in plots
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north'); % Note: 1st type of degrees, chosen from UDUNITS list.
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');      % Prescribed by CF convention and CF standard name table.

   %%% Longitude
   % Prescribed as dimension associated with variable by CF convention in:
   % <http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate>
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lon';   % This name is required when extracing the data with nc_varget(,'lat').
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'lon'}; % Should conform with dimension lat defined above
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');    % Name free of choice, will appear in plots
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east'); % Note: 2nd type of degrees, chosen from UDUNITS list.
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');    % Prescribed by CF convention and CF standard name table.

   %%% local x
   % Should be associated with a coordinate system.
  
      ifld = ifld + 1;
   nc(ifld).Name         = 'x';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'lat'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'x');                       % Name free of choice, will appear in plots
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'meter');                   % Chosen from UDUNITS list.
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % Prescribed by CF standard name table.


   %%% local y
   % Should be associated with a coordinate system.
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'y';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'lon'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'y');                       % Name free of choice, will appear in plots
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'meter');                   % Chosen from UDUNITS list.
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate'); % Prescribed by CF standard name table.

   %%% Time
   % <http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate>
   % 
   % time is a dimension, so there are two options:
   %
   % * The variable name needs the same as the dimension
   %   <http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551>
   %
   % * There needs to be an indirect mapping through the coordinates attribute
   %   <http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605>
   
   OPT.timezone = timezone_code2iso(D.timezone);

      ifld = ifld + 1;
   nc(ifld).Name         = 'time';
   nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
   nc(ifld).Dimension    = {'time'}; % {'locations','time'} % does not work in ncBrowse, nor in Quickplot (is indirect time mapping)
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value',['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
  %nc(ifld).Attribute(5) = struct('Name', 'bounds'         ,'Value', '');
   
  %%% Parameters with standard names
  % * <http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/>

      ifld = ifld + 1;
   nc(ifld).Name         = 'T';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'time','lat','lon'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'air temperature');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_Celsius'); % Note: 3rd type of degrees
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'air_temperature');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);

%% 4 Create variables with attibutes
% When variable definitons are created before actually writing the
% data in the next cell, netCDF can nicely fit all data into the
% file without the need to relocate any info. So there is no 
% need to use NC_PADHEADER.

   for ifld=1:length(nc)
      disp(['Adding :',num2str(ifld),' ',nc(ifld).Name])
      nc_addvar(outputfile, nc(ifld));   
   end
   
%% 5 Fill variables

   nc_varput(outputfile, 'time' , D.datenum-OPT.refdatenum);
   nc_varput(outputfile, 'lat'  , D.lat);
   nc_varput(outputfile, 'lon'  , D.lon);
   nc_varput(outputfile, 'T'    , D.temperature);

%% 6 Check

   nc_dump(outputfile);
   
%% For more information see: <OpenEarth.Deltares.nl>
