%KNMI_NOAAPC2NC  rewrite binary KNMI NOAA POES SST data files (NOAAPC format) into NetCDF files
%
%  Grid data definition, see example:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
%
%  The KNMI set contains data from the POES satellites 10 to 18: 
%  <a href="www.knmi.nl">www.knmi.nl</a>
%  <a href="http://www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html">www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html</a>
%
%See also: KNMI_NOAAPC_READ

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: knmi_noaapc2nc.m 8304 2013-03-08 17:03:36Z boer_g $
% $Date: 2013-03-09 01:03:36 +0800 (Sat, 09 Mar 2013) $
% $Author: boer_g $
% $Revision: 8304 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_noaapc2nc.m $
% $Keywords: $

% TO DO: find out polar_stereographic parameters to EPSG
% TO DO: save data with scale_factor and add_offset to UINT8 to sace space
% TO DO: add composite info (to cell_methods)

% function knmi_noaapc2nc(...)

%% Initialize

   OPT.fillvalue      = nan; % NaNs do work in netcdf API
   OPT.dump           = 0;
   OPT.pause          = 0;
   OPT.debug          = 0;
   OPT.pack           = 0;
   OPT.ll             = 1;
   
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % lunix  datenumber convention
   OPT.timezone       = timezone_code2iso('GMT');

%% File loop

   OPT.directory.raw  = ['F:\checkouts\OpenEarthRawData\knmi\NOAA\noaapc\1990_mom\5\'];
   OPT.directory.nc   = ['F:\checkouts\OpenEarthRawData\knmi\NOAA\noaapc\mom.nc\1990_mom\5\'];
   
   mkpath(OPT.directory.nc)

   OPT.files          = dir([OPT.directory.raw filesep '*.SST']);

   for ifile=1:length(OPT.files)  
   
      OPT.filename = ([OPT.directory.raw, filesep, OPT.files(ifile).name]); % id1-AMRGBVN-196101010000-200801010000.txt
   
      disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)])

%% 0 Read raw data

      D = knmi_noaapc_read(OPT.filename,'center',1,'landmask',nan,'cloudmask',-Inf,'count',OPT.pack); % make sure to set valid_min to prevent -Inf from corrupting color scale in ncBrowse.
      D.version = '';

      if OPT.debug
      pcolorcorcen(D.loncor,D.latcor,D.data)
      end

