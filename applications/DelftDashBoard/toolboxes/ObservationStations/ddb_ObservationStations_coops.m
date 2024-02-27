function varargout=ddb_ObservationStations_coops(opt,varargin)

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
            case{'datum'}
                datum=varargin{ii+1};
            case{'subset'}
                subset=varargin{ii+1};
            case{'timezone'}
                timezone=varargin{ii+1};
        end
    end
end

switch lower(opt)
    case{'readdatabase'}
        varargout{1}=readDatabase(inputfile);
    case{'getobservations'}
        varargout{1}=getcoopsdata('getobservations','id',id,'parameter',parameter,'t0',t0,'t1',t1,'datum',datum,'subset',subset,'timezone',timezone);
end

%%
function database=readDatabase(inputfile)

s=load(inputfile);
s=s.s;

database.name='co-ops';
database.longname=s.DatabaseName;
database.institution=s.Institution;
database.coordinatesystem.name=s.CoordinateSystem;
database.coordinatesystem.type=s.CoordinateSystemType;
database.servertype=s.ServerType;
database.url=s.URL;
database.stationlongnames=s.Name;
database.stationnames=s.Name;
database.stationids=s.IDCode;
database.subset=[];

for ii=1:length(s.Parameters)
    for jj=1:length(s.Parameters(ii).Name)
        database.parameters(ii).name{jj}=s.Parameters(ii).Name{jj};
        database.parameters(ii).status(jj)=s.Parameters(ii).Status(jj);
    end
end
database.x=s.x;
database.y=s.y;
database.xlocal=s.x;
database.ylocal=s.y;

database.datums={'IGDL','MHW','MLLW','MSL','NAVD','STND'};
database.datum='MSL';

database.subset='verified6minutes';
database.subsets={'verified6minutes','verifiedhourly','raw6minutes'};
database.subsetnames={'Verified 6 Min','Verified hourly','Raw 6 Min'};

database.timezones={'UTM','Local'};
database.timezone='UTM';

database.download=1;
