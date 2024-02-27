function knmi_potwind2nc(varargin)
%KNMI_POTWIND2NC  transforms directory of potwind ASCII files into directory of NetCDF files
%
%     knmi_potwind2nc(<keyword,value>) 
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
%  knmi_potwind2nc('directory_raw','P:\mcdata\OpenEarthRawData\knmi\potwind\raw\',...
%                  'directory_nc', 'P:\mcdata\opendap\knmi\potwind\')
%
%  Timeseries data definition:
%   * https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions (full definition)
%   * http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788 (simple)
%
% In this example time is both a dimension and a variables.
% The actual datenum values do not show up as a parameter in ncBrowse.
%
%See also: wind_plot, KNMI_POTWIND, SNCTOOLS, KNMI_POTWIND_GET_URL, KNMI_ETMGEG2NC_TIME_DIRECT

%% Initialize

   OPT.dump              = 0;
   OPT.disp              = 0;
   OPT.pause             = 0;
   
   OPT.refdatenum        = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum        = datenum(1970,1,1); % linux  datenumber convention
   OPT.timezone          = timezone_code2iso('GMT'); % potwind is in GMT, uurgeg in UT (?)
   OPT.fillvalue         = nan; % NaNs do work in netcdf API
   
%% File loop

   OPT.directory_raw     = 'F:\checkouts\OpenEarthRawData\knmi\potwind\raw\';            % []; %
   OPT.directory_nc      = 'F:\opendap.deltares.nl\thredds\dodsC\opendap\knmi\potwind\'; % []; %
   OPT.mask              = 'potwind*';
   OPT.ext               = '';

%% Keyword,value

   OPT = setproperty(OPT,varargin{:});
   
%% File loop

   OPT.files = dir([OPT.directory_raw,filesep,OPT.mask]);
%%%OPT.files = knmi_potwind_directory([OPT.directory_raw,filesep,OPT.mask]);

for ifile=1:length(OPT.files)

%    basename = filename(OPT.files{ifile}{1});
%    basename = basename(1:11);

   OPT.filename = [OPT.directory_raw, filesep, OPT.files(ifile).name]; % e.g. 'potwind_210_1981'
  
   disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])
   % disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',basename,' +'])

%% 0 Read raw data

% use knmi_potwind_multi here to concatenate the decadal files

   D             = knmi_potwind      (OPT.filename    ,'variables',OPT.fillvalue);
%    D             = knmi_potwind_multi(OPT.files{ifile},'variables',OPT.fillvalue);

%% 1a Create file

%   outputfile    = [OPT.directory_nc,filesep,basename,OPT.ext,'.nc'];
    outputfile    = [OPT.directory_nc filesep  filename(D.file.name),OPT.ext,'.nc'];
  
   if ~exist(fileparts(outputfile))
      mkpath(fileparts(outputfile))
   end
   
   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   %------------------

   nc_attput(outputfile, nc_global, 'title'         , '');
   nc_attput(outputfile, nc_global, 'institution'   , 'KNMI');
   nc_attput(outputfile, nc_global, 'source'        , 'surface observation');
