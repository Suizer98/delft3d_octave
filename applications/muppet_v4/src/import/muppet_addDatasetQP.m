function varargout=muppet_addDatasetQP(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'read'}
                % Read file data
                dataset=varargin{ii+1};
                parameter=[];
                if length(varargin)==3
                    parameter=varargin{ii+1};
                end
                dataset=read(dataset,parameter);
                varargout{1}=dataset;                
            case{'gettimes'}
                times=getTimes;
                varargout{1}=times;
            case{'import'}
                % Import data
                dataset=varargin{ii+1};
                dataset=import(dataset);
                varargout{1}=dataset;
        end
    end
end

%%
function dataset=read(dataset,parameter)

% Set for each dataset:
% parametertimesequal
% parameterstationsequal
% adjustname
%
% Reads for dataset:
% nrparameters
% parameternames;
%
% Reads for each parameter:
% name
% type
% active
% dimensions (nrm,nrn,nrk,nrt,nrstations,stations,nrdomains,domains,nrsubfields,subfields,parametername,active)
% times (if not a time series), stations

% Should move to xml file

switch lower(dataset.filename(end-2:end))
    case{'map','ada'}
        % Delwaq
        if isempty(dataset.lgafile)
            % No lga file specified
            filterspec={'*.lga', '*.lga'};
            [filename, pathname, filterindex] = uigetfile(filterspec);
            dataset.lgafile=[pathname filename];
        end
        fid=qpfopen(dataset.filename,lgafile);
    otherwise
        fid=qpfopen(dataset.filename);
        dataset.lgafile=[];
end

dataproperties=qpread(fid);

if isempty(parameter)
    % Find info for all parameters
    i1=1;
    i2=length(dataproperties);
else
    % Parameter is given (from mup file)
    idata=strmatch(lower(parameter),lower(parameters),'exact');
    i1=idata;
    i2=idata;
end

%% Coordinate System
tp='projected';
if isfield(fid,'SubType')
    switch fid.SubType
        case{'Delft3D-trih'}
            alfas=vs_get(fid,'his-const','ALFAS','quiet');
            dataset.alfas=alfas;
        case{'Delft3D-trim'}
            tp=vs_get(fid,'map-const','COORDINATES','quiet');
            alfas=vs_get(fid,'map-const','ALFAS','quiet');
            dataset.alfas=alfas;
    end
end
cs=[];
switch lower(deblank(tp))
    case{'spherical'}
        cs.name='WGS 84';
        cs.type='geographic';
end

ii=0;
timesread=0;

% Get info for each parameter
for j=i1:i2
    
    ii=ii+1;
    
    par=[];
    
    % Set default parameter properties (just the dimensions)
    par=muppet_setDefaultParameterProperties(par);
    
    par.fid=fid;
    par.lgafile=dataset.lgafile;
    par.dataproperties=dataproperties;
    par.parametertimesequal=1;
    par.parameterstationsequal=1;
    par.parameterxequal=1;
    par.parameteryequal=1;
    par.parameterzequal=1;
    par.adjustname=1;
    
    par.name=dataproperties(ii).Name;
    
    if sum(dataproperties(ii).DimFlag)>0
        
        par.size=qpread(fid,1,dataproperties(ii),'size');
        
        % Bug in qpread?
%        par.size=par.size.*dataproperties(ii).DimFlag;
        
        % Times
        if dataproperties(ii).DimFlag(1)>0
            % Try to copy times from previous parameter
            for ip=1:ii-1
                %                if dataproperties(ii).DimFlag(1)==dataproperties(ip).DimFlag(1)
                if par.size(1)==dataset.parameters(ip).parameter.size(1)
                    % Same number of times
                    if ~isempty(dataset.parameters(ip).parameter.times)
                        par.times=dataset.parameters(ip).parameter.times;
                        par.morphtimes=dataset.parameters(ip).parameter.morphtimes;
                    end
                end
                %                end
            end
            %
            if isempty(par.times)
                % Still empty, see if it's worth reading it now
                par.times=qpread(fid,dataproperties(ii),'times');

                % Try reading morphological times as well
                par.morphtimes=[];
                try
                    switch fid.SubType
                        case{'Delft3D-trih'}
                            [mt,ok]=vs_get(fid,'his-infsed-serie','MORFT','quiet');
                        case{'Delft3D-trim'}
                            [mt,ok]=vs_get(fid,'map-infsed-serie','MORFT','quiet');
                    end
                    if ok
                        for it=1:length(mt)
                            par.morphtimes(it)=par.times(1)+mt{it};
                        end
                    end
                end
                
            end
        end
        
        % Stations
        if dataproperties(ii).DimFlag(2)>0
            par.stations=qpread(fid,dataproperties(ii),'stations');
        end

        % Subfields
        par.subfields=qpread(fid,dataproperties(ii),'subfields');
        if ~isempty(par.subfields)
            par.nrsubfields=length(par.subfields);
            if ~isempty(dataset.subfield)
                par.subfieldnumber=strmatch(lower(dataset.subfield),lower(par.subfields),'exact');
            end
        else
            par.subfields={''};
            par.nrsubfields=0;
        end

        % NetCDF time series (should be fixed in qpread)
