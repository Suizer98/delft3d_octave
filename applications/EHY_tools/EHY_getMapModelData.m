function varargout = EHY_getMapModelData(inputFile,varargin)
%% varargout = EHY_getMapModelData(inputFile,varargin)
% Extracts top view data (of water levels/velocities/salinity/temperature) from output of different model types
%
% Running 'EHY_getMapModelData' without any arguments opens a interactive version, that also gives
% feedback on how to use the EHY_getMapModelData-function with input arguments.
%
% Input Arguments:
% inputFile : file with simulation results
%
% Optional input arguments:
% varName   : Name of variable, choose from:
%             'wl'        water level
%             'wd'        water depth
%             'dps'       bed level
%             'uv'        velocities (in (u,v,)x,y-direction)
%             'sal'       salinity
%             'tem'       temperature
% t0        : Start time of dataset (e.g. '01-Jan-2018' or 737061 (Matlab date) )
% tend      : End time of dataset (e.g. '01-Feb-2018' or 737092 (Matlab date) )
% layer     : Model layer, e.g. '0' (all layers), [2] or [4:8]
% tint      : interval time (t0:tint:tend) in days
%
% Output:
% Data.times              : (matlab) times belonging with the series
% Data.val/vel_*          : requested data
% Data.dimensions         : Dimensions of requested data (time,spatial_dims,lyrs)
% Data.OPT                : Structure with optional user settings used
%
% Example1: EHY_getMapModelData % interactive
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
%
%names of variables:
%   mesh2d_flowelem_ba      cell area
%   mesh2d_flowelem_bl      bed level
%   mesh2d_czs              chezy friction
%   mesh2d_flowelem_zcc     Vertical coordinate of layer centres at pressure points
%   mesh2d_flowelem_zw      Vertical coordinate of layer interfaces at pressure points

%% check user input
if ~exist('inputFile','var')
    EHY_getMapModelData_interactive
    return
end

%% Settings
OPT.varName           = 'wl';
OPT.t0                = '';
OPT.tend              = '';
OPT.tint              = ''; % in days
OPT.t                 = []; % time index. If OPT.t is specified, OPT.t0, OPT.tend and OPT.tint are not used to find time index
OPT.layer             = 0;  % all
OPT.m                 = 0;  % all (horizontal structured grid [m,n])
OPT.n                 = 0;  % all (horizontal structured grid [m,n])
OPT.k                 = 0;  % all (vertical d3d grid [m,n,k])
OPT.sedimentName      = {}; % char or cell array with the name of sediment fraction(s)
OPT.mergePartitions   = 1;  % merge output from several dfm spatial *.nc-files
OPT.mergePartitionNrs = []; % partition nrs that will be merged, e.g. [0, 4, 5]
OPT.mergeCMEMSdata    = 1;  % merge data from different map-netCDF's
OPT.disp              = 1;  % display status of getting map model data
OPT.gridFile          = ''; % grid (either lga or nc file) needed in combination with delwaq output file
OPT.sgft0             = 0;  % delwaq segment function (sgf) - datenum or datestr of t0
OPT.sgfkmax           = []; % delwaq segment function (sgf) - number of layers (k_max)
OPT.nAverageAnglePli  = 2;  % number of points of the pli-file to average in computing the angle for projecting vectorial variables
OPT.tol_t             = 0;  % tolerance to match time in datenum 
OPT.bed_layers        = 0;  % bed layers

% return output at specified reference level
OPT.z                 = ''; % z = positive up. Wanted vertical level = OPT.zRef + OPT.z
OPT.zRef              = ''; % choose: '' = model reference level, 'wl' = water level or 'bed' = from bottom level
OPT.zMethod           = ''; % interpolation method: '' = corresponding layer or 'linear' = 'interpolation between two layers'

% return output (cross section view) along a pli (file)
OPT.pliFile           = ''; % *.pli, *.ldb , *.pol 
OPT.pli               = []; % thalweg [n x 2]

% ini waterlevel needed for DELWAQ .map files
OPT.dw_iniWL          = 0;

OPT                   = setproperty(OPT,varargin);

