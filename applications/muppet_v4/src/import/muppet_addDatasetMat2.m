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

% File has already been loaded in read function
s=dataset.data;

% Find parameter to be read
for ipar=1:length(s.parameters)
    if strcmpi(s.parameters(ipar).parameter.name,dataset.parameter)
        parameter=s.parameters(ipar).parameter;
        break
    end
end

[timestep,istation,m,n,k]=muppet_findDataIndices(dataset);
shp=muppet_findDataShape(dataset.size,timestep,istation,m,n,k);

if isfield(parameter,dataset.timename)
    t=parameter.(dataset.timename)(timestep);
end
if isfield(parameter,dataset.xname)
    switch dataset.quantity
        case{'location'}
            % track
            if dataset.size(1)>0
                x=parameter.(dataset.xname)(timestep,m);
            else
                x=parameter.(dataset.xname)(m);
            end
        otherwise
            x=parameter.(dataset.xname)(m,n);
    end
end
if isfield(parameter,dataset.yname)
    switch dataset.quantity
        case{'location'}
            if dataset.size(1)>0
                y=parameter.(dataset.yname)(timestep,m);
            else
                y=parameter.(dataset.yname)(m);
            end
        otherwise
            y=parameter.(dataset.yname)(m,n);
    end
end
if isfield(parameter,dataset.zname)
    z=parameter.(dataset.zname)(m,n);
end

% Get values (and store in same structure format as qpread)
val=extractmatrix(parameter,dataset.valname,dataset.size,timestep,istation,m,n,k);
u=extractmatrix(parameter,dataset.uname,dataset.size,timestep,istation,m,n,k);
v=extractmatrix(parameter,dataset.vname,dataset.size,timestep,istation,m,n,k);
w=extractmatrix(parameter,dataset.wname,dataset.size,timestep,istation,m,n,k);
uamplitude=extractmatrix(parameter,dataset.uamplitudename,dataset.size,timestep,istation,m,n,k);
vamplitude=extractmatrix(parameter,dataset.vamplitudename,dataset.size,timestep,istation,m,n,k);
uphase=extractmatrix(parameter,dataset.uphasename,dataset.size,timestep,istation,m,n,k);
vphase=extractmatrix(parameter,dataset.vphasename,dataset.size,timestep,istation,m,n,k);

dataset.val=val;
dataset.u=u;
dataset.v=v;
dataset.w=w;
dataset.uamplitude=uamplitude;
dataset.vamplitude=vamplitude;
dataset.uphase=uphase;
dataset.vphase=vphase;

if strcmpi(dataset.quantity,'vector')
    dataset.quantity='vector2d';
end

% Determine component
switch dataset.quantity
    case{'vector2d','vector3d'}
        if isempty(dataset.component)
            dataset.component='vector';
        end
        % Vector, compute components if necessary
        switch lower(dataset.component)
            case('magnitude')
                val=sqrt(u.^2+v.^2);
                dataset.quantity='scalar';
            case('angle (radians)')
                val=mod(0.5*pi-atan2(v,u),2*pi);
                dataset.quantity='scalar';
            case('angle (degrees)')
                val=mod(0.5*pi-atan2(v,u),2*pi)*180/pi;
                dataset.quantity='scalar';
            case('m-component')
                val=u;
                dataset.quantity='scalar';
            case('n-component')
                val=v;
                dataset.quantity='scalar';
            case('x-component')
                val=u;
                dataset.quantity='scalar';
            case('y-component')
                val=v;
                dataset.quantity='scalar';
        end
end

%dataset.times=parameter.(dataset.timename);

% Compute y value for cross sections
plotcoordinate=[];
switch shp
    case{'timestackm','timestackn','crossection2dm','crossection1dm','crossection2dn','crossection1dn'}
        switch(lower(dataset.xcoordinate))
            case{'x'}
                x=squeeze(x);
            case{'y'}
                x=squeeze(y);
            case{'pathdistance'}
                x=pathdistance(squeeze(x),squeeze(y));
            case{'revpathdistance'}
                x=pathdistance(squeeze(x),squeeze(y));
                x=x(end:-1:1);
        end
        plotcoordinate=x;
end

% Determine coordinates
switch shp
    case{'polyline'}
        dataset.x=x;
        dataset.y=y;
        tp='polyline2d';
        tc='c';
        dataset.quantity='';
    case{'timestackstation'}
        dataset.x=t;
        dataset.y=z;
        dataset.z=val;
        tp='timestack';
        tc='t';
    case{'timeseriesstation'}
        switch dataset.quantity
            case{'location'}
                dataset.x=x;
                dataset.y=y;
                tp='track';
                tc='c';
                dataset.quantity='';
            otherwise
                dataset.x=t;
                dataset.y=val;
                tp='timeseries';
                tc='t';
        end
    case{'profilestation'}
        dataset.x=val;
        dataset.y=z;
        tp='xy';
        tc='c';
    case{'timestackm','timestackn'}
        dataset.x=t;
        dataset.y=plotcoordinate;        
        dataset.z=val;
        tp='timestack';
        tc='t';
    case{'timestackk'}
        dataset.x=t;
        dataset.y=z;        
        dataset.z=val;
        tp='timestack';
        tc='t';
    case{'timeseries'}
        dataset.x=t;
        dataset.y=val;
        tp='timeseries';
        tc='t';
    case{'map2d'}
        dataset.x=x;
        dataset.y=y;
        dataset.z=val;
        tp='map2d';
        tc='c';
    case{'crossection1dm','crossection1dn'}
        dataset.x=plotcoordinate;
        dataset.y=val;
        tp='xy';
        tc='c';
    case{'crossection2dm','crossection2dn'}
        dataset.x=plotcoordinate;
        dataset.y=z;
        dataset.z=val;
        tp='crosssection2d';
        tc='c';
    case{'profile'}        
        dataset.x=val;
        dataset.y=z;
        tp='xy';
        tc='c';
end

dataset.type=[tp dataset.quantity];

% Exceptions
switch dataset.quantity
    case{'tidalellipse'}
        dataset.type='tidalellipse';
end

switch tc
    case{'t'}
        dataset.tc='c';
    case{'c'}
%         if orishp(1)=='1'
%             dataset.tc='t';
%         else
            dataset.tc='c';
%         end
end

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