%    nc_attput(outputfile, nc_global, 'history'       , ['Original filename: ',str2line(filename(char(OPT.files{ifile})),'s',';'),...
%                                                        ', version:' ,str2line(D.version  ,'s',';'),...
%                                                        ', filedate:',str2line(D.file.date,'s',';'),...
%                                                        ', tranformation to NetCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_potwind2nc.m $ $Revision: 9897 $ $Date: 2013-12-18 01:12:27 +0800 (Wed, 18 Dec 2013) $ $Author: santinel $']);
   nc_attput(outputfile, nc_global, 'history'       , ['Original filename: ',str2line(filename(D.file.name),'s',';'),...
                                                       ', version:' ,str2line(D.version  ,'s',';'),...
                                                       ', filedate:',str2line(D.file.date,'s',';'),...
                                                       ', tranformation to NetCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_potwind2nc.m $ $Revision: 9897 $ $Date: 2013-12-18 01:12:27 +0800 (Wed, 18 Dec 2013) $ $Author: santinel $']);
   nc_attput(outputfile, nc_global, 'references'    , '<http://www.knmi.nl/samenw/hydra>,<http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/>,<http://openearth.deltares.nl>');
   nc_attput(outputfile, nc_global, 'email'         , '<klimaatdesk@knmi.nl>');
   
   nc_attput(outputfile, nc_global, 'comment'       , '');
   nc_attput(outputfile, nc_global, 'version'       , str2line(D.version  ,'s',';'));
						    
   nc_attput(outputfile, nc_global, 'Conventions'   , 'CF-1.6');
   nc_attput(outputfile, nc_global, 'featureType'   , 'timeSeries');  % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#featureType
   						    
   nc_attput(outputfile, nc_global, 'stationnumber' , D.stationnumber);
   nc_attput(outputfile, nc_global, 'stationname'   , D.stationname);
   nc_attput(outputfile, nc_global, 'over'          , D.over);
   nc_attput(outputfile, nc_global, 'height'        , str2line(D.height  ,'s',';'));
   
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
   nc_add_dimension(outputfile, 'locations'   , 1)
   nc_add_dimension(outputfile, 'name_strlen1', length(D.stationname)); % for multiple stations get max length

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
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'platform_name');

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
   nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
   nc(ifld).Dimension    = {'time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value',['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'axis'           ,'Value', 'T');
  %nc(ifld).Attribute(6) = struct('Name', 'bounds'         ,'Value', '');
   
   %% Parameters with standard names
   % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

      ifld = ifld + 1;
   nc(ifld).Name         = 'wind_speed';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'wind speed');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm/s');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_speed');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'UP');
   nc(ifld).Attribute(6) = struct('Name', 'cell_bounds'    ,'Value', 'point');
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error

      ifld = ifld + 1;
   nc(ifld).Name         = 'wind_from_direction';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'nautical wind direction');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degree_true');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'wind_from_direction');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   nc(ifld).Attribute(5) = struct('Name', 'KNMI_name'      ,'Value', 'DD');
   nc(ifld).Attribute(6) = struct('Name', 'cell_bounds'    ,'Value', 'point');
   nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error

   %% Parameters without standard names

      ifld = ifld + 1;
   nc(ifld).Name         = 'wind_speed_quality';
   nc(ifld).Nctype       = 'int';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'quality code wind speed');
   nc(ifld).Attribute(2) = struct('Name', 'comment'        ,'Value',['-1  = no data,',...
                                                                     '0   = valid data,',...
                                                                     '2   = data taken from WIKLI-archives,',...
                                                                     '3   = wind direction in degrees computed from points of the compass,',...
                                                                     '6   = added data,',...
                                                                     '7   = missing data,',...
                                                                     '100 = suspected data']);
   nc(ifld).Attribute(3) = struct('Name', 'KNMI_name'      ,'Value', 'QUP');
   nc(ifld).Attribute(4) = struct('Name', 'cell_bounds'    ,'Value', 'point');
   nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error

      ifld = ifld + 1;
   nc(ifld).Name         = 'wind_from_direction_quality';
   nc(ifld).Nctype       = 'int';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'quality code nautical wind direction');
   nc(ifld).Attribute(2) = struct('Name', 'comment'        ,'Value',['-1  = no data,',...
                                                                     '0   = valid data,',...
                                                                     '2   = data taken from WIKLI-archives,',...
                                                                     '3   = wind direction in degrees computed from points of the compass,',...
                                                                     '6   = added data,',...
                                                                     '7   = missing data,',...
                                                                     '100 = suspected data']);
   nc(ifld).Attribute(3) = struct('Name', 'KNMI_name'      ,'Value', 'QQD');
   nc(ifld).Attribute(4) = struct('Name', 'cell_bounds'    ,'Value', 'point');
   nc(ifld).Attribute(5) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error

   % Filename of origin
% 
%       ifld = ifld + 1;
%    nc(ifld).Name         = 'origin_number';
%    nc(ifld).Nctype       = 'int';
%    nc(ifld).Dimension    = {'locations','time'};
%    nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'KNMI file number of origin');
%    nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', '1');
%    nc(ifld).Attribute(3) = struct('Name', 'flag_values'    ,'Value', 1:length(OPT.files{ifile}));
%    nc(ifld).Attribute(4) = struct('Name', 'flag_meanings'  ,'Value', str2line(filename(char(OPT.files{ifile})),'s',' '));

%% 4 Create variables with attibutes
% When variable definitons are created before actually writing the
% data in the next cell, netCDF can nicely fit all data into the
% file without the need to relocate any info.

   for ifld=1:length(nc)
      if OPT.disp;disp(['adding ',num2str(ifld),' ',nc(ifld).Name]);end
      nc_addvar(outputfile, nc(ifld));   
   end

%% 5 Fill variables

   nc_varput(outputfile, 'lon'                        , D.lon);
   nc_varput(outputfile, 'lat'                        , D.lat);
   nc_varput(outputfile, 'platform_id'                , str2double(D.stationnumber));
%    nc_varput(outputfile, 'platform_id'                , D.stationnumber);
   nc_varput(outputfile, 'platform_name'              , D.stationname);
   nc_varput(outputfile, 'time'                       , D.datenum-OPT.refdatenum);
   nc_varput(outputfile, 'wind_speed'                 , D.UP(:)');
   nc_varput(outputfile, 'wind_from_direction'        , D.DD(:)'); % does not work with NaNs.
   nc_varput(outputfile, 'wind_speed_quality'         , int8(D.QUP(:)'));
   nc_varput(outputfile, 'wind_from_direction_quality', int8(D.QQD(:)'));
%   nc_varput(outputfile, 'origin_number'              , int8(D.origin_number(:)'));
   
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
