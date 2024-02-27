function varargout=muppet_addDatasetMat(varargin)

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
dataset.parameterstationsequal=0;
dataset.parameterxequal=1;
dataset.parameteryequal=1;
dataset.parameterzequal=1;
dataset.adjustname=1;
dataset.filename
s=load(dataset.filename);

for j=1:length(s.parameters)
    dataset.parameternames{j}=s.parameters(j).parameter.name;
end

% Coordinate System
dataset.coordinatesystem.name='undefined';
dataset.coordinatesystem.type='projected';
if isfield(s,'coordinatesystem')
    dataset.coordinatesystem=s.coordinatesystem;
end
cs=dataset.coordinatesystem;

for ii=1:length(s.parameters)
    
    % Set default parameter properties
    par=[];
    
    par.dimensions.coordinatesystem=cs;
    
    par.dimensions.parametername=s.parameters(ii).parameter.name;
    
    par.dimensions.nrm=0;
    par.dimensions.nrn=0;
    par.dimensions.nrk=0;
    
    par.dimensions.nrt=0;
    par.dimensions.times=[];
    
    par.dimensions.nrstations=0;
    par.dimensions.stations={''};
    
    par.dimensions.nrdomains=0;
    par.dimensions.domains={''};
    
    par.dimensions.nrsubfields=0;
    par.dimensions.subfields={''};
    
    if isfield(s.parameters(ii).parameter,'time')
        par.dimensions.times=s.parameters(ii).parameter.time;
        par.dimensions.nrt=length(par.dimensions.times);
    end
    
    if isfield(s.parameters(ii).parameter,'stations')
        par.dimensions.stations=s.parameters(ii).parameter.stations;
        par.dimensions.nrstations=length(par.dimensions.stations);
    end
    
    par.dimensions.nrm=s.parameters(ii).parameter.dimensions(3);
    par.dimensions.nrn=s.parameters(ii).parameter.dimensions(4);
    par.dimensions.nrk=s.parameters(ii).parameter.dimensions(5);
    
%    par.dimensions.datatype='location';
    if isfield(s.parameters(ii).parameter,'quantity')
        par.dimensions.quantity=s.parameters(ii).parameter.quantity;
    end
%     
%     
%     if isempty(parameter)
        dataset.parameters(ii).parameter.dimensions=par.dimensions;
        dataset.parameters(ii).parameter.active=1;
%     else
%         dataset.dimensions=par.dimensions;
%     end
%     
end

dataset.nrparameters=length(s.parameters);

%%
function dataset=import(dataset)
%
s=load(dataset.filename);

for ipar=1:length(s.parameters)
    if strcmpi(s.parameters(ipar).parameter.name,dataset.parameter)
        parameter=s.parameters(ipar).parameter;
        break
    end
end

m=dataset.m;
n=dataset.n;
k=dataset.k;
timestep=dataset.timestep;

if m==0
    m=[];
end
if n==0
    n=[];
end

if isempty(m)
    if dataset.dimensions.nrm>0
        m=1:dataset.dimensions.nrm;
    else
        m=1;
    end
end
if isempty(n)
    if dataset.dimensions.nrn>0
        n=1:dataset.dimensions.nrn;
    else
        n=1;
    end
end
if isempty(k)
    if dataset.dimensions.nrk>0
        k=1:dataset.dimensions.nrk;
    else
        k=1;
    end
end
if isempty(timestep) || dataset.timestep==0
    if dataset.dimensions.nrt>0
        timestep=1:dataset.dimensions.nrt;
    else
        timestep=1;
    end
end


% Find out the shape of data that is required
if parameter.dimensions(2)>0
    % Data from station
    if length(timestep)>1
        % Time varying
        if length(k)>1
            shp='timestackstation';
        else
            shp='timeseriesstation';
        end
    else
        % Profile
        shp='profilestation';
    end
