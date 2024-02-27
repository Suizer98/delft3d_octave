function varargout = EHY_getmodeldata(inputFile,stat_name,modelType,varargin)
%% varargout = EHY_getmodeldata(inputFile,stat_name,modelType,varargin)
% Extracts time series (of water levels/velocities/salinity/temperature) from output of different model types
%
% Running 'EHY_getmodeldata' without any arguments opens a interactive version, that also gives
% feedback on how to use the EHY_getmodeldata-function with input arguments.
%
% Input Arguments:
% inputFile : file with simulation results
% stat_name : station names can be either:
%             []       all stations
%             'name'   single string with station name
%             {'name'} cell array of strings
% modelType : 'dflowfm','delft3d4,'waqua','sobek3','implic'
%
% Optional input arguments:
% varName   : Name of variable, choose from:
%             'wl'        water level
%             'wd'        water depth
%             'dps'       bed level
%             'uv'        velocities (in (u,v,)x,y-direction)
%             'sal'       salinity
%             'tem'       temperature
%             'Zcen_cen'  z-coordinates (positive up) of cell centers (in NetElem/faces)
%             'Zcen_int'  z-coordinates (positive up) of cell interfaces (in NetElem/faces)
% t0        : Start time of dataset (e.g. '01-Jan-2018' or 737061 (Matlab date) )
% tend      : End time of dataset (e.g. '01-Feb-2018' or 737092 (Matlab date) )
% layer     : Model layer, e.g. '0' (all layers), [2] or [4:8]
% tint      : interval time (t0:tint:tend) in days (e.g. hourly interval: tint = 1/24)
%
% Output:
% Data.stationNames       : list of ALL stations available on history file
% Data.requestedStations  : list of requested stations
% Data.exist_stat         : logical if requested station exist in file
% Data.times              : (matlab) times belonging with the series
% Data.val/vel_*          : requested data, velocity in (u,v- and )x,y-direction
% Data.dimensions         : Dimensions of requested data (time,stats,lyrs)
% Data.location(XY)       : (time-varying) locations of requested stations (x,y or lon,lat)
% Data.OPT                : Structure with optional user settings used
%
% Example1: EHY_getmodeldata % interactive
% Example2: Data = EHY_getmodeldata('D:\trih-r01.dat',[],'d3d') % load water level (default), all stations, all times
% Example3: Data = EHY_getmodeldata('D:\trih-r01.dat',[],'d3d','varName','uv') % load velocities, all stations, all times
% Example4: Data = EHY_getmodeldata('D:\trih-r01.dat',[],'d3d','varName','uv','layer',5) % load velocities, all stations, all times, layer 5
% Example5: Data = EHY_getmodeldata('D:\r01_his.nc',{'station1','station2'},'dfm','t0','01-Jan-2000','tend','01-Feb-2000') % load two stations, one month
%
% Output:
% Data.OPT                : Structure with optional user settings used,
% Data.val                : 4-Dimensional array with dimensions (no_times,no_stat,kmax,2),
%                           Data.val(:,:,:,1) are the z_values,
%                           Data.val(:,:,:,2) are the varName values (salinity, temperature etc).
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
%% check user input
if ~all(ismember({'inputFile','stat_name','modelType'},who))
    EHY_getmodeldata_interactive
    return
end

%% Settings
OPT.varName      = 'wl';
OPT.t0           = '';
OPT.tend         = '';
OPT.tint         = ''; % in days
OPT.t            = []; % time index. If OPT.t is specified, OPT.t0, OPT.tend and OPT.tint are not used to find time index
OPT.layer        = 0; % all
OPT.sedimentName = ''; % name of sediment fraction

% return output at specified reference level
OPT.z            = ''; % z = positive up. Wanted vertical level = OPT.zRef + OPT.z
OPT.zRef         = ''; % choose: '' = model reference level, 'wl' = water level or 'bed' = from bottom level or 'middleOfWaterColumn' = middle of water column
OPT.zMethod      = ''; % interpolation method: '' = corresponding layer or 'linear' = 'interpolation between two layers'

