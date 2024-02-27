function zege_golven2nc(varargin)
%RWS_ZEGE_GOLVEN2NC  rewrite txt files from zege to netCDF-CF files
%
%See also: RWS_ZEGE_READ, rws_waterbase2nc

% created by K. Cronin
% April 2013

% varagin = mat file created by rws_zege_read_golven.m

%% Initialize

   OPT.dump              = 0;
   OPT.disp              = 0;
   OPT.pause             = 0;
   
   OPT.refdatenum        = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum        = datenum(1970,1,1); % linux  datenumber convention
   OPT.fillvalue         = NaN; % NaNs do work in netcdf API
   OPT.timezone          = '+01:00'; % check !! add to D
   
   OPT.stationTimeSeries = 0; % last items to adhere to for upcoming convenction, but not yet supported by QuickPlot
   
%% File loop

   OPT.directory_raw     = 'P:\1205122-zeebodemintegriteit\Mos3_DataAnalysis\ZEGE_data\2010'; % []; %
   OPT.directory_nc      = 'P:\1205122-zeebodemintegriteit\Mos3_DataAnalysis\ZEGE_data\2010'; % []; %   
   OPT.mask              = '*.mat'; %'*.data';  

%% Keyword,value

%    OPT = setproperty(OPT,varargin{:});
    
%% File loop

  OPT.files = dir([OPT.directory_raw, filesep, OPT.mask]); 

  for ifile=1:length(OPT.files)

   ncfile = [OPT.directory_raw, filesep, filename(OPT.files(ifile).name) '.nc' ];
  matfile = [OPT.directory_raw, filesep, filename(OPT.files(ifile).name) '.mat'];

  disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files))])

%% 0 Read raw data

   load(matfile);
   load('rws_zege_Station_WGS84_Coordinates.mat');
   % bit of a workaround to include the coordinates which don't come with the ZEGE downloads
   % the positioning of the text depends on the file name length - needs to be improved. If any 
   % questions ask K. Cronin
   
   if     strcmp('BG2',matfile(65:67)),
                  D.lat =  C.BG2.lat;
                  D.lon =  C.BG2.lon;
                  D.station_name = 'BG2';
   elseif  strcmp('DELO',matfile(65:68)),
                  D.lat =  C.VR.lat;
                  D.lon =  C.VR.lon;
                  D.station_name = 'DELO';        
    elseif strcmp('DORA',matfile(65:68)),
                  D.lat = C.DORA.lat;
                  D.lon = C.DORA.lon;
                  D.station_name = 'DORA';
     elseif strcmp('OS4',matfile(65:67)),
                  D.lat = C.OS4.lat;
                  D.lon = C.OS4.lon;
                  D.station_name = 'OS4';               
    elseif strcmp('SCHB',matfile(65:68)),
                  D.lat =  C.SCHB.lat;
                  D.lon =  C.SCHB.lon;
                  D.station_name = 'SCHB';                          
     elseif strcmp('SCHW',matfile(65:68)),
                  D.lat =  C.SCHW.lat;
                  D.lon =  C.SCHW.lon;
                  D.station_name = 'SCHW';
     elseif strcmp('WIEL',matfile(65:68)),
                  D.lat =  C.WIEL.lat;
                  D.lon =  C.WIEL.lon;
                  D.station_name = 'WIEL';
     elseif strcmp('sf-ha10',matfile(53:59)),
                  D.lat =  C.HA10.lat;
                  D.lon =  C.BG8.lon;
                  D.station_name = 'H10_opper_tem';
     elseif strcmp('bt-os4',matfile(53:58)),
                  D.lat =  C.OS4.lat;
                  D.lon =  C.OS4.lon;
                  D.station_name = 'OS4_bodem_tem';
     elseif strcmp('sf-os4',matfile(53:58)),
                  D.lat =  C.OS4.lat;
                  D.lon =  C.OS4.lon;
                  D.station_name = 'OS4_opper_tem';
   end
   
   if strcmp('bt', matfile(53:54)), 
                D.depth = 'bodem/bottom';
   elseif strcmp('sf', matfile(53:54)),
                D.depth = 'oppervlak/surface';
   end