else
    % Data from matrix
    if timestep==0 || length(timestep)>1
        % Time-varying
        if m==0 || length(m)>1
            shp='timestackm';
        elseif n==0 || length(n)>1
            shp='timestackn';
        elseif k==0 || length(k)>1
            shp='timestackk';
        else
            shp='timeseries';
        end
    else
        % Constant
        if length(m)>1
            if length(n)>1
                shp='map2d';
            elseif length(k)>1
                shp='crossection2dm';
            else
                shp='crossection1dm';
            end
        elseif length(n)>1
            if length(k)>1
                shp='crossection2dn';
            else
                shp='crossection1dn';
            end
        else
            shp='profile';
        end
    end
end

% Find station number
istation=0;
if isfield(dataset,'station')
    if ~isempty(dataset.station)
        istation=strmatch(dataset.station,parameter.stations,'exact');
    else
        istation=1:parameter.dimensions(2);
    end    
end

xname='x';
yname='y';
uname='u';
vname='v';
valname='val';

switch shp
    case{'polyline'}
                dataset.x=parameter.x;
                dataset.y=parameter.y;
                dataset.type='polyline2d';
                dataset.tc='c';
        
    case{'timestackstation'}
        
    case{'timeseriesstation'}
        switch dataset.dimensions.quantity
            case{'location'}
                timestep=1:length(parameter.time);
                dataset.x=parameter.(xname)(timestep,istation);
                dataset.y=parameter.(yname)(timestep,istation);
                dataset.times=parameter.time;
                dataset.type='track';
                dataset.tc='c';
            case{'vector'}
                dataset.x=parameter.time;
                dataset.u=parameter.(uname)(istation,timestep);
                dataset.v=parameter.(vname)(istation,timestep);
                dataset.type='timeseriesvector';
                dataset.tc='c';
            otherwise
                % scalar
                dataset.x=parameter.time;
                dataset.y=parameter.(valname)(istation,timestep);
                dataset.type='timeseriesscalar';
                dataset.tc='c';
        end
    case{'profilestation'}
    case{'timestackm'}
    case{'timestackn'}
    case{'timestackk'}
    case{'timeseries'}
    case{'map2d'}
        switch dataset.dimensions.quantity
            case{'scalar'}
                dataset.x=parameter.x;
                dataset.y=parameter.y;
                dataset.z=parameter.val;
                dataset.zz=parameter.val;
                dataset.type='map2dscalar';
                dataset.tc='c';
            case{'vector'}
                dataset.x=parameter.x;
                dataset.y=parameter.y;
                dataset.u=parameter.u;
                dataset.v=parameter.v;
                dataset.type='map2dvector2d';
                dataset.tc='c';
        end
    case{'crossection1dm'}
        switch dataset.dimensions.quantity
            case{'location'}
                dataset.x=parameter.x;
                dataset.y=parameter.y;
                dataset.type='polyline2d';
                dataset.tc='c';
            otherwise
                % scalar
                dataset.x=parameter.time;
                dataset.y=parameter.(valname)(istation,timestep);
                dataset.type='timeseriesscalar';
                dataset.tc='c';
        end
    case{'crossection1dn'}
    case{'crossection2dm'}
    case{'crossection2dn'}
    case{'profile'}        
end


