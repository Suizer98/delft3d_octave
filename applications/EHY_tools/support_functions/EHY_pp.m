%% EHY_pp_wl General EHY postprocessing script
function EHY_pp(varargin)

clearvars -except varargin;
oetsettings('quiet');

%% Initialisation
Info           = inifile('open',varargin{1});
ListOfChapters = inifile('chapters',Info);

% General information
modelType      = inifile('getstring',Info,'General'  ,'modelType   ');
if strcmp(modelType,'dflow-fm') modelType = 'dflowfm'; end

runid          = inifile('getstring',Info,'General'  ,'runid       ');
sim_dir        = inifile('getstring',Info,'General'  ,'sim_dir     ');
try
    fig_dir    = inifile('getstring',Info,'General'  ,'fig_dir     ');
catch
    fig_dir    = [sim_dir filesep runid '_figs'];
end
meas_dir       = inifile('getstring',Info,'General'  ,'meas_dir    ');

try
    mup_temp   = inifile('getstring',Info,'General'  ,'mup_temp    ');
end

try
    time_zone  =  str2num(inifile('getstring',Info,'General'  ,'time_zone   '));
catch
    time_zone  = 0.;
end
try
    varName    =  inifile('getstring',Info,'General'  ,'varName     ');
catch
    varName    = 'wl';
end
try
    Column     =  str2num(inifile('getstring',Info,'General'  ,'Column      '));
catch
    Column     = 3;
end
try
    highLow_tmp =  inifile('getstring',Info,'General'  ,'highLow     ');
    if ~strcmpi(highLow_tmp,'false')
        highLow = true;
    else
        highLow = false;
    end
catch
    highLow    = true;
end


