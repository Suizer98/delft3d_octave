function handles = ddb_initializeDFlowFMdomain(handles, opt, id, runid)

handles.model.dflowfm.domain(id).runid=runid;

switch lower(opt)
    case{'griddependentinput'}
        handles=initializeGridDependentInput(handles,id);
    case{'all'}
        handles=initializeGridDependentInput(handles,id);
        handles=initializeOtherInput(handles,id,runid);
end

%%
function handles=initializeGridDependentInput(handles,id)

% Only the grid dependent input
handles.model.dflowfm.domain(id).grid=[];
handles.model.dflowfm.domain(id).bathymetry=[];
handles.model.dflowfm.domain(id).plothandles=[];

%% Geometry
handles.model.dflowfm.domain(id).netfile             = '';
handles.model.dflowfm.domain(id).netstruc            = [];
handles.model.dflowfm.domain(id).bathymetryfile      = '';
handles.model.dflowfm.domain(id).waterlevinifile     = '';                 
handles.model.dflowfm.domain(id).landboundaryfile    = '';                     
handles.model.dflowfm.domain(id).thindamfile         = '';                     
handles.model.dflowfm.domain(id).thindykefile        = '';                    
handles.model.dflowfm.domain(id).proflocfile         = '';                     
handles.model.dflowfm.domain(id).profdeffile         = '';                    
handles.model.dflowfm.domain(id).manholefile         = '';
handles.model.dflowfm.domain(id).waterlevini         = 0;
handles.model.dflowfm.domain(id).botlevuni           = -5;
handles.model.dflowfm.domain(id).botlevtype          = 3;
handles.model.dflowfm.domain(id).anglat              = 0;
handles.model.dflowfm.domain(id).conveyance2d        = 3;
handles.model.dflowfm.domain(id).circumference       = [];

%% Observation points
handles.model.dflowfm.domain(id).obsfile      = '';
handles.model.dflowfm.domain(id).nrobservationpoints=0;
handles.model.dflowfm.domain(id).observationpoints(1).name='';
handles.model.dflowfm.domain(id).observationpoints(1).x=NaN;
handles.model.dflowfm.domain(id).observationpoints(1).y=NaN;
handles.model.dflowfm.domain(id).observationpointshandle='';
handles.model.dflowfm.domain(id).activeobservationpoint=1;
handles.model.dflowfm.domain(id).observationpointnames={''};
handles.model.dflowfm.domain(id).selectobservationpoint=0;
handles.model.dflowfm.domain(id).changeobservationpoint=0;
handles.model.dflowfm.domain(id).deleteobservationpoint=0;
handles.model.dflowfm.domain(id).addobservationpoint=0;

%% Cross sections
handles.model.dflowfm.domain(id).crsfile      = '';
handles.model.dflowfm.domain(id).nrcrosssections=0;
handles.model.dflowfm.domain(id).crosssections(1).name='';
handles.model.dflowfm.domain(id).crosssections(1).x=0;
handles.model.dflowfm.domain(id).crosssections(1).y=0;
handles.model.dflowfm.domain(id).crosssectionshandle='';
handles.model.dflowfm.domain(id).activecrosssection=1;
handles.model.dflowfm.domain(id).crosssectionnames={''};

%% External forcing
handles.model.dflowfm.domain(id).extforcefilenew        = '';
handles.model.dflowfm.domain(id).bcfile                 = '';

% Boundaries
handles.model.dflowfm.domain(id).boundary(1).boundary=ddb_delft3dfm_initialize_boundary('','water_level','astronomic',floor(now),floor(now)+10,0,0);
handles.model.dflowfm.domain(id).nrboundaries = 0;
handles.model.dflowfm.domain(id).boundarynames = {''};
handles.model.dflowfm.domain(id).activeboundary=1;

% Meteo
handles.model.dflowfm.domain(id).windufile = '';
handles.model.dflowfm.domain(id).windvfile = '';
handles.model.dflowfm.domain(id).airpressurefile = '';
handles.model.dflowfm.domain(id).spiderwebfile = '';
handles.model.dflowfm.domain(id).rainfile = '';

%%
handles.model.dflowfm.domain(id).foufile      = '';

%%
function handles=initializeOtherInput(handles,id,runid)

% All the other input

handles.model.dflowfm.domain(id).attName=runid;

%% Model
handles.model.dflowfm.domain(id).autostart=1;

%% Description
handles.model.dflowfm.domain(id).description={''};

%% Numerics
handles.model.dflowfm.domain(id).cflmax              = 0.7;
handles.model.dflowfm.domain(id).cflwavefrac         = 0.1;
handles.model.dflowfm.domain(id).advectype           = 3;
handles.model.dflowfm.domain(id).limtypsa            = 0;
handles.model.dflowfm.domain(id).hdam                = 0;
handles.model.dflowfm.domain(id).tlfsmo              = 3600;

