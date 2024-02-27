function stationNames = EHY_getStationNames(inputFile,modelType,varargin)
%% stationNames = EHY_getStationNames(outputfile,modelType,varargin)
%
% This function returns the station names based on a model output file
%
% Example1: 	stationNames=EHY_getStationNames('D:\trih-r01.dat','d3d')
% Example2: 	stationNames=EHY_getStationNames('D:\r01_his.nc','dflowfm')
% Example3: 	stationNames=EHY_getStationNames('D:\SDS-run1','simona','varName','uv')
%
% Note that SIMONA models can have different water level vs. velocity stations
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

OPT.varName = 'wl'; % 'wl','uv','cross_section_*','general_structure_*'
OPT         = setproperty(OPT,varargin);

%% check user input
if ~exist('modelType','var') || isempty(modelType)
    modelType = EHY_getModelType(inputFile);
end

%%
stationNames = '';
switch modelType
    
    case {'d3dfm','dflow','dflowfm','mdu','dfm','nc'}
        %% Delft3D-Flexible Mesh
        if ~isempty(strfind(lower(OPT.varName),'cross_section'))
            stationNames  = nc_varget(inputFile,'cross_section_name');
        elseif ~isempty(strfind(lower(OPT.varName),'general_structure'))
            if nc_isvar(inputFile,'general_structure_name')
                stationNames  = nc_varget(inputFile,'general_structure_name');
            elseif nc_isvar(inputFile,'general_structure_id')
                stationNames = nc_varget(inputFile,'general_structure_id');
            end
        else % 'wl' or 'uv'
            stationNames  = nc_varget(inputFile,'station_name');
        end
        
        if size(stationNames,2) == 1 % transpose needed in this case
            stationNames = stationNames';
        end
        stationNames = cellstr(strtrim(stationNames));
        
    case {'d3d','d3d4','delft3d4','mdf'}
        %% Delft3D 4
        trih = vs_use(inputFile,'quiet');
        stationNames = cellstr(strtrim(vs_get(trih,'his-const',{1},'NAMST','quiet')));
        
    case {'waqua','simona','siminp','triwaq'}
        %% SIMONA (WAQUA/TRIWAQ)
        sds = qpfopen(inputFile);
        if strcmpi(OPT.varName,'uv')
            stationNames = strtrim(waquaio(sds,[],'flowstat-uv'));
        elseif strcmpi(OPT.varName,'salinity') || strcmpi(OPT.varName,'temperature')
            stationNames = strtrim(waquaio(sds,[],'transtat'));
        elseif strcmpi(OPT.varName,'cross_section_discharge')
            stationNames = [strtrim(waquaio(sds,[],'flowcrs-u'))' strtrim(waquaio(sds,[],'flowcrs-v'))'];
        else % 'wl','wd','dps'
            stationNames = strtrim(waquaio(sds,[],'flowstat-wl'));
        end
        
    case {'sobek3' 'sobek3_new'}
        
        %% SOBEK3
        D = read_sobeknc(inputFile);
        % Old format
        try
            stationNames = cellstr(strtrim(D.feature_name'));
            % New format
        catch
            stationNames = cellstr(D.observation_id');
        end
        
    case 'implic'
        %% IMPLIC
        D         = dir2(inputFile,'file_incl','\.dat$');
        files     = find(~[D.isdir]);
        filenames = {D(files).name};
        for i_stat = 1: length(filenames)
            [~,name,~] = fileparts(filenames{i_stat});
            stationNames{i_stat} = name;
        end
    case 'waqua_scaloost'
        [path,~,~] = fileparts(inputFile);
        D         = dir2(path,'file_incl','\.dat$');
        files     = find(~[D.isdir]);
        filenames = {D(files).name};
        for i_stat = 1: length(filenames)
            [~,name,~] = fileparts(filenames{i_stat});
            index = strfind(name,'_');
            stationNames{i_stat} = name(1:index(1) - 1);
        end
        stationNames = unique(stationNames);
    case 'delwaq'
        %% DELWAQ
        dw = delwaq('open',inputFile);
        stationNames = dw.SegmentName;
        
end
