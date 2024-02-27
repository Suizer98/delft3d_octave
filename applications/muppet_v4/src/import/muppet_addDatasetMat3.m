function varargout=muppet_addDatasetMat(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'read'}
                % Read file data
                dataset=varargin{ii+1};
                dataset=read(dataset);
                varargout{1}=dataset;
            case{'import'}
                % Import data
                dataset=varargin{ii+1};
                dataset=import(dataset);
                varargout{1}=dataset;
        end
    end
end

%%
function dataset=read(dataset)

% Set for each dataset:
% adjustname
%
% Reads for dataset:
%
% Reads for each parameter:
% name
% type
% active
% dimensions (size,stations,nrdomains,domains,nrsubfields,subfields,active)
% times (if not a time series), stations

% Should move to xml file

dataset.adjustname=1;

s=load(dataset.filename);

dataset.data=s;

% Coordinate System
dataset.coordinatesystem.name='undefined';
dataset.coordinatesystem.type='projected';
if isfield(s,'coordinatesystem')
    dataset.coordinatesystem=s.coordinatesystem;
end
cs=dataset.coordinatesystem;

for ii=1:length(s.parameters)
    
    % Set default parameter properties
    dataset.parameters(ii).parameter=[];
    dataset.parameters(ii).parameter=muppet_setDefaultParameterProperties(dataset.parameters(ii).parameter);
    dataset.parameters(ii).parameter.name=s.parameters(ii).parameter.name;
    
    dataset.parameters(ii).parameter.coordinatesystem=cs;
    
    if isfield(s.parameters(ii).parameter,'dimensions')
        s.parameters(ii).parameter.size=s.parameters(ii).parameter.dimensions;
    end
    
    % Determine size (if not available in parameter structure)
    if isfield(s.parameters(ii).parameter,'size')
        dataset.parameters(ii).parameter.size=s.parameters(ii).parameter.size;
    else
        dataset.parameters(ii).parameter.size(1)=length(s.parameters(ii).parameter.time);
        dataset.parameters(ii).parameter.size(2)=0;
        dataset.parameters(ii).parameter.size(3)=size(s.parameters(ii).parameter.x,1);
        dataset.parameters(ii).parameter.size(4)=size(s.parameters(ii).parameter.x,2);
        dataset.parameters(ii).parameter.size(5)=0;
    end
    
    % Time
    if isfield(s.parameters(ii).parameter,'time')
        dataset.parameters(ii).parameter.times=s.parameters(ii).parameter.time;
    end

    % Stations
    if isfield(s.parameters(ii).parameter,'stations')
        dataset.parameters(ii).parameter.stations=s.parameters(ii).parameter.stations;
    end

    % Quantity
    if isfield(s.parameters(ii).parameter,'quantity')
        dataset.parameters(ii).parameter.quantity=s.parameters(ii).parameter.quantity;
    end

end

%%
function dataset=import(dataset)

% 1) Fills common data structure d (procedure is different for each file type)
% 2) Processes data (same for each file type, because of common data structure d)

% Mat file has already been loaded in read function, data is stored in
% dataset.data

s=dataset.data;

% Find parameter to be read
for ipar=1:length(s.parameters)
    if strcmpi(s.parameters(ipar).parameter.name,dataset.parameter)
        parameter=s.parameters(ipar).parameter;
        break
    end
end

[timestep,istation,m,n,k]=muppet_findDataIndices(dataset);

%shp=muppet_findDataShape(dataset.size,timestep,istation,m,n,k);
%dataset=muppet_determineDatasetShape(dataset,timestep,istation,m,n,k);

if isfield(parameter,dataset.timename)
    d.Time=parameter.(dataset.timename)(timestep);
end
if isfield(parameter,dataset.xname)
    switch dataset.quantity
        case{'location'}
            if dataset.size(1)>0
                d.X=parameter.(dataset.xname)(timestep,m);
            else
                d.X=parameter.(dataset.xname)(m);
            end
        otherwise
            d.X=parameter.(dataset.xname)(m,n);
    end
end
if isfield(parameter,dataset.yname)
    switch dataset.quantity
        case{'location'}
            if dataset.size(1)>0
                d.Y=parameter.(dataset.yname)(timestep,m);
            else
                d.Y=parameter.(dataset.yname)(m);
            end
        otherwise
            d.Y=parameter.(dataset.yname)(m,n);
    end
end
if isfield(parameter,dataset.zname)
    d.Z=parameter.(dataset.zname)(m,n);
end

% Get values (and store in same structure format as qpread)
d.Val=extractmatrix(parameter,dataset.valname,dataset.size,timestep,istation,m,n,k);
d.Time=extractmatrix(parameter,dataset.timename,dataset.size,timestep,istation,m,n,k);
d.XComp=extractmatrix(parameter,dataset.uname,dataset.size,timestep,istation,m,n,k);
d.YComp=extractmatrix(parameter,dataset.vname,dataset.size,timestep,istation,m,n,k);
d.ZComp=extractmatrix(parameter,dataset.wname,dataset.size,timestep,istation,m,n,k);
d.UAmplitude=extractmatrix(parameter,dataset.uamplitudename,dataset.size,timestep,istation,m,n,k);
d.VAmplitude=extractmatrix(parameter,dataset.vamplitudename,dataset.size,timestep,istation,m,n,k);
d.UPhase=extractmatrix(parameter,dataset.uphasename,dataset.size,timestep,istation,m,n,k);
d.VPhase=extractmatrix(parameter,dataset.vphasename,dataset.size,timestep,istation,m,n,k);

if strcmpi(dataset.quantity,'vector')
    dataset.quantity='vector2d';
end

% dataset=muppet_determineDatasetShape(dataset,timestep,istation,m,n,k);

%% From here on, everything should be the same for each type of datafile

dataset=muppet_finishImportingDataset(dataset,d,timestep,istation,m,n,k);

% % Squeeze
% d=muppet_squeezeDataset(d);
% 
% %% Determine component
% [dataset,d]=muppet_determineDatasetComponent(dataset,d);
% 
% %% Copy data to dataset structure
% dataset=muppet_copyToDataStructure(dataset,d,shpmat,plane,ndim);
% 
% %% Determine cell centres/corners
% dataset.xz=dataset.x;
% dataset.yz=dataset.y;
% dataset.zz=dataset.z;
% 
% %dataset.type=[shp dataset.quantity];
% dataset.type=[dataset.quantity num2str(ndim) 'd' plane];
% 
% %% Set time-varying or constant
% dataset=muppet_setDatasetVaryingOrConstant(dataset,timestep);
% 

function val=extractmatrix(parameter,fld,sz,timestep,istation,m,n,k)

nind=0;
val=[];
if isfield(parameter,fld)
    if ~isempty(parameter.(fld))
        if sz(1)>0
            nind=nind+1;
            str{nind}='timestep';
        end
        if sz(2)>0
            nind=nind+1;
            str{nind}='istation';
        end
        if sz(3)>0
            nind=nind+1;
            str{nind}='m';
        end
        if sz(4)>0
            nind=nind+1;
            str{nind}='n';
        end
        if sz(5)>0
            nind=nind+1;
            str{nind}='k';
        end
        sind='';
        for ii=1:nind
            sind=[sind str{ii} ','];
        end
        sind=sind(1:end-1);
        evalstr=['val=squeeze(parameter.(fld)(' sind '));'];
        eval(evalstr);
    end
end