%% Parse struct to netCDF

 %% 1a Create file

   outputfile     = ncfile;
   nc_create_empty (outputfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   %------------------

   nc_attput(outputfile, nc_global, 'title'         , 'Zeeland metingen');
   nc_attput(outputfile, nc_global, 'institution'   , 'Rijkswaterstaat');
   nc_attput(outputfile, nc_global, 'source'        , 'wave buoy');
   nc_attput(outputfile, nc_global, 'history'       , '$Id: rws_zege_golven2nc.m 8476 2013-04-19 08:43:26Z boer_g $');
   nc_attput(outputfile, nc_global, 'references'    , 'www.hmcz.nl');
   nc_attput(outputfile, nc_global, 'email'         , '');
   
   nc_attput(outputfile, nc_global, 'comment'       , 'DELO station is VR');
   nc_attput(outputfile, nc_global, 'version'       , '');
						    
   nc_attput(outputfile, nc_global, 'Conventions'   , 'CF-1.4');
 %  nc_attput(outputfile, nc_global, 'CF:featureType', 'stationTimeSeries');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   						    
   nc_attput(outputfile, nc_global, 'terms_for_use' , 'These data can be used freely for research purposes provided that the following source is acknowledged: KNMI.');
   nc_attput(outputfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
%% Add discovery information (test):

   %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
   
%   nc_attput(outputfile, nc_global, ' station_id'                 , char(D.header));
%   nc_attput(outputfile, nc_global, 'Depth'                      , char(D.depth));
  % nc_attput(outputfile, nc_global, 'geospatial_lat_max'         , max(D.lat(:)));
  % nc_attput(outputfile, nc_global, 'geospatial_lon_min'         , min(D.lon(:)));
  % nc_attput(outputfile, nc_global, 'geospatial_lon_max'         , max(D.lon(:)));
  % nc_attput(outputfile, nc_global, 'time_coverage_start'        , datestr(D.datenum(  1),'yyyy-mm-ddPHH:MM:SS'));
  % nc_attput(outputfile, nc_global, 'time_coverage_end'          , datestr(D.datenum(end),'yyyy-mm-ddPHH:MM:SS'));
  % nc_attput(outputfile, nc_global, 'geospatial_lat_units'       , 'degrees_north');
  % nc_attput(outputfile, nc_global, 'geospatial_lon_units'       , 'degrees_east' );

%% 2 Create dimensions

    nc_add_dimension(outputfile, 'time'        , length(DAT.data.datenum))
    nc_add_dimension(outputfile, 'locations'   , 1)
    nc_add_dimension(outputfile, 'name_strlen1', length(char(D.station_name))); % for multiple stations get max length
    nc_add_dimension(outputfile, 'name_strlen2', length(char(DAT.header))); 

%% 3 Create variables

   clear nc
   ifld = 0;
   
   %% Station number: allows for exactly same variables when multiple timeseries in one netCDF file
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'station_id';
   nc(ifld).Nctype       = 'char'; % no double needed
   nc(ifld).Dimension    = {'locations', 'name_strlen1'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station id');
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id');

   % Station long name

      ifld = ifld + 1;
   nc(ifld).Name         = 'station_name';
   nc(ifld).Nctype       = 'char';
   nc(ifld).Dimension    = {'locations','name_strlen2'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station name');
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_name');

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
    
   %% Latitude
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lat';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {'locations'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station latitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');

   %%
   %% Station_longname
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.
   
   %   ifld = ifld + 1;
   %nc(ifld).Name         = 'station_longname';
   %nc(ifld).Nctype       = 'char'; % no double needed
   %nc(ifld).Dimension    = {'locations'};
   %nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station name');
  % nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
  % nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude');
   
   %% Time
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
   % time is a dimension, so there are two options:
   % * the variable name needs the same as the dimension
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
   % * there needs to be an indirect mapping through the coordinates attribute
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
   
 %  OPT.timezone = timezone_code2iso('GMT');

      ifld = ifld + 1;
   nc(ifld).Name         = 'time';
   nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
   if OPT.stationTimeSeries
   nc(ifld).Dimension    = {'locations','time'}; % QuickPlot error: plots dimensions instead of datestr
   else
   nc(ifld).Dimension    = {'time'}; % {'locations','time'} % does not work in ncBrowse, nor in Quickplot (is indirect time mapping)
   end
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value',['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
   
   %% Parameters with standard names
   % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

   
      ifld = ifld + 1;
   nc(ifld).Name         = 'sea_surface_wave_significant_height';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'sea_surface_wave_significant_height');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'sea_surface_wave_significant_height');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', double(OPT.fillvalue));
%  %  if OPT.stationTimeSeries
%  %  nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
%  %  end
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'sea_surface_wind_wave_tm02';
   nc(ifld).Nctype       = 'float';
   nc(ifld).Dimension    = {'locations','time'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'Gem. golfperiode uit spectrale momenten m0+m2 van 30-500 mhz in s in oppervlaktewater');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 's');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', double(OPT.fillvalue));
%   % if OPT.stationTimeSeries
%   % nc(ifld).Attribute(7) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
%   % end
   

 
%% 4 Create variables with attibutes
% When variable definitons are created before actually writing the
% data in the next cell, netCDF can nicely fit all data into the
% file without the need to relocate any info.

   for ifld=1:length(nc)
      if OPT.disp;disp(['adding ',num2str(ifld),' ',nc(ifld).Name]);end
      nc_addvar(outputfile, nc(ifld));   
   end
   
%% 5 Fill variables

     nc_varput(outputfile, 'station_id'                  ,char(D.station_name));       
     nc_varput(outputfile, 'station_name'                ,char(DAT.header{1}));
     nc_varput(outputfile, 'lon'                         , D.lon);
     nc_varput(outputfile, 'lat'                         , D.lat);
     nc_varput(outputfile, 'time'                       , DAT.data.datenum - OPT.refdatenum);
	 nc_varput(outputfile, 'sea_surface_wind_wave_tm02'                         , DAT.data.TM02);
     nc_varput(outputfile, 'sea_surface_wave_significant_height'                , (DAT.data.H3)/100);

   
   
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