%        if strcmpi(fid.qp_filetype,'netcdf')
        if strcmpi(fid.QP_FileType,'NetCDF')
            if isfield(dataproperties(ii),'Dimension')
                if ~isempty(dataproperties(ii).Dimension)
                    if strcmpi(dataproperties(ii).Dimension{3},'locations')
                        stations=nc_varget(dataset.filename,'platform_name');
                        stations=stations';
                        for istat=1:size(stations,1)
                            par.stations{istat}=deblank(stations(istat,:));
                        end
                        par.size(2)=par.size(3);
                        par.size(3)=0;
                    end
                    if strcmpi(dataproperties(ii).Dimension{3},'station')
                        stations=nc_varget(dataset.filename,'station_name');
                        for istat=1:size(stations,1)
                            par.stations{istat}=deblank(stations(istat,:));
                        end
                        par.size(2)=par.size(3);
                        par.size(3)=0;
                    end
                end
            end
        end
        
            % Unstructured grid
            if strcmpi(fid.QP_FileType,'netcdf')
                if ~isempty(dataproperties(ii).DimFlag)
                    if strcmpi(dataproperties(ii).DimName{3},'nmesh2d_face')
                        % unstructured grid
                        par.dataproperties(ii).Loc='z';
                        par.unstructuredgrid=1;
                    end
                    if strcmpi(dataproperties(ii).DimName{3},'nmesh2d_node')
                        % unstructured grid
                        par.dataproperties(ii).Loc='d';
                        par.unstructuredgrid=1;
                    end
                end
            end
        
        % Unstructured grid
%        if strcmpi(fid.qp_filetype,'netcdf')
        if strcmpi(fid.QP_FileType,'NetCDF')
            if ~isempty(dataproperties(ii).DimName)
                if strcmpi(dataproperties(ii).DimName{3},'nFlowElem')
                    % unstructured grid
                    par.dataproperties(ii).Loc='z';
                    par.unstructuredgrid=1;
                end
                if strcmpi(dataproperties(ii).DimName{3},'nNetNode')
                    % unstructured grid
                    par.dataproperties(ii).Loc='d';
                    par.unstructuredgrid=1;
                end
            end
        end
        
        
        if ~isempty(cs)
            par.coordinatesystem=cs;
        end
                
        par.nval=dataproperties(ii).NVal;
        
        switch dataproperties(ii).NVal
            case 0
                par.quantity='location'; % Grids, open boundaries etc.
            case 1
                par.quantity='scalar';
            case 2
                par.quantity='vector2d';
            case 3
                par.quantity='vector3d';
            case 4
                par.quantity='location';
            case 5
                par.quantity='boolean'; % 0/1 Inactive cells, etc.
            otherwise
                par.quantity='unknown';
        end
        par.rawquantity=par.quantity;
        active=1;
    else
        active=0;
    end
    
    dataset.parameters(ii).parameter=par;
    dataset.parameters(ii).parameter.active=active;
    
end

%%
function times=getTimes
% Times
dataset=gui_getUserData('tag','datasetgui');
dataset.times=[];
fid=qpfopen([dataset.filename]);
dataproperties=qpread(fid);
% Find first parameter with times
for ii=1:length(dataproperties)
    if dataproperties(ii).DimFlag(1)>0
        times=qpread(fid,dataproperties(ii).Name,'times');
        break
    end
end

%%
function dataset=import(dataset)

