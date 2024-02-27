function varargout=muppet_addDatasetTekal(varargin)

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
    fid=tekal('open',dataset.filename,'loaddata');
catch
    disp([dataset.filename ' does not appear to be a valid tekal file!']);    
end

dataset.fid=fid;

columnlabels=fid.Field(1).ColLabels;

sz=fid.Field(1).Size;
nblocks=length(fid.Field);

% Four types of tekal files
if strcmpi(fid.Field(1).DataTp,'annotation')
    tp='histogram';
else
    switch lower(columnlabels{1})
        case{'date'}
            tp='timeseries';
            % Check if all column labels are numbers
            % If so, assume that the data is a time stack
            its=1;
            for ic=3:length(columnlabels)
                if isempty(str2num(columnlabels{ic}))
                    its=0;
                end
            end
            if its
                tp='timestack';
            end
        otherwise
            if length(sz)==4
                tp='map';
            else
                tp='xy';
            end
    end
end

dataset.tekaltype=tp;
dataset.columnlabels=columnlabels;

nrows=sz(1);
ncols=sz(2);

dataset.nrblocks=nblocks;

fourier=0;
% Check if this is a Fourier map file
if ~isempty(fid.Field(1).Comments)
    for ic=1:length(fid.Field(1).Comments)
        ifou=strfind(fid.Field(1).Comments{ic},'Results fourier analysis');
        if ~isempty(ifou)
            fourier=1;
            const=t_getconsts;
            break
        end            
    end
end

for iblock=1:nblocks
    dataset.blocks{iblock}=fid.Field(iblock).Name;
    if fourier
        % Determine which component this is
        [a,b,f]=strread(dataset.blocks{iblock},'%s %s %f');
        % Recompute frequency degrees per hour to cycles per hour (as in t_getconst)
        f=f/360;
        % Find nearest frequency
        ic= abs(const.freq-f)==min(abs(const.freq-f));
        dataset.blocks{iblock}=[deblank(const.name(ic,:)) ' - ' a{1}];
    end
end
if isempty(dataset.block)
    dataset.block=dataset.blocks{1};
end

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
    case{'timestack'}        
        % Different blocks contain time series for different stations 
        npar=1;
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
%            par.name=columnlabels{ipar+2};
            par.name='timestack';
            par.size=[nrows 0 0 0 length(columnlabels)-2];
            par.times=times;
            dataset.parameters(ipar).parameter=par;            
        end
    case{'map'}
        % x and y in columns 1 and 2
        dataset.xcoordinate=columnlabels{1};
        dataset.ycoordinate=columnlabels{2};        
        dataset.selectxcoordinate=1;        
        dataset.selectycoordinate=1;
        npar=ncols;
        for ipar=1:npar
            par=[];
            par=muppet_setDefaultParameterProperties(par);
            par.name=columnlabels{ipar};
            par.size=[0 0 sz(3) sz(4) 0];
            dataset.parameters(ipar).parameter=par;            
        end        
    case{'xy'}
        % x and y
        npar=ncols;
        if npar==2
            dataset.selectxcoordinate=1;
            if isempty(dataset.xcoordinate)
                dataset.xcoordinate=columnlabels{1};
            end
            if isempty(dataset.parameter)
                dataset.parameter=columnlabels{2};
            end
        else
            dataset.selectxcoordinate=1;
            dataset.selectycoordinate=1;
            if isempty(dataset.xcoordinate)
            dataset.xcoordinate=columnlabels{1};
            end
            if isempty(dataset.ycoordinate)
            dataset.ycoordinate=columnlabels{2};
            end
            if isempty(dataset.parameter)
            dataset.parameter=columnlabels{3};
            end
        end
%        if isempty(dataset.parameter)
%            dataset.parameter=columnlabels{2};
%        end
        
        for ipar=1:npar
            par=[];
            par=muppet_setDefaultParameterProperties(par);
            par.name=columnlabels{ipar};
            par.size=[0 0 0 0 0];
            dataset.parameters(ipar).parameter=par;                        
        end        
    case{'histogram'}
        % x and y
        npar=ncols-1;
        for ipar=1:npar
            par=[];
            par=muppet_setDefaultParameterProperties(par);
            par.name=columnlabels{ipar}; % Label is in the last column
            par.size=[0 0 0 0 0];
            dataset.parameters(ipar).parameter=par;            
        end
end

% Tekal files can have multiple quantities, so ...
dataset.selectedquantity='scalar';
dataset.selectquantity=0;        

dataset.scalar_or_vector=0;

switch tp
    case{'timeseries'}
        if npar>1
            % Set possible quantities
            dataset.selectquantity=1;
            dataset.scalar_or_vector=1;
            %             dataset.nrquantities=2;
            %             dataset.quantities={'scalar','vector2d'};
            %             dataset.ucomponent=dataset.parameters(1).parameter.name;
            %             dataset.vcomponent=dataset.parameters(2).parameter.name;
        end
    case{'map'}
        %         dataset.activeparameter=3;
        if npar>3
            % Set possible quantities
            dataset.selectquantity=1;
            dataset.selectuvcomponent=1;
            dataset.scalar_or_vector=1;
            %             dataset.nrquantities=2;
            %             dataset.quantities={'scalar','vector2d'};
            %             dataset.quantity='vector2d';
            dataset.ucomponent=dataset.parameters(3).parameter.name;
            dataset.vcomponent=dataset.parameters(4).parameter.name;
        end