%% 1a Create file
   
      if OPT.pack
      OPT.ext = ['_sst_pack',num2str(OPT.pack)];
      else
      OPT.ext = '';
      end
     %outputfile    = [OPT.directory.nc,filesep, filename(OPT.filename)         ,OPT.ext,'.nc']; % 8.3 DOS KNMI name
      outputfile    = [OPT.directory.nc,filesep,'N',datestr(D.datenum,30),'_SST',OPT.ext,'.nc']; % 30 (ISO 8601) 'yyyymmddTHHMMSS' name
   
      nc_create_empty (outputfile)
   
      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
      %------------------
   
      nc_attput(outputfile, nc_global, 'title'           , '');
      nc_attput(outputfile, nc_global, 'institution'     , 'KNMI');
      nc_attput(outputfile, nc_global, 'source'          , 'surface observation');
      nc_attput(outputfile, nc_global, 'history'         ,['Original filename: ',filename(OPT.filename),...
                                                           ', version:' ,D.version,...
                                                           ', filedate:',OPT.files(ifile).date,...
                                                           ', tranformation to NetCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_noaapc2nc.m $ $Date: 2013-03-09 01:03:36 +0800 (Sat, 09 Mar 2013) $ $Author: boer_g $']);
      nc_attput(outputfile, nc_global, 'references'      , '<www.knmi.nl>,<www.knmi.nl/onderzk/applied/sd/en/AVHRR_archive_KNMI.html>,<http://dx.doi.org/10.1016/j.csr.2007.06.011>,<http://openearth.deltares.nl>');
      nc_attput(outputfile, nc_global, 'email'           , '<Hans.Roozekrans@knmi.nl>');
   
      nc_attput(outputfile, nc_global, 'comment'         , '');
      nc_attput(outputfile, nc_global, 'version'         , D.version);
   						   
      nc_attput(outputfile, nc_global, 'Conventions'     , 'CF-1.4');
      nc_attput(outputfile, nc_global, 'CF:featureType'  , 'Grid');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
      nc_attput(outputfile, nc_global, 'terms_for_use'   , 'These data can be used freely for research purposes provided that the following source is acknowledged: KNMI.');
      nc_attput(outputfile, nc_global, 'disclaimer'      , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
      
      nc_attput(outputfile, nc_global, 'satnum'          , D.satnum);
      nc_attput(outputfile, nc_global, 'orbnum'          , D.orbnum);
      nc_attput(outputfile, nc_global, 'type'            , D.type);
      nc_attput(outputfile, nc_global, 'yearday'         , D.yearday);
   
%% Add discovery information (test):

      %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
   
      nc_attput(outputfile, nc_global, 'geospatial_lat_min'         , min(D.latcor(:)));
      nc_attput(outputfile, nc_global, 'geospatial_lat_max'         , max(D.latcor(:)));
      nc_attput(outputfile, nc_global, 'geospatial_lon_min'         , min(D.loncor(:)));
      nc_attput(outputfile, nc_global, 'geospatial_lon_max'         , max(D.loncor(:)));
      nc_attput(outputfile, nc_global, 'time_coverage_start'        , datestr(D.datenum(  1),'yyyy-mm-ddPHH:MM:SS'));
      nc_attput(outputfile, nc_global, 'time_coverage_end'          , datestr(D.datenum(end),'yyyy-mm-ddPHH:MM:SS'));
      nc_attput(outputfile, nc_global, 'geospatial_lat_units'       , 'degrees_north');
      nc_attput(outputfile, nc_global, 'geospatial_lon_units'       , 'degrees_east' );

%% 2 Create dimensions
   
      nc_add_dimension(outputfile, 'time' , 1)
      nc_add_dimension(outputfile, 'x'    , D.nx)
      nc_add_dimension(outputfile, 'y'    , D.ny)
      nc_add_dimension(outputfile, 'x_cor', D.nx+1)
      nc_add_dimension(outputfile, 'y_cor', D.ny+1)

%% 3 Create variables
   
      clear nc
      ifld = 0;
   
   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
   
        ifld = ifld + 1;
      nc(ifld).Name             = 'polar_stereographic';
      nc(ifld).Nctype           = 'char';
      nc(ifld).Dimension        = {}; % no dimension, dummy variable
      nc(ifld).Attribute(end+1) = struct('Name', 'projection_name'                      ,'Value', 'Polar Stereographic';
      nc(ifld).Attribute(end+1) = struct('Name', 'EPSG_code'                            ,'Value', 'UNKNOWN'); % or UNDEFINED
      nc(ifld).Attribute(end+1) = struct('Name', 'proj4_params'                         ,'Value', D.proj4_params);

      % See ADADUC manual for polar_stereographic example
      nc(ifld).Attribute(    1) = struct('Name', 'grid_mapping_name'                    ,'Value', 'polar_stereographic');
      nc(ifld).Attribute(end+1) = struct('Name', 'latitude_of_projection_origin'        ,'Value', '+90'); % Either +90. or -90.
      nc(ifld).Attribute(end+1) = struct('Name', 'straight_vertical_longitude_from_pole','Value', 0);
      nc(ifld).Attribute(end+1) = struct('Name', 'scale_factor_at_projection_origin'    ,'Value', D.scale_in_m);
      nc(ifld).Attribute(end+1) = struct('Name', 'false_easting'                        ,'Value', 0);
      nc(ifld).Attribute(end+1) = struct('Name', 'false_northing'                       ,'Value', 0);

      nc(ifld).Attribute(end+1) = struct('Name', 'inverse_flattening'                   ,'Value', 298.183263207106);
      nc(ifld).Attribute(end+1) = struct('Name', 'semi_major_axis'                      ,'Value', 6378140000);
      nc(ifld).Attribute(end+1) = struct('Name', 'semi_minor_axis'                      ,'Value', 6356750000);
      nc(ifld).Attribute(end+1) = struct('Name', 'longitude_of_prima_meridian'          ,'Value', 0);
      

   %% Local Cartesian coordinates

        ifld = ifld + 1;
      nc(ifld).Name         = 'x';
      nc(ifld).Nctype       = 'int';
      nc(ifld).Dimension    = {'x'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'x-coordinate in Cartesian system');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'km');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', '1 km2 pixel centers');
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'y';
      nc(ifld).Nctype       = 'int';
      nc(ifld).Dimension    = {'y'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'y-coordinate in Cartesian system');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'km');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', '1 km2 pixel centers');

        ifld = ifld + 1;
      nc(ifld).Name         = 'x_cor';
      nc(ifld).Nctype       = 'int';
      nc(ifld).Dimension    = {'x_cor'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'x-coordinate of pixel corners in Cartesian system');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'km');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', '1 km2 pixel corners');
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'y_cor';
      nc(ifld).Nctype       = 'int';
      nc(ifld).Dimension    = {'y_cor'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'y-coordinate of pixel corners in Cartesian system');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'km');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'comment'        ,'Value', '1 km2 pixel corners');
   
      if OPT.ll
