function cosmos_convertTimeSeriesMat2NC(hm,m)

model=hm.models(m);
archdir = model.appendeddirtimeseries;

yr=year(hm.cycle);
t0=datenum(yr,1,1);

for istat=1:model.nrStations
    
    stName=model.stations(istat).name;
    stLongName=model.stations(istat).longName;
    
    for i=1:model.stations(istat).nrDatasets

        if model.stations(istat).datasets(i).toOPeNDAP
            
            par=model.stations(istat).datasets(i).parameter;
            parLongName=getParameterInfo(hm,par,'longname');
            
            fname=[archdir par '.' stName '.mat'];
            
            if exist(fname,'file')
                
                s=load(fname);
                it1=find(s.Time>=t0,1,'first');
                s.Time=s.Time(it1:end);
                s.Val=s.Val(it1:end);
                
                OPT.title                  = '';
                OPT.institution            = '';
                OPT.source                 = '';
                OPT.history                = ['tranformation to netCDF: $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/cosmos/code/OMSRunner/postproc/general/cosmos_convertTimeSeriesMat2NC.m $'];
                OPT.references             = '';
                OPT.email                  = '';
                OPT.comment                = '';
                OPT.version                = '';
                OPT.acknowledge            =['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution];
                OPT.disclaimer             = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
                
                %% Define dimensions/coordinates
                lon=model.stations(istat).location(1);
                lat=model.stations(istat).location(2);
                
                if ~strcmpi(model.coordinateSystemType,'geographic') || ~strcmpi(model.coordinateSystem,'WGS 84')
                    [lon,lat]=convertCoordinates(lon,lat,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                end

                OPT.lon                    = lon;
                OPT.lat                    = lat;
                OPT.station_name           = stLongName;
                OPT.wgs84.code             = 4326;
                
                %% Define variable (define some data)
                
                OPT.val                    = s.Val;
                OPT.datenum                = s.Time;
                OPT.timezone               = '+00:00';  % MET=+1
                OPT.varname                = par;   % free to choose: will appear in netCDF tree
                OPT.units                  = 'm/s';         % from UDunits package: http://www.unidata.ucar.edu/software/udunits/
                OPT.long_name              = parLongName; % free to choose: will appear in plots
                OPT.standard_name          = parLongName;
                OPT.val_type               = 'single';      % 'single' or 'double'
                OPT.fillvalue              = nan;
                
                ncfile=[archdir stName '.' par '.' num2str(yr) '.nc'];
                
                writeNC(ncfile,OPT);
            end
        end
    end
end

%%
function writeNC(ncfile,OPT)

%% 1.a Create netCDF file

nc_create_empty(ncfile);

%% 1.b Add overall meta info
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents

nc_attput(ncfile, nc_global, 'title'         , OPT.title);
nc_attput(ncfile, nc_global, 'institution'   , OPT.institution);
nc_attput(ncfile, nc_global, 'source'        , OPT.source);
nc_attput(ncfile, nc_global, 'history'       , OPT.history);
nc_attput(ncfile, nc_global, 'references'    , OPT.references);
nc_attput(ncfile, nc_global, 'email'         , OPT.email);

nc_attput(ncfile, nc_global, 'comment'       , OPT.comment);
nc_attput(ncfile, nc_global, 'version'       , OPT.version);

nc_attput(ncfile, nc_global, 'Conventions'   , 'CF-1.4');
nc_attput(ncfile, nc_global, 'CF:featureType', 'Grid');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions

nc_attput(ncfile, nc_global, 'terms_for_use' , OPT.acknowledge);
nc_attput(ncfile, nc_global, 'disclaimer'    , OPT.disclaimer);

%% 2   Create matrix span dimensions
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#dimensions

nc_add_dimension(ncfile, 'time'    , length(OPT.datenum));
nc_add_dimension(ncfile, 'string'  , length(OPT.station_name)); % you could set this to UNLIMITED, be we suggest to keep UNLIMITED for time

% If you would like to include more locations of the same data,
% you can optionally use 'location' as a 2nd dimension.
% Here we use it for one station too, to be able to link cordinates.

nc_add_dimension(ncfile, 'location', 1);

%% 3.a Create coordinate variables: time
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#time-coordinate

% For time we use "x units since reference_date + timezone", where
% * x              can be a character or number,
% * units          can be any units from UDunits: e.g. days, seconds, years, ...
% * reference_date is the moment where t-0 is defined in ISO notation
% * timezone       offset from GMT, in format -/+  HH:00
% For reference_date we advice to use a common epoch. Although gthis is a
% matlab tutorial, the matlab datenumber convention is not adviced:
% Here a a serial date number of 1 corresponds to Jan-1-0000. However, this
% epoch gives wrong dates in ncbrowse, as it uses a different calender. The
% Excel epoch of 31-dec-1899 is too stupid to be worth  mentioning. The Apple
% convenction of 1980 has been superseded since Apple uses unix as a basis. So
% * 1970-01-01    is adviced to use as epoch, the very common linux datenumber
%                 convention (which has no calender issues).

% OPT.refdatenum             = datenum(1970,1,1);

clear nc;ifld = 1;
nc(ifld).Name             = 'time';   % dimension 'time' is here filled with variable 'time'
nc(ifld).Nctype           = 'double';
nc(ifld).Dimension        = {'time'};
nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'time');
% nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', ['seconds since 1900-01-01 00:00:00 ',OPT.timezone]);
nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'time');
% nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.datenum(:)) max(OPT.datenum(:))]-OPT.refdatenum);