% Define periods
ch_periods = find(~cellfun(@isempty,strfind(ListOfChapters,'Periods')));
no_periods = size(Info.Data{ch_periods,2},1);
for i_period = 1: no_periods
    hlp = Info.Data{ch_periods,2}{i_period,2};
    index = strfind(hlp,'''');
    Periods{i_period,1} = hlp(index(1) + 1:index(2) - 1);
    Periods{i_period,2} = hlp(index(3) + 1:index(4) - 1);
end

% Plot the Periods?
ch_periods = find(~cellfun(@isempty,strfind(ListOfChapters,'Plot_Period')));
hlp        = size(Info.Data{ch_periods,2},1);
if hlp ~= no_periods error(['Plot_Period inconsistent with Periods in ' varargin{1}]);end
for i_period = 1: no_periods
    hlp                = Info.Data{ch_periods,2}{i_period,2};
    plot_per(i_period) = str2num(hlp);
end

% Stations
ch_stations = find(~cellfun(@isempty,strfind(ListOfChapters,'Stations')));
no_stat     = size(Info.Data{ch_stations,2},1);
for i_stat = 1: no_stat
    stations_sim{i_stat} = Info.Data{ch_stations,2}{i_stat,2};
end

% Longnames
ch_stations = find(~cellfun(@isempty,strfind(ListOfChapters,'LongNames')));
hlp        = size(Info.Data{ch_stations,2},1);
if hlp ~= no_stat error(['LongNames inconsistent with Stations in ' varargin{1}]);end
for i_stat = 1: no_stat
    stations_fullname{i_stat} = Info.Data{ch_stations,2}{i_stat,2};
end

% ShortNames
ch_stations = find(~cellfun(@isempty,strfind(ListOfChapters,'ShortNames')));
hlp        = size(Info.Data{ch_stations,2},1);
if hlp ~= no_stat error(['ShortNames inconsistent with Stations in ' varargin{1}]);end
for i_stat = 1: no_stat
    stations_shortname{i_stat} = Info.Data{ch_stations,2}{i_stat,2};
end

% Measurements
if ~strcmpi(lower(meas_dir),'opendap')
    ch_stations = find(~cellfun(@isempty,strfind(ListOfChapters,'Measurements')));
    hlp        = size(Info.Data{ch_stations,2},1);
    if hlp ~= no_stat error(['Measurements inconsistent with Stations in ' varargin{1}]);end
    for i_stat = 1: no_stat
        stations_tek{i_stat} = [meas_dir filesep Info.Data{ch_stations,2}{i_stat,2}];
    end
end

% Muppet template files
ch_mupFile = [];
ch_mupFile = find(~cellfun(@isempty,strfind(ListOfChapters,'mupFiles')));
for i_stat = 1: no_stat
    if ~isempty(ch_mupFile)
        mupFile{i_stat} = Info.Data{ch_mupFile,2}{i_stat,2};
    else
        mupFile{i_stat} = mup_temp;
    end
end

% Tidal analyses
ch_tide  = find(~cellfun(@isempty,strfind(ListOfChapters,'Tide')));
if ~isempty(ch_tide)
    tide = true;

    % Start and stop time
    hlp                 = inifile('get',Info,'Tide'  ,'Period      ');
    index               = strfind(hlp,'''');
    tide_start          = hlp(index(1) + 1:index(2) - 1);
    tide_stop           = hlp(index(3) + 1:index(4) - 1);

    % Constituents
    hlp                 = inifile('get',Info,'Tide'  ,'Constituents');
    i_cons              = 1;
    Constituents{i_cons} = '';
    for i_char = 1: length(hlp)
        if ~strcmp(hlp(i_char:i_char),' ');
            Constituents{i_cons} = [Constituents{i_cons} hlp(i_char:i_char)];
        elseif ~strcmp(hlp(i_char-1:i_char-1),' ');
            i_cons               = i_cons + 1;
            Constituents{i_cons} = '';
        end
    end

    % Latitude
    latitude    = inifile('get',Info,'Tide'  ,'Latitude');
else
    tide = false;
end

%% Start postprocessing, first create output directories
if exist(fig_dir,'dir') rmdir(fig_dir,'s'); end
mkdir (fig_dir);

% Read computational data for requested stations
inputFile = EHY_simdirRunIdAndModelType2outputfile(sim_dir  ,runid       ,modelType);
Data      = EHY_getmodeldata                      (inputFile,stations_sim,modelType,'varName',varName);

% Cycle over the periods
for i_per = 1: size(Periods,1)
    %% Initialise the statistics
    for i_stat = 1: no_stat
        Statistics(i_stat) = EHY_pp_statistics([]             ,[]               , ...
                                            'times'        ,[]               , ...
                                            'tide'         , true            , ...
                                            'extremes'     , 2               ) ;
    end

    %% Create directory for the Figures for each seperate period
    per_dir   = [fig_dir filesep 'Period_' num2str(i_per,'%3.3i')];
    mkdir (per_dir)

    %% Cycle over the requested stations
    for i_stat = 1: no_stat
        if Data.exist_stat(i_stat)
            display(stations_sim{i_stat});

            %% Get water level data for i_stat
            dattim_cmp = Data.times + time_zone/24.;
            wlev_cmp   = Data.val(:,i_stat);

            %% Read the measurement Data
            if ~strcmpi(lower(meas_dir),'opendap') && ~strcmpi(lower(stations_tek{i_stat}(end-6:end)),'opendap')
                try
                    % tekal files at specific location
                    INFO        = tekal('open',stations_tek{i_stat},'loaddata');
                    dates_meas  = num2str(INFO.Field(1).Data(:,1),'%8.8i');
                    times_meas  = num2str(INFO.Field(1).Data(:,2),'%6.6i');
                    dattim_meas = datenum([dates_meas(:,1:8) times_meas(:,1:6)],'yyyymmddHHMMSS');
                    wlev_meas   = INFO.Field(1).Data(:,Column);
                    wlev_meas(wlev_meas == 999.999) = NaN;     % Skip default values in measurement files
                catch
                    % nc files
                    dattim_meas = ncread(stations_tek{i_stat},'time') + datenum(1970,1,1);
                    wlev_meas   = ncread(stations_tek{i_stat},'sea_surface_height');
                end
                    
            else
                % try to get the data from opendap server, only works for dutch stations
                [dattim_meas,wlev_meas] = EHY_opendap('Parameter','waterhoogte','Station',stations_shortname{i_stat});
            end

            % only use data in selected period
            i_start = max(find(dattim_meas>datenum(Periods{i_per,1},'yyyymmdd  HHMMSS'),1,'first') - 1,1);
            i_stop  = find(dattim_meas>=datenum(Periods{i_per,2},'yyyymmdd  HHMMSS'),1,'first');
            dattim_meas = dattim_meas(i_start:i_stop);
            wlev_meas   = wlev_meas  (i_start:i_stop);
            
            
            if ~isempty(find(~isnan(wlev_meas)))
                [dattim_meas,wlev_meas] = FillGaps(dattim_meas,wlev_meas,'interval',120./1440.); % Fill with NaNs if interval between consequetive measurements is more than 2 hours
            end
            %% Determine shortest overlaping time span
            time_start    = max(dattim_cmp(1)  ,dattim_meas(1)  );
            time_start    = max(time_start,datenum(Periods{i_per,1},'yyyymmdd HHMMSS'));
            time_stop     = min(dattim_cmp(end),dattim_meas(end));
            time_stop     = min(time_stop,datenum(Periods{i_per,2},'yyyymmdd HHMMSS'));
            dattim_interp = time_start:10/1440:time_stop;

            %% Intepolate both measurement as simulation data to 10 min time interval
            wlev_cmp_interp     = interp1(dattim_cmp ,wlev_cmp        ,dattim_interp);
            [dattim_meas,index] = unique(dattim_meas);
            wlev_meas_interp    = interp1(dattim_meas,wlev_meas(index),dattim_interp);

            %% Write the simulation and measurement data to TEKAL TEK file
            file_tek = [per_dir filesep stations_shortname{i_stat} '_' runid '_' num2str(i_per,'%3.3i') '.tek'];
            fid      = fopen(file_tek,'w+');
            fprintf(fid,'* Simulation : %s \n',runid);
            fprintf(fid,'* Station    : %s \n',stations_shortname{i_stat});
            fprintf(fid,'* Column    1: Date \n');
            fprintf(fid,'* Column    2: Time \n');
            fprintf(fid,'* Column    3: Water level Computed\n');
            fprintf(fid,'* Column    4: Water level Measured\n');
            fprintf(fid,'* Column    5: Difference (Computed - Measured) \n');
            fprintf(fid,'WaterLevel \n');

            if length(dattim_interp) == 0
                fprintf(fid,'%5i %5i \n',1,5);
                fprintf(fid,'%16s  %12.6f %12.6f %12.6f \n',datestr(datenum(1900,0,0),'yyyymmdd  HHMMSS'),             ...
                    NaN, ...
                    NaN, ...
                    NaN    );
            else
                fprintf(fid,'%5i %5i \n',length(dattim_interp),5);
                for i_time = 1: length(dattim_interp)
                    fprintf(fid,'%16s  %12.6f %12.6f %12.6f \n',datestr(dattim_interp(i_time),'yyyymmdd  HHMMSS'),             ...
                        wlev_cmp_interp (i_time), ...
                        wlev_meas_interp(i_time), ...
                        wlev_cmp_interp (i_time) - wlev_meas_interp(i_time) );
                end
            end
            fclose (fid);

            %% Do statistics
            Statistics(i_stat) = EHY_pp_statistics(wlev_cmp_interp, wlev_meas_interp, ...
                'times'        , dattim_interp   , ...
                'tide'         , true            , ...
                'extremes'     , 2               ) ;

            str_biasrmse  = ['Bias = '   num2str(Statistics(i_stat).bias,'%6.3f') ' [m]'...
                ', Rmse = ' num2str(Statistics(i_stat).rmse,'%6.3f') ' [m]'];

            %% Plot simulation results
            if plot_per(i_per)
                copyfile      (mupFile{i_stat},[per_dir filesep 'temporary.mup']);
                substitute    ('**runid**'           ,runid                    ,[per_dir filesep 'temporary.mup']);
                substitute    ('**runid_name**'      ,simona2mdu_replacechar(runid,'_','-'),                ...
                    [per_dir filesep 'temporary.mup']);
                substitute    ('**station**'         ,stations_shortname{i_stat}     ,[per_dir filesep 'temporary.mup']);
                substitute    ('**station_nr**'      ,num2str(i_stat,'%2.2i')  ,[per_dir filesep 'temporary.mup']);
                substitute    ('**station_fullname**',stations_fullname{i_stat},[per_dir filesep 'temporary.mup']);
                substitute    ('**biasrmse**'        ,str_biasrmse             ,[per_dir filesep 'temporary.mup']);
                substitute    ('**Tstart**'          ,Periods{i_per,1}         ,[per_dir filesep 'temporary.mup']);
                substitute    ('**Tstop**'           ,Periods{i_per,2}         ,[per_dir filesep 'temporary.mup']);
                substitute    ('**Tstart2**'         ,Periods{i_per,1}(1:8)    ,[per_dir filesep 'temporary.mup']);
                substitute    ('**Tstop2**'          ,Periods{i_per,2}(1:8)    ,[per_dir filesep 'temporary.mup']);
                substitute    ('**Tper**'            ,num2str(i_per,'%3.3i')   ,[per_dir filesep 'temporary.mup']);

                orgdir = pwd;
                cd (per_dir);
                %             command = '"n:\Deltabox\Bulletin\ormondt\Muppet_v4.03\win64\muppet\bin\muppet4.exe" temporary.mup';
                %             system (command);
                muppet4('temporary.mup')
                copyfile('temporary.mup',[num2str(i_stat,'%2.2i') '_' stations_shortname{i_stat} '.mup']);
                delete  ([num2str(i_stat,'%2.2i') '_' stations_shortname{i_stat} '_' runid '_' Periods{i_per,1}(1:8) '-' Periods{i_per,2}(1:8)]);
                delete  ('temporary.mup');
                cd (orgdir);
            end
        end
    end

    %% Write statistics to xls files
    clear cell_arr
   
    %  Definition
    cell_arr{1,1}  = ['Simulation : ' runid];
    cell_arr{1,2}  = 'Bias [m]';
    cell_arr{1,3}  = 'RMSE [m]';
    cell_arr{1,4}  = 'Std  [m]';

    % values
    i_row = 1;
    for i_stat = 1: no_stat
        if Data.exist_stat(i_stat)
            i_row               = i_row + 1;
            cell_arr {i_row,1}  = stations_fullname{i_stat};
            cell_arr {i_row,2}  = Statistics(i_stat).bias;
            cell_arr {i_row,3}  = Statistics(i_stat).rmse;
            cell_arr {i_row,4}  = Statistics(i_stat).std;
        end
    end

    % Averages
    i_row             = i_row + 1;
    cell_arr{i_row,1}  = 'Gemiddeld';
    for i_col = 2: size(cell_arr,2)
        values                 = cell2mat(cell_arr(2:end-1,i_col));
        index                  = ~isnan(values);
        cell_arr{i_row,i_col}  = mean(values(index));
    end

    % Write to excel file
    colwidth      = [28 repmat(17,1,size(cell_arr,2) - 1)];
    format(1:4)   = {'.000'};
    
    xlsFile=strrep([fig_dir filesep runid '.xls'],[filesep filesep],[filesep]);
    xlswrite_report(xlsFile,cell_arr,[Periods{i_per,1}(1:8) ' - ' Periods{i_per,2}(1:8)], ...
        'colwidth'                   ,colwidth, ...
        'format'                     ,format  );
    
    % High and low water statistics
    if highLow
        clear cell_arr
        
        % Definition
        cell_arr{1,1}  = ['Simulation : ' runid];
        cell_arr{1,2}  = 'HW Bias [m]';
        cell_arr{1,3}  = 'HW RMSE [m]';
        cell_arr{1,4}  = 'timHW Bias [min]';
        cell_arr{1,5}  = 'timHW RMSE [min]';
        cell_arr{1,6}  = 'LW Bias  [m]';
        cell_arr{1,7}  = 'LW RMSE  [m]';
        cell_arr{1,8}  = 'timLW Bias [min]';
        cell_arr{1,9}  = 'timLW RMSE [min]';
        cell_arr{1,10} = 'difHW [m]';
        cell_arr{1,11} = 'timHW [min]';
        cell_arr{1,12} = 'difLW [m]';
        cell_arr{1,13} = 'timLW [min]';
        
        % values
        i_row = 1;
        for i_stat = 1: no_stat
            if Data.exist_stat(i_stat)
                i_row               = i_row + 1;
                cell_arr {i_row,1}  = stations_fullname{i_stat};
                cell_arr {i_row,2}  = Statistics(i_stat).hwlw(1).series_bias;
                cell_arr {i_row,3}  = Statistics(i_stat).hwlw(1).series_rmse;
                cell_arr {i_row,4}  = Statistics(i_stat).hwlw(1).time_series_bias;
                cell_arr {i_row,5}  = Statistics(i_stat).hwlw(1).time_series_rmse;
                cell_arr {i_row,6}  = Statistics(i_stat).hwlw(2).series_bias;
                cell_arr {i_row,7}  = Statistics(i_stat).hwlw(2).series_rmse;
                cell_arr {i_row,8}  = Statistics(i_stat).hwlw(2).time_series_bias;
                cell_arr {i_row,9}  = Statistics(i_stat).hwlw(2).time_series_rmse;
                cell_arr {i_row,10} = Statistics(i_stat).hwlw(1).diff;
                cell_arr {i_row,11} = Statistics(i_stat).hwlw(1).time_diff;
                cell_arr {i_row,12} = Statistics(i_stat).hwlw(2).diff;
                cell_arr {i_row,13} = Statistics(i_stat).hwlw(2).time_diff;
            end
        end
        
        % Averages
        i_row             = i_row + 1;
        cell_arr{i_row,1}  = 'Gemiddeld';
        for i_col = 2: size(cell_arr,2)
            cell_arr{i_row,i_col}  = mean(cell2mat(cell_arr(2:end-1,i_col)));
        end
        
        % Write to excel file
        colwidth      = [28 repmat(17,1,size(cell_arr,2) - 1)];
        format(1:2)   = {'.000'};
        format(3:4)   = {'0'};
        format(5:6)   = {'.000'};
        format(7:8)   = {'0'};
        format(9)     = {'.000'};
        format(10)    = {'0'};
        format(11)    = {'.000'};
        format(12)    = {'0'};
        
        xlsFile=strrep([fig_dir filesep runid '_hwlw.xls'],[filesep filesep],[filesep]);
        xlswrite_report(xlsFile,cell_arr,[Periods{i_per,1}(1:8) ' - ' Periods{i_per,2}(1:8)], ...
            'colwidth'                        ,colwidth, ...
            'format'                          ,format  );
    end
end

% Tidal analyses
if tide
    tba_file = [fig_dir filesep runid '_tba.xls'];
    tbb_file = [fig_dir filesep runid '_tbb.xls'];
    
    i_tide = 0;
    for i_stat = 1: no_stat
        if Data.exist_stat(i_stat)
            i_tide = i_tide + 1;
            dattim_cmp = Data.times + time_zone/24.;
            wlev_cmp   = Data.val(:,i_stat);
            
            % Read the measurement Data
            if ~strcmpi(lower(meas_dir),'opendap') && ~strcmpi(lower(stations_tek{i_stat}(end-6:end)),'opendap')
                % tekal files at specific location
                INFO        = tekal('open',stations_tek{i_stat},'loaddata');
                dates_meas  = num2str(INFO.Field.Data(:,1),'%8.8i');
                times_meas  = num2str(INFO.Field.Data(:,2),'%6.6i');
                dattim_meas = datenum([dates_meas(:,1:8) times_meas(:,1:6)],'yyyymmddHHMMSS');
                wlev_meas   = INFO.Field.Data(:,3);
            else
                % try to get the data from opendap server, only works for dutch stations
                [dattim_meas,wlev_meas] = EHY_opendap('Parameter','waterhoogte','Station',stations_shortname{i_stat});
                i_start = max(find(dattim_meas>datenum(tide_start,'yyyymmdd  HHMMSS'),1,'first') - 1,1);
                i_stop  = find(dattim_meas>=datenum(tide_stop,'yyyymmdd  HHMMSS'),1,'first');
                dattim_meas = dattim_meas(i_start:i_stop);
                wlev_meas   = wlev_meas  (i_start:i_stop);
            end
            
            if ~isempty(find(~isnan(wlev_meas)))
                [dattim_meas,wlev_meas] = FillGaps(dattim_meas,wlev_meas,'interval',120./1440.); % Fill with NaNs if interval between consequetive measurements is more than 2 hours
            end

            % Determine shortest overlaping time span
            time_start    = max(dattim_cmp(1)  ,dattim_meas(1)  );
            time_start    = max(time_start,datenum(tide_start,'yyyymmdd HHMMSS'));
            time_stop     = min(dattim_cmp(end),dattim_meas(end));
            time_stop     = min(time_stop,datenum(tide_stop,'yyyymmdd HHMMSS'));
            dattim_interp = time_start:10/1440:time_stop;

            % Intepolate both measurement as simulation data to 10 min time interval
            wlev_cmp_interp  = interp1(dattim_cmp ,wlev_cmp ,dattim_interp);
            wlev_meas_interp = interp1(dattim_meas,wlev_meas,dattim_interp);

            % Analyse the computational results
            Tide_cmp(i_tide) = t_tide(wlev_cmp_interp , 'interval', 10./60.    , 'latitude'  , latitude    , ...
                'rayleigh' ,Constituents, 'start time', time_start  , ...
                'synthesis',0           , 'error'     ,'wboot'      );
            % Analyse the measurements
            if ~isempty(find(~isnan(wlev_meas)))
                Tide_meas(i_tide)= t_tide(wlev_meas_interp, 'interval', 10./60.     , 'latitude'  , latitude    , ...
                    'rayleigh' ,Constituents, 'start time', time_start  , ...
                    'synthesis',0           , 'error'     ,'wboot'      );
            else
                Tide_meas(i_tide)              = Tide_cmp(i_tide);
                Tide_meas(i_tide).tidecon(:,:) = NaN;
            end
        end
    end

    % Write to output (xls) file
    EHY_tba(tba_file,runid,stations_fullname(Data.exist_stat),Tide_cmp,Tide_meas);
    EHY_tbb(tbb_file,runid,stations_fullname(Data.exist_stat),Tide_cmp,Tide_meas);
end


