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

dataset.parametertimesequal=1;
dataset.parameterstationsequal=1;
dataset.parameterxequal=1;
dataset.parameteryequal=1;
dataset.parameterzequal=1;
dataset.adjustname=1;

switch dataset.filename(end-2:end)
    case{'map','ada'}
        % Delwaq
        filterspec={'*.lga', '*.lga'};
        [filename, pathname, filterindex] = uigetfile(filterspec);
        dataset.lgafile=[pathname filename];
        fid=qpfopen(dataset.filename,dataset.lgafile);
    otherwise
        fid=qpfopen(dataset.filename);
        
end

dataset.fid=fid;

dataproperties=qpread(fid);

for j=1:length(dataproperties)
    dataset.parameternames{j}=dataproperties(j).Name;
end

if isempty(parameter)
    % Find info for all parameters
    i1=1;
    i2=length(dataproperties);
else
    idata=strmatch(lower(parameter),lower(parameters),'exact');
    i1=idata;
    i2=idata;
end

% Dimensions of datasets
maxdims=[0 0 0 0 0];
for idim=1:5
    for ii=i1:i2
        if dataproperties(ii).DimFlag(idim) && maxdims(idim)==0
            sz=qpread(fid,dataproperties(ii).Name,'size');
            maxdims=max(maxdims,sz);
        end
    end
end

% Coordinate System
tp='projected';
switch fid.SubType
    case{'Delft3D-trih'}
    case{'Delft3D-trim'}
        tp=vs_get(fid,'map-const','COORDINATES','quiet');
end
switch lower(deblank(tp))
    case{'spherical'}
        cs.name='WGS 84';
        cs.type='geographic';
    otherwise
        cs.name='unspecified';
        cs.type='projected';        
end

% Times
times=[];
switch fid.SubType
    case{'Delft3D-trih'}
        % Don't read times from time series as this can take forever and is
        % not absolutely necessary at this stage
    otherwise
        % Find first parameter with times
        for ii=i1:i2
            if dataproperties(ii).DimFlag(1)>0
                times=qpread(fid,dataproperties(ii).Name,'times');
                break
            end
        end
end

% Find first parameter with stations
for ii=i1:i2
    if dataproperties(ii).DimFlag(2)>0
        stations=qpread(fid,dataproperties(ii).Name,'stations');
        break
    end
end

for ii=i1:i2
    
    % Set default parameter properties
    par=[];

    par.dimensions.coordinatesystem=cs;
    
    par.dimensions.parametername=dataproperties(ii).Name;

    par.dimensions.nrm=0;
    par.dimensions.nrn=0;
    par.dimensions.nrk=0;

    par.dimensions.nrt=0;
    par.dimensions.times=times;
    
    par.dimensions.nrstations=0;
    par.dimensions.stations={''};
    
    par.dimensions.nrdomains=0;
    par.dimensions.domains={''};

    par.dimensions.nrsubfields=0;
    par.dimensions.subfields={''};

    par.dimensions.datatype='scalar';

    if sum(dataproperties(ii).DimFlag)>0
        if dataproperties(ii).DimFlag(1)
            par.dimensions.nrt=maxdims(1);
            par.dimensions.times=times;
        end
        if dataproperties(ii).DimFlag(2)
            par.dimensions.nrstations=maxdims(2);
            par.dimensions.stations=stations;
        end
        if dataproperties(ii).DimFlag(3)
            par.dimensions.nrm=maxdims(3);
        end
        if dataproperties(ii).DimFlag(4)
            par.dimensions.nrn=maxdims(4);
        end
        if dataproperties(ii).DimFlag(5)
            par.dimensions.nrk=maxdims(5);
        end
        par.dimensions.nval=dataproperties(ii).NVal;
        switch dataproperties(ii).NVal
            case 0
                par.dimensions.quantity='grid'; % Grids, open boundaries etc.
            case 1
                par.dimensions.quantity='scalar';
            case 2
                par.dimensions.quantity='vector2d';
            case 3
                par.dimensions.quantity='vector3d';
            case 4
                par.dimensions.quantity='location';
            case 5
                par.dimensions.quantity='boolean'; % 0/1 Inactive cells, etc.
            otherwise
                par.dimensions.quantity='unknown';
        end
        active=1;
    else
        active=0;
    end
        
    if isempty(parameter)
        dataset.parameters(ii).parameter.dimensions=par.dimensions;
        dataset.parameters(ii).parameter.active=active;
    else
        dataset.dimensions=par.dimensions;
    end
    