%% Longitude
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'longitude';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'x','y'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'actual_range'   ,'Value', [min(D.loncen(:)) max(D.loncen(:))]); % 
   
%% Latitude
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
      
        ifld = ifld + 1;
      nc(ifld).Name         = 'latitude';
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {'x','y'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'actual_range'   ,'Value', [min(D.latcen(:)) max(D.latcen(:))]); % 
      end % if OPT.ll

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
      nc(ifld).Dimension    = {'time'}; % {'locations','time'} % does not work in ncBrowse, nor in Quickplot (is indirect time mapping)
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);

%% Parameters with standard names
% * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   
      %% Define dimensions in this order:
      %  time,z,y,x

        ifld = ifld + 1;
      nc(ifld).Name             = 'SST';
      nc(ifld).Nctype           = 'double';
      nc(ifld).Dimension        = {'x','y','time'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'sea surface temperature');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_Celcius');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'sea_surface_skin_temperature'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'latitude longitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'polar_stereographic');
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [D.data_min_value D.data_max_value]);
      
      if OPT.pack
      nc(ifld).Nctype        = 'int'; %'byte'; %short
      nc(ifld).Attribute(9)  = struct('Name', 'valid_min'      ,'Value', D.count_min_value);
      nc(ifld).Attribute(10) = struct('Name', 'valid_max'      ,'Value', D.count_max_value);
      nc(ifld).Attribute(11) = struct('Name', 'scale_factor'   ,'Value', D.gain);
      nc(ifld).Attribute(12) = struct('Name', 'add_offset'     ,'Value', D.offset);
      end

     %nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'point');x
     %nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'point');y
     %nc(ifld).Attribute(6) = struct('Name', 'cell_methods'   ,'Value', 'point');time

%% 4 Create variables with attibutes
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
      
%% 5 Fill variables
   
      nc_varput(outputfile, 'x'        , [1:D.nx]'-0.5);
      nc_varput(outputfile, 'y'        , [1:D.ny]'-0.5);
      nc_varput(outputfile, 'x_cor'    , [1:(D.nx+1)]');
      nc_varput(outputfile, 'y_cor'    , [1:(D.ny+1)]');
      if OPT.ll
      nc_varput(outputfile, 'longitude', D.loncen');
      nc_varput(outputfile, 'latitude' , D.latcen');
      end % if OPT.ll
      nc_varput(outputfile, 'time'         , D.datenum' - OPT.refdatenum);
      if OPT.pack
      nc_datput(outputfile, 'SST'          , int16(flipud(D.count)')); % do not use nc_varput with scale_factor and add_offset
      % uint8 and int8 both becomes nc_byte, 
      % * upper D.count levels ( > 512) are outside n_byte range
      % * unit 8 is read as int8, so [-512 512] instad of [0 1024]
      % * altarnative int16 contains too much space (twice).
      else
      nc_varput(outputfile, 'SST'          , D.data');
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



