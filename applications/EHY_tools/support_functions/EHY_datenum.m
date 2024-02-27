function daten = EHY_datenum(date,format)
% Similar function as MATLABs datenum. However, when 'format' is not provided
% this function will make an educated guess.
%
% daten       datenum [double]
% date        datestr [char]
% format      format of input, e.g. 'yyyymmdd' [char]
%
% Example1:   daten = EHY_datenum('20200101')
% Example2:   daten = EHY_datenum('20200101','yyyymmdd')
% Example3:   daten = EHY_datenum('202001011500')
% Example4:   daten = EHY_datenum(202001011500) % numeric value instead of char
%
% support function of the EHY_tools - E: Julien.Groenenboom@Deltares.nl
%%

%% check format
if iscell(date) && numel(date) == 1
    date = char(date);
end
if ~ischar(date)
    if date > datenum(1900,1,1) && date < datenum(2100,1,1)
        daten = date; % date is already a MATLAB datenum
        return
    end
    warning(['Input provided (' num2str(date) ') will be treated as a char (i.e. ''' num2str(date) ''') instead of a numeric value'])
    date = num2str(date);
end

% deal with 1950-01-01T00:00:00Z
if strcmpi(date(end),'Z')
    date = date(1:end-1); 
end
date = strrep(upper(date),'T',' ');

if length(date) == 8
    format = 'yyyymmdd';
elseif length(date) == 10
    format = 'yyyymmddHH';
elseif length(date) == 12 && all(~(isspace(date)))
    format = 'yyyymmddHHMM';
elseif length(date) == 13
    format = 'yyyymmdd HHMM';
elseif length(date) == 14 && all(~(isspace(date)))
    format = 'yyyymmddHHMMSS';
elseif length(date) == 15 && isspace(date(9))
    format = 'yyyymmdd HHMMSS';
elseif length(date) == 19 && all(ismember(date([5 8]),'-')) && all(ismember(date([14 17]),':'))
    format = 'yyyy-mm-dd HH:MM:SS';
elseif length(date) == 20 && all(ismember(date([5 8]),'-')) && all(ismember(date([14 17]),':')) ...
        && strcmp(date(19),'.') % mistake in creation of ERA5-meteo-files
    date = date(1:16);
    format = 'yyyy-mm-dd HH:MM';
elseif all(ismember(date([5 8]),'-')) && all(ismember(date([14 17]),':'))
    date = date(1:19);
    format = 'yyyy-mm-dd HH:MM:SS'; % '1970-01-01 00:00:00.......'
elseif all(ismember(date([5 7]),'-')) && all(ismember(date([13 16]),':'))
    format = 'yyyy-m-dd HH:MM:SS'; % '2021-5-30 00:00:00'
end

%% Determine daten
if exist('format','var') && ~isempty(format)
    daten = datenum(date,format);
else
    error(['Could not convert ' date ' to MATLABs datenum format'])
end
