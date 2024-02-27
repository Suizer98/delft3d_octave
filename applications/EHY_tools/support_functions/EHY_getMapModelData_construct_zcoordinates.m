function [Zcen_int,Zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates(inputFile,modelType,OPT)

% This function uses the order of dimensions: [times,cells,layers]

%%
if ~exist('modelType','var')
    modelType = EHY_getModelType(inputFile);
end

%% CMEMS?
if EHY_isCMEMS(inputFile)
    [Zcen_int,Zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates_CMEMS(inputFile,OPT);
    return
end

%% old DELWAQ .map?
if strcmp(modelType,'delwaq')
    [Zcen_int,Zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates_DELWAQ(inputFile,modelType,OPT);
    return
end

%%
gridInfo = EHY_getGridInfo(inputFile,{'no_layers','layer_model'},'mergePartitions',0);
no_lay   = gridInfo.no_layers;
OPT.varName = 'waterlevel';
OPT.disp = 0;
DataWL   = EHY_getMapModelData(inputFile,OPT);
wl       = DataWL.val;

%% from [m,n] to cells (like FM)
if strcmp(modelType,'d3d')
    modelSize = size(wl);
    wl = reshape(wl,[modelSize(1) prod(modelSize(2:3))]);
end

%%
cen = NaN([size(wl) no_lay]);
int = NaN([size(wl) no_lay+1]);

switch gridInfo.layer_model
    case 'sigma-model'
        gridInfo = EHY_getGridInfo(inputFile,{'layer_perc'},'mergePartitions',0);
        
        % determine bed level
        DataBED = EHY_getMapModelData(inputFile,OPT,'varName','bedlevel');
        bl      = DataBED.val;
        if strcmp(modelType,'d3d')
            bl = reshape(bl,[1 prod(modelSize(2:3))]); % from [m,n] to cells (like FM)
        else
            bl = reshape(bl,1,length(bl));
        end
        
        if strcmp(modelType,'dfm')
            % vertical interfaces at cell center
            int(:,:,1) = repmat(bl,length(DataWL.times),1);
            for i_lay = 1:no_lay-1
                int(:,:,i_lay+1) = int(:,:,1) + (sum(gridInfo.layer_perc(1:i_lay)) * (wl - bl));
            end
            int(:,:,no_lay+1) = wl;
        elseif strcmp(modelType,'d3d')  % sigma model numbers from surface to bed!
            % vertical interfaces at cell center
            bl_tmp     = repmat(bl,length(DataWL.times),1);
            int(:,:,1) = wl;
            for i_lay = 1:no_lay
                int(:,:,i_lay+1) = int(:,:,1) - (sum(gridInfo.layer_perc(1:i_lay)) * (wl - bl_tmp));
            end
            % check
            if length(find(abs(bl_tmp - int(:,:,no_lay + 1)) > 1e-3)) ~= 0
                error ('Wrong reconstruction interfaces d3d sigma layers')
            end
        end
        
    case 'z-model'
        no_times = size(int,1);
        no_cells = size(int,2);
        
        gridInfo = EHY_getGridInfo(inputFile,{'Z'},'mergePartitions',OPT.mergePartitions, ...
            'mergePartitionNrs',OPT.mergePartitionNrs,'disp',0);
        if strcmp(modelType,'d3d')
            bl = reshape(gridInfo.Zcen,[prod(modelSize(2:3)) 1]); % from [m,n] to cells (like FM)
        else
            bl = reshape(gridInfo.Zcen,no_cells,1);
        end
        
        ZKlocal  = reshape(gridInfo.Zcen_int,1,[]);
        ZKlocal2 = repmat(ZKlocal,no_cells,1);
        
        for iT = 1:no_times
            int_field = NaN(no_cells,no_lay+1);
            
            logi = ZKlocal > bl; % ZKlocal <= wl(iT,:)'
            int_field(logi) = ZKlocal2(logi);
            logi = [-10^8 ZKlocal(1:end-1)] > wl(iT,:)';
            int_field(logi) = NaN;
            
            % water level
            [~,cellIndMax] = max(int_field,[],2);
            nonan = ~all(isnan(int_field),2);
            cellIndMax(~nonan) = NaN;
            cellIndMaxUni = unique(cellIndMax(nonan));
            for ii = 1:length(cellIndMaxUni)
                logi = cellIndMax == cellIndMaxUni(ii);
                if cellIndMaxUni(ii) == no_lay+1 % top layer
                    int_field(logi,end) = wl(iT,logi);
                else
                    int_field(logi,cellIndMaxUni(ii)+1) = wl(iT,logi);
                end
            end
            
            % bed level (initialize as keepzlayeringatbed = 0)
            [~,cellIndMin] = min(int_field,[],2);
            nonan = ~all(isnan(int_field),2);
            cellIndMin(~nonan) = NaN;
            cellIndMinUni = unique(cellIndMin(nonan));
            for ii = 1:length(cellIndMinUni)
                logi = cellIndMin == cellIndMinUni(ii);
                if cellIndMinUni(ii) == 1 % bottom layer
                    int_field(logi,1) = bl(logi);
                else
                    int_field(logi,cellIndMinUni(ii)-1) = bl(logi);
                end
            end
            
            %% mdu
            if strcmp(modelType,'dfm')
                try
                    mdu = dflowfm_io_mdu('read',EHY_getMdFile(inputFile));
                    % make sure needed variable names can be found in lower-case
                    fns = fieldnames(mdu);
                    for iF = 1:length(fns)
                        mdu.(lower(fns{iF})) = mdu.(fns{iF});
                    end
                    fns = fieldnames(mdu.geometry);
                    for iF = 1:length(fns)
                        mdu.geometry.(lower(fns{iF})) = mdu.geometry.(fns{iF});
                    end
                end
            end
                        
            %% z-sigma-layer model? Add sigma-layers at the top
            if strcmp(modelType,'dfm')
                try
                    % check
                    if isfield(mdu.geometry,'numtopsiguniform') && mdu.geometry.numtopsiguniform
                        FMversion = EHY_getFMversion(inputFile,modelType);
                        if FMversion < 67072
                            disp('<strong>Numtopsiguniform was not yet implemented (correctly) in the FM version you used. You should move to FM >= 67072 (Jul 8, 2020) </strong>')
                            disp('<strong>Reconstructing z-coordinates as if Numtopsiguniform = 0 (as was used in your run)</strong>')
                            mdu.geometry.numtopsiguniform = 0;
                        end
                    end
                    
                    numtopsig = mdu.geometry.numtopsig;
                    if isfield(mdu.geometry,'numtopsiguniform') && mdu.geometry.numtopsiguniform
                        sigma_bottom = max([int_field(:,end-numtopsig) bl],[],2) ;
                        sigma_top    = wl(iT,:)';
                        dh = sigma_top - sigma_bottom;
                        int_field(:,(end-numtopsig):end) = sigma_bottom+linspace(0,1,numtopsig+1).*dh;
                    elseif numtopsig > 0
                        for ii = 1:size(int_field,1)
                            logi = ~isnan(int_field(ii,:));
                            logi(1:end-1-numtopsig) = false; % only top numtopsig are changed into sigma-layers
                            ind1 = find(logi,1,'first');
                            ind2 = find(logi,1,'last');
                            if ~isempty(ind1) && ~isempty(ind2)
                                no_active_layers =  ind2-ind1;
                                if 1 % current implementation
                                    int_field(ii,logi) = linspace(int_field(ii,ind1),int_field(ii,ind2),no_active_layers+1);
                                else % Base sigma-%-distribution on initial z-layer-distribution
                                    dz = diff(int_field(ii,ind1:ind2));
                                    dz(end) = 5; % how to deal with ini wl ?
                                    perc = [0 dz/sum(dz)];
                                    dh = int_field(ii,ind2) - int_field(ii,ind1);
                                    int_field(ii,logi) = int_field(ii,ind1) + cumsum(perc) * dh;
                                end
                            end
                        end
                    end
                catch
                    disp('Could not correct vertical coordinates for possible usage of numtopsig and numtopsiguniform')
                end
            end
            
            %% Keepzlayeringatbed
            if ~exist('keepzlayeringatbed','var') % only needed to determine this value once
                keepzlayeringatbed = 0; % Delft3D 4 default
                try
                    fns = fieldnames(mdu.numerics);
                    ind = strmatch('keepzlayeringatbed',lower(fns),'exact');
                    if ~isempty(ind)
                        keepzlayeringatbed = mdu.numerics.(fns{ind(1)});
                    else
                        fns = fieldnames(mdu.geometry);
                        ind = strmatch('keepzlayeringatbed',lower(fns),'exact');
                        keepzlayeringatbed = mdu.geometry.(fns{ind(1)});
                    end
                end
            end
            
            [~,cellIndMin] = min(int_field,[],2);
            cellIndMinUni = unique(cellIndMin);
            for ii = 1:length(cellIndMinUni)
                logi = cellIndMin == cellIndMinUni(ii);
                if keepzlayeringatbed == 0
                    % this should already be the case
                    int_field(logi,cellIndMinUni(ii)) = bl(logi);
                elseif keepzlayeringatbed == 1
                    int_field(logi,cellIndMinUni(ii)) = ZKlocal(cellIndMinUni(ii));
                elseif keepzlayeringatbed == 2
                    int_field(logi,cellIndMinUni(ii)) = bl(logi);
                    if cellIndMinUni(ii)+1 < length(ZKlocal)
                        int_field(logi,cellIndMinUni(ii)+1) = mean([bl(logi) int_field(logi,cellIndMinUni(ii)+2)],2);
                    end
                end
            end
            
            %%
            int(iT,:,:) = int_field;
        end
end

%% vertical centers at cell center
cen = (int(:,:,1:end-1) + int(:,:,2:end)) ./ 2;

%% cells (like FM) back to [m,n]
if strcmp(modelType,'d3d')
    cen = reshape(cen,[modelSize no_lay]);
    int = reshape(int,[modelSize no_lay+1]);
    wl  = reshape(wl , modelSize);
    bl  = reshape(bl , [1 modelSize(2:3)]);
end

Zcen_cen = cen;
Zcen_int = int;

end

function [Zcen_int,Zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates_CMEMS(inputFile)
%         % water level
%         [pathstr, name, ext] = fileparts(inputFile);
%         [~,name] = strtok(name,'_');
%         wlFile = [pathstr filesep 'zos' name ext];
%         if ~exist(wlFile,'file')
%             error(['Could not find corresponding waterlevel-file: ' newline wlFile])
%         end
%         Data_WL = EHY_getMapModelData(wlFile,OPT,'varName','zos');
%         wl       = DataWL.val;
infonc = ncinfo(inputFile);
ind = strmatch('latitude',{infonc.Dimensions.Name},'exact');
lat_len = infonc.Dimensions(ind).Length;
ind = strmatch('longitude',{infonc.Dimensions.Name},'exact');
lon_len = infonc.Dimensions(ind).Length;
ind = strmatch('time',{infonc.Dimensions.Name},'exact');
time_len = infonc.Dimensions(ind).Length;

depth = double(ncread(inputFile,'depth'));
depth_cen = permute(depth,[2 3 4 1]);
Zcen_cen = -1*repmat(depth_cen,time_len,lon_len,lat_len);
depth_int = permute(center2corner1(depth)',[2 3 4 1]);
Zcen_int = -1*repmat(depth_int,time_len,lon_len,lat_len);
wl = squeeze(Zcen_int(:,:,:,1));
bl = squeeze(Zcen_int(:,:,:,end));
end

function [Zcen_int,Zcen_cen,wl,bl] = EHY_getMapModelData_construct_zcoordinates_DELWAQ(inputFile,modelType,OPT)

% Get the available and requested dimensions
OPT.layer = 0;
[dims,~,~,OPT] = EHY_getDimsInfo(inputFile,OPT,modelType);

dw = delwaq('open',inputFile);

[~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(OPT.gridFile);

if ismember(typeOfModelFileDetail,{'lga','cco'})
    dwGrid = delwaq('open',OPT.gridFile);
    
    m_ind = dims(mInd).index;
    n_ind = dims(nInd).index;
    k_ind = 1:dwGrid.MNK(3);
    
    for iT = 1:length(dims(timeInd).index)
        time_ind  = dims(timeInd).index(iT);
        
        % bed level
        if ~exist('bl','var')
            subs_ind   = strmatch('TotalDepth',dw.SubsName);
            [~,data]  = delwaq('read',dw,subs_ind,0,1); % first time_ind to combine with OPT.dw_iniWL
            data      = waq2flow3d(data,dwGrid.Index);
            data(data == -999) = NaN;
            TotalDepth = data(m_ind,n_ind,k_ind);
            TotalDepth = max(TotalDepth,[],3);
            bl = OPT.dw_iniWL - TotalDepth;
        end
        
        % Zcen_int / Zcen_cen
        subs_ind   = strmatch('Depth',dw.SubsName);
        [~,data]  = delwaq('read',dw,subs_ind,0,time_ind);
        data      = waq2flow3d(data,dwGrid.Index);
        data(data == -999) = 0;
        Depth = data(m_ind,n_ind,k_ind);
        Depth(:,:,end+1) = 0; % add bottom interface
        Zcen_int(iT,:,:,:) = bl + flip(cumsum(flip(Depth,3),3),3);
        Zcen_cen(iT,:,:,:) = (Zcen_int(iT,:,:,1:end-1) + Zcen_int(iT,:,:,2:end))/2;
    end
    
    % water level
    wl = Zcen_int(:,:,:,1);
    
    % delete ghost cells
    if n_ind(1) == 1
        bl = bl(2:end,:);
        wl = wl(:,2:end,:);
        Zcen_int = Zcen_int(:,2:end,:,:);
        Zcen_cen = Zcen_cen(:,2:end,:,:);
    end
    if m_ind(1)==1
        bl = bl(:,2:end);
        wl = wl(:,:,2:end);
        Zcen_int = Zcen_int(:,:,2:end,:);
        Zcen_cen = Zcen_cen(:,:,2:end,:);
    end
    
elseif strcmp(typeOfModelFileDetail, 'nc')
    
    GI = EHY_getGridInfo(inputFile,{'no_layers','dimensions'},'gridFile',OPT.gridFile);
    
    for iT = 1:length(dims(timeInd).index)
        time_ind  = dims(timeInd).index(iT);
        
        % bed level
        if ~exist('bl','var')
            subs_ind   = strmatch('TotalDepth',dw.SubsName);
            segm_ind = 1:GI.no_NetElem;
            [~, TotalDepth] = delwaq('read', dw, subs_ind, segm_ind, 1); % first time_ind to combine with OPT.dw_iniWL
            bl = OPT.dw_iniWL - TotalDepth';
        end
        
        % Zcen_int / Zcen_cen
        subs_ind  = strmatch('Depth',dw.SubsName);
        [~,Depth] = delwaq('read',dw,subs_ind,0,time_ind);
        Depth     = reshape(Depth,GI.no_NetElem,GI.no_layers);
        Depth(:,end+1) = 0; % add bottom interface
        Zcen_int(iT,:,:) = bl + flip(cumsum(flip(Depth,2),2),2);
        Zcen_cen(iT,:,:) = (Zcen_int(iT,:,1:end-1) + Zcen_int(iT,:,2:end))/2;
    end
    
    % water level
    wl = Zcen_int(:,:,1);
    
end

end
