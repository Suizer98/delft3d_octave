function varargout=muppet_addDatasetDelft3DBoundaryConditions(varargin)

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
            case{'gettimes'}
                varargout{1}=[];
        end
    end
end

%%
function dataset=read(dataset,varargin)

try
    info = bct_io('READ',dataset.filename);
catch
    disp([dataset.filename ' does not appear to be a valid Delft3D boundary conditions file!']);    
end

dataset.info=info;

columnlabels=fid.Field(1).ColLabels;

sz=fid.Field(1).Size;
nblocks=length(fid.Field);

% Three types of tekal files
switch lower(columnlabels{1})
    case{'date'}
        tp='timeseries';
    otherwise
        if length(sz)==4
            tp='map';
        else
            tp='xy';
        end
end

dataset.tekaltype=tp;
dataset.columnlabels=columnlabels;

nrows=sz(1);
ncols=sz(2);

dataset.nrblocks=nblocks;
for iblock=1:nblocks
    dataset.blocks{iblock}=fid.Field(iblock).Name;
end
dataset.block=dataset.blocks{1};

switch tp
    case{'timeseries'}        
        % Different blocks contain time series for different stations 
        npar=ncols-2;
        dates=fid.Field(1).Data(:,1);
        times=fid.Field(1).Data(:,2);
        years=floor(dates/10000);
        months=floor((dates-years*10000)/100);
        days=dates-years*10000-months*100;
        hours=floor(times/10000);
        minutes=floor((times-hours*10000)/100);
        seconds=times-hours*10000-minutes*100;
        times=datenum(years,months,days,hours,minutes,seconds);
        for ipar=1:npar
            par=[];
            par=muppet_setDefaultParameterProperties(par);
            par.timesbyblock=1;
            par.name=columnlabels{ipar+2};
            par.size=[nrows 0 0 0 0];
            par.times=times;
            dataset.parameters(ipar).parameter=par;            
        end
    case{'map'}
        % x and y in columns 1 and 2
        dataset.xcoordinate=columnlabels{1};
        dataset.ycoordinate=columnlabels{2};        
        dataset.selectcoordinates=1;        
        npar=ncols;
        for ipar=1:npar
            par=[];
            par=muppet_setDefaultParameterProperties(par);
            par.name=columnlabels{ipar};
            par.size=[0 0 sz(3) sz(4) 0];
            dataset.parameters(ipar).parameter=par;            
        end        
end

% Tekal files can have multiple quantities, so ...
dataset.selectedquantity='scalar';
switch tp
    case{'timeseries'}
        if npar>1
            % Set possible quantities
            dataset.nrquantities=2;
            dataset.quantities={'scalar','vector2d'};
            dataset.ucomponent=dataset.parameters(1).parameter.name;
            dataset.vcomponent=dataset.parameters(2).parameter.name;
        end
    case{'map'}
        dataset.activeparameter=3;
        if npar>3
            % Set possible quantities
            dataset.nrquantities=2;
            dataset.quantities={'scalar','vector2d'};
            dataset.ucomponent=dataset.parameters(3).parameter.name;
            dataset.vcomponent=dataset.parameters(4).parameter.name;
        end
end

%%
function dataset=import(dataset)

fid=tekal('open',dataset.filename);

[timestep,istation,m,n,k]=muppet_findDataIndices(dataset);

iblock=strmatch(lower(dataset.block),lower(dataset.blocks),'exact');

dataset.quantity=dataset.selectedquantity;

switch dataset.tekaltype
    case{'timeseries'}
        switch dataset.quantity
            case{'scalar'}
                icol=strmatch(lower(dataset.parameter),lower(dataset.columnlabels),'exact');
                parameter.time=dataset.times;
                parameter.val=fid.Field(iblock).Data(:,icol);
                parameter.val(parameter.val==999.999)=NaN;
                parameter.val(parameter.val==-999)=NaN;
            case{'vector2d'}
                icolu=strmatch(lower(dataset.ucomponent),lower(dataset.columnlabels),'exact');
                icolv=strmatch(lower(dataset.vcomponent),lower(dataset.columnlabels),'exact');
                parameter.time=dataset.times;
                parameter.u=fid.Field(iblock).Data(:,icolu);
                parameter.u(parameter.u==999.999)=NaN;
                parameter.u(parameter.u==-999)=NaN;
                parameter.v=fid.Field(iblock).Data(:,icolv);
                parameter.v(parameter.u==999.999)=NaN;
                parameter.v(parameter.u==-999)=NaN;
        end
    case{'map'}
        parameter.x=fid.Field(iblock).Data(:,:,1);
        parameter.y=fid.Field(iblock).Data(:,:,2);                
        parameter.x(parameter.x==999.999)=NaN;
        parameter.x(parameter.x==-999)=NaN;
        parameter.y(parameter.y==999.999)=NaN;
        parameter.y(parameter.y==-999)=NaN;
        switch dataset.quantity
            case{'scalar'}
                icol=strmatch(lower(dataset.parameter),lower(dataset.columnlabels),'exact');
                parameter.val=fid.Field(iblock).Data(:,:,icol);
                parameter.val(parameter.val==999.999)=NaN;
                parameter.val(parameter.val==-999)=NaN;
            case{'vector2d'}
                icolu=strmatch(lower(dataset.ucomponent),lower(dataset.columnlabels),'exact');
                icolv=strmatch(lower(dataset.vcomponent),lower(dataset.columnlabels),'exact');
                parameter.u=fid.Field(iblock).Data(:,:,icolu);
                parameter.u(parameter.u==999.999)=NaN;
                parameter.u(parameter.u==-999)=NaN;
                parameter.v=fid.Field(iblock).Data(:,:,icolv);
                parameter.v(parameter.u==999.999)=NaN;
                parameter.v(parameter.u==-999)=NaN;
        end
    case{'xy'}
end

% Get values (and store in same structure format as qpread)
d.X=muppet_extractmatrix(parameter,'x',dataset.size,timestep,istation,m,n,k);
d.Y=muppet_extractmatrix(parameter,'y',dataset.size,timestep,istation,m,n,k);
d.Time=muppet_extractmatrix(parameter,'time',dataset.size,timestep,istation,m,n,k);
d.Val=muppet_extractmatrix(parameter,'val',dataset.size,timestep,istation,m,n,k);
d.XComp=muppet_extractmatrix(parameter,'u',dataset.size,timestep,istation,m,n,k);
d.YComp=muppet_extractmatrix(parameter,'v',dataset.size,timestep,istation,m,n,k);
d.ZComp=muppet_extractmatrix(parameter,'w',dataset.size,timestep,istation,m,n,k);
d.UAmplitude=muppet_extractmatrix(parameter,'uamplitude',dataset.size,timestep,istation,m,n,k);
d.VAmplitude=muppet_extractmatrix(parameter,'vamplitude',dataset.size,timestep,istation,m,n,k);
d.UPhase=muppet_extractmatrix(parameter,'uphase',dataset.size,timestep,istation,m,n,k);
d.VPhase=muppet_extractmatrix(parameter,'vphase',dataset.size,timestep,istation,m,n,k);

% From here on, everything should be the same for each type of datafile
dataset=muppet_finishImportingDataset(dataset,d,timestep,istation,m,n,k);