% ini waterlevel needed for DELWAQ .his files
OPT.dw_iniWL     = 0;

OPT              = setproperty(OPT,varargin);

%% modify input
inputFile = strtrim(inputFile);
if ~isempty(OPT.t0)        OPT.t0      = datenum(OPT.t0);      end
if ~isempty(OPT.tend)      OPT.tend    = datenum(OPT.tend);    end
if ~isnumeric(OPT.layer)   OPT.layer   = str2num(OPT.layer);   end
if ~isnumeric(OPT.z )      OPT.z       = str2num(OPT.z);       end

%% Get model type
if isempty(modelType);                                              modelType = EHY_getModelType(inputFile);
elseif ismember(modelType,{'d3dfm','dflow','dflowfm','mdu','dfm'}); modelType = 'dfm';
elseif ismember(upper(modelType),{'SFINCS'});                       modelType = 'dfm'; % read SFINCS as DFM
elseif ismember(modelType,{'d3d','d3d4','delft3d4','mdf'});         modelType = 'd3d';
elseif ismember(modelType,{'waqua','simona','siminp'});             modelType = 'simona';
end

%% Get name of the parameter as known on output file
[OPT.varName,varNameInput] = EHY_nameOnFile(inputFile,OPT.varName);
if strcmp(OPT.varName,'noMatchFound')
    error(['Requested variable (' varNameInput ') not available in model output'])
end

%% temp fix for incorrect z-coordinates in dfm
if strcmp(OPT.varName,'zcoordinate_w') && ~EHY_isCMEMS(inputFile)
    FMversion = EHY_getFMversion(inputFile,modelType);
    if FMversion < 67858
        disp('<strong>Reconstruction of zcoordinate_w is not needed anymore when moving to FM version >= 67858 (Oct 27, 2020)</strong>')
        disp('Fix for DFM: Reconstructing Zcen_int based on water level and z-coordinates of cell centers')
        Data = EHY_getmodeldata_zcen_int(inputFile,stat_name,modelType,OPT);
        if nargout==1
            varargout{1} = Data;
        end
        return
    end
end

%% return output at specified reference level
if ~isempty(OPT.z)
    if strcmpi(OPT.varName,'chl')
        OPT.varName = varNameInput; % set back to original requested varName (needed for chl)
    end
    Data = EHY_getmodeldata_z(inputFile,stat_name,modelType,OPT);
    if nargout==1
        varargout{1} = Data;
    end
    return
end

%% Get the available and requested dimensions
[dims,dimsInd,Data,OPT] = EHY_getDimsInfo(inputFile,OPT,modelType,stat_name);