fid=dataset.fid;

parameter=dataset.parameter;

for ii=1:length(dataset.dataproperties)
    parameternames{ii}=dataset.dataproperties(ii).Name;
end

ipar=strmatch(lower(parameter),lower(parameternames),'exact');
dataproperties=dataset.dataproperties(ipar);

% Read times (if they haven't been read yet)
if dataset.size(1)>0
    % Times available
    if isempty(dataset.times)
        % No times specified yet, read them first
        dataset.times=qpread(fid,dataproperties,'times');
    end
end

% Find data indices
[timestep,istation,m,n,k,idomain]=muppet_findDataIndices(dataset);
% Bad idea as this will lead to write out all time steps for timeseries in
% mup files
%dataset.timestep=timestep;

%% Load data into structure d
inparg{1}=timestep;
inparg{2}=istation;
inparg{3}=m;
inparg{4}=n;
inparg{5}=k;

arg=[];
narg=0;
for ii=1:5
    if dataset.size(ii)>0
        narg=narg+1;
        arg{narg}=inparg{ii};    
    end
end

if ~isempty(dataset.subfields)
    if isempty(dataset.subfields{1})
        dataset.subfields=[];
    end
end

% Get grid angles
try
    if isfield(dataset,'alfas')
        switch fid.SubType
            case{'Delft3D-trih'}
                dataset.alfas=dataset.alfas(istation);
            case{'Delft3D-trim'}
                if isempty(dataset.m) && isempty(dataset.n)
                elseif ~isempty(dataset.m) && isempty(dataset.n)
                    dataset.alfas=dataset.alfas(m,:);
                elseif isempty(dataset.m) && ~isempty(dataset.n)
                    dataset.alfas=dataset.alfas(n,:);
                elseif ~isempty(dataset.m) && ~isempty(dataset.n)
                    dataset.alfas=dataset.alfas(n,m);
                end
        end
        dataset.alfas=squeeze(dataset.alfas);
    end
end

% And get the data
switch length(arg)
    case 1
        if ~isempty(dataset.subfields)
            d=qpread(fid,idomain,dataproperties,'griddata',dataset.subfieldnumber,arg{1});
        else
            d=qpread(fid,idomain,dataproperties,'griddata',arg{1});
        end
    case 2
        if ~isempty(dataset.subfields)
            d=qpread(fid,idomain,dataproperties,'griddata',dataset.subfieldnumber,arg{1},arg{2});
        else
            d=qpread(fid,idomain,dataproperties,'griddata',arg{1},arg{2});
        end
        % Fix for DFlow-FM to make water levels NaN when depth<0.2 m
        if isfield(dataproperties,'Geom')
            if strcmpi(dataproperties.Geom,'polyg')
                if strcmpi(dataproperties.Name,'waterlevel')
                    ipar2=strmatch('waterdepth',lower(parameternames),'exact');
                    dataproperties2=dataset.dataproperties(ipar2);
                    dpt=qpread(fid,idomain,dataproperties2,'griddata',arg{1},arg{2});
                    d.Val(dpt.Val<0.2)=NaN;
                end
            end
        end
        
    case{3}
        if ~isempty(dataset.subfields)
            d=qpread(fid,idomain,dataproperties,'griddata',dataset.subfieldnumber,arg{1},arg{2},arg{3});
        else
%            d=qpread(fid,idomain,dataproperties,'griddata',1,arg{1},arg{2},arg{3});
            d=qpread(fid,idomain,dataproperties,'griddata',arg{1},arg{2},arg{3});
        end
    case{4}
        if ~isempty(dataset.subfields)
            d=qpread(fid,idomain,dataproperties,'griddata',dataset.subfieldnumber,arg{1},arg{2},arg{3},arg{4});
        else
            d=qpread(fid,idomain,dataproperties,'griddata',arg{1},arg{2},arg{3},arg{4});
        end
end

if ~isempty(dataset.subfields)
    dataset.subfield=dataset.subfields{dataset.subfieldnumber};
end

% d.Time=dataset.morphtimes;

% z or d
if isfield(dataproperties,'Loc')
    dataset.location=dataproperties.Loc;
end

% From here on, everything should be the same for each type of datafile
% d must always look like structure as imported from qpread

dataset=muppet_finishImportingDataset(dataset,d,timestep,istation,m,n,k);
