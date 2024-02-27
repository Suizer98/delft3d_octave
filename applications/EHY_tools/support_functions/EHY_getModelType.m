function modelType = EHY_getModelType(fname)
%% modelType = EHY_getModelType(fname)
%
% This function returns the modelType based on a filename
% modelType can be:
% nc        netCDF file (but not recognized as Delft3D FM, SOBEK, etc.)
% dfm       Delft3D Flexible Mesh
% d3d       Delft3D 4
% simona    SIMONA (WAQUA/TRIWAQ)
%
% Example1: 	modelType = EHY_getModelType('D:\model.mdu')
% Example2: 	modelType = EHY_getModelType('D:\model.obs')
% Example3: 	modelType = EHY_getModelType('D:\trih-r01.dat')
%
% Hint: to get the type of model file, use EHY_getTypeOfModelFile
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

%%
if ischar(fname)
    
    modelType = '';
    [~, name, ext] = fileparts(lower(fname));
    
    % netCDF
    if strcmpi(ext,'.nc')
        modelType = 'nc';
    end
    
    % Delft3D FM
    if isempty(modelType) || strcmp(modelType,'nc')
        if ismember(ext,{'.mdu','.ext','.bc','.pli','.xyn','.tim'})
            modelType = 'dfm';
        end
    end
    
    % Delft3D FM or SOBEK3 netCDF outputfile
    if isempty(modelType) || strcmpi(ext,'.nc')
        if ~isempty(strfind(fname,'_his.nc')) || ~isempty(strfind(fname,'_map.nc')) || ~isempty(strfind(fname,'_net.nc')) || ...
                ~isempty(strfind(fname,'_fou.nc')) || ~isempty(strfind(fname,'_waqgeom.nc')) || ~isempty(strfind(fname,'_netgeom.nc'))
            modelType = 'dfm';
        elseif ~isempty(strfind(name,'observations'))
            modelType = 'sobek3_new';
        elseif ~isempty(strfind(name,'water level (op)-'))
            modelType = 'sobek3';
        end
    end
    
    % Delft3D 4
    if isempty(modelType)
        if ~isempty(strfind(name,'trih-')) || ~isempty(strfind(name,'trim-')) || ...
                ismember(ext,{'.mdf','.bcc','.bct','.bca','.bnd','.crs','.dat','.def','.enc','.eva','.grd','.obs','.src'})
            modelType = 'd3d';
        end
    end
    
    % SIMONA (WAQUA/TRIWAQ)
    if isempty(modelType)
        if ~isempty(strfind(name,'sds'   )) || ~isempty(strfind(name,'siminp'))  || ~isempty(strfind(name,'rgf')) || ...
                ~isempty(strfind(name,'points')) || ~isempty(strfind(name,'timeser'))
            modelType = 'simona';
        end
    end
    
    % delwaq
    if ismember(ext,{'.map','.his','.lga','.cco','.sgf'})
        modelType = 'delwaq';
    end
    
%     % CMEMS // HiRLAM (i.e. [lat,lon]- or[x,y]-data) -->> treat as dfm
%     if strcmpi(ext,'.nc')
%         if nc_isvar(fname,'longitude') ||  nc_isvar(fname,'x') ||  nc_isvar(fname,'X')
%             modelType = 'dfm';
%         end
%     end
    
     % Implic
    if isempty(modelType)
        if isdir(fname)
            modelType = 'implic';
        end
    end
    
    % Implic
    if isempty(modelType)
        if ~isempty(strfind(fname,'waqua-scaloost'))
            modelType = 'waqua_scaloost';
        end
    end
    
elseif isstruct(fname)
    
    % Delft3D 4
    if isfield(fname,'FileType')
        if strcmpi(fname.FileType,'NEFIS')
            modelType = 'd3d';
        end
    end
    
end