%% Physics
handles.model.dflowfm.domain(id).uniffrictcoef       = 0.023;
handles.model.dflowfm.domain(id).uniffricttype       = 1;
handles.model.dflowfm.domain(id).vicouv              = 1;
handles.model.dflowfm.domain(id).smagorinsky         = 0;
handles.model.dflowfm.domain(id).elder               = 0;
handles.model.dflowfm.domain(id).irov                = 0;
handles.model.dflowfm.domain(id).wall_ks             = 0.01;
handles.model.dflowfm.domain(id).vicoww              = 0;
handles.model.dflowfm.domain(id).tidalforcing        = 0;
handles.model.dflowfm.domain(id).salinity            = 0;

%% Wind
handles.model.dflowfm.domain(id).icdtyp=3;
handles.model.dflowfm.domain(id).cdbreakpoints=[0.00100  0.00300 0.0015];
handles.model.dflowfm.domain(id).windspeedbreakpoints=[0.0 25.0 50.0];
handles.model.dflowfm.domain(id).pavbnd=101200;
handles.model.dflowfm.domain(id).rhoair=1.2;

%% Time
handles.model.dflowfm.domain(id).refdate        = floor(now);
handles.model.dflowfm.domain(id).tunit          = 's';
handles.model.dflowfm.domain(id).dtuser         = 60.0;
handles.model.dflowfm.domain(id).dtmax          = 60.0;
handles.model.dflowfm.domain(id).dtinit         = 1.0;
handles.model.dflowfm.domain(id).autotimestep   = 1;
handles.model.dflowfm.domain(id).tstart         = floor(now);
handles.model.dflowfm.domain(id).tstop          = floor(now)+10;

%% Output
handles.model.dflowfm.domain(id).hisfile      = '';
handles.model.dflowfm.domain(id).hisinterval  = 600.0;
handles.model.dflowfm.domain(id).xlsinterval  = 0;
handles.model.dflowfm.domain(id).flowgeomfile = '';
handles.model.dflowfm.domain(id).mapfile      = '';
handles.model.dflowfm.domain(id).mapinterval  = 3600;
handles.model.dflowfm.domain(id).rstinterval  = 0;
handles.model.dflowfm.domain(id).waqfilebase  = '';
handles.model.dflowfm.domain(id).waqinterval  = 0;
handles.model.dflowfm.domain(id).snapshotdir  = '';

%% Fourier analysis
handles.model.dflowfm.domain(id).fourier.parameterList={'water level','velocity','discharge'};
handles.model.dflowfm.domain(id).fourier.pList={'wl','uv','qf'};
handles.model.dflowfm.domain(id).fourier.optionList={'fourier','max','min','ellipse'};
handles.model.dflowfm.domain(id).fourier.tableOption='generate';
handles.model.dflowfm.domain(id).fourier.include=0;
handles.model.dflowfm.domain(id).fourier.foufile='';

% Edit table
handles.model.dflowfm.domain(id).fourier.editTable.parameterNumber=1;
handles.model.dflowfm.domain(id).fourier.editTable.startTime=floor(now);
handles.model.dflowfm.domain(id).fourier.editTable.stopTime=floor(now)+1;
handles.model.dflowfm.domain(id).fourier.editTable.nrCycles=1;
handles.model.dflowfm.domain(id).fourier.editTable.nodalAmplificationFactor=1;
handles.model.dflowfm.domain(id).fourier.editTable.astronomicalArgument=0;
handles.model.dflowfm.domain(id).fourier.editTable.layer=1;
handles.model.dflowfm.domain(id).fourier.editTable.max=0;
handles.model.dflowfm.domain(id).fourier.editTable.min=0;
handles.model.dflowfm.domain(id).fourier.editTable.ellipse=0;
handles.model.dflowfm.domain(id).fourier.editTable.option=1;

handles.model.dflowfm.domain(id).fourier.generateTable.parameterNumber=1;
handles.model.dflowfm.domain(id).fourier.generateTable.astronomicalComponents='M2';
handles.model.dflowfm.domain(id).fourier.generateTable.componentNumber=1;
handles.model.dflowfm.domain(id).fourier.generateTable.layer=1;
handles.model.dflowfm.domain(id).fourier.generateTable.fourier=1;
handles.model.dflowfm.domain(id).fourier.generateTable.max=0;
handles.model.dflowfm.domain(id).fourier.generateTable.min=0;
handles.model.dflowfm.domain(id).fourier.generateTable.ellipse=0;

handles.model.dflowfm.domain(id).fourier.layerList{1}='1';
handles.model.dflowfm.domain(id).fourier.spinUpTime=1440;

tt=t_getconsts;
handles.model.dflowfm.domain(id).fourier.astronomicalComponents=[];
for i=1:size(tt.name,1)
    handles.model.dflowfm.domain(id).fourier.astronomicalComponents{i}=deblank(tt.name(i,:));
end
