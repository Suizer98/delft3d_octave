function [Data_xy,gridInfo] = EHY_getMapModelData_xy(inputFile,varargin)
%  Function: Create data needed for plotting of cross section information

%% Initialise:
OPT       = varargin{1};
Data.modelType = EHY_getModelType(inputFile);

%% Read the pli file
if ~isempty(OPT.pliFile)
    pli = readldb(OPT.pliFile);
    pli = [pli.x pli.y];
    OPT = rmfield(OPT,'pliFile');
elseif ~isempty(OPT.pli)
    pli = OPT.pli;
    OPT = rmfield(OPT,'pli');
else
    error('You need to specify either "pliFile" or "pli"')
end

if size(pli,1) == 2 && size(pli,2) > 2
    pli = pli';
end

%% Determine which partitions to load data from
if isempty(OPT.mergePartitionNrs)
    if OPT.mergePartitions == 1
        partitionNrs = EHY_findPartitionNumbers(inputFile,'pli',pli,'disp',OPT.disp);
    else
        partitionNrs = str2num(inputFile(end-10:end-7));
    end
    % continue with relevant partition numbers
    OPT.mergePartitionNrs = partitionNrs;
end

%% Horizontal (x,y) coordinates
if ~isfield(OPT,'gridFile'); OPT.gridFile = ''; end
tmp   = EHY_getGridInfo(inputFile,{'XYcor', 'XYcen','face_nodes','layer_model'},'mergePartitionNrs',OPT.mergePartitionNrs,'disp',OPT.disp,'gridFile',OPT.gridFile);
names = fieldnames(tmp); for i_name = 1: length(names) Data.(names{i_name}) = tmp.(names{i_name}); end

%% get "z-data"
[dims,dimsInd,tmp] = EHY_getDimsInfo(inputFile,OPT,Data.modelType);
names = fieldnames(tmp); for i_name = 1: length(names) Data.(names{i_name}) = tmp.(names{i_name}); end
if ~isempty(dimsInd.layers) && dims(dimsInd.layers).sizeOut > 1
    if strcmp(Data.modelType,'dfm') && nc_isvar(inputFile,'mesh2d_flowelem_zcc')
        Zint = EHY_getMapModelData(inputFile,OPT(:),'varName','mesh2d_flowelem_zw');
        Data.Zint = Zint.val;
        Zcen = EHY_getMapModelData(inputFile,OPT(:),'varName','mesh2d_flowelem_zcc');
        Data.Zcen = Zcen.val;
    else
        try
            GI = EHY_getGridInfo(inputFile,'layer_model','mergePartitions',0,'disp',0);
            if strcmpi(Data.modelType,'dfm') && strcmpi(GI.layer_model,'z-model')
                disp('Reconstruction of z-layer-coordinates for map-files is not needed anymore when moving to FM version >= 70827 (Mar, 2021) by specifying "fullGridOutput = 1"')
            end
        end
        [Data.Zint,Data.Zcen,Data.wl,Data.bed] = EHY_getMapModelData_construct_zcoordinates(inputFile,Data.modelType,OPT);
    end
    dmy = size(Data.Zcen);
    no_layers = dmy(end);
else
    no_layers = 1;
end

%% get underlayers elevation

if ~isempty(dimsInd.bed_layers) && dims(dimsInd.bed_layers).sizeOut > 1
    if strcmp(Data.modelType,'dfm')
        [Data.Zint,no_bed_layers]=EHY_getMapModelData_construct_Zint_bed(inputFile,Data.modelType,OPT);
    else
        error('sorry, not yet implemented.')
    end
else
    no_bed_layers = 1;
end

%% check if layers are to be computed
%wether they are flow layers or sediment layers, the way to deal with them is the same
%and it is either one or the other one that it is required.
no_layers=max([no_layers,no_bed_layers]);

%% get wanted "varName"-data for all relevant partitions
tmp   = EHY_getMapModelData(inputFile,OPT);
names = fieldnames(tmp); for i_name = 1: length(names) Data.(names{i_name}) = tmp.(names{i_name}); end

%% Calculate values at pli locations
if OPT.disp
    disp('Start determining properties along trajectory')
end

