function varargout = odv2nc(varargin)
%ODV2NC  transforms one ODV CTD casts into one netCDF file
%
%     odv2nc(<keyword,value>) 
%
%  where the following <keyword,value> pairs have been implemented:
%
%   * fillvalue      (default nan)
%   * dump           whether to check nc_dump on matlab command line after writing file (default 0)
%   * odvfile        input file
%   * ncfile         output file, if empty, extension of odvfile is replaced with nc
%   * refdatenum     default (datenum(1970,1,1))
%   * pause          pause between files (default 0)
%
% Example:
%
%  L = odv_metadata('userab12c34-data_centre000-311210_result')
%  for i=1:length(L.fullfile)
%     odv2nc(L.fullfile{i})
%  end
%
%See also: OceanDataView, snctools

% $Id: odv2nc.m 5239 2011-09-16 13:09:55Z boer_g $
% $Date: 2011-09-16 21:09:55 +0800 (Fri, 16 Sep 2011) $
% $Author: boer_g $
% $Revision: 5239 $
% $HeadURL
% $Keywords:

%% Initialize

   OPT.dump              = 1;
   OPT.disp              = 1;
   OPT.pause             = 1;
   OPT.odvfile           = '';
   OPT.ncfile            = '';
   OPT.stationTimeSeries = 0;  % coordinates attribute
   OPT.version           = ''; % from odv meta-data file or zip file name

   OPT.refdatenum        = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum        = datenum(1970,1,1); % lunix  datenumber convention
   OPT.fillvalue         = nan; % NaNs do work in netcdf API
   
%% Keyword,value

   if odd(nargin)
      OPT.odvfile = varargin{1};
      varargin = {varargin{2:end}};
   end

   OPT = setproperty(OPT,varargin{:});
   if nargin == 0
     varargout = {OPT};
     return
   end
   

%% 0 Read all raw data

   D = odvread(OPT.odvfile);
   D.timezone         = 'GMT';