%% Get the computational data
switch modelType
    case {'dfm','nc'}
        %%  Delft3D-Flexible Mesh
        % station x,y-location info
        if any(ismember({dims.name},{'stations','cross_section'})) && ...
                isempty([strfind(OPT.varName,'coordinate') strfind(OPT.varName,'station_x') strfind(OPT.varName,'station_y')])
            if strcmp(dims(stationsInd).name,'stations')
                xVarName = EHY_nameOnFile(inputFile,'station_x_coordinate');
            elseif strcmp(dims(stationsInd).name,'cross_section')
                xVarName = EHY_nameOnFile(inputFile,'cross_section_x_coordinate');
            end
            yVarName = strrep(xVarName,'x','y');
            
            if nc_isvar(inputFile,xVarName)
                X = EHY_getmodeldata(inputFile,Data.requestedStations(Data.exist_stat),'dfm',OPT,'varName',xVarName);
                Y = EHY_getmodeldata(inputFile,Data.requestedStations(Data.exist_stat),'dfm',OPT,'varName',yVarName);
                
                infonc = ncinfo(inputFile,xVarName);
                if strncmp('cross_',yVarName,6) || ismember('time',{infonc.Dimensions.Name}) % moving stations or cross-section
                    Data.locationX(:,Data.exist_stat) = X.val;
                    Data.locationY(:,Data.exist_stat) = Y.val;
                else
                    Data.location(Data.exist_stat,:) = [reshape(X.val,[],1) reshape(Y.val,[],1)];
                end
            end
        end
        
        % initialise start+count and optimise if possible
        [dims,start,count] = EHY_getmodeldata_optimiseDims(dims);
        
        % The handling of all the wanted indices (like times, stations and layers) is done within ncread_blocks
        if ~ismember(OPT.varName,{'x_velocity','y_velocity','point_u','point_v'})
            Data.val   =  ncread_blocks(inputFile,OPT.varName,start,count,dims);
        else
            Data.vel_x   = ncread_blocks(inputFile,EHY_nameOnFile(inputFile,'x_velocity'),start,count,dims);
            Data.vel_y   = ncread_blocks(inputFile,EHY_nameOnFile(inputFile,'y_velocity'),start,count,dims);
            Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
            Data.vel_dir = mod(atan2(Data.vel_x,Data.vel_y)*180/pi,360);
            Data.vel_dir_comment = 'Considered clockwise from geographic North to where vector points';
        end
        
    case 'd3d'
        %% Delft3D 4
        % open inputfile
        trih = vs_use(inputFile,'quiet');
        
        % station info
        locationMN = vs_get(trih,'his-const',{1},'MNSTAT','quiet')';
        Data.locationMN(Data.exist_stat,:) = locationMN(dims(stationsInd).index,:);
        locationXY = vs_get(trih,'his-const',{1},'XYSTAT','quiet')';
        Data.location(Data.exist_stat,:)   = locationXY(dims(stationsInd).index,:);
        
        % vertical grid info
        gridInfo = EHY_getGridInfo(inputFile,{'layer_model','no_layers'});
        no_layers = gridInfo.no_layers;
        layer_model = gridInfo.layer_model;
        
        % loop over stations
        dims0 = dims;
        for i_stat = 1:length(dims0(stationsInd).index)
            dims = dims0;
            
            % First, special cases
            time_ind = dims(timeInd).index;
            stat_ind = dims(stationsInd).index(i_stat);
            indexOut = dims(stationsInd).indexOut(i_stat);
            
            switch lower(OPT.varName)
                case {'bedlevel','dps'} % make bedlevel positive up
                    DPS                  = vs_get(trih,'his-const',{1},'DPS',{stat_ind},'quiet');
                    Data.val(:,indexOut) = -DPS;
                case 'wd'
                    wl                   = cell2mat(vs_get(trih,'his-series',{time_ind},'ZWL',{stat_ind},'quiet')); % ref to wl
                    DPS                  = vs_get(trih,'his-const',{1},'DPS',{stat_ind},'quiet'); % bed to ref
                    Data.val(:,indexOut) = wl+DPS;
                case {'uv','zcuru'}
                    if no_layers == 1 % 2Dh
                        data = qpread(trih,1,'depth averaged velocity','griddata',time_ind,stat_ind);
                        Data.vel_x(:,indexOut) = data.XComp;
                        Data.vel_y(:,indexOut) = data.YComp;
                        Data.vel_u(:,indexOut) = cell2mat(vs_get(trih,'his-series',{time_ind},'ZCURU',{stat_ind,1},'quiet'));
                        Data.vel_v(:,indexOut) = cell2mat(vs_get(trih,'his-series',{time_ind},'ZCURV',{stat_ind,1},'quiet'));
                    else % 3D
                        layer_ind  = dims(layersInd).index;
                        data = qpread(trih,1,'horizontal velocity','griddata',time_ind,stat_ind,0);
                        Data.vel_x(:,indexOut,:) = squeeze(data.XComp(:,1,dims(layersInd).index));
                        Data.vel_y(:,indexOut,:) = squeeze(data.YComp(:,1,dims(layersInd).index));
                        Data.vel_u(:,indexOut,:) = cell2mat(vs_get(trih,'his-series',{time_ind},'ZCURU',{stat_ind,layer_ind},'quiet'));
                        Data.vel_v(:,indexOut,:) = cell2mat(vs_get(trih,'his-series',{time_ind},'ZCURV',{stat_ind,layer_ind},'quiet'));
                    end
                    Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
                    Data.vel_dir = mod(atan2(Data.vel_x,Data.vel_y)*180/pi,360);
                    Data.vel_dir_comment = 'Considered clockwise from geographic North to where vector points';
                    
                case {'zcen_cen' 'zcen_int'}
                    if strcmp(gridInfo.layer_model,'sigma-model')
                        thick    = vs_let(trih,'his-const', 'THICK','quiet');
                        DPS      = vs_let(trih,'his-const', 'DPS',  'quiet');
                    elseif strcmp(gridInfo.layer_model,'z-model')
                        DPS      = vs_let(trih,'his-const', 'DPS',  'quiet');
                        zk       = vs_get(trih,'his-const', 'ZK' ,  'quiet');
                    end
                    zwl      = vs_let(trih,'his-series',{time_ind},'ZWL',{stat_ind},'quiet');
                    for i_time = 1:dims(timeInd).sizeOut
                        if strcmpi(layer_model,'sigma-model')
                            depth = DPS(stat_ind) + zwl(i_time);
                            Zcen_int(i_time,1     )        = zwl(i_time);
                            Zcen_int(i_time,no_layers + 1) = -DPS(stat_ind);
                            Zcen_cen(i_time,1     )        = zwl(i_time) - 0.5*thick(1)*depth;
                            for k = 2: no_layers
                                Zcen_int(i_time,k)  = Zcen_int(i_time,k-1) - thick(k-1)*depth;
                                Zcen_cen(i_time,k)  = Zcen_cen(i_time,k-1) - 0.5*(thick(k-1) + thick(k))*depth;
                            end
                        elseif strcmpi(layer_model,'z-model')
                            zk_int(1:no_layers + 1) = NaN;
                            
                            %restrict to active computational layers
                            i_start = find(zk> -DPS(stat_ind),1,'first') - 1;
                            i_stop =  find(zk>  zwl(i_time),1,'first');
                            if isempty(i_stop) i_stop = no_layers + 1; end
                            zk_int(i_start) = -DPS(stat_ind);
                            zk_int(i_stop)  =  zwl(i_time);
                            
                            zk_int(i_start+1:i_stop-1) = zk(i_start+1:i_stop-1);
                            Zcen_int(i_time,:) = zk_int;
                            for k = 1: no_layers
                                Zcen_cen(i_time,k) = 0.5*(Zcen_int(i_time,k  ) + Zcen_int(i_time,k+1) );
                            end
                        end
                    end
                    
                    % return requested variable as 'Data.val'
                    % and return other output as well
                    if strcmpi(OPT.varName    ,'Zcen_cen')
                        Data.val(:,indexOut,:) = Zcen_cen;
                    elseif strcmpi(OPT.varName,'Zcen_int')
                        Data.val(:,indexOut,:) = Zcen_int;
                    end
                    Data.Zcen_cen(:,indexOut,:) = Zcen_cen;
                    Data.Zcen_int(:,indexOut,:) = Zcen_int;
                    
                otherwise % Apply generic approach
                    dims(stationsInd).index = dims0(stationsInd).index(i_stat);
                    dims(stationsInd).indexOut = dims0(stationsInd).indexOut(i_stat);
                    
                    grp = char(vs_find(vs_use(inputFile,'quiet'), OPT.varName));
                    if size(grp,1)>1; grp = grp(1,:); end
                    if ~isempty(strfind(grp,'-const'))
                        dims(timeInd).index = 1; % const
                    end
                    time_ind  = {dims(1).index};
                    other_ind = {dims(2:end).index};
                    
                    % get data
                    data = vs_let(trih,grp,time_ind,OPT.varName,other_ind,'quiet');
                    
                    % put it in Data.val in correct format
                    if ~isempty(strfind(grp,'-const'))
                        dims(timeInd) = []; % remove constant time index
                    end
                    if iscell(data)
                        data = cell2mat(data);
                    end
                    Data.val(dims(:).indexOut) = data;
                    Data.val(Data.val == -999) = NaN;
            end
        end
        
        
    case 'simona'
        %% SIMONA (WAQUA/TRIWAQ)
        % open data file
        sds = qpfopen(inputFile);
        
        if exist('layersInd','var')
            no_layers = dims(layersInd).size;
            layer_ind = dims(layersInd).index;
        else
            no_layers = 1;
        end
        
        % location info: [m,n] and [x,y]
        if strcmp(OPT.varName,'uv')
            mn                        = waquaio(sds,[],'uv-mn');
            [x,y]                     = waquaio(sds,[],'uv-xy');
        else
            mn                        = waquaio(sds,[],'wl-mn');
            [x,y]                     = waquaio(sds,[],'wl-xy');
        end
        Data.locationMN(dims(stationsInd).indexOut,:) = mn(dims(stationsInd).index,:);
        Data.locationXY(dims(stationsInd).indexOut,:) = [x(dims(stationsInd).index) y(dims(stationsInd).index)];
        
        time_ind  = dims(timeInd).index;
        switch OPT.varName
            case 'wl' % ref to wl
                Data.val(:,dims(stationsInd).indexOut)        = waquaio(sds,[],'wlstat',time_ind,dims(stationsInd).index);
            case 'dps' % bed to ref
                [~,~,z_int]        = waquaio(sds,[],'z-stat',1,dims(stationsInd).index);
                Data.val(dims(stationInd).indexOut)   = -1.*z_int(no_layers + 1:no_layers+1:end);
            case 'wd'
                wl(:,dims(stationsInd).indexOut)  = waquaio(sds,[],'wlstat',time_ind,dims(stationsInd).index);
                [~,~,z_int]                       = waquaio(sds,[],'z-stat',1,dims(stationsInd).index);
                dps(dims(stationsInd).indexOut)   =  -1.*z_int(no_layers + 1:no_layers+1:end);
                for i_stat = 1: size(wl,2)
                    Data.val(:,i_stat) = wl(:,i_stat)+dps(i_stat);
                end
            case 'uv'
                if no_layers==1
                    [uu,vv] = waquaio(sds,[],'uv-stat',time_ind,dims(stationsInd).index);
                    Data.vel_x(:,dims(stationsInd).indexOut) = uu;
                    Data.vel_y(:,dims(stationsInd).indexOut) = vv;
                else
                    Data.vel_x(:,dims(stationsInd).indexOut,:) = waquaio(sds,[],'u-stat',time_ind,dims(stationsInd).index,layer_ind);
                    Data.vel_y(:,dims(stationsInd).indexOut,:) = waquaio(sds,[],'v-stat',time_ind,dims(stationsInd).index,layer_ind);
                end
                Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
                Data.vel_dir = mod(atan2(Data.vel_x,Data.vel_y)*180/pi,360);
                Data.vel_dir_comment = 'Considered clockwise from geographic North to where vector points';
            case 'salinity'
                if no_layers==1
                    Data.val(:,dims(stationsInd).indexOut)   = waquaio(sds,[],'stsubst:            salinity',time_ind,dims(stationsInd).index);
                else
                    Data.val(:,dims(stationsInd).indexOut,:) = waquaio(sds,[],'stsubst:            salinity',time_ind,dims(stationsInd).index,layer_ind);
                end
            case 'cross_section_discharge'
                Data.val(:,dims(stationsInd).indexOut) = waquaio(sds,[],'mq-stat',time_ind,dims(stationsInd).index);
        end
        
    case 'sobek3'
        %% SOBEK3
        time_ind  = dims(timeInd).index;
        % loop over stations
        for i_stat = 1:length(dims(stationsInd).index)
            stat_ind  = dims(stationsInd).index(i_stat);
            indexOut = dims(stationsInd).indexOut(i_stat);
            % open data file
            D          = read_sobeknc(inputFile); %we are reading the whole file! better to just read what is requested.
            % get data
            switch OPT.varName
                case 'wl'
                    Data.val(:,indexOut)         =D.value(stat_ind,time_ind);
                otherwise
                    Data.val(:,indexOut)         =D.(OPT.varName)(stat_ind,time_ind);
            end
        end
        
    case 'sobek3_new'
        %% SOBEK3 new
        time_ind  = dims(timeInd).index;
        % loop over stations
        for i_stat = 1:length(dims(stationsInd).index)
            stat_ind  = dims(stationsInd).index(i_stat);
            indexOut = dims(stationsInd).indexOut(i_stat);
            % open data file
            D          = read_sobeknc(inputFile);
            refdate    = ncreadatt(inputFile, 'time','units');
            Data.times = D.time(time_ind)/1440/60 + datenum(refdate(15:end),'yyyy-mm-dd  HH:MM:SS');
            % get data
            switch OPT.varName
                case 'wl'
                    Data.val(:,indexOut) = D.water_level(stat_ind,time_ind);
            end
        end
        
    case 'implic'
        %% IMPLIC
        %  get simulation data either by reading mat file or direct reading
        %  of IMPLIC output files
        if exist([inputFile filesep 'implic.mat'],'file')
            load([inputFile filesep 'implic.mat']);
        else
            months = {'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt' 'nov' 'dec'};
            for i_stat = 1: length(Data.stationNames)
                fileName = [inputFile filesep Data.stationNames{i_stat} '.dat'];
                fid      = fopen(fileName,'r');
                line     = fgetl(fid);
                line     = fgetl(fid);
                line     = fgetl(fid);
                i_time   = 0;
                while ~feof(fid)
                    i_time  = i_time + 1;
                    line    = fgetl(fid);
                    r_val   = str2num(line(18:end))/100.;
                    tmp.val_tmp (i_time,i_stat)  = r_val;
                end
                fclose(fid);
            end
            tmp.times = Data.times;
            save([inputFile filesep 'implic.mat'],'tmp');
        end
        
        % loop over stations
        for i_stat = 1:1:length(dims(stationsInd).index)
            stat_ind  = dims(stationsInd).index(i_stat);
            indexOut = dims(stationsInd).indexOut(i_stat);
            switch OPT.varName
                case 'wl'
                    Data.val(:,indexOut) = tmp.val_tmp(:,stat_ind);
            end
        end
        clear tmp
        
    case 'waqua_scaloost'
        %% ASCII data Scaloost as supplied by Zeeland
        for i_stat = 1: length(Data.stationNames)
            fileName = [strrep(inputFile,'**stationName**',Data.stationNames{i_stat}) '.dat'];
            fid      = fopen(fileName,'r');
            line     = fgetl(fid);
            line     = fgetl(fid);
            line     = fgetl(fid);
            i_time   = 0;
            while ~feof(fid)
                i_time  = i_time + 1;
                line    = fgetl(fid);
                r_val   = str2num(line(18:end))/100.;
                tmp.val_tmp (i_time,i_stat)  = r_val;
            end
            fclose(fid);
        end
        tmp.times = Data.times;
        
        % loop over stations
        for i_stat = 1:1:length(dims(stationsInd).index)
            stat_ind  = dims(stationsInd).index(i_stat);
            indexOut = dims(stationsInd).indexOut(i_stat);
            switch OPT.varName
                case 'wl'
                    Data.val(:,indexOut) = tmp.val_tmp(:,stat_ind);
            end
        end
        clear tmp
        
    case 'delwaq'
        %% DELWAQ
        dw = delwaq('open',inputFile);
        time_ind  = dims(timeInd).index;
        
        % loop over stations
        for i_stat = 1:length(dims(stationsInd).index)
            % stat_ind
            if ischar(stat_name); stat_name = cellstr(stat_name); end
            if ~isempty(stat_name) && ~strcmp(Data.requestedStations{i_stat},stat_name{i_stat})  %GTSO-03 > GTSO-03 (01), GTSO-03 (02), etc.
                S = regexp(Data.stationNames, regexptranslate('wildcard',[stat_name{i_stat} '*']));
                stat_ind = find(~cellfun(@isempty,S));
                dims(end+1).name = 'layers';
                Data.requestedStations{i_stat} = stat_name{i_stat};
            else
                stat_ind = dims(stationsInd).index(i_stat);
            end
            indexOut = dims(stationsInd).indexOut(i_stat);
            
            for LoopNeededToBreak = 1
                if ismember(lower(OPT.varName),{'wl','bedlevel','zcen_cen','zcen_int'})
                    % bed level
                    subInd = strmatch('TotalDepth',dw.SubsName);
                    [~,TotalDepth] = delwaq('read',dw,subInd,stat_ind,1);
                    TotalDepth(TotalDepth==0) = []; TotalDepth = unique(TotalDepth);
                    if numel(TotalDepth)>1; error('debug me'); end
                    bl = OPT.dw_iniWL - TotalDepth;
                    
                    if strcmpi(OPT.varName,'bedlevel')
                        Data.val(:,indexOut) = bl; % of Data.val = bl;
                        continue
                    end
                    
                    % Zcen_int / Zcen_cen
                    subInd = strmatch('Depth',dw.SubsName);
                    [~,data] = delwaq('read',dw,subInd,stat_ind,time_ind);
                    Depth = permute(data,[3 2 1]);
                    Depth(:,end+1) = 0; % add bottom interface
                    Zcen_int = bl + fliplr(cumsum(fliplr(Depth),2));
                    % to do, set equal Zcen_int interfaces towards bed to NaN
                    Zcen_cen = (Zcen_int(:,1:end-1) + Zcen_int(:,2:end))/2;
                    
                    % water level
                    if strcmpi(OPT.varName,'wl')
                        Data.val(:,indexOut) = Zcen_int(:,1);
                        continue
                    end
                    
                    if strcmpi(OPT.varName    ,'Zcen_cen')
                        Data.val(:,indexOut,:) = Zcen_cen;
                    elseif strcmpi(OPT.varName,'Zcen_int')
                        Data.val(:,indexOut,:) = Zcen_int;
                    end
                    Data.Zcen_cen(:,indexOut,:) = Zcen_cen;
                    Data.Zcen_int(:,indexOut,:) = Zcen_int;
                    
                else
                    subInd = strmatch(OPT.varName,dw.SubsName);
                    if isempty(subInd); error(['Could not find substance ''' OPT.varName ''' on provided file']); end
                    [~,data] = delwaq('read',dw,subInd,stat_ind,time_ind);
                    Data.val(:,indexOut,:) = permute(data,[3 2 1]);
                end
            end
        end
end

%% fill data of non-existing stations with NaN's
if ~isfield(Data,'exist_stat')
    % non-station info from modelfile
else
    % station at 1st dimension
    fns = intersect(fieldnames(Data),{'locationMN','location'});
    for iFns = 1:length(fns)
        Data.(fns{iFns})(~Data.exist_stat,:,:) = NaN;
    end
    if ~strcmp(modelType,'dfm')
        % station at 2nd dimension
        fns = intersect(fieldnames(Data),{'val','vel_x','vel_y','vel_u','vel_v','locationX','locationY'});
        for iFns = 1:length(fns)
            Data.(fns{iFns})(:,~Data.exist_stat,:) = NaN;
        end
    end
end

%% add dimension information to Data
% dimension information
dimensionsComment = {dims.name};
fn = char(intersect(fieldnames(Data),{'val','vel_x','val_x'}));
while ~isempty(fn) && ndims(Data.(fn)) < numel(dimensionsComment)
    dimensionsComment(end) = [];
end

% add to Data-struct
dimensionsComment = sprintf('%s,',dimensionsComment{:});
Data.dimensions = ['[' dimensionsComment(1:end-1) ']'];

%% Chlorinity  requested than convert salinity to chlorinity
if strcmpi(varNameInput,'chl')
    Data.val = 1000.*saco_convert(Data.val,27); % 1000: from g/kg to mg/l
end

%% Remove 0 time at end of file (sometimes written after crash)
if isfield(Data,'times')
    idDel = find(diff(Data.times)<0)+1;
    Data.times(idDel:end) = [];
    if isfield(Data,'val')
        Data.val(idDel:end,:,:) = [];
    elseif isfield('Data','vel_x')
        Data.vel_x(idDel:end,:,:) = [];
        Data.vel_y(idDel:end,:,:) = [];
        Data.vel_mag(idDel:end,:,:) = [];
        Data.vel_dir(idDel:end,:,:) = [];
    end
end

%% Fill output struct
Data.OPT               = OPT;
Data.OPT.inputFile     = inputFile;

if nargout==1
    varargout{1} = Data;
end

end

function Data = EHY_getmodeldata_zcen_int(inputFile,stat_name,modelType,OPT)
%% temp fix for incorrect z-coordinates in dfm

Data_wl       = EHY_getmodeldata(inputFile,stat_name,modelType,OPT,'varName','wl');
Data_zcen_cen = EHY_getmodeldata(inputFile,stat_name,modelType,OPT,'varName','zcen_cen');
gridInfo      = EHY_getGridInfo(inputFile,{'layer_model','no_layers'},'disp',0);

Data = Data_zcen_cen;
Data.val = NaN*Data.val;
Data.OPT.varName = 'zcen_int';

% short names
no_lay = gridInfo.no_layers;
wl     = Data_wl.val;
cen    = Data_zcen_cen.val;
% int is going to be Data.val
int    = NaN(size(Data.val)+[0 0 1]);

if strcmp(gridInfo.layer_model,'sigma-model')
    int(:,:,no_lay+1) = wl;
    for i_lay = no_lay:-1:1
        int(:,:,i_lay) = int(:,:,i_lay + 1) -2*(int(:,:,i_lay + 1) - cen(:,:,i_lay));
    end
    
elseif strcmp(gridInfo.layer_model,'z-model')
    
    % fix for DFM z-layer models: non-active layers have value of top layer
    nT = size(cen,1); %no_times
    if nT<1
        error('Hard to determine changing surface layer over time, when only one timestep is requested')
    end
    nS = size(cen,2); %no_stations
    nZ = size(cen,3); %no_z-layers
    for iS = 1:nS % stations
        zloc_cen_stat(1:nT,1:nZ) = squeeze(cen(:,iS,:));
        surface_layer = 0;
        for iZ = 1:nZ %z-layers
            zloc = squeeze(zloc_cen_stat(:,iZ));
            dzloc = diff(zloc);
            if sum(dzloc)==0 && surface_layer == 0
                logi(:,iS,iZ) = false(size(zloc));
            elseif ~(sum(dzloc) == 0) && (surface_layer == 0)
                logi(:,iS,iZ) = false(size(zloc));
                surface_layer = 1;
                dzloc_last_active_layer = dzloc;
            elseif ~(sum(dzloc - dzloc_last_active_layer) == 0)
                %the water surface changes z-layer over time
                logi(:,iS,iZ) = [false; (dzloc == dzloc_last_active_layer)];
                dzloc_last_active_layer = dzloc;
            elseif sum(dzloc - dzloc_last_active_layer) == 0
                % the water surface does not reach the next z-layer,
                %therefore for this and all the next layers: set to NaN
                for iZleft = iZ:nZ
                    logi(:,iS,iZleft) = true(size(zloc));
                end
                break %stop looping over rest of layers
            end
        end
    end
    % set top layers to NaNs
    cen(logi) = NaN;
    
    % reconstruct interfaces based on water level and centers
    for iT = 1:size(cen,1) % time
        for iS = 1:size(cen,2) % stations
            topActiveLayerNr = min([find(isnan(squeeze(cen(iT,iS,:))),1)-1 no_lay]);
            int(iT,iS,(topActiveLayerNr+1):(no_lay+1)) = NaN; % above active layer = NaN
            int(iT,iS,(topActiveLayerNr+1)) = wl(iT,iS); % active layer interface = water level
            for i_lay=topActiveLayerNr:-1:1 % layers below, reconstruct
                int(iT,iS,i_lay) = int(iT,iS,i_lay + 1) -2*(int(iT,iS,i_lay + 1) - cen(iT,iS,i_lay));
            end
            % In a z-layer model, the lowest interface can be deeper than the
            % bed level (keepzlayeringatbed =1 )
        end
    end
    
end

Data.val = int;
Data.Zcen_cen = cen;
Data.Zcen_int = int;

end
