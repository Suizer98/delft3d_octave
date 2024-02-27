function [newName,varNameInput] = EHY_nameOnFile(fName,varName)
%% [newName,varNameInput] = EHY_nameOnFile(fName,varName)
%
% This function returns the variable/dimension name (newName) that you would like to
% read (varName) based on the available variables names in the netCDF file (fName).
%
% Useful to deal with the changing variable names in the FM output files,
% like NetNode_x (old) which is the same as mesh2d_node_x (newer)
%
% Example1: newName = EHY_nameOnFile('D:\runid_his.nc','sal')
%   returns newName = 'salinity';
% Example2: newName = EHY_nameOnFile('D:\runid_map.nc','waterlevel')
%   returns newName = 'mesh2d_s1';
% Example3: newName = EHY_nameOnFile('D:\runid_his.nc','nmesh2d_layer')
%   returns newName = laydim;
%
% E: Julien.Groenenboom@deltares.nl

%% get modelType and typeOfModelFileDetail
modelType                  = EHY_getModelType(fName);
[~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(fName);
if EHY_isCMEMS(fName)
    modelType = 'CMEMS';
end
%% return if regular netCDF file
varNameInput = varName;
if strcmp(modelType,'nc')
    if strcmpi(varName,'wl') && ~nc_isvar(fName,'wl') && nc_isvar(fName,'waterlevel')
        newName = 'waterlevel';
    else
        newName = varName;
    end
    return
end

%% Change variable name (for usage in EHY_getmodeldata) for Delft3D 4, IMPLIC and SOBEK3
if strcmpi(varName,'vel'                  ) varName = 'uv'         ; end
if strcmpi(varName,'vel_perp'             ) varName = 'uv'         ; end
if strcmpi(varName,'vel_para'             ) varName = 'uv'         ; end
if strcmpi(varName,'sal'                  ) varName = 'salinity'   ; end
if strcmpi(varName,'chl'                  ) varName = 'salinity'   ; end
if strcmpi(varName,'tem'                  ) varName = 'temperature'; end
if strcmpi(varName,'waterlevel'           ) varName = 'wl'         ; end
if strcmpi(varName,'water level'          ) varName = 'wl'         ; end
if strcmpi(varName,'waterdepth'           ) varName = 'wd'         ; end
if strcmpi(varName,'water depth'          ) varName = 'wd'         ; end
if strcmpi(varName,'bed'                  ) varName = 'bedlevel'   ; end
if strcmpi(varName,'bl'                   ) varName = 'bedlevel'   ; end
if strcmpi(varName,'suspendedload'        ) varName = 'suspload'   ; end
if strcmpi(varName,'sedimentconcentration') varName = 'sedconc'    ; end
if strcmpi(varName,'den'                  ) varName = 'density'    ; end
if strcmpi(varName,'wd'                   ) varName = 'waterdepth' ; end

%% Change the name of the requested Variable name
newName = varName;
switch typeOfModelFileDetail
    case 'his_nc' % dfm
        % Get the name of varName as specified on the history file of a simulation
        if strcmpi(varName,'wl'         ) newName = 'waterlevel'   ; end
        if strcmpi(varName,'wd'         ) newName = 'waterdepth'   ; end
        if strcmpi(varName,'uv'         ) newName = 'x_velocity'   ; end
        if strcmpi(varName,'Zcen'       ) newName = 'zcoordinate_c'; end
        if strcmpi(varName,'Zint'       ) newName = 'zcoordinate_w'; end
        if strcmpi(varName,'Zcen_cen'   ) newName = 'zcoordinate_c'; end
        if strcmpi(varName,'Zcen_int'   ) newName = 'zcoordinate_w'; end
        if strcmpi(varName,'vicoww'     ) newName = 'vicww'        ; end
        
    case {'map_nc','fou_nc'} % dfm
        % Get the name of varName as specified on the map file of a simulation
        if strcmpi(varName,'wl'         ) newName = 's1'         ;  end
        if strcmpi(varName,'salinity'   ) newName = 'sa1'        ;  end
        if strcmpi(varName,'temperature') newName = 'tem1'       ;  end
        if strcmpi(varName,'density')     newName = 'rho'        ;  end
        if strcmpi(varName,'uv'         ) newName = 'ucx'        ;  end
        if strcmpi(varName,'wd'         ) newName = 'waterdepth' ;  end
        if strcmpi(varName,'bedlevel'   ) newName = 'FlowElem_bl';  end
        if strcmpi(varName,'Zcen_cen'   ) newName = 'flowelem_zcc'; end
        if strcmpi(varName,'Zcen_int'   ) newName = 'flowelem_zw';  end
        if strcmpi(varName,'vel_perp'   ) newName = 'ucx';          end
        if strcmpi(varName,'vel_para'   ) newName = 'ucx';          end
        if strcmpi(varName,'velW'       ) newName = 'ucz';          end

    case 'trim' % d3d
        % Get the name of varName as specified on the map file of a simulation
        if strcmpi(varName,'wl'         ) newName = 'S1'         ; end
        if strcmpi(varName,'bedlevel'   ) newName = 'DPS0'       ; end
        if strcmpi(varName,'uv'         ) newName = 'U1'         ; end
        if strcmpi(varName,'velW'       ) newName = 'wphy'       ; end
        if strcmpi(varName,'density'    ) newName = 'RHO'        ; end
%         if strcmpi(varName,'dps'        ) newName = 'DPS0'       ; end %DPS is different than DPS0 in case of morphodynamic simulation
        if strcmpi(varName,'avbedload'  ) newName = 'SBUUA'      ; end
        if strcmpi(varName,'avsuspload' ) newName = 'SSUUA'      ; end
        if strcmpi(varName,'bedload'    ) newName = 'SBUU'       ; end
        if strcmpi(varName,'suspload'   ) newName = 'SSUU'       ; end
        if strcmpi(varName,'tau'        ) newName = 'TAUKSI'     ; end
        if strcmpi(varName,'sedconc'    ) newName = 'RSEDEQ'     ; end
        if strcmpi(varName,'dpsed'      ) newName = 'DP_BEDLYR'  ; end
    case 'trih' % d3d
        % Get the name of varName as specified on the history file of a simulation
        if strcmpi(varName,'wl'         ) newName = 'ZWL'        ; end
        if strcmpi(varName,'bedlevel'   ) newName = 'DPS'        ; end
        if strcmpi(varName,'uv'         ) newName = 'ZCURU'      ; end
        if strcmpi(varName,'density'    ) newName = 'zrho'       ; end
        if strcmpi(varName,'vicoww'     ) newName = 'ZVICWW'     ; end
    case 'sds' % simona
        if strcmpi(varName,'x_velocity' ) newName = 'uv'         ; end
    case 'his' % DELWAQ .his-file
        if strcmpi(varName,'temperature') newName = 'Temp'       ; end
    case 'map' % DELWAQ .map-file
        if strcmpi(varName,'temperature') newName = 'Temp'       ; end
end

if strcmpi(modelType,'CMEMS')
    if strcmpi(varName,'salinity');    newName = 'so'; end
    if strcmpi(varName,'temperature'); newName = 'thetao'; end
    % set modelType back to 'nc' for further processing
    modelType = 'nc';
end

%% for FM output (netCDF files)
if ismember(modelType,{'dfm','SFINCS'}) && strcmp(fName(end-2:end),'.nc')
    
    %%% get ncinfo
    infonc   = ncinfo(fName);
    varNames = {infonc.Variables.Name};
    dimNames = {infonc.Dimensions.Name};
    if any(~cellfun(@isempty,strfind(varNames,'_agg'))) % DELWAQ-aggregated file
        varNames = strrep(varNames,'_agg','');
        dimNames = strrep(dimNames,'_agg','');
        aggregated = 1;
    end
    
    %%% Change Variable or Dimension name to deal with old/new variable names like NetNode_x (older) vs. mesh2d_node_x (newer)
    %%% based on the list at the end of this script
    if ~nc_isvar(fName,newName)
        fmNames = getFmNames;
        for iN = 1:length(fmNames)
            if ismember(newName,fmNames{iN})
                newName = char(intersect(fmNames{iN},[varNames dimNames]));
            end
        end
    end
    
    if exist('aggregated','var') % DELWAQ-aggregated file
        newName = strrep(newName,'mesh2d','mesh2d_agg');
    end
        
    %%% Change Variable or Dimension name to deal with old/new variable names like tem1 (older) vs. mesh2d_tem1 (newer)
    if ~nc_isvar(fName,newName) && ~nc_isdim(fName,newName)
        if size(newName,1)>1
            ind = find(ismember({infonc.Dimensions.Name},newName),1);
            if numel(unique([infonc.Dimensions(ind).Length]))
                newName = newName(1,:);
            else
                error('Multiple variable/dimension-names, but different Lengths')
            end
        end
        
        indVarNames = find(~cellfun(@isempty,strfind(lower(varNames),lower(newName))));
        for ii = 1:length(indVarNames)
            varNamesNoPrefix = strrep(varNames,'mesh2d_','');
            if strcmpi(newName,varNamesNoPrefix{indVarNames(ii)})
                newName = infonc.Variables(indVarNames(ii)).Name; matchFound = 1;
            end
        end
        indDimNames = find(~cellfun(@isempty,strfind(lower(dimNames),lower(newName))));
        for ii = 1:length(indDimNames)
            dimNamesNoPrefix = strrep(dimNames,'nmesh2d_','');
            if strcmpi(newName,dimNamesNoPrefix{indDimNames(ii)})
                newName = infonc.Dimensions(indDimNames(ii)).Name; matchFound = 1;
            end
        end
        if ~exist('matchFound','var')
            newName = 'noMatchFound';
        end
    end
    
    %%% Deal with *_water_quality_*-variables in Delft3D FM
    if ~nc_isvar(fName,newName)
        varInd = find(~cellfun(@isempty,strfind(varNames,'water_quality_')));
        for iV = 1:length(varInd)
            AttrInd = strmatch('long_name',{infonc.Variables(varInd(iV)).Attributes.Name},'exact');
            long_name = infonc.Variables(varInd(iV)).Attributes(AttrInd).Value;
            if strcmpi(varName,long_name)
                newName = varNames{varInd(iV)};
                disp(['variable ''' varNameInput ''' renamed to ''' newName '''']);
            end
        end
    end
    
end

% check case sensitive: ZwL to ZWL
variables = EHY_variablesOnFile(fName,modelType);
logi = strcmpi(newName,variables);
if sum(logi) == 1
    newName = char(variables(logi));
end

end

function fmNames = getFmNames

fmNames={};
%%% VARIABLE names used within different versions of Delft3D-Flexible Mesh
fmNames{end+1,1}={'mesh2d_node_x','NetNode_x'}; % x-coordinate of nodes
fmNames{end+1,1}={'mesh2d_node_y','NetNode_y'}; % y-coordinate of nodes
fmNames{end+1,1}={'mesh2d_node_z','NetNode_z'}; % z-coordinate of nodes

fmNames{end+1,1}={'FlowElem_xcc','mesh2d_face_x'}; % x-coordinate of faces
fmNames{end+1,1}={'FlowElem_ycc','mesh2d_face_y'}; % y-coordinate of faces

fmNames{end+1,1}={'NetLink_xu','mesh2d_edge_x'}; % x-coordinate of edge
fmNames{end+1,1}={'NetLink_yu','mesh2d_edge_y'}; % y-coordinate of edge

fmNames{end+1,1}={'NetLink','mesh2d_edge_nodes'}; % 'link between two netnodes' / 'Mapping from every edge to the two nodes that it connects'
fmNames{end+1,1}={'NetElemNode','mesh2d_face_nodes'}; % 'mapping from net cell to net nodes' 

fmNames{end+1,1}={'FlowElemContour_x','mesh2d_face_x_bnd','Mesh2d_face_x_bnd','mesh2d_agg_face_x_bnd'}; % x-coordinates of flow element contours
fmNames{end+1,1}={'FlowElemContour_y','mesh2d_face_y_bnd','Mesh2d_face_x_bnd','mesh2d_agg_face_y_bnd'}; % y-coordinates of flow element contours

fmNames{end+1,1}={'mesh2d_flowelem_domain','FlowElemDomain'}; % flow element domain
fmNames{end+1,1}={'mesh2d_flowelem_bl','Mesh2d_flowelem_bl','FlowElem_bl'}; % bed level
fmNames{end+1,1}={'mesh2d_flowelem_ba','FlowElem_bac'}; % area (m2) of cell faces

%% List of Delft3D FM and SFINCS variable names
fmNames{end+1,1}={'station_x_coordinate','station_x'};
fmNames{end+1,1}={'station_y_coordinate','station_y'};
fmNames{end+1,1}={'x_velocity','point_u'};
fmNames{end+1,1}={'y_velocity','point_v'};

%%% DIMENSION names used within different versions of Delft3D Flexible Mesh
fmNames{end+1,1}={'mesh2d_nNodes','nmesh2d_node','nNetNode','NetElemNode'}; % number of nodes
fmNames{end+1,1}={'mesh2d_nFaces','nmesh2d_face','nNetElem','nFlowElem'}; % number of faces
fmNames{end+1,1}={                'nmesh2d_edge','nNetLink'}; % number of velocity-points

fmNames{end+1,1}={'mesh2d_nLayers','laydim','nmesh2d_layer',}; % layer
end