end

dataset.nrparameters=length(dataproperties);


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

parameter=dataset.parameter;

m=dataset.m;
n=dataset.n;
k=dataset.k;
timestep=dataset.timestep;

if isempty(m)
    if dataset.dimensions.nrm>0
        m=0;
    else
        m=1;
    end
end
if isempty(n)
    if dataset.dimensions.nrn>0
        n=0;
    else
        n=1;
    end
end
if isempty(k)
    if dataset.dimensions.nrk>0
        k=0;
    else
        k=1;
    end
end
if isempty(timestep)
    if dataset.dimensions.nrt>0
        timestep=0;
    else
        timestep=1;
    end
end

fid=dataset.fid;

%% Times
if dataset.dimensions.nrt>0
    % Check to see if times need to be loaded (only for partial time series)
    if isempty(dataset.dimensions.times)
        if dataset.timestep~=0
            times=qpread(fid,parameter,'times');
        end
    else
        times=dataset.dimensions.times;
    end
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

itime=[];

if ~isempty(dataset.time)
    % Time given, determine time step
    if dataset.dimensions.nrt>1
        itime=find(times>dataset.time-1.0e-5 & times<dataset.time+1.0e-5);
        timestep=itime;
        if isempty(itime)
            str{1}=['Error! Time ' datestr(dataset.time,'yyyymmdd HHMMSS') ' not found in file ' dataset.filename '!'];
            str{2}='Dataset skipped';
            strv=strvcat(str{1},str{2});
            uiwait(errordlg(strv,'Error','modal'));
            muppet_writeErrorLog(str);
            return
        end
    else        
        itime=1;
        timestep=1;
    end
    if length(itime)>1
        % Multiple times found
        itime=itime(1);
    end
elseif ~isempty(timestep)
    if dataset.dimensions.nrt>1
        % Time step given, determine time
        if timestep~=0 && length(timestep)==1 % What about multiple timesteps?
            itime=timestep;
            if itime>0
                dataset.time=times(itime);
            end
        end
    end
end

%% Stations (have already been read)
% Find station number
istation=0;
if isfield(dataset,'station')
    if ~isempty(dataset.station)
        istation=strmatch(dataset.station,dataset.dimensions.stations,'exact');
    end
end

%% Domains
idomain=1;
if isfield(dataset,'domain')
    if ~isempty(dataset.domain)
        idomain=strmatch(dataset.domain,dataset.dimensions.domains,'exact');
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


% Find out the shape of data that is required
if ~isempty(dataset.station)
    % Data from station
    if timestep==0 || length(timestep)>1
        % Time varying
        if k==0 || length(k)>1
            tp='timestackstation';
        else
            tp='timeseriesstation';
        end
    else
        % Profile
        tp='profilestation';
    end
    % Set input arguments
    switch tp
        case{'timeseriesstation'}
            arg{1}=timestep;
            arg{2}=istation;
        case{'timestackstation'}
            arg{1}=timestep;
            arg{2}=istation;
            if dataset.dimensions.nrk>0
                arg{3}=k;
            end
        case{'profilestation'}
            arg{1}=itime;
            arg{2}=istation;
            if dataset.dimensions.nrk>0
                arg{3}=k;
            end
    end
else
    % Data from matrix
    if timestep==0 || length(timestep)>1
        % Time-varying
        if m==0 || length(m)>1
            tp='timestackm';
        elseif n==0 || length(n)>1
            tp='timestackn';
        elseif k==0 || length(k)>1
            tp='timestackk';
        else
            tp='timeseries';
        end            
    else
        % Constant
        if m==0 || length(m)>1
            if n==0 || length(n)>1
                tp='map2d';
            elseif k==0 || length(k)>1
                tp='crossection2dm';
            else
                tp='crossection1dm';
            end
        elseif n==0 || length(n)>1
            if k==0 || length(k)>1
                tp='crossection2dn';
            else
                tp='crossection1dn';
            end
        else
            tp='profile';
        end
    end
    % Set input arguments
    if dataset.dimensions.nrt>0
        arg{1}=timestep;
        arg{2}=m;
        arg{3}=n;
        if dataset.dimensions.nrk>0
            arg{4}=k;
        end
    else
        arg{1}=m;
        arg{2}=n;
        if dataset.dimensions.nrk>0
            arg{3}=k;
        end
    end