%% 3.b Create coordinate variables: longitude
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

ifld = ifld + 1;
nc(ifld).Name             = 'lon';
nc(ifld).Nctype           = 'double';
nc(ifld).Dimension        = {'location'};
nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude');
nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude');
nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lon(:)) max(OPT.lon(:))]);
nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

%% 3.c Create coordinate variables: latitude
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate

ifld = ifld + 1;
nc(ifld).Name             = 'lat';
nc(ifld).Nctype           = 'double';
nc(ifld).Dimension        = {'location'};
nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'latitude');
nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'latitude');
nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lat(:)) max(OPT.lat(:))]);
nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

%% 3.d Create coordinate variables: coordinate system: WGS84 default
%      global ellispes: WGS 84, ED 50, INT 1924, ETRS 89 and the upcoming ETRS update etc.
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#grid-mappings-and-projections
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings

ifld = ifld + 1;
nc(ifld).Name         = 'wgs84'; % preferred
nc(ifld).Nctype       = nc_int;
nc(ifld).Dimension    = {};
nc(ifld).Attribute    = nc_cf_grid_mapping(OPT.wgs84.code);
var2evalstr(nc(ifld).Attribute)

%% 3.e Station number/name/code: proposed on:
%      https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions

ifld = ifld + 1;
nc(ifld).Name         = 'station_id';
nc(ifld).Nctype       = 'char';
nc(ifld).Dimension    = {'location','string'};
nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'station identification code');
nc(ifld).Attribute(2) = struct('Name', 'standard_name'  ,'Value', 'station_id'); % standard name

%% 4   Create dependent variable
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#variables
%      Parameters with standard names:
%      http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

ifld = ifld + 1;
nc(ifld).Name             = OPT.varname;
nc(ifld).Nctype           = nc_type(OPT.val_type);
nc(ifld).Dimension        = {'location','time'};
nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', OPT.long_name    );
nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', OPT.units        );
nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue    );
nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.val(:)) max(OPT.val(:))]);
nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');
nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);

%% 5.a Create all variables with attributes

for ifld=1:length(nc)
    nc_addvar(ncfile, nc(ifld));
end

%% 5.b Fill all variables
tm=(OPT.datenum-datenum(1900,1,1))*86400;
%nc_varput(ncfile, 'time'         , OPT.datenum - OPT.refdatenum);
nc_varput(ncfile, 'time'         , tm);
nc_varput(ncfile, 'lon'          , OPT.lon         );
nc_varput(ncfile, 'lat'          , OPT.lat         );
nc_varput(ncfile, 'wgs84'        , OPT.wgs84.code  );
nc_varput(ncfile, 'station_id'   , OPT.station_name);
nc_varput(ncfile, OPT.varname    , OPT.val'         );
