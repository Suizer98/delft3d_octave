function knmi_uurgeg2nc(varargin)
%KNMI_UURGEG2NC  transforms directory of uurgeg ASCII files into directory of netCDF files
%
%     knmi_uurgeg2nc(<keyword,value>) 
%
%  where the following <keyword,value> pairs have been implemented:
%
%   * fillvalue      (default nan)
%   * dump           whether to check nc_dump on matlab command line after writing file (default 0)
%   * directory_raw  directory where to get the raw data from (default [])
%   * directory_nc   directory where to put the nc data to (default [])
%   * mask           file mask (default 'potwind*')
%   * refdatenum     default (datenum(1970,1,1))
%   * ext            extension to add to the files before *.nc (default '')
%   * pause          pause between files (default 0)
%
% Example:
%  knmi_uurgeg2nc ('directory_raw','P:\mcdata\OpenEarthRawData\knmi\uurgeg\raw\',...
%                  'directory_nc', 'P:\mcdata\opendap\knmi\uurgeg\')
%
%  Timeseries data definition:
%   * https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions (full definition)
%   * http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788 (simple)
%
% In this example time is both a dimension and a variables.
% The actual datenum values do not show up as a parameter in ncBrowse.
%
%See also: KNMI_uurgeg, SNCTOOLS, KNMI_uurgeg_GET_URL, KNMI_POTWIND2NC_TIME_DIRECT

% based on knmi_etmgeg2nc.m

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: knmi_uurgeg2nc.m 8630 2013-05-16 13:05:00Z boer_g $
% $Date: 2013-05-16 21:05:00 +0800 (Thu, 16 May 2013) $
% $Author: boer_g $
% $Revision: 8630 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_uurgeg2nc.m $
% $Keywords: $

%% Initialize

   OPT.dump              = 0;
   OPT.disp              = 0;
   OPT.pause             = 0;

   OPT.refdatenum        = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum        = datenum(1970,1,1); % lunix  datenumber convention
   OPT.timezone          = timezone_code2iso('GMT');
   OPT.fillvalue         = NaN; % NaNs do work in netcdf API

%% File loop

   OPT.directory_raw     = 'F:\checkouts\OpenEarthRawData\knmi\uurgeg\raw\';%[]; %
   OPT.directory_nc      = 'F:\checkouts\opendap\knmi\uurgeg\';             %[]; %
   OPT.mask              = 'uurgeg*';
   OPT.ext               = '';
   
%% Keyword,value

   OPT = setproperty(OPT,varargin{:});

%% File loop

   OPT.files         = dir([OPT.directory_raw,filesep,OPT.mask]);

for ifile=1:length(OPT.files)  

   OPT.filename = [OPT.directory_raw, filesep, OPT.files(ifile).name]; % e.g. 'uurgeg_273.txt'

   disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])

%% 0 Read raw data

   D                                = knmi_uurgeg(OPT.filename);
   D.version                        = '';

