function varargout=ddb_ObservationStations_usgs(OPT,varargin)
%DDB_OBSERVATIONSTATIONS_NDBC ddb wrapper for getndbcdata
%
%See also: getndbcdata, getcoopsdata

xl=[];
yl=[];

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
            case{'xlim'}
                xl=varargin{ii+1};
            case{'ylim'}
                yl=varargin{ii+1};
        end
    end
end

switch lower(OPT)
    case{'readdatabase'}
        % Set capabilities in global structure
%        getndbcdata('getcapabilities','inputfile',inputfile);
        varargout{1}=readDatabase(xl,yl);
    case{'getobservations'}
        %varargout{1}=getusgsdata('getobservations','id',id,'parameter',parameter,'t0',t0,'t1',t1);
        try 
        if parameter == 'discharges' 
            fnumber = '00060'; 
            data = nwi_usgs_read(id{1,1},t0,t1,fnumber,'d:\');
            figure; plot(data.datenum, data.par_02_00060_00003); datetick('x',6); xlabel('Date'); ylabel('Discharge (mean in cubic feet per second)')
        end
        catch
        end

        try 
        if parameter == 'gage height';  
            fnumber = '00065'; 
            data = nwi_usgs_read(id{1,1},t0,t1,fnumber,'d:\');
            figure; plot(data.datenum, data.par_01_00065_00003); datetick('x',6); xlabel('Date'); ylabel('Gage height (mean in feet)')
        end
        catch
        end
end

%%
function database=readDatabase(xl,yl)
handles = getHandles;
dr=handles.toolbox.observationstations.dataDir;
path = [dr 'usgs.mat'];
load (path)
database = s;
