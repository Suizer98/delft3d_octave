function varargout=dart(opt,varargin)
%NOAA.DATA get capabilities, inventory meta-data or data from DART DODS data
%
%  S      = noaa.dart('getcapabilities') loads capabilities into DDB struct
% [S,C]   = noaa.dart('getcapabilities') returnc nc_cf_harvest format
% [S,C,R] = noaa.dart('getcapabilities') also loads raw capabilities csv data
%
%See also: getcoopsdata, getndbcdata, getICESdata, 
%  https://comms01.ndbc.noaa.gov/dart/dart_meta/public.php
%  http://www.ndbc.noaa.gov/dart_stations.php 
%  http://dods.ndbc.noaa.gov/thredds/catalog/data/dart/

% getcapabilities
%OPT.outputfile   = 'ddb';
OPT.cache = 1;

switch lower(opt)
    case{'getcapabilities'}
    % download latest meta-data of operational al buoys
    xlsname = [fileparts(mfilename('fullpath')),filesep,'dartmeta_public.xls'];
    if ~(OPT.cache) & exist(xlsname)
    disp('please wait while downloading data')
    urlwrite('http://www.ndbc.noaa.gov/dart_metadata/dartmeta_public.xls',...
        xlsname);
    end

    [X,~] = csv2struct(xlsname,'units',1,'delimiter',char(9));
    %X = urlread('http://www.ndbc.noaa.gov/dart_stations.php')
    
    % DART
    % Deep-ocean Assessment and Reporting of Tsunamis technology.
    % BPR:
    % Bottom Pressure Recorder
    % TX:
    % Transmission
    % Deployment IDs:
    % Station and Date when BPR was deployed.
    % Start current Deployment:
    % The date when the BPR was deployed.
    % Start of current real-time data:
    % First release of data during current deployment.
    % Transmission Status:
    % Description of the state of the real-time data transmissions.
    % Ocean Designator:
    % The basin (Atlantic (A), Pacific (P)) and initial establishment priority number of the site.
    % GTS IDs:
    % The bulletin headers used to send out the station messages on the Global Telecommunication System (GTS) and NOAAPORT. Click for additional info.
    % Transmitter IDs:
    % The 8-character identifier that contains the WMO Station Index Number and the transmitter designator - primary (P), secondary (S). The transmitter id is included in the GTS messages.
    % Service date:
    % The date the last service of the buoy of BPR occurred.
    % Establishment date:
    % Date at which this Station (not site) was first operational.
    % Trigger threshold:
    % The difference between the predicted water-column height and the measured height that will cause the system to go into rapid reporting or Event Mode. Adjustable to a value between 30 - 89 mm. based on conditions at each station. Click for additional info.
    % Generation:
    % DART II generation. Click for additional info.
    % DART II* generation with newer version of firmware. Click for additional info.
    
    D.lon   = str2deg(X.BPR_Longitude); % BPR_Longitude
    D.lat   = str2deg(X.Buoy_Latitude); % BPR_Latitude
    D.ID    = cellstr(num2str(X.WMO_ID));
    D.name  = X.Hull;
    D.depth = X.PAROS_Returned_Depth__m_;
    D.t0    = datenum(X.Start_of_real_time_data);
    
    CATALOG.geospatialCoverage_eastwest_start   = D.lon;
    CATALOG.geospatialCoverage_northsouth_start = D.lat;
    CATALOG.platform_id                         = D.ID;
    CATALOG.platform_name                       = D.ID;
    CATALOG.timeCoverage_start                  = D.t0;
    CATALOG.timeCoverage_end                    = D.t0*nan;
    
    varargout{1}=D;
    if nargout>1
    varargout{2}=CATALOG;
    end
    if nargout>2
    varargout{3}=X;
    end
end



    