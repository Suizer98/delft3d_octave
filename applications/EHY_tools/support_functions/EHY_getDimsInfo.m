function [dims,dimsInd,Data,OPT] = EHY_getDimsInfo(inputFile,OPT,modelType,stat_name)

%% Info
% dims.size         size  as on modelfile
% dims.index        index as on modelfile
% dims.indexOut     index in 'Data'-struct
% dims.sizeOut      size  in 'Data'-struct

if isfield(OPT,'gridFile')
    gridFile = OPT.gridFile;
end

%% determine "dims" - Get info about available dimensions on file (and their sizes)
[~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(inputFile);
switch lower(modelType)
    case {'dfm','nc'}
        infonc    = ncinfo(inputFile,OPT.varName);
        dimsNames = {infonc.Dimensions.Name};
        dimsSizes = infonc.Size;
        no_dims   = length(dimsNames);
        for iD = 1:no_dims
            ind = no_dims-iD+1;
            dims(ind).name       = dimsNames{iD};
            dims(ind).size       = dimsSizes(iD);
            dims(ind).index      = 1:dimsSizes(iD);
            dims(ind).indexOut   = 1:dimsSizes(iD);
        end
        
        % sediment fractions
        if any(ismember({dims(:).name},{'nSedTot'}))
            NAMSED = ncread(inputFile,'sedfrac_name')';
%             dims(end+1).name = 'sedimentFraction';
        end
        
    case 'd3d'
        d3d = vs_use(inputFile,'quiet');
        data_group = char(vs_find(d3d,OPT.varName));
        if isempty(data_group)
            NAMCON = EHY_getConstituentNames(inputFile);
            const_ind = strmatch(lower(OPT.varName),lower(NAMCON),'exact');
            if ~isempty(const_ind)
                requestedVarIsConstit = 1;
                if strcmp(typeOfModelFileDetail,'trih')
                    OPT.varName = 'GRO';
                    data_group = char(vs_find(d3d,OPT.varName));
                elseif strcmp(typeOfModelFileDetail,'trim')
                    OPT.varName = 'R1';
                    data_group = char(vs_find(d3d,OPT.varName));
                end
            else
                data_group(1:3) = d3d.CelDef(1).Name(1:3);
            end
        end
        grp = [data_group(1,1:3) '-const']; % his- or map-const
        
        % try to determine dimensions based on size
        ind = strmatch(OPT.varName,{d3d.ElmDef.Name},'exact');
        if isempty(ind) % Hopefully, variable has same dimension as velocity
            ind = find(ismember({d3d.ElmDef.Name},{'ZCURU','U1'}));
        end
        Size = d3d.ElmDef(ind).Size;
        
        % time (always add time)
        dims(1).name = 'time';
        
        if strcmp(typeOfModelFileDetail,'trih')
            % stations
            NOSTAT = vs_get(d3d,grp,{1},'NOSTAT','quiet');
            if length(Size)>=1 && Size(1) == NOSTAT
                dims(end+1).name = 'stations';
            end
        elseif strcmp(typeOfModelFileDetail,'trim')
            % faces/grid cells
            MMAX = vs_get(d3d,grp,{1},'MMAX','quiet');
            NMAX = vs_get(d3d,grp,{1},'NMAX','quiet');
            if length(Size)>=2 && Size(1) == NMAX && Size(2) == MMAX
                dims(end+1).name = 'n';
                dims(end+1).name = 'm';
            end
        end
        
        % layers (in 2Dh, layer is sometimes needed (e.g. 'ZCURU')
        KMAX = vs_get(d3d,grp,{1},'KMAX','quiet');
        if strcmp(typeOfModelFileDetail,'trih') && length(Size)>=2 && Size(2) == KMAX
            dims(end+1).name = 'layers';
        elseif strcmp(typeOfModelFileDetail,'trim') && length(Size)>=3 && Size(3) == KMAX
            dims(end+1).name = 'layers';
        end
        
        if strcmp(typeOfModelFileDetail,'trih') && length(Size)>=2 && KMAX > 1 && Size(2) == KMAX+1
            dims(end+1).name = 'interfaces';
        end
        
        % constituent/concentration (incl. Salinity and Temperature)
        if exist('requestedVarIsConstit','var')
            if length(Size)>=3 && Size(end) == length(NAMCON)
                dims(end+1).name = 'constit';
            end
        end
        
        % sediment fractions
        if ismember('NAMSED',{d3d.ElmDef.Name})
            NAMSED = squeeze(vs_let(d3d,grp,'NAMSED','quiet'));
            if size(NAMSED,2) > 1 && Size(end) == size(NAMSED,1)
                dims(end+1).name = 'sedimentFraction';
            end
        end
        
        % turbulence 
        if strcmpi(OPT.varName,'ZTUR')
            dims(end+1).name = 'turbulence';
        end
        
        % check if all dimensions (besides time) are found
        no_dims = length({dims.name}) - sum(strcmp('time',{dims.name}));
        if no_dims ~= length(Size)
            error('debug needed')
        end
        
    case 'delwaq'
        % time
        dims(1).name = 'time';
        
        if strcmpi(typeOfModelFileDetail,'his')
            % stations
            stationNames = EHY_getStationNames(inputFile,modelType,'varName',OPT.varName);
            if ~isempty(stationNames)
                dims(end+1).name = 'stations';
            end
        elseif strcmpi(typeOfModelFileDetail,'map')
            [~, typeOfModelFileDetailGrid] = EHY_getTypeOfModelFile(gridFile);
            if ismember(typeOfModelFileDetailGrid, {'lga', 'cco'})     % faces/grid cells
                dims(end+1).name = 'm';
                dims(end+1).name = 'n';
            elseif strcmp(typeOfModelFileDetailGrid, 'nc')
                dims(end+1).name = 'faces';
                gridInfo = EHY_getGridInfo(gridFile, {'dimensions'});
                dims(end).size = gridInfo.no_NetElem;
            end
            
            % layers
            gridInfo = EHY_getGridInfo(inputFile,{'no_layers'}, 'gridFile', gridFile);
            if isfield(gridInfo,'no_layers') && gridInfo.no_layers > 1  && ...
                    ~ismember(OPT.varName,{'wl','bedlevel'}) && isempty(strfind(lower(OPT.varName),'s1'))
                dims(end+1).name = 'layers';
            end
            
        end
        
        if strcmpi(typeOfModelFileDetail,'sgf')
            dims = [];
            dims.name = '';
        end
    
    case 'simona'
        % time
        dims(1).name = 'time';
        
        db = dbstack;
        if strcmp(db(2).name,'EHY_getmodeldata') % his
            % stations
            stationNames = EHY_getStationNames(inputFile,modelType,'varName',OPT.varName);
            if ~isempty(stationNames)
                dims(end+1).name = 'stations';
            end
        elseif strcmp(db(2).name,'EHY_getMapModelData') % map
            % m and n
            dims(end+1).name = 'm';
            dims(end+1).name = 'n';
        end
        
        % layers
        gridInfo = EHY_getGridInfo(inputFile,{'no_layers'});
        if isfield(gridInfo,'no_layers') && gridInfo.no_layers > 1 && ~ismember(OPT.varName,{'wl','wd','dps'})
            dims(end+1).name = 'layers';
        end
        
    otherwise % SOBEK / .. 
        % time // always ask for time
        dims(1).name = 'time';
        
        % layers
        gridInfo = EHY_getGridInfo(inputFile,{'no_layers'});
        if isfield(gridInfo,'no_layers') && gridInfo.no_layers > 1 && ~ismember(OPT.varName,{'wl','wd','dps'})
            dims(end+1).name = 'layers';
        end
        
        % stations
        stationNames = EHY_getStationNames(inputFile,modelType,'varName',OPT.varName);
        if ~isempty(stationNames)
            dims(end+1).name = 'stations';
        end
        
end

%% dimsInd
if nargout > 1
    dimsInd.stations = find(ismember({dims(:).name},{'stations','cross_section','general_structures'}));
    dimsInd.time = find(ismember({dims(:).name},{'time','nmesh2d_dlwq_time'}));
    dimsInd.layers = find(ismember({dims(:).name},{'layers','laydim','nmesh2d_layer','mesh2d_nLayers','depth','nmesh2d_layer_dlwq'})); % depth is needed for CMEMS
    dimsInd.interfaces = find(ismember({dims(:).name},'interfaces')); % depth is needed for CMEMS
    dimsInd.faces = find(ismember({dims(:).name},{'faces','nmesh2d_face','mesh2d_nFaces','nFlowElem','nNetElem'}));
    dimsInd.m = find(ismember({dims(:).name},{'m','edge_m'})); % structured grid
    dimsInd.n = find(ismember({dims(:).name},{'n','edge_n'}));
    dimsInd.constit = find(ismember({dims(:).name},'constit'));
    dimsInd.sedfrac = find(ismember({dims(:).name},{'sedimentFraction','nSedTot'}));
    dimsInd.turbulence = find(ismember({dims(:).name},'turbulence'));
    dimsInd.bed_layers = find(ismember({dims(:).name},{'nBedLayers'})); 
end

%% Data
if nargout > 2
    Data = struct;
    
    %% Get list with the numbers of the requested stations
    if ~isempty(dimsInd.stations)
        [Data,stationNrNoNan]           = EHY_getRequestedStations(inputFile,stat_name,modelType,'varName',OPT.varName);
        dims(dimsInd.stations).index    = reshape(stationNrNoNan,1,length(stationNrNoNan));
        dims(dimsInd.stations).indexOut = find(Data.exist_stat);
        dims(dimsInd.stations).sizeOut  = length(Data.requestedStations);
    end
    
    %% Get time information from simulation and determine index of required times
    if ~isempty(dimsInd.time)
        if strcmpi(modelType,'simona') && ~isempty(dimsInd.m)
            Data.times = EHY_getmodeldata_getDatenumsFromOutputfile(inputFile,0,'SDS_his_or_map','map');
        else
            Data.times = EHY_getmodeldata_getDatenumsFromOutputfile(inputFile);
        end
        if EHY_isCMEMS(inputFile) && nc_isvar(inputFile,'latitude') && OPT.mergeCMEMSdata
            % handling of time indices is done within EHY_getMapCMEMSData
        else  
            dims(dimsInd.time).size             = length(Data.times);
            [Data,time_index,~,index_requested] = EHY_getmodeldata_time_index(Data,OPT);
            dims(dimsInd.time).index            = time_index(index_requested);
            dims(dimsInd.time).indexOut         = 1:length(dims(dimsInd.time).index);
        end
    end
    
    %% Get layer information and type of vertical schematisation
    if isempty(dimsInd.layers) && ~isempty(dimsInd.interfaces) % properties at vertical interfaces
        dimsInd.layers = dimsInd.interfaces;
        dimsInd = rmfield(dimsInd,'interfaces');
        dims(dimsInd.layers).name = 'layers';
        interfaceProperty = 1;
    end
    if ~isempty(dimsInd.layers)
        if exist('gridFile','var')
            gridInfo                  = EHY_getGridInfo(inputFile,{'no_layers','layer_model'},'mergePartitions',0,'gridFile',gridFile);
        else
            gridInfo                  = EHY_getGridInfo(inputFile,{'no_layers','layer_model'},'mergePartitions',0);
        end
        if exist('interfaceProperty','var')
            gridInfo.no_layers = gridInfo.no_layers + 1;
        end
        OPT                           = EHY_getmodeldata_layer_index(OPT,gridInfo,modelType);
        dims(dimsInd.layers).index    = OPT.layer';
        dims(dimsInd.layers).size     = gridInfo.no_layers;
        dims(dimsInd.layers).indexOut = 1:length(OPT.layer);
    end
    
    %% Get horizontal grid information (cells / faces)
    if ~isempty(dimsInd.faces)
        dims(dimsInd.faces).index    = 1:dims(dimsInd.faces).size;
        dims(dimsInd.faces).indexOut = 1:dims(dimsInd.faces).size;
    end
    if ~isempty(dimsInd.m)
        [OPT,msize,nsize] = EHY_getmodeldata_mn_index(OPT,inputFile);
        dims(dimsInd.m).index    = OPT.m;
        dims(dimsInd.m).indexOut = 1:length(OPT.m);
        dims(dimsInd.m).size     = msize;
        dims(dimsInd.n).index    = OPT.n;
        dims(dimsInd.n).indexOut = 1:length(OPT.n);
        dims(dimsInd.n).size     = nsize;
    end
    
    %% Get constituent information
    if ~isempty(dimsInd.constit)
        dims(dimsInd.constit).index = const_ind;
        dims(dimsInd.constit).indexOut = 1;
    end
    
    %% Get sediment fractions information
    if ~isempty(dimsInd.sedfrac)
        NAMSED = strtrim(cellstr(NAMSED));
        if ~isempty(OPT.sedimentName)
            [lia,locb] = ismember(OPT.sedimentName,NAMSED);
            sed_ind = locb(lia);
        else
            OPT.sedimentName = NAMSED;
            sed_ind = 1:length(NAMSED);
        end
        dims(dimsInd.sedfrac).index    = sed_ind;
        dims(dimsInd.sedfrac).indexOut = 1:length(sed_ind);
    end
    
    %% Get bed layers information
    if ~isempty(dimsInd.bed_layers)
        if OPT.bed_layers==0 %all
            OPT.bed_layers=1:1:dims(dimsInd.bed_layers).size;
        end
        dims(dimsInd.bed_layers).index    = OPT.bed_layers;
        dims(dimsInd.bed_layers).indexOut = 1:length(OPT.bed_layers);
    end
    
    %% Turbulence (Delft3D 4's ZTUR) - Turbulence energy & energy dissipation
    if ~isempty(dimsInd.turbulence)
        dims(dimsInd.turbulence).index    = 1:2;
        dims(dimsInd.turbulence).indexOut = 1:2;
    end
    
    %%
    for iD = 1:length(dims)
        % dims.sizeOut
        if ~isfield(dims(iD),'sizeOut') || isempty(dims(iD).sizeOut)
            dims(iD).sizeOut = length(dims(iD).indexOut);
        end
        dims(iD).index = reshape(dims(iD).index,1,[]);
    end
    
    % assign dimsInd in caller
    fns = fieldnames(dimsInd);
    for iFns = 1:length(fns)
        if ~isempty(dimsInd.(fns{iFns}))
            assignin('caller',[fns{iFns} 'Ind'],dimsInd.(fns{iFns}))
        end
    end
end
