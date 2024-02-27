function [transect] = jarkus_createtransectstruct()
%JARKUS_CREATETRANSECTSTRUCT  create jarkus transect struct
%
%    [transect] = jarkus_createtransectstruct()
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

%% Create a transect structure with default values
    
    % this should be a general transect structure not specific to 1
    % dataset. It will be preferably replaced by 1 or more classdefs if
    % enough people have matlab versions which will allow it to just work (tm). 
    
    % start creating a single transect structure
    % TODO: find better names for these variables.
    
    transect.areaCode             = 0;
    transect.areaName             = '';
    transect.time                 = 0; % days since 1970
    transect.alongshoreCoordinate = 0; % dam
    transect.timeTopo             = 0; % days since 1970
    transect.timeBathy            = 0; % days since 1970
    transect.year                 = []; % year of recording (human rep. of time)
    transect.dayTopo              = []; % day of Topo recording (human rep. of timeTopo)
    transect.dayBathy             = []; % day of Bathy recording (human rep. of timeBathy)
    transect.monthTopo            = []; % month of Topo recording (human rep. of timeTopo)
    transect.monthBathy           = []; % month of Bathy recording (human rep. of timeBathy)
    transect.n                    = 0;
    % this is jarkus specific.... should be moved to another entity 
    % Origin of the data (and combine 1,3 and 5):
    % id=1 non-overlap beach data
    % id=2 overlap beach data
    % id=3 interpolation data (between beach and off shore)
    % id=4 overlap off shore data
    % id=5 non-overlap off shore data
    transect.origin               = []; % row vector of origin codes 
    % row vector of cross-shore distance from pole;
    transect.crossShoreCoordinate = []; % m
    % row vector of altitude
    transect.altitude             = []; % m positive up
    transect.id                   = 0;
    transect.timelims             = [];
    transect.nsources             = 1;

end % end function createtransectstruct