%% 1a Create file

   outputfile    = [OPT.directory_nc filesep  filename(D.file.name),OPT.ext,'.nc'];
   
   if ~exist(fileparts(outputfile))
      mkpath(fileparts(outputfile))
   end
   
   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   %------------------

   nc_attput(outputfile, nc_global, 'title'         , 'daily averaged meteo parameter.');
   nc_attput(outputfile, nc_global, 'institution'   , 'KNMI');
   nc_attput(outputfile, nc_global, 'source'        , 'surface observation');
   nc_attput(outputfile, nc_global, 'history'       , ['Original filename: ',filename(D.file.name),...
                                                       ', version:' ,D.version,...
                                                       ', filedate:',D.file.date,...
                                                       ', tranformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_uurgeg2nc.m $ $Revision: 8630 $ $Date: 2013-05-16 21:05:00 +0800 (Thu, 16 May 2013) $ $Author: boer_g $']);
   nc_attput(outputfile, nc_global, 'references'    , '<http://www.knmi.nl/klimatologie/daggegevens/download.html>,<http://openearth.deltares.nl>');
   nc_attput(outputfile, nc_global, 'email'         , 'http://www.knmi.nl/contact/emailformulier.htm?klimaatdesk');
   nc_attput(outputfile, nc_global, 'comment'       , '');
   nc_attput(outputfile, nc_global, 'version'       , D.version);
						   
   nc_attput(outputfile, nc_global, 'Conventions'   , 'CF-1.6');
   nc_attput(outputfile, nc_global, 'featureType'   , 'timeSeries');  % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#featureType
   
   nc_attput(outputfile, nc_global, 'platform_id'   , unique(D.data.STN));
   nc_attput(outputfile, nc_global, 'platform_name' , D.platform_name);
   nc_attput(outputfile, nc_global, 'platform_url'  , D.url);

   nc_attput(outputfile, nc_global, 'terms_for_use' , 'These data can be used freely for research purposes provided that the following source is acknowledged: KNMI.');
   nc_attput(outputfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% Add discovery information (test):

   %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
   
   nc_attput(outputfile, nc_global, 'geospatial_lat_min'         , min(D.lat(:)));
   nc_attput(outputfile, nc_global, 'geospatial_lat_max'         , max(D.lat(:)));
   nc_attput(outputfile, nc_global, 'geospatial_lon_min'         , min(D.lon(:)));
   nc_attput(outputfile, nc_global, 'geospatial_lon_max'         , max(D.lon(:)));
   nc_attput(outputfile, nc_global, 'time_coverage_start'        , datestr(D.datenum(  1),'yyyy-mm-ddPHH:MM:SS'));
   nc_attput(outputfile, nc_global, 'time_coverage_end'          , datestr(D.datenum(end),'yyyy-mm-ddPHH:MM:SS'));
   nc_attput(outputfile, nc_global, 'geospatial_lat_units'       , 'degrees_north');
   nc_attput(outputfile, nc_global, 'geospatial_lon_units'       , 'degrees_east' );

%% 2 Create dimensions

   nc_add_dimension(outputfile, 'time'        , length(D.datenum))
   nc_add_dimension(outputfile, 'locations'   , size(D.platform_name,1)); %
   nc_add_dimension(outputfile, 'name_strlen1', size(D.platform_name,2)); % for multiple stations get max length

%% 3 Create variables
   clear nc
   ifld = 0;

   %% Station number: allows for exactly same variables when multiple timeseries in one netCDF file
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#time-series-data

      ifld = ifld + 1;
   nc(ifld).Name         = 'platform_id';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'locations'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'platform identification code');
   nc(ifld).Attribute(2) = struct('Name', 'cf_role'        ,'Value', 'timeseries_id');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'platform_id');

      ifld = ifld + 1;
   nc(ifld).Name         = 'platform_name';
   nc(ifld).Nctype       = 'char';
   nc(ifld).Dimension    = {'locations','name_strlen1'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'platform name');
   nc(ifld).Attribute(1) = struct('Name', 'standard_name'  ,'Value', 'platform_name');

   %% Define dimensions in this order:
   %  time,z,y,x
   %
   %  For standard names see:
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table

   %% Longitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lon';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'locations'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station longitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude');
   nc(ifld).Attribute(4) = struct('Name', 'axis'           ,'Value', 'X');
    
   %% Latitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lat';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'locations'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station latitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');
   nc(ifld).Attribute(4) = struct('Name', 'axis'           ,'Value', 'Y');

   %% Time
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
   % time is a dimension, so there are two options:
   % * the variable name needs the same as the dimension
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
   % * there needs to be an indirect mapping through the coordinates attribute
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'time';
   nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: double
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'axis'           ,'Value', 'T');
  %nc(ifld).Attribute(6) = struct('Name', 'bounds'         ,'Value', '');
   
   %% Parameters with standard names
   % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   
   varnames = fieldnames(D.data);
   for ivar=1:length(varnames)
     
      varname = varnames{ivar};
   
         ifld = ifld + 1;
      nc(ifld).Name         = strtrim(D.name{ivar});
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'locations','time'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', D.long_name{ivar});
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', D.units{ivar});
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', D.standard_name{ivar});
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'knmi_name'      ,'Value', varname);
      nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', D.cell_methods{ivar});
      nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
      if ~isnan(D.comment{ivar})
      nc(ifld).Attribute(8) = struct('Name', 'units_comment'  ,'Value', D.comment{ivar});
      else
      nc(ifld).Attribute(8) = struct('Name', 'units_comment'  ,'Value', '');
      end

   end

%% 4 Create variables with attibutes
% When variable definitons are created before actually writing the
% data in the next cell, netCDF can nicely fit all data into the
% file without the need to relocate any info.

   for ifld=1:length(nc)
      if OPT.disp;disp(['adding ',num2str(ifld),' ',nc(ifld).Name]);end
      nc_addvar(outputfile, nc(ifld));   
   end

%% 5 Fill variables

   nc_varput(outputfile, 'lon'                                             , D.lon);
   nc_varput(outputfile, 'lat'                                             , D.lat);
   nc_varput(outputfile, 'platform_id'                                     , unique(D.data.STN));
   nc_varput(outputfile, 'platform_name'                                   , D.platform_name);
   nc_varput(outputfile, 'time'                                            , D.datenum - OPT.refdatenum);
   
   
   for ivar=1:length(varnames)
   
      varname = varnames{ivar};
      
      nc_varput(outputfile, strtrim(D.name{ivar}), D.data.(varname) (:)');
      
   end

%% 6 Check

   if OPT.dump
   nc_dump(outputfile);
   end
   
%% Pause

   if OPT.pause
      pausedisp
   end

end %for ifile=1:length(OPT.files)   
   
%% EOF
