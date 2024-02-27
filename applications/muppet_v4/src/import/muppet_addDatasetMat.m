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
        if isfield(s.parameters(ii).parameter,'time')
            dataset.parameters(ii).parameter.size(1)=length(s.parameters(ii).parameter.time);
        else
            dataset.parameters(ii).parameter.size(1)=0;
        end
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
        dataset.parameters(ii).parameter.rawquantity=s.parameters(ii).parameter.quantity;
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
dataset.rawquantity='scalar';

% Find parameter to be read
for ipar=1:length(s.parameters)
    if strcmpi(s.parameters(ipar).parameter.name,dataset.parameter)
        parameter=s.parameters(ipar).parameter;
        break
    end
end

[timestep,istation,m,n,k]=muppet_findDataIndices(dataset);

% Coordinates

% Time
if isfield(parameter,dataset.timename)
    d.Time=parameter.(dataset.timename)(timestep);
end

% X
if isfield(parameter,dataset.xname)
    switch dataset.quantity
        case{'location'}
            if dataset.size(1)>0
                % Multiple timesteps, track
                if dataset.size(2)>0
                    % Multiple stations
                    d.X=parameter.(dataset.xname)(timestep,istation);
                else
%                else
                    if size(parameter.(dataset.xname),1)==1 || size(parameter.(dataset.xname),2)==1
                        d.X=parameter.(dataset.xname)(timestep);
                    else
                        d.X=parameter.(dataset.xname)(timestep,:);
                    end
                end
            else
                % One timestep, so just separate locations
                if dataset.size(2)>0
                    % Multiple stations
                    d.X=parameter.(dataset.xname)(istation);
                elseif dataset.size(3)>0
                    % Multiple M
                    d.X=parameter.(dataset.xname)(m);
                end
            end
        otherwise
            if size(parameter.(dataset.xname),1)==1 || size(parameter.(dataset.xname),2)==1
                d.X=parameter.(dataset.xname);
            else
                d.X=parameter.(dataset.xname)(m,n);
            end
    end
end

% Y
if isfield(parameter,dataset.yname)
    switch dataset.quantity
        case{'location'}
            if dataset.size(1)>0
                % Multiple timesteps, track
                if dataset.size(2)>0
                    % Multiple stations
                    d.Y=parameter.(dataset.yname)(timestep,istation);
                else
%                else
                    if size(parameter.(dataset.yname),1)==1 || size(parameter.(dataset.yname),2)==1
                        d.Y=parameter.(dataset.yname)(timestep);
                    else
                        d.Y=parameter.(dataset.yname)(timestep,:);
                    end
                end
            else
                % One timestep, so just separate locations
                if dataset.size(2)>0
                    % Multiple stations
                    d.Y=parameter.(dataset.yname)(istation);
                elseif dataset.size(3)>0
                    % Multiple M
                    d.Y=parameter.(dataset.yname)(m);
                end
            end
        otherwise
            if size(parameter.(dataset.yname),1)==1 || size(parameter.(dataset.yname),2)==1
                d.Y=parameter.(dataset.yname);
            else
                d.Y=parameter.(dataset.yname)(m,n);
            end
    end
end

% Z
if isfield(parameter,dataset.zname)
    d.Z=parameter.(dataset.zname)(m,n);
end

% Type
if isfield(parameter,'type')
    dataset.type=parameter.type;
end

% Labels
if isfield(parameter,'labels')
    dataset.xticklabel=parameter.labels;
end

% Location
if isfield(parameter,'location')
    dataset.location=parameter.location;
end

% Get values (and store in same structure format as qpread)
d.Val=muppet_extractmatrix(parameter,dataset.valname,dataset.size,timestep,istation,m,n,k);
%d.Time=muppet_extractmatrix(parameter,dataset.timename,dataset.size,timestep,istation,m,n,k);
d.XComp=muppet_extractmatrix(parameter,dataset.uname,dataset.size,timestep,istation,m,n,k);
d.YComp=muppet_extractmatrix(parameter,dataset.vname,dataset.size,timestep,istation,m,n,k);
d.ZComp=muppet_extractmatrix(parameter,dataset.wname,dataset.size,timestep,istation,m,n,k);
d.UAmplitude=muppet_extractmatrix(parameter,dataset.uamplitudename,dataset.size,timestep,istation,m,n,k);
d.VAmplitude=muppet_extractmatrix(parameter,dataset.vamplitudename,dataset.size,timestep,istation,m,n,k);
d.UPhase=muppet_extractmatrix(parameter,dataset.uphasename,dataset.size,timestep,istation,m,n,k);
d.VPhase=muppet_extractmatrix(parameter,dataset.vphasename,dataset.size,timestep,istation,m,n,k);

if strcmpi(dataset.quantity,'vector')
    dataset.quantity='vector2d';
end

% From here on, everything should be the same for each type of datafile
dataset=muppet_finishImportingDataset(dataset,d,timestep,istation,m,n,k);