%% modify input
inputFile = strtrim(inputFile);
if ~isempty(OPT.t0);        OPT.t0   = datenum(OPT.t0);     end
if ~isempty(OPT.tend);      OPT.tend = datenum(OPT.tend);   end
if ~isempty(OPT.sgft0);     OPT.sgft0 = datenum(OPT.sgft0); end
if ~isnumeric(OPT.t);       OPT.t = str2num(OPT.t);         end
if ~isnumeric(OPT.tint);    OPT.tint = str2num(OPT.tint);   end
if ~isnumeric(OPT.m);       OPT.m = str2num(OPT.m);         end
if ~isnumeric(OPT.n);       OPT.n = str2num(OPT.n);         end
if ~isnumeric(OPT.k);       OPT.k = str2num(OPT.k);         end
if ~isnumeric(OPT.z);       OPT.z = str2num(OPT.z);         end
if ~isnumeric(OPT.sgfkmax); OPT.sgfkmax = str2num(OPT.sgfkmax); end
if ~isnumeric(OPT.mergePartitions); OPT.mergePartitions = str2num(OPT.mergePartitions); end
if ~isnumeric(OPT.layer) && ~isempty(str2num(OPT.layer))
    OPT.layer   = str2num(OPT.layer);
end
if all(OPT.layer==0) && ~all(OPT.k==0) % OPT.k was provided, OPT.layer not
    OPT.layer = OPT.k; % OPT.layer is used in script
end

%% Get model type
modelType = EHY_getModelType(inputFile);

%% Get name of the parameter as known on output file
[OPT.varName,varNameInput] = EHY_nameOnFile(inputFile,OPT.varName);
if strcmp(OPT.varName,'noMatchFound')
    error(['Requested variable (' varNameInput ') not available in model output'])
end

%% find top or bottom layer in z-layer model
if ischar(OPT.layer)
    Data = EHY_getMapModelData_zLayerTopBottom(inputFile,modelType,OPT);
end

%% return output at specified reference level
if ~exist('Data','var') && ~isempty(OPT.z)
    Data = EHY_getMapModelData_z(inputFile,modelType,OPT);
end

%% return sideview output along a pli file
if ~exist('Data','var') && (~isempty(OPT.pliFile) || ~isempty(OPT.pli))
    [Data,gridInfo] = EHY_getMapModelData_xy(inputFile,OPT);
end