%% 1a Create netCDF file

   if isempty(OPT.ncfile)
      OPT.ncfile = [filepathstrname(OPT.odvfile),'.nc'];
   end
   
   nc_create_empty (OPT.ncfile)

   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   % ------------------

   nc_attput(OPT.ncfile, nc_global, 'title'          , 'Profile data');
   nc_attput(OPT.ncfile, nc_global, 'institution'    , D.institution);
   nc_attput(OPT.ncfile, nc_global, 'source'         , '');
   nc_attput(OPT.ncfile, nc_global, 'history'        , ['Tranformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/OceanDataView/odv2nc.m $']);
   nc_attput(OPT.ncfile, nc_global, 'references'     , 'data:<http://www.nioz.nl>, distribution:<http://www.nodc.nl>,<http://www.seadatanet.org>, netCDF conversion:<http://www.OpenEarth.eu>');
   nc_attput(OPT.ncfile, nc_global, 'email'          , '');
   
   nc_attput(OPT.ncfile, nc_global, 'comment'        , 'There is no SeaDataNet netCDF convention yet, this is just a trial to speed-up the SDN netCDF process.');
   nc_attput(OPT.ncfile, nc_global, 'version'        , OPT.version);
						    
   nc_attput(OPT.ncfile, nc_global, 'Conventions'    , 'CF-1.4/SeaDataNet-0.7'); % http://www.unidata.ucar.edu/software/netcdf/conventions.html
   						    
   nc_attput(OPT.ncfile, nc_global, 'terms_for_use'  ,['These data can be used freely for research purposes provided that the following source is acknowledged:.',D.institution]);
   nc_attput(OPT.ncfile, nc_global, 'disclaimer'     , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
   %% Add SeaDataNet attrbutes: this allows only one ODV file per netCDF file !!!
   %  current standard http://www.seadatanet.org/content/download/3886/29530/version/2/file/SeaDataNet+Formats+0.7.doc, we prefer it to be a coordinate   
   
   nc_attput(OPT.ncfile, nc_global, 'SDN_LOCAL_CDI_ID',D.LOCAL_CDI_ID);
   nc_attput(OPT.ncfile, nc_global, 'SDN_EDMO_code'   ,D.EDMO_code);

%% 2 Create dimensions

   if D.cast
   dimname = mkvar(D.local_name{10});
   else
   dimname = 'location';
   end
   
   nc_add_dimension(OPT.ncfile, dimname, length(D.data{1}))
   nc_add_dimension(OPT.ncfile, 'cruise_str'            , size(char(D.metadata.cruise ),2));
   nc_add_dimension(OPT.ncfile, 'station_str'           , size(char(D.metadata.station),2));
   nc_add_dimension(OPT.ncfile, 'type_str'              , size(char(D.metadata.type   ),2));
   nc_add_dimension(OPT.ncfile, 'SDN_LOCAL_CDI_ID_str'  , length(D.LOCAL_CDI_ID));
   if length(D) > 1
   nc_add_dimension(OPT.ncfile, 'SDN_LOCAL_CDI_ID'      , length(D));
   error('merging multiple CDI into one netCDFf file not implemented yet')
   end

%% 3 Create variables: SDN meta-info
   
   clear nc
   ifld = 0;

   %% Cruise number
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'cruise_id';
   nc(ifld).Nctype       = 'char';
   nc(ifld).Dimension    = {dimname,'cruise_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'        ,'Value', 'cruise identification number');
   nc(ifld).Attribute(2) = struct('Name', 'sdn_standard_name','Value', 'cruise_id');

   %% Station number
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'station_id';
   nc(ifld).Nctype       = 'char';
   nc(ifld).Dimension    = {dimname,'station_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'        ,'Value', 'station identification number');
   nc(ifld).Attribute(2) = struct('Name', 'standard_name'    ,'Value', 'station_id');
   nc(ifld).Attribute(3) = struct('Name', 'sdn_standard_name','Value', 'station_id');

   %% Type
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'type';
   nc(ifld).Nctype       = 'char';
   nc(ifld).Dimension    = {dimname,'type_str'};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'        ,'Value', 'type of observation');
   nc(ifld).Attribute(2) = struct('Name', 'comment'          ,'Value', 'B for bottle or C for CTD, XBT or stations with >250 samples');
   nc(ifld).Attribute(3) = struct('Name', 'sdn_standard_name','Value', 'type');
   
   %% Define dimensions in this order:
   %  time,z,y,x
   %
   %  For standard names see:
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table

   %% Time
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
   % time is a dimension, so there are two options:
   % * the variable name needs the same as the dimension
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
   % * there needs to be an indirect mapping through the coordinates attribute
   %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
   
   OPT.timezone = timezone_code2iso(D.timezone);

      ifld = ifld + 1;
   nc(ifld).Name         = 'time';
   nc(ifld).Nctype       = 'double'; % float not sufficient as datenums are big: doubble
   nc(ifld).Dimension    = {dimname};
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value',['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
  %nc(ifld).Attribute(5) = struct('Name', 'bounds'         ,'Value', '');
   
   %% Longitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lon';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {dimname}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'        ,'Value', 'station longitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'            ,'Value', 'degrees_east');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'    ,'Value', 'longitude');
   nc(ifld).Attribute(4) = struct('Name', 'sdn_standard_name','Value', 'lon');
    
   %% Latitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'lat';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {dimname}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'        ,'Value', 'station latitude');
   nc(ifld).Attribute(2) = struct('Name', 'units'            ,'Value', 'degrees_north');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'    ,'Value', 'latitude');
   nc(ifld).Attribute(4) = struct('Name', 'sdn_standard_name','Value', 'lat');

   %% LOCAL_CDI_ID
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'LOCAL_CDI_ID';
   nc(ifld).Nctype       = 'char';
   nc(ifld).Dimension    = {dimname,'SDN_LOCAL_CDI_ID_str'};
   nc(ifld).Attribute(1) = struct('Name', 'sdn_standard_name','Value', 'SDN_LOCAL_CDI_ID');
   nc(ifld).Attribute(2) = struct('Name', 'comment'          ,'Value', ' ');

   %% EDMO_code
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'SDN_EDMO_code';
   nc(ifld).Nctype       = 'int'; % no double needed
   nc(ifld).Dimension    = {dimname};
   nc(ifld).Attribute(1) = struct('Name', 'sdn_standard_name','Value', 'SDN_EDMO_code');
   nc(ifld).Attribute(2) = struct('Name', 'comment'          ,'Value', ' ');
   
   %% Bottom depth
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
      ifld = ifld + 1;
   nc(ifld).Name         = 'bot_depth';
   nc(ifld).Nctype       = 'float'; % no double needed
   nc(ifld).Dimension    = {dimname}; % QuickPlot error: plots dimensions instead of datestr
   nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'bottom depth');
   nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'meter');
   nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', '');
   nc(ifld).Attribute(4) = struct('Name', 'positive'       ,'Value', 'down');

