function varargout=DDB_OBSERVATIONSTATIONS_NDBC(OPT,varargin)
%DDB_OBSERVATIONSTATIONS_NDBC ddb wrapper for getndbcdata
%
%See also: getndbcdata, getcoopsdata

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'id','stationid'}
                id=varargin{ii+1};
            case{'parameter'}
                parameter=varargin{ii+1};
            case{'starttime','t0','tstart'}
                t0=varargin{ii+1};
            case{'stoptime','t1','tstop'}
                t1=varargin{ii+1};
            case{'inputfile'}
                inputfile=varargin{ii+1};
            case{'outputfile'}
                outputfile=varargin{ii+1};
        end
    end
end

switch lower(OPT)
    case{'readdatabase'}
        % Set capabilities in global structure
        getndbcdata('getcapabilities','inputfile',inputfile);
        varargout{1}=readDatabase;
    case{'getobservations'}
        varargout{1}=getndbcdata('getobservations','id',id,'parameter',parameter,'t0',t0,'t1',t1);
end

%%
function database=readDatabase

database.name                  = 'ndbc';
database.longname              = 'NDBC';
database.institution           = 'NDBC';
database.coordinatesystem.name = 'WGS 84';
database.coordinatesystem.type = 'geographic';
database.servertype            = [];
database.url                   = [];

stations=getndbcdata('getstations');

for istat=1:length(stations)
    database.stationlongnames{istat} = stations(istat).description;
    database.stationnames{istat}     = stations(istat).description;
    database.stationids{istat}       = stations(istat).id;
    database.x(istat)                = stations(istat).x;
    database.y(istat)                = stations(istat).y;
    database.xlocal(istat)           = stations(istat).x;
    database.ylocal(istat)           = stations(istat).y;
    for j=1:length(stations(istat).observedproperties)
        database.parameters(istat).name{j}=stations(istat).observedproperties{j};
        database.parameters(istat).status(j)=1;
    end
end

database.datums      = {''};
database.datum       = '';

database.subset      = '';
database.subsets     = {''};
database.subsetnames = {''};

database.timezones   = {''};
database.timezone    = '';
 
database.download    = 1;
