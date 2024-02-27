function rws_waterbase2nc(varargin)
%RWS_WATERBASE2NC  rewrite zipped txt files from waterbase.nl timeseries to netCDF-CF files
%
%     rws_waterbase2nc(<keyword,value>)
%
%  where the following <keyword,value> pairs have been implemented:
%
%   * fillvalue      (default nan)
%   * dump           whether to check nc_dump on matlab command line after writing file (default 0)
%   * directory_raw  directory where to get the raw data from (default [])
%   * directory_nc   directory where to put the nc data to (default [])
%   * mask           file mask (default 'id*.zip')
%   * refdatenum     default (datenum(1970,1,1))
%   * ext            extension to add to the files before *.nc (default '')
%   * pause          pause between files (default 0)
%
% Example:
%  rws_waterbase2nc('directory_raw','P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\',...
%                   'directory_nc', 'P:\mcdata\opendap\rijkswaterstaat\waterbase\')
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.5/cf-conventions.html#id2867470">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
% In this example time is both a dimension and a variables.
% The actual datenum values do not show up as a parameter in ncBrowse.
%
%See also: RWS_WATERBASE_GET_URL, RWS_WATERBASE_READ, SNCTOOLS
%          NC_CF_STATIONTIMESERIES2META, NC_CF_STATIONTIMESERIES

% $Id: rws_waterbase2nc.m 14588 2018-09-14 10:56:51Z kaaij $
% $Date: 2018-09-14 18:56:51 +0800 (Fri, 14 Sep 2018) $
% $Author: kaaij $
% $Revision: 14588 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase2nc.m $
% $Keywords: $

% TO DO: make time dimension unlimited
% TO DO: use single precision for parameter
% TO DO: save meta-info properties as int8 with each number explained in an att called legend, see also CF flags

%% Choose parameter
%  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table/
%  keep name shorter than namelengthmax (=63)

OPT.donar_wnsnum       = []; % 0=all or select index from OPT.names above

%% Initialize

OPT.dump               = 0;
OPT.display            = 'multiWaitbar'; %1; % empty is multiWaitbar, 1=command line
OPT.pause              = 0;
OPT.debug              = 0;

OPT.refdatenum         = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
OPT.refdatenum         = datenum(1970,1,1); % lunix  datenumber convention
OPT.fillvalue          = nan;                 % NaNs do work in netcdf API
OPT.wgs84              = 4326;

OPT.att_name           = {''};
OPT.att_val            = {''};

%% File loop

%OPT.directory_raw      = 'P:\mcdata\OpenEarthRawData\rijkswaterstaat\waterbase\cache\';        % [];%
%OPT.directory_raw      = 'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\cache\';
OPT.directory_raw      = 'd:\OpenEarth\waterbase\';

%OPT.directory_nc       = 'P:\mcdata\opendap\rijkswaterstaat\waterbase\';                       % [];%
%OPT.directory_nc       = 'F:\checkouts\OpenEarthRawData\rijkswaterstaat\waterbase\processed\'; % [];%
OPT.directory_nc       = 'd:\OpenEarth\waterbase_nc\'; % [];%

OPT.ext                = '';

OPT.mask               = 'id*.txt';
OPT.mask               = 'id*.zip';

OPT.unzip              = 1; % process only zipped files: unzip them, and delete if afterwards
OPT.load               = 1; % 0=auto read mat file, 1=load slow *.txt file
OPT.method             = 'fgetl';
OPT.uniquecoordinate   = 1; % whether to replace an x vector by mode(x)

%% Keyword,value

OPT = setproperty(OPT,varargin{:});

%% Parameter choice

DONAR     = xls2struct([fileparts(mfilename('fullpath')) filesep 'rws_waterbase_name2standard_name.xls']);
att_names = fieldnames(DONAR);

%% Parameter choice
if  OPT.donar_wnsnum==0
    OPT.donar_wnsnum = OPT.codes;
end

%% Parameter loop

for ivar=[OPT.donar_wnsnum]
    
    %% extract meta-data standards (DONAR, CF, UM Aquo, SeaDataNet)
    try
        index     = find(DONAR.donar_wnsnum==ivar);
    catch
        index     = find(cell2mat(DONAR.donar_wnsnum(2:end))==ivar);
        index = index + 1;
    end
    OPT.name  = DONAR.name{index}; %(1:min(63,length(OPT.standard_name))); % matlab names have a max length of 63 characters
    OPT.units = DONAR.units{index};
    
    for iatt = 1:length(att_names)
        att_name   = att_names{iatt};
        att_val    = DONAR.(att_name);
        if isnumeric(att_val)
            att_values{iatt} = att_val(index);
        else
            att_values{iatt} = att_val{index};
        end
    end
    
    %% File loop of all files in a directory
    if ~exist(OPT.directory_nc,'dir') mkdir(OPT.directory_nc); end;

    OPT.files          = dir([OPT.directory_raw,filesep,OPT.mask]);
    
    multiWaitbar(mfilename,0,'label','Creating netCDF from waterbase ASCII.','color',[0.2 0.6 0.])
    
    
    for ifile=1:length(OPT.files)
        
        clear D
        
        OPT.filename = fullfile(OPT.directory_raw, OPT.files(ifile).name(1:end-4)); % id1-AMRGBVN-196101010000-200801010000.txt
        OPT.fileext = fileext(fullfile(OPT.directory_raw, OPT.files(ifile).name));
        
        disp(['  Processing ',num2str(ifile,'%0.4d'),'/',num2str(length(OPT.files),'%0.4d'),': ',filename(OPT.filename),' to netCDF.'])
        
        multiWaitbar(mfilename,ifile/length(OPT.files),'label',['Processing to netCDF: ',filename(OPT.filename)])
        
        %% 0 Read raw data
        
        if exist([OPT.filename,'.mat'],'file')==2 & OPT.load==0
            
            D = load([OPT.filename,'.mat']);% speeds up considerably
            %% extract url to add it to netCDF nc_global.history
            if ~isfield(D,'url')
                fidurl = fopen([fileparts(OPT.filename),filesep,filename(OPT.filename),'.url'],'r');
                rec    = fgetl(fidurl); % [InternetShortcut]
                rec    = fgetl(fidurl); % URL=%s
                fclose(fidurl);
                D.url  = rec(5:end);
            end
        else
            if OPT.unzip
                OPT.zipname  = [OPT.filename,'.zip'];
                OPT.unzippedfilename = char(unzip(OPT.zipname,filepathstr(OPT.filename)));
            end
            
            if OPT.fileext=='.txt'
                fname = [OPT.filename,'.txt'];
            else
                fname = [OPT.unzippedfilename];
            end
            [D] = rws_waterbase_read(fname,...
                'locationcode',1,...
                'fieldname',OPT.name,...
                'fieldnamescale',1,...
                'method',OPT.method,...
                'url',1);
            if OPT.unzip
                delete([OPT.unzippedfilename]);%,'.txt'
            end
            
            save([OPT.filename,'.mat'],'-struct','D'); % to save time 2nd attempt
            
        end % exist([OPT.filename,'.mat'])
        
        if ~(all(isnan(D.data.datenum)))
            
            %% Unit conversion
            % deal with RWS specific, non-general units here,
            % the general ones are done by convert_units
            if ~(isempty(OPT.units) | isnan(OPT.units))
                if OPT.debug
                    ['data > goal units = ' D.data.units, ' > ' OPT.units]
                end
                if strcmpi(D.data.units,'graad t.o.v. kaartnoorden')
                    if strcmpi(OPT.units,'degree_true')
                        D.data.units       = 'degree_true';
                    else
                        error(['no conversion defined for data units:',D.data.units])
                    end
                elseif strcmpi(D.data.units,'graad')
                    if strcmpi(OPT.units,'degree_true')
                        D.data.units       = 'degree_true';
                    else
                        error(['no conversion defined for data units:',D.data.units])
                    end
                elseif strcmpi(D.data.units,'graden Celsius')
                    if strcmpi(    OPT.units,'degree_Celsius')
                        D.data.units           = 'degree_Celsius';
                    else
                        error(['no conversion defined for data units:',D.data.units])
                    end
                elseif strcmpi(D.data.units,'oC') % donar_wnsnum=44
                    if strcmpi(    OPT.units,'degree_Celsius')
                        D.data.units           = 'degree_Celsius';
                    else
                        error(['no conversion defined for data units:',D.data.units])
                    end
                elseif strcmpi(D.data.units,'DIMSLS')  % introduced by rws between june 2010 and mar 2011 for donar_wnsnum=559
                    if strcmpi(OPT.units,'psu')
                        D.data.units       = 'psu';
                    elseif strcmpi(OPT.units,'ppt')
                        D.data.units       = 'ppt';
                    elseif strcmpi(OPT.units,'1') % for pH
                        D.data.units       = '1';
                    else
                        error(['no conversion defined for data units:',D.data.units])
                    end
                elseif strcmpi(D.data.units,'psu')
                    if strcmpi(OPT.units,'psu')
                        D.data.units       = 'psu';
                    end
                elseif strcmpi(D.data.units,'cm t.o.v. NAP')
                    D.data.units           = 'cm';
                    D.data.(OPT.name) = D.data.(OPT.name).*convert_units(D.data.units,OPT.units);
                    D.data.units      = OPT.units;
                elseif strcmpi(D.data.units,'cm t.o.v. Mean Sea Level')
                    D.data.units           = 'cm';
                    D.data.(OPT.name) = D.data.(OPT.name).*convert_units(D.data.units,OPT.units);
                    D.data.units      = OPT.units;
                elseif strcmpi(D.data.units,'/m')
                    D.data.units           = '1/m';
                    D.data.(OPT.name) = D.data.(OPT.name).*convert_units(D.data.units,OPT.units);
                    D.data.units      = OPT.units;
                else
                    D.data.(OPT.name) = D.data.(OPT.name).*convert_units(D.data.units,OPT.units);
                    D.data.units      = OPT.units;
                end
            else
                if OPT.debug
                    ['data units kept = ' D.data.units]
                end
                D.data.units = '';
            end
            D.version     = '';
            
            %% 0 Create file
            %  should work when filename is
            %  * id22-IJMDMNTSPS-190001010000-201003062359.txt(.zip)
            %  * id22-IJMDMNTSPS.txt(.zip)
            
            fname = OPT.files(ifile).name; % can include .zip
            ind = strfind (fname,'-'); if length(ind)==1;ind=[ind strfind(fname,'.txt')];end
            ncfile    = fullfile(OPT.directory_nc,[fname(1:ind(2)-1),OPT.ext,'.nc']); % id1-AMRGBVN*
            
            if OPT.debug;disp(ncfile);end
            
            nc_create_empty (ncfile)
            
            %% 1 Add global meta-info to file
            %  Add overall meta info:
            %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
            
            nc_attput(ncfile, nc_global, 'title'           , '');
            nc_attput(ncfile, nc_global, 'institution'     , 'Rijkswaterstaat');
            nc_attput(ncfile, nc_global, 'source'          , 'surface observation');
            nc_attput(ncfile, nc_global, 'history'         , ['Source: ',D.url,', tranformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_waterbase2nc.m $ $Revision: 14588 $ $Date: 2018-09-14 18:56:51 +0800 (Fri, 14 Sep 2018) $ $Author: kaaij $']);
            nc_attput(ncfile, nc_global, 'references'      , '<http://www.waterbase.nl>,<http://openearth.deltares.nl>');
            nc_attput(ncfile, nc_global, 'email'           , '<servicedesk-data@rws.nl>');
            
            nc_attput(ncfile, nc_global, 'comment'         , 'The structure of this netCDF file is described in: https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions, http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.5/cf-conventions.html#id2867470');
            nc_attput(ncfile, nc_global, 'version'         , D.version);
            
            nc_attput(ncfile, nc_global, 'Conventions'     , 'CF-1.6, UM Aquo 2010 proof of concept, SeaDataNet proof of concept'); % these are independent conventions, so separate by comma: http://www.unidata.ucar.edu/software/netcdf/conventions.html
            nc_attput(ncfile, nc_global, 'featureType'     , 'timeSeries');  % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#featureType
            
            nc_attput(ncfile, nc_global, 'terms_for_use'   , 'These data can be used freely for research purposes provided that the following source is acknowledged: Rijkswaterstaat.');
            nc_attput(ncfile, nc_global, 'disclaimer'      , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
            
            nc_attput(ncfile, nc_global, 'stationname'     , D.data.location);
            nc_attput(ncfile, nc_global, 'location'        , D.data.location);
            nc_attput(ncfile, nc_global, 'donar_code'      , D.data.locationcode);
            nc_attput(ncfile, nc_global, 'locationcode'    , D.data.locationcode);
            
            % MAKE A VARIABLE WITH ATTS flag_values (1:length(unique(val))) AND flag_meanings (unique(val))
            % ATTS TO VAR                                                                  -1----------------                -2---------- -3------------------------------------ -4------- -5---                                              -8---- -9-------------------------------------------------------------------
            % ATTS TO Z                                                                                                                                                                         -1----- -2-----------------
            % ATTS TO X,Y                                                                                                                                                                                                   -1--  VARABLE
            % locatie           ;waarnemingssoort                         ;datum     ;tijd ;bepalingsgrenscode;waarde;eenheid;hoedanigheid;anamet                                ;ogi      ;vat  ;bemhgt;refvlk             ;EPSG;x/lat;y/long;orgaan;biotaxon (cijfercode,biotaxon omschrijving,biotaxon Nederlandse naam)
            % Breskens badstrand;Zwevende stof in mg/l in oppervlaktewater;1988-06-14;07:21;                  ;70    ;mg/l   ;NVT         ;Bepaling van hoeveelheid zwevende stof;Nationaal;Pomp ;  -100;T.o.v. Waterspiegel;7415;28370;380620;NVT   ;NVT,NVT,Niet van toepassing
            % Breskens badstrand;Zwevende stof in mg/l in oppervlaktewater;1995-10-23;08:20;                  ;95    ;mg/l   ;NVT         ;Bepaling van hoeveelheid zwevende stof;Nationaal;Emmer;  -100;T.o.v. Waterspiegel;7415;28370;380620;NVT   ;NVT,NVT,Niet van toepassing
            
            nc_attput(ncfile, nc_global, 'waarnemingssoort', D.data.waarnemingssoort);
            
            if ischar(D.data.refvlk)
                nc_attput(ncfile, nc_global, 'reference_level' , D.data.refvlk);
            else
                nc_attput(ncfile, nc_global, 'reference_level' , str2line({D.data.refvlk},'s',';')');
            end
            
            if isfield(D.data,'hoedanigheid')
                if  length(D.data.hoedanigheid)==1;nc_attput(ncfile, nc_global, 'hoedanigheid' , D.data.hoedanigheid);end
            end
            
            if isfield(D.data,'anamet')
                if  length(D.data.anamet      )==1;nc_attput(ncfile, nc_global, 'anamet'       , D.data.anamet      );end
            end
            
            if isfield(D.data,'ogi')
                if  length(D.data.ogi         )==1;nc_attput(ncfile, nc_global, 'ogi'          , D.data.ogi         );end
            end
            
            if isfield(D.data,'vat') % cel if varying over stations
                if  ischar(D.data.vat         )   ;nc_attput(ncfile, nc_global, 'vat'          , D.data.vat         );
                else
                    nc_attput(ncfile, nc_global, 'vat'          , 'varying'          );
                end
            end
            
            
            %% Add discovery information (test):
            
            %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
            
            nc_attput(ncfile, nc_global, 'geospatial_lat_min'         , min(D.data.lat));
            nc_attput(ncfile, nc_global, 'geospatial_lat_max'         , max(D.data.lat));
            nc_attput(ncfile, nc_global, 'geospatial_lon_min'         , min(D.data.lon));
            nc_attput(ncfile, nc_global, 'geospatial_lon_max'         , max(D.data.lon));
            nc_attput(ncfile, nc_global, 'time_coverage_start'        , datestr(D.data.datenum(  1),'yyyy-mm-ddPHH:MM:SS'));
            nc_attput(ncfile, nc_global, 'time_coverage_end'          , datestr(D.data.datenum(end),'yyyy-mm-ddPHH:MM:SS'));
            nc_attput(ncfile, nc_global, 'geospatial_lat_units'       , 'degrees_north');
            nc_attput(ncfile, nc_global, 'geospatial_lon_units'       , 'degrees_east' );
            
            %% 2 Create dimensions
            
            nc_add_dimension(ncfile, 'time'        , length(D.data.datenum))
            nc_add_dimension(ncfile, 'locations'   , 1);
            nc_add_dimension(ncfile, 'name_strlen1', max(length(D.data.locationcode),1)); % for multiple stations get max length
            nc_add_dimension(ncfile, 'name_strlen2', max(length(D.data.location    ),1)); % for multiple stations get max length
            
            %% 3 Create variables
            
            clear nc
            ifld = 0;
            
   %% Station number: allows for exactly same variables when multiple timeseries in one netCDF file
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html#time-series-data
            
            ifld = ifld + 1;
            nc(ifld).Name         = 'platform_id';
            nc(ifld).Nctype       = 'char';
            nc(ifld).Dimension    = {'locations','name_strlen1'};
            nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'platform identification code');
            nc(ifld).Attribute(2) = struct('Name', 'cf_role'        ,'Value', 'timeseries_id');
            nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'platform_id');
            
            ifld = ifld + 1;
            nc(ifld).Name         = 'platform_name';
            nc(ifld).Nctype       = 'char';
            nc(ifld).Dimension    = {'locations','name_strlen2'};
            nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'platform name');
            nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'platform_name');
            
            % Define dimensions in this order:
            % [time,z,y,x]
            %
            % For standard names see:
            % http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table
            
            % Longitude:
            % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
            
            ifld = ifld + 1;
            nc(ifld).Name             = 'lon';
            nc(ifld).Nctype           = 'float'; % no double needed
            nc(ifld).Dimension        = {'locations'};
            if length(D.data.lon(:))>1
                if OPT.uniquecoordinate
                    D.data.lon = mode(D.data.lon);
                    nc(ifld).Dimension        = {'locations'};
                    nc(ifld).Attribute(    1) = struct('Name', 'actual_range'   ,'Value', [min(D.data.lon(:)) max(D.data.lon(:))]);
                    nc(ifld).Attribute(end+1) = struct('Name', 'comment'        ,'Value', 'lon vector replaced by mode(lon), see attribute actual_range');
                else
                    nc(ifld).Dimension        = {'locations','time'};
                    nc(ifld).Attribute(    1) = struct('Name', 'comment'        ,'Value', '');
                end
            end
            nc(ifld).Attribute(end+1) = struct('Name', 'long_name'      ,'Value', 'station longitude');
            nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
            nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude');
            nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
            
            % Latitude:
            % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
            
            ifld = ifld + 1;
            nc(ifld).Name             = 'lat';
            nc(ifld).Nctype           = 'float'; % no double needed
            nc(ifld).Dimension        = {'locations'};
            if length(D.data.lat(:))>1
                if OPT.uniquecoordinate
                    D.data.lat = mode(D.data.lat);
                    nc(ifld).Dimension        = {'locations'};
                    nc(ifld).Attribute(    1) = struct('Name', 'actual_range'   ,'Value', [min(D.data.lat(:)) max(D.data.lat(:))]);
                    nc(ifld).Attribute(end+1) = struct('Name', 'comment'        ,'Value', 'lat vector replaced by mode(lat), see attribute actual_range');
                else
                    nc(ifld).Dimension        = {'locations','time'};
                    nc(ifld).Attribute(    1) = struct('Name', 'comment'        ,'Value', '');
                end
            end
            nc(ifld).Attribute(end+1) = struct('Name', 'long_name'      ,'Value', 'station latitude');
            nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
            nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'latitude');
            nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
            
            %% lat/lon coordinate system
            %  and x/y coordinate system
            %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
            
            ifld = ifld + 1;
            nc(ifld).Name         = 'wgs84';
            nc(ifld).Nctype       = nc_int;
            nc(ifld).Dimension    = {};
            nc(ifld).Attribute    = nc_cf_grid_mapping(OPT.wgs84);
            
            if ~(D.data.epsg==OPT.wgs84) % sometimes x/y are already wgs84, then no need for x/y
                
                ifld = ifld + 1;
                nc(ifld).Name         = 'epsg';
                nc(ifld).Nctype       = nc_int;
                nc(ifld).Dimension    = {};
                nc(ifld).Attribute    = nc_cf_grid_mapping(D.data.epsg);
                
                % x:
                
                ifld = ifld + 1;
                nc(ifld).Name             = 'x';
                nc(ifld).Nctype           = 'float'; % no double needed
                nc(ifld).Dimension        = {'locations'};
                if length(D.data.x(:))>1
                    if OPT.uniquecoordinate
                        D.data.x = mode(D.data.x);
                        nc(ifld).Dimension        = {'locations'};
                        nc(ifld).Attribute(    1) = struct('Name', 'actual_range'   ,'Value', [min(D.data.x(:)) max(D.data.x(:))]);
                        nc(ifld).Attribute(end+1) = struct('Name', 'comment'        ,'Value', 'x vector replaced by mode(x), see attribute actual_range');
                    else
                        nc(ifld).Dimension        = {'locations','time'};
                        nc(ifld).Attribute(    1) = struct('Name', 'comment'        ,'Value', '');
                    end
                end
                nc(ifld).Attribute(end+1) = struct('Name', 'long_name'      ,'Value', 'station x');
                nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
                nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate');
                nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');
                
                % y:
                
                ifld = ifld + 1;
                nc(ifld).Name             = 'y';
                nc(ifld).Nctype           = 'float'; % no double needed
                nc(ifld).Dimension        = {'locations'};
                if length(D.data.y(:))>1
                    if OPT.uniquecoordinate
                        D.data.y = mode(D.data.y);
                        nc(ifld).Dimension        = {'locations'};
                        nc(ifld).Attribute(    1) = struct('Name', 'actual_range'   ,'Value', [min(D.data.y(:)) max(D.data.y(:))]);
                        nc(ifld).Attribute(end+1) = struct('Name', 'comment'        ,'Value', 'y vector replaced by mode(y), see attribute actual_range');
                    else
                        nc(ifld).Dimension        = {'locations','time'};
                        nc(ifld).Attribute(    1) = struct('Name', 'comment'        ,'Value', '');
                    end
                end
                nc(ifld).Attribute(end+1) = struct('Name', 'long_name'      ,'Value', 'station y');
                nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
                nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate');
                nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');
                
            end
            
            % z:
            
            ifld = ifld + 1;
            nc(ifld).Name             = 'z';
            nc(ifld).Nctype           = 'float'; % no double needed
            if length(D.data.z)==1
                nc(ifld).Dimension        = {'locations'};
            else
                nc(ifld).Dimension        = {'locations','time'};
            end
            nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'station depth');
            nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'meters');
            nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'height_above_reference_ellipsoid');
            nc(ifld).Attribute(end+1) = struct('Name', 'positive'       ,'Value', 'up');
            nc(ifld).Attribute(end+1) = struct('Name', 'axis'           ,'Value', 'Z');
            
            % Time:
            % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate
            % time is a dimension, so there are two options:
            % * the variable name needs the same as the dimension:
            %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
            % * there needs to be an indirect mapping through the coordinates attribute:
            %   http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
            
            OPT.timezone = timezone_code2iso('MET');
            
            ifld = ifld + 1;
            nc(ifld).Name             = 'time';
            nc(ifld).Nctype           = 'double'; % float not sufficient as datenums are big: doubble
            nc(ifld).Dimension        = {'time'};
            nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'time');
            nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
            nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'time');
            nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
            
            %nc(ifld).Attribute(5) = struct('Name', 'bounds'         ,'Value', '');
            
            % Parameters with standard names:
            % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/standard-name-table/
            
            ifld = ifld + 1;
            nc(ifld).Name             = OPT.name; % thre isn't always a standard name, and it can be over 63 chars long
            nc(ifld).Nctype           = 'float'; % no double needed
            nc(ifld).Dimension        = {'locations','time'};
            nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(D.data.(OPT.name)) max(D.data.(OPT.name))]);
            
            % standard names
            for jj=1:length(att_names)
                nc(ifld).Attribute(end+1) = struct('Name', att_names{jj}    ,'Value', att_values{jj});
            end
            
            nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', single(OPT.fillvalue)); % needs to be same type as data itself (i.e. single)
            nc(ifld).Attribute(end+1) = struct('Name', 'cell_methods'   ,'Value', 'time: point area: point');
            nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');  % QuickPlot error
            
            % custom atts
            for jj=1:length(OPT.att_name)0
                nc(ifld).Attribute(end+1) = struct('Name', OPT.att_name{jj} ,'Value', OPT.att_val{jj});
            end
            
            %% 4 Create variables with attibutes
            % When variable definitons are created before actually writing the
            % data in the next cell, netCDF can nicely fit all data into the
            % file without the need to relocate any info.
            
            for ifld=1:length(nc)
                if OPT.debug;disp([num2str(ifld),' ',nc(ifld).Name]);end
                nc_addvar(ncfile, nc(ifld));
            end
            
            %% 5 Fill variables
            
            nc_varput(ncfile, 'platform_id'  , D.data.locationcode);
            nc_varput(ncfile, 'platform_name', D.data.location);
            nc_varput(ncfile, 'lon'          , D.data.lon);
            nc_varput(ncfile, 'lat'          , D.data.lat);
            if ~(D.data.epsg==OPT.wgs84) % sometimes x/y are already wgs84, then no need for x/y
                nc_varput(ncfile, 'x'        , D.data.x);
                nc_varput(ncfile, 'y'        , D.data.y);
            end
            nc_varput(ncfile, 'z'            , D.data.z(:)');  % orientation matters because netCDF variable is 2D: [location x time]
            nc_varput(ncfile, 'time'         , D.data.datenum(:)' - OPT.refdatenum);
            nc_varput(ncfile, OPT.name       , D.data.(OPT.name)(:)');  % orientation matters because netCDF variable is 2D: [location x time]
            nc_varput(ncfile, 'wgs84'        , OPT.wgs84);
            if nc_isvar(ncfile,'epsg')
                nc_varput(ncfile, 'epsg'     , D.data.epsg); % always keep as, because when x/y are wgs84 they refer to epsg
            end
            
            %% 6 Check
            
            if OPT.dump
                nc_dump(ncfile);
            end
            
            %% Pause
            
            if OPT.pause
                pausedisp
            end
            
        end
        
    end %file loop % for ifile=1:length(OPT.files)
    
    multiWaitbar(mfilename,1,'label','Created netCDF from waterbase ASCII.')
    
end %variable loop % for ivar=1:length(OPT.codes)

%% EOF
