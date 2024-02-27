function FMversion = EHY_getFMversion(inputFile,modelType)

FMversion = '?'; % Delft3D FM version

if ~exist('modelType','var') % modelType was not provided
    modelType = EHY_getModelType(inputFile);
end

if strcmp(modelType,'dfm')
    % e.g. source = 'D-Flow FM 1.2.41.63609' or 'Deltares, D-Flow FM Version 1.2.100.66357, Apr 10 2020, 02:20:29, model'
    source = ncreadatt(inputFile,'/','source');
    nrs = regexp(source,'\d*', 'match');
    FMversion = str2double(nrs{cellfun(@length,nrs) >= 5});
end
