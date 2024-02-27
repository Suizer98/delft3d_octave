function varargout=ddb_ObservationStations_dart(opt,varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'id','stationid'}
                id=varargin{ii+1};
            case{'parameter'}
                parameter=varargin{ii+1};
            case{'starttime','t0'}
                t0=varargin{ii+1};
            case{'stoptime','t1'}
                t1=varargin{ii+1};
            case{'inputfile'}
                inputfile=varargin{ii+1};
            case{'outputfile'}
                outputfile=varargin{ii+1};
        end
    end
end

switch lower(opt)
    case{'readdatabase'}
        varargout{1}=readDatabase(inputfile);
    case{'getobservations'}
        varargout{1}=getData(id,parameter,t0,t1);
end

%%
function database=readDatabase(inputfile)

s=load(inputfile);
s=s.s;

database.name='dart';
database.longname=s.DatabaseName;
database.institution=s.Institution;
database.coordinatesystem.name=s.CoordinateSystem;
database.coordinatesystem.type=s.CoordinateSystemType;
database.servertype=s.ServerType;
database.url=s.URL;
database.stationlongnames=s.Name;
database.stationids=s.IDCode;
database.stationnames=s.Name;
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

database.datums={''};
database.datum='';

database.subset='';
database.subsets={''};
database.subsetnames={''};

database.timezones={''};
database.timezone='';

database.download=0;
