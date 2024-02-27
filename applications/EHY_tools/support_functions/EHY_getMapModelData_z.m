function Data = EHY_getMapModelData_z(inputFile,modelType,OPT)

%% Info in EHY_getMapModelData:
% OPT.z            = ''; % z = positive up. Wanted vertical level = OPT.zRef + OPT.z
% OPT.zRef         = ''; % choose: '' = model reference level, 'wl' = water level or 'bed' = from bottom level
% OPT.zMethod      = ''; % interpolation method: '' = corresponding layer or 'linear' = 'interpolation between two layers'

%% OPT
OPT0 = OPT;
OPT = rmfield(OPT,{'z','zRef','zMethod','layer'});
varName0 = OPT.varName;

%% determine reference level
if ismember(OPT0.zRef,{'wl','bed','bl'})
    OPT.varName = OPT0.zRef;
    Data_zRef = EHY_getMapModelData(inputFile,OPT);
    refLevel = Data_zRef.val;
    if any(size(refLevel) == 1)
        refLevel = reshape(refLevel,[1 numel(refLevel)]);
    end
elseif isempty(OPT0.zRef) 
    refLevel = 0; % model reference level
else
    error(['Unknown reference level: ' OPT0.zRef ])
end

%% get "zcen_int"-data
[DataZ.Zcen_int,DataZ.Zcen_cen] = EHY_getMapModelData_construct_zcoordinates(inputFile,modelType,OPT);

%% get wanted "varName"-data for all necessary layers
% get data
OPT.varName = varName0; % change wanted variabele back to original value
DataAll = EHY_getMapModelData(inputFile,OPT);

%% check
dimTextInd = strfind(DataAll.dimensions,',');
if isempty(strfind(lower(DataAll.dimensions(dimTextInd(end)+1:end-1)),'lay'))
    error('Last dimension is not the layer-dimension and that is what this script uses. Please contact Julien.Groenenboom@deltares.nl')
elseif isempty(strfind(DataAll.dimensions(2:dimTextInd(1)-1),'time'))
    error('First dimension is not the time-dimension and that is what this script uses. Please contact Julien.Groenenboom@deltares.nl')
end

%% from [m,n] (like d3d4) to cells (like dfm)
%  Notsure if this will always work; also not sure if modelsize cannot be 4
%  in case of velocities
try modelSize = size(DataAll.val); catch modelSize = size(DataAll.vel_x); end 
if length(modelSize) == 4
    DataAll.val    = reshape(DataAll.val,   [modelSize(1) prod(modelSize(2:3)) modelSize(4)]); 
    DataZ.Zcen_cen = reshape(DataZ.Zcen_cen,[modelSize(1) prod(modelSize(2:3)) modelSize(4)]); 
    DataZ.Zcen_int = reshape(DataZ.Zcen_int,[modelSize(1) prod(modelSize(2:3)) modelSize(4)+1]); 
    if numel(refLevel)>1
        if size(refLevel,1) == 1
            refLevel = repmat(refLevel,modelSize(1),1,1); % repmat over time-dimension
        end
        refLevel = reshape(refLevel,[modelSize(1) prod(modelSize(2:3))]);
    end
end

%% Calculate values at specified reference level

% we are going to loop over fieldnames 'val','vel_x','vel_mag',etc.
v = intersect(fieldnames(DataAll),{'val','vel_x','vel_y','vel_mag','vel_dir','val_x','val_y'});

% initiate Data-struct
Data      = DataAll;
Data.OPT  = setproperty(Data.OPT,OPT0); % set original OPT back
% delete 'layer'-dimension
no_dims   = size(Data.(v{1}));
no_layers = no_dims(end);
Data.OPT  = rmfield(Data.OPT,'layer');
for iV = 1:length(v) % loop over fieldname 'val','vel_x','vel_mag',etc.
    Data.(v{iV})  = NaN([no_dims(1:end-1) length(OPT0.z)]);
end

if length(OPT0.z) > 1
    Data.dimensions = [Data.dimensions(1:dimTextInd(end)-1) ',z]'];
else
    Data.dimensions = [Data.dimensions(1:dimTextInd(end)-1) ']'];
end

% correct for order of layering > make layer 1 the bottom layer | This is only used within this function for the next loop
gridInfo = EHY_getGridInfo(inputFile,'layer_model','mergePartitions',0,'disp',0);
if strcmp(modelType,'delwaq') || (strcmp(modelType,'d3d') && strcmp(gridInfo.layer_model,'sigma-model'))
    DataZ.Zcen_int = flip(DataZ.Zcen_int,3);
    DataZ.Zcen_cen = flip(DataZ.Zcen_cen,3);
    for iV = 1:length(v) % loop over fieldname 'val','vel_x','vel_mag',etc.
        DataAll.(v{iV}) = flip(DataAll.(v{iV}),3);
    end
end

% wanted Z-coordinate
for iZ = 1:length(OPT0.z)
    wantedZ = refLevel + OPT0.z(iZ); % 1st dim = time, 2nd dim = cells
    
    % get corresponding layer/apply interpolation
    switch OPT0.zMethod
        case 'linear'
            error('to do --> maybe this can be copied from/combined with EHY_getmodeldata_z')
            
        otherwise % corresponding layer
            dz = 10^-6; % margin needed for precision issues
            for iV = 1:length(v) % loop over fieldname 'val','vel_x','vel_mag',etc.
                slicePerZ = NaN(size(Data.(v{1}),1),size(Data.(v{1}),2)); % size of first two dims of Data.val
                for iL = 1:no_layers % loop over layers
                    getFromThisModelLayer = DataZ.Zcen_int(:,:,iL) <= wantedZ+dz & DataZ.Zcen_int(:,:,iL+1) >= wantedZ-dz;
                    if any(any(getFromThisModelLayer))
                        valInThisModelLayer = DataAll.(v{iV})(:,:,iL);
                        slicePerZ(getFromThisModelLayer) = valInThisModelLayer(getFromThisModelLayer);
                    end
                    if all(all(~isnan(slicePerZ)))
                        break
                    end
                end
                Data.(v{iV})(:,:,iZ) = slicePerZ;
            end
    end
end

%% cells (like dfm) back to [m,n] (like d3d)
if length(modelSize) == 4
    Data.val = reshape(Data.val,modelSize(1:3));
end