end

% Load data
switch length(arg)
    case 1
        d=qpread(fid,idomain,parameter,'griddata',arg{1});
    case 2
        d=qpread(fid,idomain,parameter,'griddata',arg{1},arg{2});
    case{3}
        d=qpread(fid,idomain,parameter,'griddata',arg{1},arg{2},arg{3});
    case{4}
        d=qpread(fid,idomain,parameter,'griddata',arg{1},arg{2},arg{3},arg{4});
end

% Determine component
switch dataset.dimensions.quantity
    case{'vector2d','vector3d'}
        if isempty(dataset.component)
            dataset.component='vector';
        end
        % Vector, compute components if necessary
        switch lower(dataset.component)
            case('magnitude')
                d.Val=sqrt(d.XComp.^2+d.YComp.^2);
                dataset.dimensions.quantity='scalar';
            case('angle (radians)')
                d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi);
                dataset.dimensions.quantity='scalar';
            case('angle (degrees)')
                d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi)*180/pi;
                dataset.dimensions.quantity='scalar';
            case('m-component')
                d.Val=d.XComp;
                dataset.dimensions.quantity='scalar';
            case('n-component')
                d.Val=d.YComp;
                dataset.dimensions.quantity='scalar';
            case('x-component')
                d.Val=d.XComp;
                dataset.dimensions.quantity='scalar';
            case('y-component')
                d.Val=d.YComp;
                dataset.dimensions.quantity='scalar';
        end
end

% Compute y value for cross sections
plotcoordinate=[];
switch tp
    case{'timestackm','timestackn','crossection2dm','crossection1dm','crossection2dn','crossection1dn'}
        switch(lower(dataset.plotcoordinate))
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

switch tp
    case{'timeseriesstation','timeseries'}
        dataset.type='timeseries';
        dataset.x=d.Time;
        switch dataset.dimensions.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end
    case{'timestackstation','timestackk'}
        dataset.type='timestack';
        dataset.x=d.Time;
        dataset.y=d.Z;
        switch dataset.dimensions.quantity
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
    case{'profilestation','profile'}
        dataset.type='xy';
        dataset.y=d.Z;
        switch dataset.dimensions.quantity
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
    case{'timestackm','timestackn'}
        dataset.type='timestack';
        dataset.x=d.Time;
        dataset.y=plotcoordinate;
        switch dataset.dimensions.quantity
            case{'scalar'}
                dataset.y=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end
    case{'map2d'}
        dataset.type='map2d';
        dataset.x=d.X;
        dataset.y=d.Y;
        switch dataset.dimensions.quantity
            case{'scalar','boolean'}
                dataset.z=d.Val;
            case{'grid'}
                dataset.xdam=d.XDam;
                dataset.ydam=d.YDam;
            case{'vector2d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                % Why would you want this ?
                dataset.u=d.XComp;
                dataset.v=d.YComp;
        end
    case{'crossection2dm','crossection2dn'}
        dataset.type='crossection2d';
        dataset.x=plotcoordinate;
        dataset.y=d.Z;
        switch dataset.dimensions.quantity
            case{'scalar'}
                dataset.z=d.Val;
            case{'vector2d'}
                dataset.u=d.XComp;
                dataset.v=d.YComp;
            case{'vector3d'}
                dataset.u=d.XComp;
                dataset.v=d.ZComp;
        end
    case{'crossection1dm','crossection1dn'}
        dataset.type='crossection1d';
        dataset.x=plotcoordinate;
        switch dataset.dimensions.quantity
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

dataset.type=[dataset.type dataset.dimensions.quantity];

if isempty(dataset.time) || dataset.dimensions.nrt<=1
    dataset.tc='c';
else
    dataset.tc='t';
    dataset.availabletimes=times;
%    dataset.availablemorphtimes=data.morphtimes;
end

if isfield(dataset,'time')
    if isfield(dataset,'timestep')
        dataset=rmfield(dataset,'timestep');
    end
end