% % Determine component
% switch dataset.dimensions.quantity
%     case{'vector2d','vector3d'}
%         if isempty(dataset.component)
%             dataset.component='vector';
%         end
%         % Vector, compute components if necessary
%         switch lower(dataset.component)
%             case('magnitude')
%                 d.Val=sqrt(d.XComp.^2+d.YComp.^2);
%                 dataset.dimensions.quantity='scalar';
%             case('angle (radians)')
%                 d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi);
%                 dataset.dimensions.quantity='scalar';
%             case('angle (degrees)')
%                 d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi)*180/pi;
%                 dataset.dimensions.quantity='scalar';
%             case('m-component')
%                 d.Val=d.XComp;
%                 dataset.dimensions.quantity='scalar';
%             case('n-component')
%                 d.Val=d.YComp;
%                 dataset.dimensions.quantity='scalar';
%             case('x-component')
%                 d.Val=d.XComp;
%                 dataset.dimensions.quantity='scalar';
%             case('y-component')
%                 d.Val=d.YComp;
%                 dataset.dimensions.quantity='scalar';
%         end
% end
%
% % Compute y value for cross sections
% plotcoordinate=[];
% switch tp
%     case{'timestackm','timestackn','crossection2dm','crossection1dm','crossection2dn','crossection1dn'}
%         switch(lower(dataset.plotcoordinate))
%             case{'x'}
%                 x=squeeze(d.X);
%             case{'y'}
%                 x=squeeze(d.Y);
%             case{'pathdistance'}
%                 x=pathdistance(squeeze(d.X),squeeze(d.Y));
%             case{'revpathdistance'}
%                 x=pathdistance(squeeze(d.X),squeeze(d.Y));
%                 x=x(end:-1:1);
%         end
%         plotcoordinate=x;
% end
%
% % Set empty values
% dataset.x=[];
% dataset.x=[];
% dataset.y=[];
% dataset.z=[];
% dataset.xz=[];
% dataset.yz=[];
% dataset.zz=[];
% dataset.u=[];
% dataset.v=[];
% dataset.w=[];
%
% switch tp
%     case{'timeseriesstation','timeseries'}
%         dataset.type='timeseries';
%         dataset.x=d.Time;
%         switch dataset.dimensions.quantity
%             case{'scalar'}
%                 dataset.y=d.Val;
%             case{'vector2d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%         end
%     case{'timestackstation','timestackk'}
%         dataset.type='timestack';
%         dataset.x=d.Time;
%         dataset.y=d.Z;
%         switch dataset.dimensions.quantity
%             case{'scalar'}
%                 dataset.y=d.Val;
%             case{'vector2d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.ZComp;
%         end
%     case{'profilestation','profile'}
%         dataset.type='xy';
%         dataset.y=d.Z;
%         switch dataset.dimensions.quantity
%             case{'scalar'}
%                 dataset.x=d.Val;
%             case{'vector2d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.ZComp;
%         end
%     case{'timestackm','timestackn'}
%         dataset.type='timestack';
%         dataset.x=d.Time;
%         dataset.y=plotcoordinate;
%         switch dataset.dimensions.quantity
%             case{'scalar'}
%                 dataset.y=d.Val;
%             case{'vector2d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%         end
%     case{'map2d'}
%         dataset.type='map2d';
%         dataset.x=d.X;
%         dataset.y=d.Y;
%         switch dataset.dimensions.quantity
%             case{'scalar','boolean'}
%                 dataset.z=d.Val;
%             case{'grid'}
%                 dataset.xdam=d.XDam;
%                 dataset.ydam=d.YDam;
%             case{'vector2d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%         end
%     case{'crossection2dm','crossection2dn'}
%         dataset.type='crossection2d';
%         dataset.x=plotcoordinate;
%         dataset.y=d.Z;
%         switch dataset.dimensions.quantity
%             case{'scalar'}
%                 dataset.z=d.Val;
%             case{'vector2d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.ZComp;
%         end
%     case{'crossection1dm','crossection1dn'}
%         dataset.type='crossection1d';
%         dataset.x=plotcoordinate;
%         switch dataset.dimensions.quantity
%             case{'scalar'}
%                 dataset.y=d.Val;
%             case{'vector2d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.ZComp;
%         end
% end
%
% dataset.xz=dataset.x;
% dataset.yz=dataset.y;
% dataset.zz=dataset.z;
%
% dataset.type=[dataset.type dataset.dimensions.quantity];
%
% if isempty(dataset.time) || dataset.dimensions.nrt<=1
%     dataset.tc='c';
% else
%     dataset.tc='t';
%     dataset.availabletimes=times;
% %    dataset.availablemorphtimes=data.morphtimes;
% end
%
% if isfield(dataset,'time')
%     if isfield(dataset,'timestep')
%         dataset=rmfield(dataset,'timestep');
%     end
% end
