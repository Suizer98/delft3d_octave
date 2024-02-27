function tf = EHY_isPartitioned(filename,modelType)
% tf = EHY_isPartitioned(filename,modelType,typeOfModelFile)
%
% This function checks based on a filename if a simulation was a partitioned Delft3D-Flexible Mesh simulation
% and returns TRUE or FALSE
%
% Example1: tf = EHY_isPartitioned('D:\runid_0002_map.nc')
%               returns tf = TRUE
% Example2: tf = EHY_isPartitioned('D:\runid_0002_map.nc','dfm','outputfile')
%               returns tf = TRUE
% Example3: tf = EHY_isPartitioned('D:\trih-runid.dat','d3d')
%               returns tf = FALSE
%
% Support function of the EHY_tools. Julien.Groenenboom@deltares.nl
%
%% check user input
if ~exist('modelType','var')
    modelType = EHY_getModelType(filename);
end
[typeOfModelFile, typeOfModelFileDetail] = EHY_getTypeOfModelFile(filename);

%% determine if filename belongs to partitioned FM simulation
tf = false;
switch modelType
    case 'dfm'
        if strcmp(modelType,'dfm') && strcmp(typeOfModelFile,'outputfile') && ismember(typeOfModelFileDetail,{'map_nc','fou_nc'}) && ...
                length(filename)>10 && ~isempty(str2num(filename(end-10:end-7)))
            tf = true;
        end
end