end

%%
function dataset=import(dataset)

%fid=tekal('open',dataset.filename);
fid=dataset.fid;

[timestep,istation,m,n,k]=muppet_findDataIndices(dataset);

iblock=strmatch(lower(dataset.block),lower(dataset.blocks),'exact');

% Two options:

dataset.rawquantity='scalar';
dataset.quantity='scalar';

if dataset.scalar_or_vector
    if dataset.from_gui
        % 1) we came here through GUI import
        if strcmpi(dataset.selectedquantity,'vector2d')
            dataset.rawquantity='vector2d';
            dataset.quantity='vector2d';
            dataset.parameter='';
        else
            dataset.ucomponent='';
            dataset.vcomponent='';
        end
    else
        % 2) we came here from loading mup file
        if isempty(dataset.parameter)
            dataset.rawquantity='vector2d';
            dataset.quantity='vector2d';
        else
            dataset.ucomponent='';
            dataset.vcomponent='';            
        end
    end
end

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
    case{'timestack'}
        switch dataset.quantity
            case{'scalar'}
                parameter.time=dataset.times;
                parameter.val=fid.Field(iblock).Data(:,3:end);
                parameter.val(parameter.val==999.999)=NaN;
                parameter.val(parameter.val==-999)=NaN;
                for ic=3:length(dataset.columnlabels)
                    z(ic-2)=str2num(dataset.columnlabels{ic});
                end
%                parameter.z=z;
                parameter.z=repmat(z,[length(parameter.time) 1]);
                parameter.time=repmat(parameter.time,[1 length(z)]);
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
                parameter.x(isnan(parameter.val))=NaN;
                parameter.y(isnan(parameter.val))=NaN;
            case{'vector2d'}
                icolu=strmatch(lower(dataset.ucomponent),lower(dataset.columnlabels),'exact');
                icolv=strmatch(lower(dataset.vcomponent),lower(dataset.columnlabels),'exact');
                parameter.u=fid.Field(iblock).Data(:,:,icolu);
                parameter.u(parameter.u==999.999)=NaN;
                parameter.u(parameter.u==-999)=NaN;
                parameter.v=fid.Field(iblock).Data(:,:,icolv);
                parameter.v(parameter.u==999.999)=NaN;
                parameter.v(parameter.u==-999)=NaN;
                parameter.x(isnan(parameter.u))=NaN;
                parameter.y(isnan(parameter.u))=NaN;
        end
    case{'xy'}
        icolx=strmatch(lower(dataset.xcoordinate),lower(dataset.columnlabels),'exact');
        icoly=strmatch(lower(dataset.ycoordinate),lower(dataset.columnlabels),'exact');
        if isempty(icoly)
            
            % This is an xy dataset
            icoly=strmatch(lower(dataset.parameter),lower(dataset.columnlabels),'exact');
            
            parameter.x=fid.Field(iblock).Data(:,icolx);
            parameter.y=fid.Field(iblock).Data(:,icoly);
            parameter.x(parameter.x==999.999)=NaN;
            parameter.x(parameter.x==-999)=NaN;
            parameter.y(parameter.y==999.999)=NaN;
            parameter.y(parameter.y==-999)=NaN;
            dataset.type='xy1dxy';
            
        else
            
            % This is an xyz dataset
            icolz=strmatch(lower(dataset.parameter),lower(dataset.columnlabels),'exact');
            
            parameter.x=fid.Field(iblock).Data(:,icolx);
            parameter.y=fid.Field(iblock).Data(:,icoly);
            parameter.val=fid.Field(iblock).Data(:,icolz);
            parameter.x(parameter.x==999.999)=NaN;
            parameter.x(parameter.x==-999)=NaN;
            parameter.y(parameter.y==999.999)=NaN;
            parameter.y(parameter.y==-999)=NaN;
            parameter.val(parameter.val==999.999)=NaN;
            parameter.val(parameter.val==-999)=NaN;
            dataset.type='scalar1dxyz';
            
        end
%         parameter.x=fid.Field(iblock).Data(:,icolx);
%         parameter.y=fid.Field(iblock).Data(:,icoly);
%         parameter.x(parameter.x==999.999)=NaN;
%         parameter.x(parameter.x==-999)=NaN;
%         parameter.y(parameter.y==999.999)=NaN;
%         parameter.y(parameter.y==-999)=NaN;
%         dataset.type='xy1dxy';
    case{'histogram'}
        icol=strmatch(lower(dataset.parameter),lower(dataset.columnlabels),'exact');
        parameter.x=1:size(fid.Field(iblock).Data{1},1);
        parameter.y=fid.Field(iblock).Data{1}(:,icol);
        dataset.xticklabel=fid.Field(iblock).Data{2};
        dataset.type='histogram';
end

% Get values (and store in same structure format as qpread)
d.X=muppet_extractmatrix(parameter,'x',dataset.size,timestep,istation,m,n,k);
d.Y=muppet_extractmatrix(parameter,'y',dataset.size,timestep,istation,m,n,k);
d.Z=muppet_extractmatrix(parameter,'z',dataset.size,timestep,istation,m,n,k);
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
