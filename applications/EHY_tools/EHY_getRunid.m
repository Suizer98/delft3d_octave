function runid = EHY_getRunid(filename)
[~,name,ext] = fileparts(filename);
modelType = EHY_getModelType(filename);
[typeOfModelFile, typeOfModelFileDetail] = EHY_getTypeOfModelFile(filename);
runid='';

switch modelType
    %  Delft3D-Flexible Mesh
    case 'dfm'
        if strcmp(typeOfModelFileDetail,'his_nc')
            runid = strrep(name,'_his','');
        elseif strcmp(typeOfModelFileDetail,'map_nc')
            runid = strrep(name,'_map','');
        end
        
        % if partioned run, delete partition number
        if length(runid)>5 && ~isempty(str2num(runid(end-3:end))) && strcmp(runid(end-4),'_')
            runid=runid(1:end-5);
        end
        
        % Delft3D 4
    case 'd3d'
        if strcmp(typeOfModelFileDetail,'trih')
            runid = strrep(name,'trih-','');
        elseif strcmp(typeOfModelFileDetail,'trim')
            runid = strrep(name,'trim-','');
        end
        
end
