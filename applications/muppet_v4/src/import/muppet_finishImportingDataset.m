function dataset=muppet_finishImportingDataset(dataset,d,timestep,istation,m,n,k)
% Generic import function for different file types

% Determine shape of selected data
dataset=muppet_determineDatasetShape(dataset,timestep,istation,m,n,k);

% Squeeze d
d=muppet_squeezeDataset(d);

% Determine component
[dataset,d]=muppet_determineDatasetComponent(dataset,d);

% Copy data to dataset structure
dataset=muppet_copyToDataStructure(dataset,d);

% Determine type
if isempty(dataset.type)
    
    if dataset.unstructuredgrid
        strucstr='u';        
    else
        strucstr='';
    end
    
    trackstr='';
    if strcmpi(dataset.quantity,'location')
        if ~isempty(dataset.times)
            if isempty(dataset.time)
                % This is a track
                trackstr='track';            
            end
        end
    end
    
    dataset.type=[dataset.quantity trackstr num2str(dataset.ndim) 'd' strucstr dataset.plane];

end

% Determine cell centres/corners
dataset=muppet_computeCentresAndCorners(dataset);

%% Set time-varying or constant
dataset=muppet_setDatasetVaryingOrConstant(dataset,timestep);
