function DATA = nesthd_getSeriesFromBc(fileInp,itdate,varargin)

% Returns time series from a dhydro bc file
% order is the order of pli points specified in names
% times alway in minutes realtive to itdate
%
%% Initialise
OPT.names = {};
OPT       = setproperty(OPT,varargin);

%% Read the data either from bc file or previously generated map file
[~,name,~] = fileparts(fileInp);
if ~exist([name '.mat'])
   DATA_bc = dflowfm_io_extfile('read',fileInp);
   save([name '.mat'],'DATA_bc','-v7.3');
else
    warning(['Loading DATA from previously generated mat file: ' name '.mat']);
    load([name '.mat']);
end

%% Names not specified. generate a list of names from the bc file
if isempty(OPT.names)
    for i_bc = 1: length(DATA_bc)
        nr_key          = get_nr(DATA_bc(i_bc).Keyword.Name,'Name');
        OPT.names{i_bc} = DATA_bc(i_bc).Keyword.Value(nr_key);
    end
end

%% Get for all requested pli point names
for i_name = 1: length(OPT.names)
    
    DATA(i_name).Name  = OPT.names{i_name};
    
    % find the number of the series in the bc file
    for i_bc = 1 : length(DATA_bc)
         nr_key          = get_nr(DATA_bc(i_bc).Keyword.Name,'Name');
         if strcmp(DATA_bc(i_bc).Keyword.Value(nr_key),OPT.names{i_name})
             nr_bc = i_bc;
             break
         end
    end
    
    % Get time unit
    Name            = DATA_bc(nr_bc).Keyword.Name;
    Value           = DATA_bc(nr_bc).Keyword.Value;
    nr_entry        = get_nr(Value,'time') + 1;
    nr_pos          = strfind(Value{nr_entry},'since');
    itdate_bc       = datenum(strtrim(strrep(strrep(strrep(Value{nr_entry}(nr_pos + 5:end),' ',''),'-',''),':','')),'yyyymmddHHMMSS');
    if ~isempty(strfind(lower(Value{nr_entry}),'day'    )) fac =  1.0        ; end
    if ~isempty(strfind(lower(Value{nr_entry}),'hour'   )) fac = 24.0        ; end
    if ~isempty(strfind(lower(Value{nr_entry}),'minutes')) fac = 24.0*60.    ; end
    if ~isempty(strfind(lower(Value{nr_entry}),'seconds')) fac = 24.0*60.*60.; end
    
    % Vertical levels
    nr_entry         = get_nr(Name,'Vertical position type');
    if ~isempty(nr_entry) DATA(i_name).lev_type = Value(nr_entry);end
    nr_entry         = get_nr(Name,'Vertical position specification');
    if ~isempty(nr_entry) DATA(i_name).lev_dhydro       = cell2mat(Value(nr_entry));end
   
    % fill DATA with times and values
    DATA(i_name).times = itdate_bc + cell2mat(DATA_bc(nr_bc).values(:,1))/fac;
    no_times           = length (DATA(i_name).times);
    for i_time = 1: no_times
        DATA(i_name).value(i_time,:) = cell2mat(DATA_bc(nr_bc).values(i_time,2:end));
    end
end
