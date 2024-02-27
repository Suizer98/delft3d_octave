function varargout=muppet_addDatasetDelft3D(varargin)

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

switch dataset.filename(end-2:end)
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
        case{'Delft3D-trim'}
            tp=vs_get(fid,'map-const','COORDINATES','quiet');
    end
end
switch lower(deblank(tp))
    case{'spherical'}
        cs.name='WGS 84';
        cs.type='geographic';
    otherwise
        cs.name='unspecified';
        cs.type='projected';        
end

ii=0;

% Get info for each parameter
for j=i1:i2
    
    ii=ii+1;
    
    par=[];

    % Set default parameter properties (just the dimensions)
    par=muppet_setDefaultParameterDimensions(par);
    
    par.fid=fid;
    par.lgafile=dataset.lgafile;
    par.dataproperties=dataproperties;    
    par.parametertimesequal=1;
    par.parameterstationsequal=1;
    par.parameterxequal=1;
    par.parameteryequal=1;
    par.parameterzequal=1;
    par.adjustname=1;
    
%    par.parametername=dataproperties(ii).Name;
    par.name=dataproperties(ii).Name;
    
    par.size=qpread(fid,1,dataproperties(ii),'size');

    % Times
    if dataproperties(ii).DimFlag(1)>0 && par.size(1)<1000
        % Only read times when there are less than 1,000
        par.times=qpread(fid,dataproperties(ii),'times');

        % Try reading morphological times as well
        par.morphtimes=[];
        try
            [mt,ok]=vs_get(fid,'map-infsed-serie','MORFT','quiet');
            if ok
                for it=1:length(mt)
                    par.morphtimes(it)=par.times(1)+mt{it};
                end
            end
        end
    end

    % Stations
    if dataproperties(ii).DimFlag(2)>0
        par.stations=qpread(fid,dataproperties(ii),'stations');
    end

    par.coordinatesystem=cs;
    
    if sum(dataproperties(ii).DimFlag)>0

        par.nval=dataproperties(ii).NVal;

        switch dataproperties(ii).NVal
            case 0
                par.quantity='grid'; % Grids, open boundaries etc.
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
dataset=gui_getUserData;
dataset.times=[];
fid=qpfopen([dataset.pathname dataset.filename]);
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

timestep=dataset.timestep;
m=dataset.m;
n=dataset.n;
k=dataset.k;
istation=0;

% Check to see if all data along dimension if required

% Time
if dataset.size(1)>0
    % Times available
    if ~isempty(dataset.time)
        % Specific time given, determine time step        
        if isempty(dataset.times)
            % No times specified yet, read them first
            dataset.times=qpread(fid,dataproperties,'times');
        end
        timestep=find(dataset.times>dataset.time-1.0e-5 & dataset.times<dataset.time+1.0e-5);
        if isempty(timestep)
            str{1}=['Error! Time ' datestr(dataset.time,'yyyymmdd HHMMSS') ' not found in file ' dataset.filename '!'];
            str{2}='Dataset skipped';
            strv=strvcat(str{1},str{2});
            uiwait(errordlg(strv,'Error','modal'));
            muppet_writeErrorLog(str);
            return
        end
    end
    if isempty(timestep)
        % All times selected
        timestep=0;
    end
    if length(timestep)==1 && timestep~=0
        dataset.time=dataset.times(timestep);
        dataset.time=dataset.morphtimes(timestep);
    end
    dataset.timestep=[];
end

%% Station (stations have already been read)
if dataset.size(2)>0
    % Find station number
    if ~isempty(dataset.station)
        istation=strmatch(dataset.station,dataset.stations,'exact');
    end
end

% M
if dataset.size(3)>0 && isempty(m)
    m=0;
end

% N
if dataset.size(4)>0 && isempty(n)
    n=0;
end

% K
if dataset.size(5)>0 && isempty(k)
    k=0; % All layers
end


% % Morphological times (in case of MORFAC)
% morphtimes=[];
% try
%     fi=vs_use([dataset.pathname dataset.filename],'quiet');
%     [mt,ok]=vs_get(fi,'map-infsed-serie','MORFT','quiet');
%     if ok
%         if iscell(mt)
%             data.morphtimes=data.times(1)+cell2mat(mt);
%         else
%             data.morphtimes=data.times(1)+mt;
%         end
%     else
%         data.morphtimes=[];
%     end
% end

% Find time (when given by time)


%% Domains
idomain=1;
if isfield(dataset,'domain')
    if ~isempty(dataset.domain)
        idomain=strmatch(dataset.domain,dataset.domains,'exact');
    end
end

%% Read sediment fractions
% if strcmp(dataset.SubField,'none')==0
%     switch FileInfo.SubType,
%         case{'Delft3D-trim'}
%             ConstGroup='map-const';
%         case{'Delft3D-trih'}
%             ConstGroup='his-const';
%     end
%     switch FileInfo.SubType,
%         case{'Delft3D-trim','Delft3D-trih'}
%             ised=vs_find(FileInfo,'LSED');
%             if isempty(ised)
%                 LSed=0;
%             else
%                 LSed=vs_get(FileInfo,ConstGroup,'LSED','quiet');
%             end
%             if LSed>0
%                 [Sediments0,Succes]=vs_get(FileInfo,ConstGroup,'NAMSED','quiet');
%                 if Succes==0
%                     [Sediments0,Succes]=vs_get(FileInfo,ConstGroup,'NAMCON','quiet');
%                     for i=1:size(LSed)
%                         Sediments{i}=Sediments0(i+(size(Sediments0,1)-LSed),:);
%                     end
%                 else
%                     for i=1:size(Sediments0,1)
%                         Sediments{i}=Sediments0(i,:);
%                     end
%                 end
%                 for i=1:size(Sediments0,1)
%                     Sediments{i}=Sediments0(i,:);
%                 end
%                 if i>1
%                     Sediments{i+1}='sum over all fractions';
%                 end
%             end
%         otherwise
%             LSed=0;
%     end
%     if LSed>0
%         SedNr=strmatch(dataset.SubField,Sediments);
%     else
%         SedNr=0;
%     end
% else
%     LSed=0;
%     SedNr=0;
% end