%% regular data extraction (only when 'Data' does not exist)
if ~exist('Data','var')
    
    %% Get the available and requested dimensions
    [dims,dimsInd,Data,OPT] = EHY_getDimsInfo(inputFile,OPT,modelType);
    
    %% check if output data is in several partitions and merge if necessary
    if OPT.mergePartitions == 1 && EHY_isPartitioned(inputFile) && exist('facesInd','var')
        
        % get cell array with ncFiles based on inputFile (and requested partition numbers)
        ncFiles = EHY_getListOfPartitionedNcFiles(inputFile,OPT.mergePartitionNrs);
        
        for iF = 1:length(ncFiles)
            if OPT.disp
                disp(['Reading and merging map model data from partitions: ' num2str(iF) '/' num2str(length(ncFiles))])
            end
            ncFile = ncFiles{iF};
            if nc_isvar(ncFile,OPT.varName)
                DataPart = EHY_getMapModelData(ncFile,OPT,'mergePartitions',0);
            else
                disp(['Variable ',OPT.varName,' is not available in partition ' num2str(iF)])
            end
            if iF==1
                Data = DataPart;
            else
                if isfield(Data,'val')
                    Data.val = cat(facesInd,Data.val,DataPart.val);
                elseif isfield(Data,'vel_x')
                    Data.vel_x = cat(facesInd,Data.vel_x,DataPart.vel_x);
                    Data.vel_y = cat(facesInd,Data.vel_y,DataPart.vel_y);
                    Data.vel_mag = cat(facesInd,Data.vel_mag,DataPart.vel_mag);
                    Data.vel_dir = cat(facesInd,Data.vel_dir,DataPart.vel_dir);
                end
            end
        end
        Data.OPT.mergePartitions = 1;
        modelType = 'partitionedFmRun';
        dims = EHY_getmodeldata_optimiseDims(dims);
    end
    
    %% Get the computational data
    switch modelType
        case {'dfm','nc'}
            %%  Delft3D-Flexible Mesh
            % initialise start+count and optimise if possible
            [dims,start,count] = EHY_getmodeldata_optimiseDims(dims);
            
            if OPT.mergeCMEMSdata && EHY_isCMEMS(inputFile)
                [Data.times,value]     = EHY_getMapCMEMSData(inputFile,start,count,OPT);
                dims(timeInd).size     = length(Data.times);
                dims(timeInd).sizeOut  = length(Data.times);
                dims(timeInd).index    = 1:length(Data.times);
                dims(timeInd).indexOut = 1:length(Data.times);
            else
                if ~isempty(strfind(OPT.varName,'ucx')) || ~isempty(strfind(OPT.varName,'ucy')) || ismember(OPT.varName,{'u','v'})
                    value_x   =  nc_varget(inputFile,strrep(OPT.varName,'ucy','ucx'),start-1,count);
                    value_y   =  nc_varget(inputFile,strrep(OPT.varName,'ucx','ucy'),start-1,count);
                else
                    value     =  nc_varget(inputFile,OPT.varName,start-1,count);
                end
            end
            
            % initiate correct order if no_dims == 1
            if numel(dims) == 1
                if exist('value','var')
                    Data.val = NaN(dims.sizeOut,1);
                elseif exist('value_x','var')
                    Data.vel_x = NaN(dims.sizeOut,1);
                    Data.vel_y = NaN(dims.sizeOut,1);
                end
            end
            
            % deal with deleted leading/trailing singleton dimensions
            valueIndex = {dims.index};
            while all(valueIndex{1}==1)
                valueIndex(1) = [];
            end
            while all(valueIndex{end}==1)
                valueIndex(end) = [];
            end
            if exist('value','var')
                while size(value,1) == 1
                    value = permute(value,[2:ndims(value) 1]);
                end
            elseif exist('value_x','var')
                while size(value_x,1) == 1
                    value_x = permute(value_x,[2:ndims(value_x) 1]);
                    value_y = permute(value_y,[2:ndims(value_y) 1]);
                end
            end
            
            % put value(_x/_y) in output structure 'Data'
            if exist('value','var')
                Data.val(dims.indexOut) = value(valueIndex{:});
            elseif exist('value_x','var')
                Data.vel_x(dims.indexOut) = value_x(valueIndex{:});
                Data.vel_y(dims.indexOut) = value_y(valueIndex{:});
            end
            
            % If partitioned run, delete ghost cells
            [~, name] = fileparts(inputFile);
            varName = EHY_nameOnFile(inputFile,'FlowElemDomain');
            if EHY_isPartitioned(inputFile,modelType) && nc_isvar(inputFile,varName) && exist('facesInd','var')
                domainNr = str2num(name(end-7:end-4));
                FlowElemDomain = ncread(inputFile,varName);
                
                if isfield(Data,'val')
                    if facesInd == 1
                        Data.val(FlowElemDomain ~= domainNr,:,:) = [];
                    elseif facesInd == 2
                        Data.val(:,FlowElemDomain ~= domainNr,:) = [];
                    elseif facesInd == 3
                        Data.val(:,:,FlowElemDomain ~= domainNr,:) = [];
                    elseif facesInd == 4
                        Data.val(:,:,:,FlowElemDomain ~= domainNr) = [];
                    else
                        error('We never thought that facesInd could be given in index %d',facesInd)
                    end
                elseif isfield(Data,'vel_x')
                    if facesInd == 1
                        Data.vel_x(FlowElemDomain ~= domainNr,:,:) = [];
                        Data.vel_y(FlowElemDomain ~= domainNr,:,:) = [];
                    elseif facesInd == 2
                        Data.vel_x(:,FlowElemDomain ~= domainNr,:) = [];
                        Data.vel_y(:,FlowElemDomain ~= domainNr,:) = [];
                    end
                end
            end
            
            if isfield(Data,'vel_x')
                Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
                Data.vel_dir = mod(atan2(Data.vel_x,Data.vel_y)*180/pi,360);
                Data.vel_dir_comment = 'Considered clockwise from geographic North to where vector points';
            end
            
            if EHY_isCMEMS(inputFile) % [time,depth,lat,lon] to [time,lat,lon,depth]
                if ndims(Data.val)==4
                    Data.val = permute(Data.val,[1 3 4 2]);
                    Data.val = flipud(Data.val);
                    dims = dims([1 3 4 2]); % to get correct [dimension-info]
                end
            end
            
        case 'd3d'
            %% Delft3D 4
            trim = vs_use(inputFile,'quiet');
            % needed for special cases
            time_ind = dims(timeInd).index;
            m_ind = dims(mInd).index;
            n_ind = dims(nInd).index;
            
            switch OPT.varName
                case 'wd' % water depth, bed to wl
                    wl  = vs_let(trim,'map-series',{time_ind},'S1'  ,{n_ind,m_ind},'quiet');
                    dps = vs_let(trim,'map-const' ,{1}       ,'DPS0',{n_ind,m_ind},'quiet');
                    Data.val = wl+dps;
                    
                case 'U1' % velocity
                    if dims(layersInd).size ~= 1 % 3D
                        data = qpread(trim,1,'horizontal velocity','griddata',time_ind,m_ind,n_ind,dims(layersInd).index);
                    else % 2Dh
                        data = qpread(trim,1,'depth averaged velocity','griddata',time_ind,m_ind,n_ind);
                    end
                    %swap m/n because it is swapped back later on
                    if length(data.Time) == 1
                        data.XComp = permute(data.XComp,[2 1 3]); data.YComp = permute(data.YComp,[2 1 3]);
                    else
                        data.XComp = permute(data.XComp,[1 3 2 4]); data.YComp = permute(data.YComp,[1 3 2 4]);
                    end
                    Data.vel_x(dims.indexOut) = data.XComp; Data.vel_y(dims.indexOut) = data.YComp;
                    Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
                    Data.vel_dir = mod(atan2(Data.vel_x,Data.vel_y)*180/pi,360);
                    Data.vel_dir_comment = 'Considered clockwise from geographic North to where vector points';
                    
                case 'DP_BEDLYR' % sediment thickness
                    Data.val = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,2},'quiet');
                    
                case {'TAUKSI','TAUETA','TAUMAX'} % bed shear
                    Data.val_x   = vs_let(trim,'map-series',{time_ind},OPT.varName,{n_ind,m_ind},'quiet');
                    Data.val_y   = vs_let(trim,'map-series',{time_ind},'TAUETA'   ,{n_ind,m_ind},'quiet');
                    Data.val_max = vs_let(trim,'map-series',{time_ind},'TAUMAX'   ,{n_ind,m_ind},'quiet');
                    Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
                    
                otherwise % Apply generic approach
                    grp = char(vs_find(vs_use(inputFile,'quiet'), OPT.varName));
                    if ~isempty(strfind(grp,'-const'))
                        dims(timeInd).index = 1; % const
                        Data.times = Data.times(1);
                    end
                    time_ind  = {dims(1).index};
                    other_ind = {dims(2:end).index};
                    
                    if ~ismember(OPT.varName,{'SBUU','SSUU','SBUUA','SSUUA'})
                        Data.val = vs_let(trim,grp,time_ind,OPT.varName,other_ind,'quiet');
                    else
                        Data.val_x   = vs_let(trim,grp,time_ind,OPT.varName,other_ind,'quiet');
                        Data.val_y   = vs_let(trim,grp,time_ind,strrep(OPT.varName,'U','V'),other_ind,'quiet');
                        Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
                    end
                    
                    if any(strcmp(OPT.varName,{'DPS0','DPS'})) % make bedlevel positive up 
                        Data.val = -1*Data.val;
                    end
            end
            
            if ~any(ismember({'val','vel_x','val_x'},fieldnames(Data)))
                error('Couldn''t find any "%s"-data in %s',OPT.varName,inputFile)
            end
            
            % get active/inactive mask
            mask = vs_let(trim,'map-const',{1},'KCS',{n_ind,m_ind},'quiet');
            mask(mask==0) = NaN;
            mask = mask*0+1;
            
            % mask data and swap m,n-indices (from vs_let) from [n,m] to [time,m,n(,layers,sedimentFraction)]
            fns = intersect(fieldnames(Data),{'val','vel_x','vel_y','vel_mag','vel_dir','val_x','val_y','val_max','val_mag'});
            for iFns = 1:length(fns)
                Data.(fns{iFns})(Data.(fns{iFns}) == -999) = NaN;
                Data.(fns{iFns}) = Data.(fns{iFns}).*mask;
                Data.(fns{iFns}) = permute(Data.(fns{iFns}),[1 3 2 4 5]);
            end
            dmy = dims(2); dims(2) = dims(3); dims(3) = dmy; % swap [n,m] to [m,n]
            dmy = mInd; mInd = nInd; nInd = dmy;
            
            % delete ghost cells // aim: get same result as 'loaddata' from d3d_qp
            for iFns = 1:length(fns)
                % delete
                if m_ind(1)==1; Data.(fns{iFns}) = Data.(fns{iFns})(:,2:end,:,:,:); end
                if n_ind(1)==1; Data.(fns{iFns}) = Data.(fns{iFns})(:,:,2:end,:,:); end
                % set to NaN
                if m_ind(end)==dims(mInd).size; Data.(fns{iFns})(:,end,:,:,:) = NaN; end
                if n_ind(end)==dims(nInd).size; Data.(fns{iFns})(:,:,end,:,:) = NaN; end
            end
            
        case 'delwaq'
            [~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(inputFile);
            if strcmpi(typeOfModelFileDetail,'map')
                if ismember(lower(OPT.varName),{'wl','bedlevel','zcen_cen','zcen_int','waterdepth'})
                    [Zcen_int,Zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates(inputFile,modelType,OPT);
                    if strcmpi(OPT.varName,'wl')
                        Data.val = wl;
                    elseif strcmpi(OPT.varName,'bedlevel')
                        Data.val = reshape(bl,[1 size(bl)]); % [time(1),m,n]
                        Data.times = Data.times(1);
                    elseif ismember(lower(OPT.varName),{'wd','waterdepth'})
                        Data.val = wl - reshape(bl,[1 size(bl)]); % [time,m,n]
                    else
                        if strcmpi(OPT.varName,'Zcen_cen')
                            Data.val = Zcen_cen;
                        elseif strcmpi(OPT.varName,'Zcen_int')
                            Data.val = Zcen_int;
                        end
                        Data.Zcen_cen = Zcen_cen;
                        Data.Zcen_int = Zcen_int;
                    end
                else
                    dw       = delwaq('open',inputFile);
                    subs_ind = strmatch(OPT.varName,strrep(dw.SubsName,' ',''));
                    if isempty(subs_ind); error(['Variable ''' OPT.varName ''' not available on file: ' inputFile]); end
                    [~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(OPT.gridFile);
                    if ismember(typeOfModelFileDetail,{'lga','cco'})
                        dwGrid   = delwaq('open',OPT.gridFile);
                        Data.val = NaN([dims.sizeOut]); % allocate
                        
                        m_ind = dims(mInd).index;
                        n_ind = dims(nInd).index;
                        
                        for iT = 1:length(dims(timeInd).index)
                            time_ind  = dims(timeInd).index(iT);
                            [~,data]  = delwaq('read',dw,subs_ind,0,time_ind);
                            data      = waq2flow3d(data,dwGrid.Index);
                            Data.val(dims(timeInd).indexOut(iT),:,:,:) = data(m_ind,n_ind,dims(layersInd).index);
                        end
                        
                        % delete ghost cells
                        if n_ind(1)==1; Data.val = Data.val(:,2:end,:,:); end
                        if m_ind(1)==1; Data.val = Data.val(:,:,2:end,:); end
                        
                    elseif strcmp(typeOfModelFileDetail, 'nc')
                        no_segm_perlayer = dims(facesInd).size;
                        
                        if exist('layersInd','var') && ~isempty(layersInd)
                            layer_ind = dims(layersInd).index;
                            for iL = 1:length(layer_ind)
                                segm_ind = ((layer_ind(iL) - 1) * no_segm_perlayer + 1):(layer_ind(iL) * no_segm_perlayer);
                                [~, data] = delwaq('read', dw, subs_ind, segm_ind, dims(timeInd).index);
                                Data.val(dims(timeInd).indexOut,dims(facesInd).indexOut,dims(layersInd).indexOut(iL)) = permute(data,[3 2 1]);
                            end
                        else
                            [~, data] = delwaq('read', dw, subs_ind, dims(facesInd).index, dims(timeInd).index);
                            Data.val(dims(timeInd).indexOut,dims(facesInd).indexOut) = permute(data,[3 2 1]);
                        end
                        
                    end
                end
                
            elseif strcmpi(typeOfModelFileDetail,'sgf')
                
                gridInfo = EHY_getGridInfo(OPT.gridFile,'dimensions');
                no_segm_perlayer = gridInfo.no_NetElem;
                
                layer_ind = OPT.layer;
                segm_ind = ((layer_ind - 1) * no_segm_perlayer + 1):(layer_ind * no_segm_perlayer);
                total_no_seg = OPT.sgfkmax * gridInfo.no_NetElem;
                
                data = delwaq_sgf('read',inputFile, total_no_seg, OPT.sgft0);
                
                Data.times = data.Date';
                [Data,time_ind] = EHY_getmodeldata_time_index(Data,OPT);
                
                Data.val = data.data(time_ind,segm_ind);
                
                dims(1).name = 'time';
                dims(2).name = 'segments';
                
            end
            Data.val(Data.val == -999) = NaN;
            
        case 'simona'
            %% SIMONA (WAQUA/TRIWAQ)
            % open data file
            sds = qpfopen(inputFile);
            
            m_ind = dims(mInd).index;
            n_ind = dims(nInd).index;
            
            switch OPT.varName
                case 'wl' % ref to wl
                    for iT = 1:length(dims(timeInd).index)
                        Data.val(dims(timeInd).indexOut(iT),:,:) = waquaio(sds,[],'waterlevel',dims(timeInd).index(iT),n_ind,m_ind);
                    end
            end
            
            % swap m,n-indices (from vs_let) from [n,m] to [time,m,n(,layers)]
            Data.val = permute(Data.val,[1 3 2]);
            dmy = dims(2); dims(2) = dims(3); dims(3) = dmy; % swap [n,m] to [m,n]
            dmy = mInd; mInd = nInd; nInd = dmy;
            
            % delete ghost cells // aim: get same result as 'loaddata' from d3d_qp
            % delete
            if m_ind(1)==1; Data.val = Data.val(:,2:end,:,:,:); end
            if n_ind(1)==1; Data.val = Data.val(:,:,2:end,:,:); end
            % set to NaN
            if m_ind(end)==dims(mInd).size; Data.val(:,end,:,:,:) = NaN; end
            if n_ind(end)==dims(nInd).size; Data.val(:,:,end,:,:) = NaN; end
            
    end
    
    %% add dimension information to Data
    % dimension information
    dimensionsComment = {dims.name};
    fn = char(intersect(fieldnames(Data),{'val','vel_x','val_x'}));
    while ~isempty(fn) && ndims(Data.(fn)) < numel(dimensionsComment)
        dimensionsComment(end) = [];
    end
    
    % add to Data-struct
    dimensionsComment = sprintf('%s,',dimensionsComment{:});
    Data.dimensions = ['[' dimensionsComment(1:end-1) ']'];
end

%% Fill output struct
Data.OPT               = OPT;
Data.OPT.inputFile     = inputFile;

if strcmpi(varNameInput,'chl')
    Data.val = 1000.*saco_convert(Data.val,27); % 1000: from g/kg to mg/l
end

%% Assign output to varargout
varargout{1} = Data;
if nargout == 2
    varargout{2} = gridInfo;
end