warning off
if strcmp(Data.modelType,'dfm') || isfield(Data,'face_nodes')
    arb = arbcross(Data.face_nodes',Data.Xcor,Data.Ycor,pli(:,1),pli(:,2));
elseif ismember(Data.modelType,{'d3d','delwaq'}) || isfield(Data,'Xcor')
    arb = arbcross(Data.Xcor,Data.Ycor,pli(:,1),pli(:,2));
end
warning on

Data_xy.Xcor = arb.x;
Data_xy.Ycor = arb.y;

%% Determine X,Y and distance (S) at crossings (*cor) and middle of crossings (*cen)
% *cor
Data_xy.Scor=NaN(size(Data_xy.Xcor));
nonan = ~isnan(Data_xy.Xcor);
Data_xy.Scor(nonan,:) = [0; cumsum(sqrt(diff(Data_xy.Xcor(nonan)).^2+diff(Data_xy.Ycor(nonan)).^2))];
% *cen
Data_xy.Xcen = (Data_xy.Xcor(1:end-1) + Data_xy.Xcor(2:end)) ./ 2;
Data_xy.Ycen = (Data_xy.Ycor(1:end-1) + Data_xy.Ycor(2:end)) ./ 2;
Data_xy.Scen = (Data_xy.Scor(1:end-1) + Data_xy.Scor(2:end)) ./ 2;

%%  Determine vertical levels at Scen locations and corresponding values
if isfield(Data,'times')
    no_times = length(Data.times);
else
    no_times   = 1;
    Data.times = [];
    Data.val   = permute(Data.val,[3 1 2]);
end

if isfield(Data,'face_nodes')
    if isfield(Data,'val')
        switch numel(size(Data.val))
            case 2
                val = arbcross(arb,{'FACE' permute(Data.val,[2 1])});
            case 3
                val = arbcross(arb,{'FACE' permute(Data.val,[dimsInd.faces, setdiff([2 3 1], dimsInd.faces,'stable')])});
            case 4
                val = arbcross(arb,{'FACE' permute(Data.val,[dimsInd.faces dimsInd.bed_layers dimsInd.sedfrac dimsInd.time])});
            otherwise
                error('Add this case')
        end
    elseif isfield(Data,'vel_x')
        vel_x = arbcross(arb,{'FACE' permute(Data.vel_x,[2 3 1])});
        vel_y = arbcross(arb,{'FACE' permute(Data.vel_y,[2 3 1])});
        vel_dir = arbcross(arb,{'FACE' permute(Data.vel_dir,[2 3 1])});
        vel_mag = arbcross(arb,{'FACE' permute(Data.vel_mag,[2 3 1])});
    end
    if no_layers > 1
        Zint = arbcross(arb,{'FACE' permute(Data.Zint,[2 3 1])});
    end
elseif strcmp(Data.modelType,'d3d') || isfield(Data,'Xcor')
    if isfield(Data,'val')
        val = arbcross(arb,{'FACE' permute(Data.val,[2 3 4 1])});
    elseif isfield(Data,'vel_x') || isfield(Data,'val_x')
        %COMMENT #1
        %when reading, for instance, <sbuu>, the variable is in
        %<val_x> <val_y> rather than <vel_x> <vel_y>, but it is 
        %in essence the same. Ideal we would not make this 
        %distinction when reading, but this change is not backward
        %compatible. We solve is here the best we can for not 
        %repeating code.
        
        if isfield(Data,'val_x')
            Data.vel_x=Data.val_x;
            Data.vel_y=Data.val_y;
            Data.vel_mag=Data.val_mag;
            Data.vel_dir=NaN(size(Data.val_mag));
        end
        
        vel_x = arbcross(arb,{'FACE' permute(Data.vel_x,[2 3 4 1])});
        vel_y = arbcross(arb,{'FACE' permute(Data.vel_y,[2 3 4 1])});
        vel_dir = arbcross(arb,{'FACE' permute(Data.vel_dir,[2 3 4 1])});
        vel_mag = arbcross(arb,{'FACE' permute(Data.vel_mag,[2 3 4 1])});
    elseif isfield(Data,'val_x')
        
        vel_x = arbcross(arb,{'FACE' permute(Data.vel_x,[2 3 4 1])});
        vel_y = arbcross(arb,{'FACE' permute(Data.vel_y,[2 3 4 1])});
        vel_dir = arbcross(arb,{'FACE' permute(Data.vel_dir,[2 3 4 1])});
        vel_mag = arbcross(arb,{'FACE' permute(Data.vel_mag,[2 3 4 1])});
    else
        error('You should not get here')
    end
    if no_layers > 1
        Zint = arbcross(arb,{'FACE' permute(Data.Zint,[2 3 4 1])});
    end
end

no_XYcenTrajectory = length(arb.dxt);

%number of sediment or constituents
if ~isempty(dimsInd.sedfrac) 
    no_frac=dims(dimsInd.sedfrac).sizeOut;
else
    no_frac=1;
end

Data_xy.val  = zeros(no_times, no_XYcenTrajectory, no_layers, no_frac);
if no_layers > 1
    Data_xy.Zint = zeros(no_times, no_XYcenTrajectory, no_layers+1);
end

for iT = 1:no_times
    for iC = 1:no_XYcenTrajectory
        for iF=1:no_frac

            startBlock = (iT-1)*no_layers*no_frac+(iF-1)*no_layers+1;
            endBlock = startBlock + no_layers - 1;
            
            if isfield(Data,'val')
                Data_xy.val(iT,iC,:,iF) = val(iC,startBlock:endBlock);
            elseif isfield(Data,'vel_x')
                Data_xy.vel_x(iT,iC,:) = vel_x(iC,startBlock:endBlock);
                Data_xy.vel_y(iT,iC,:) = vel_y(iC,startBlock:endBlock);
                Data_xy.vel_mag(iT,iC,:) = vel_mag(iC,startBlock:endBlock);
                Data_xy.vel_dir(iT,iC,:) = vel_dir(iC,startBlock:endBlock);
            end

            if no_layers > 1
                startBlock = (iT-1)*(no_layers+1)+1;
                endBlock = startBlock + (no_layers+1) - 1;
                Data_xy.Zint(iT,iC,:) = Zint(iC,startBlock:endBlock);
            end
            
        end %iF
    end
end
if no_layers > 1
    Data_xy.Zcen = (Data_xy.Zint(:,:,1:end-1) + Data_xy.Zint(:,:,2:end)) ./ 2;
end
Data_xy.times = Data.times;

if OPT.disp
    disp('Finished determining properties along trajectory')
end

% below was added to remove polygon-points and therewith mimic d3d-style,
% but the new arbcross is better so d3d-style should include pol-points.
if 0 && strcmp(Data.modelType,'dfm')
    % remove polygon-points to mimic d3d-style
    deleteLogi = arb.wght(:,3) > 0;
    Data_xy.Xcor(deleteLogi) = [];Data_xy.Ycor(deleteLogi) = [];Data_xy.Scor(deleteLogi) = [];
    if isfield(Data_xy,'Zint'); Data_xy.Zint(:,deleteLogi,:) = []; end
    deleteLogi = deleteLogi(1:end-1);
    Data_xy.Xcen(deleteLogi) = [];Data_xy.Ycen(deleteLogi) = [];Data_xy.Scen(deleteLogi) = [];
    if isfield(Data_xy,'Zcen'); Data_xy.Zcen(:,deleteLogi,:) = []; end
    Data_xy.val(:,deleteLogi,:) = []; % 2D or (not to be) 3D.
    no_XYcenTrajectory = length(Data_xy.Xcen);
end

% In case of velocity we project it to the pli
if isfield(Data,'vel_x')
    angle_track = angle_polyline(Data_xy.Xcen,Data_xy.Ycen,OPT.nAverageAnglePli,0);
    Data_xy.vel_para = NaN(size(Data_xy.vel_x));
    Data_xy.vel_perp = Data_xy.vel_para;
    bol_nn = ~isnan(angle_track);
    for k = 1:no_layers
        [Data_xy.vel_para(:,bol_nn,k),Data_xy.vel_perp(:,bol_nn,k)] = project_vector(Data_xy.vel_x(:,bol_nn,k),Data_xy.vel_y(:,bol_nn,k),angle_track(bol_nn));
    end
    if no_layers>1
        layer_thickness = diff(Data_xy.Zint,1,3);
        layer_thickness_tot = sum(layer_thickness,3);
        
        Data_xy.vel_x_da = sum(layer_thickness.*Data_xy.vel_x,3)./layer_thickness_tot;
        Data_xy.vel_y_da = sum(layer_thickness.*Data_xy.vel_y,3)./layer_thickness_tot;
        Data_xy.vel_mag_da = sum(layer_thickness.*Data_xy.vel_mag,3)./layer_thickness_tot;
        Data_xy.vel_para_da = sum(layer_thickness.*Data_xy.vel_para,3)./layer_thickness_tot;
        Data_xy.vel_perp_da = sum(layer_thickness.*Data_xy.vel_perp,3)./layer_thickness_tot;
    end
end 

%% make gridInfo for plotting using EHY_plotMapModelData
if nargout > 1
    if no_layers > 1 
        gridInfo.Xcor = Data_xy.Scor;
        gridInfo.Ycor = Data_xy.Zint; % [times,cells,layers]
    else
        gridInfo = [];
        if isfield(Data,'val')
            for iC = 1:no_XYcenTrajectory
                for iT = 1:no_times
                    Data_xy.val_staircase(iT,2*iC-1)  = Data_xy.val(iT,iC);
                    Data_xy.val_staircase(iT,2*iC)    = Data_xy.val(iT,iC);
                end
                Data_xy.Scor_staircase(2*iC-1,1) = Data_xy.Scor(iC);
                Data_xy.Scor_staircase(2*iC,1)   = Data_xy.Scor(iC+1);
            end
        elseif isfield(Data,'vel_x')
%             warning('to do')
        end
        
    end
end