% Determine shape of original data

shpmat=muppet_determineShapeMatrix(dataset.size,timestep,istation,m,n,k);

%% Determine input arguments for qp_read

inparg{1}=timestep;
inparg{2}=istation;
inparg{3}=m;
inparg{4}=n;
inparg{5}=k;

arg=[];
narg=0;
for ii=1:5
    if shpmat(ii)==1 || shpmat(ii)==2
        narg=narg+1;
        arg{narg}=inparg{ii};    
    end
end

%% Load data
switch length(arg)
    case 1
        d=qpread(fid,idomain,dataproperties,'griddata',arg{1});
    case 2
        d=qpread(fid,idomain,dataproperties,'griddata',arg{1},arg{2});
    case{3}
        d=qpread(fid,idomain,dataproperties,'griddata',arg{1},arg{2},arg{3});
    case{4}
        d=qpread(fid,idomain,dataproperties,'griddata',arg{1},arg{2},arg{3},arg{4});
end

% Squeeze data
fldnames=fieldnames(d);
for ii=1:length(fldnames)
    if isnumeric(d.(fldnames{ii}))
        d.(fldnames{ii})=squeeze(d.(fldnames{ii}));
    end
end





%% Determine component
switch dataset.quantity
    case{'vector2d','vector3d'}
        if isempty(dataset.component)
            dataset.component='vector';
        end
        % Vector, compute components if necessary
        switch lower(dataset.component)
            case('magnitude')
                d.Val=sqrt(d.XComp.^2+d.YComp.^2);
                dataset.quantity='scalar';
            case('angle (radians)')
                d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi);
                dataset.quantity='scalar';
            case('angle (degrees)')
                d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi)*180/pi;
                dataset.quantity='scalar';
            case('m-component')
                d.Val=d.XComp;
                dataset.quantity='scalar';
            case('n-component')
                d.Val=d.YComp;
                dataset.quantity='scalar';
            case('x-component')
                d.Val=d.XComp;
                dataset.quantity='scalar';
            case('y-component')
                d.Val=d.YComp;
                dataset.quantity='scalar';
        end
end

%% Compute y value for cross sections
plotcoordinate=[];
if (shpmat(3)==1 && shpmat(4)>1) || (shpmat(3)>1 && shpmat(4)==1) 
        switch(lower(dataset.xcoordinate))
            case{'x'}
                x=squeeze(d.X);
            case{'y'}
                x=squeeze(d.Y);
            case{'pathdistance'}
                x=pathdistance(squeeze(d.X),squeeze(d.Y));
            case{'revpathdistance'}
                x=pathdistance(squeeze(d.X),squeeze(d.Y));
                x=x(end:-1:1);
        end
        plotcoordinate=x;
end

%% Copy data to dataset structure
dataset=muppet_copyToDataStructure(dataset,d);


% Set empty values
dataset.x=[];
dataset.x=[];
dataset.y=[];
dataset.z=[];
dataset.xz=[];
dataset.yz=[];
dataset.zz=[];
dataset.u=[];
dataset.v=[];
dataset.w=[];

for ii=1:5    
    shpstr(ii)=num2str(shpmat(ii));
end
switch shpstr
    case{'21000','21001','20110','20111'}
        dataset.type='timeseries';
        dataset.x=d.Time;
        switch dataset.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end
    case{'21002','20112'}
        dataset.type='timestack';
        dataset.x=d.Time;
        dataset.y=d.Z;
        switch dataset.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
    case{'11002','10112'}
        % Profile
        dataset.type='xy';
        dataset.y=d.Z;
        switch dataset.quantity
            case{'scalar'}
                dataset.x=d.Val;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
    case{'20212','20122'}
        dataset.type='timestack';
        dataset.x=d.Time;
        dataset.y=plotcoordinate;
        switch dataset.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end
    case{'10220','10221','00220','00221'}
        dataset.type='map2d';
        dataset.x=d.X;
        dataset.y=d.Y;
        switch d.XUnits
            case{'deg'}
                dataset.coordinatesystem.name='WGS 84';
                dataset.coordinatesystem.type='geographic';
        end
        switch dataset.quantity
            case{'scalar','boolean'}
                dataset.z=d.Val;
            case{'grid'}
                dataset.xdam=d.XDam;
                dataset.ydam=d.YDam;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end
    case{'10212','10122','00212','00122'}
        dataset.type='crossection2d';
        dataset.x=plotcoordinate;
        dataset.y=d.Z;
        switch dataset.quantity
            case{'scalar'}
                dataset.z=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
    case{'10210','10120','00210','00120','10211','10121','00211','00121'}
        dataset.type='crossection1d';
        dataset.x=plotcoordinate;
        switch dataset.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
end

dataset.xz=dataset.x;
dataset.yz=dataset.y;
dataset.zz=dataset.z;

dataset.type=[dataset.type dataset.quantity];

% z or d
if isfield(dataproperties,'Loc')
    dataset.location=dataproperties.Loc;
end

if dataset.size(1)==0 || (dataset.size(1)>1 && (timestep==0 || length(timestep)>1))
    dataset.tc='c';
else
    dataset.tc='t';
    dataset.availabletimes=dataset.times;
%    dataset.availablemorphtimes=data.morphtimes;
end