%% 3 Create variables: SDN data, skip flags for now

   for ivar=[10:2:length(D.local_name)]

         ifld = ifld + 1;
      nc(ifld).Name         = mkvar(D.local_name{ivar});
      nc(ifld).Nctype       = 'float';
      nc(ifld).Dimension    = {dimname};
      % <subject></subject>
      nc(ifld).Attribute( 1) = struct('Name', 'standard_name'     ,'Value', D.standard_name{ivar});
      nc(ifld).Attribute( 2) = struct('Name', 'units'             ,'Value', D.units{ivar});
      nc(ifld).Attribute( 3) = struct('Name', 'local_name'        ,'Value', D.local_name{ivar});
      % <object></object>
      nc(ifld).Attribute( 4) = struct('Name', 'sdn_standard_name' ,'Value', D.sdn_standard_name{ivar});
      % <units></units>
      nc(ifld).Attribute( 5) = struct('Name', 'sdn_units'         ,'Value', D.sdn_units{ivar});
      nc(ifld).Attribute( 6) = struct('Name', 'sdn_long_name'     ,'Value', '');
      nc(ifld).Attribute( 7) = struct('Name', 'sdn_description'   ,'Value', D.sdn_long_name{ivar});

      nc(ifld).Attribute( 8) = struct('Name', '_FillValue'        ,'Value', OPT.fillvalue);
      nc(ifld).Attribute( 9) = struct('Name', 'cell_bounds'       ,'Value', 'point');
      if ivar==10
      nc(ifld).Attribute(10) = struct('Name', 'positive'          ,'Value', 'down');
      nc(ifld).Attribute(11) = struct('Name', 'AXIS'              ,'Value', 'Z');
      else
      nc(ifld).Attribute( 9) = struct('Name', 'coordinates'       ,'Value', mkvar(D.local_name{10}));
      end
   
   end

%% 4 Create variables with attibutes
%    When variable definitons are created before actually writing the
%    data in the next cell, netCDF can nicely fit all data into the
%    file without the need to relocate any info.

   for ifld=1:length(nc)
      if OPT.disp;
         disp(['adding ',num2str(ifld),' ',nc(ifld).Name]);
         %var2evalstr(nc(ifld))
      end
      nc_addvar(OPT.ncfile, nc(ifld));   
   end

%% 5 Fill variables: SDN data, skip flags for now

   nc_varput(OPT.ncfile, 'cruise_id'    , D.cruise);
   if D.cast
   nc_varput(OPT.ncfile, 'station_id'   , D.station);
   end
   nc_varput(OPT.ncfile, 'type'         , D.type);

   nc_varput(OPT.ncfile, 'LOCAL_CDI_ID' , D.LOCAL_CDI_ID);
   nc_varput(OPT.ncfile, 'SDN_EDMO_code', D.EDMO_code);

   nc_varput(OPT.ncfile, 'time'         , D.metadata.datenum-OPT.refdatenum);
   nc_varput(OPT.ncfile, 'lon'          , D.metadata.longitude);
   nc_varput(OPT.ncfile, 'lat'          , D.metadata.latitude);
   nc_varput(OPT.ncfile, 'bot_depth'    , D.metadata.bot_depth);

   for ivar=[10:2:length(D.local_name)] % below 10 is meta-data
   nc_varput(OPT.ncfile, mkvar(D.local_name{ivar}), D.data{ivar});
   end
   
%% 6 Check

   if OPT.dump
   nc_dump(OPT.ncfile);
   end
   
   if OPT.pause
      pausedisp
   end
   
end   
   
%% EOF
   