function Data = EHY_getMapModelData_zLayerTopBottom(inputFile,modelType,OPT)

OPT0 = rmfield(OPT,{'z','zRef','zMethod','layer'});
DataAll  = EHY_getMapModelData(inputFile,OPT0);

%% determine search direction
if strcmp(EHY_getTypeOfModelFile(inputFile),'nc_griddata')
    warning('Model input type is nc_griddata, EHY_tools assumes that z-layer 1 is the top layer (CMEMS-convention)')
    if strcmp(OPT.layer,'top')
        direction = 'first';
    elseif strcmp(OPT.layer,'bottom')
        direction = 'last';
    end
elseif ~isempty(strfind(inputFile,'_fou.nc'))
    if strcmp(OPT.layer,'top')
        direction = 'last';
    elseif strcmp(OPT.layer,'bottom')
        direction = 'first';
    end
    DataAll.val = permute(DataAll.val,[3 1 2]); % add time dimensions (size=1)
else
    disp(['Model input type is ' modelType ', EHY_tools will use EHY_getMapModelData_z to find active cells only'])
    if strcmp(OPT.layer,'top')
        OPT.z = 0;
        OPT.zRef = 'wl';
        %         direction = 'last';
    elseif strcmp(OPT.layer,'bottom')
        OPT.z = 0;
        OPT.zRef = 'bed';
        %         direction = 'first';
    end
    Data = EHY_getMapModelData_z(inputFile,modelType,OPT);
    if nargout==1
        varargout{1} = Data;
    end
    return
end

%% permute and reshape DataAll.val to [timesInd x facesInd x layerInd]
if strcmp(EHY_getTypeOfModelFile(inputFile),'nc_griddata') ||strcmp(modelType,'d3d')
%     if strcmp(EHY_getTypeOfModelFile(inputFile),'nc_griddata')
%         DataAll.val = permute(DataAll.val,[1 3 4 2]);
%     end
    modelSize   = size(DataAll.val);
    DataAll.val = reshape(DataAll.val,[modelSize(1) prod(modelSize(2:3)) modelSize(4)]);
end

%% find the corresponding values per timestep and per face
if isfield(DataAll,'times')
    Data.times = DataAll.times;
end
Data.val   = [];
Data.OPT   = DataAll.OPT;
for iT = 1:size(DataAll.val,1)
    for iF = 1:size(DataAll.val,2)
        id_layer = find(~isnan(DataAll.val(iT,iF,:)),1,direction);
        if ~isempty(id_layer)
            Data.val(iT,iF) = DataAll.val(iT,iF,id_layer);
        else
            Data.val(iT,iF) = NaN;
        end
    end
end

%% reshape data back to its original format (without the layer dimension)
if strcmp(modelType,'d3d') || strcmp(EHY_getTypeOfModelFile(inputFile),'nc_griddata')
    Data.val = reshape(Data.val,modelSize(1:3));
end

end