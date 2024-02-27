function [Data,stationNrNoNan] = EHY_getRequestedStations(fileInp,requestedStations,modelType,varargin)
% Gets the subset of requested stations out of the list of available stations
OPT.varName = 'wl';
OPT         = setproperty(OPT,varargin);
varName     = OPT.varName;

if ~exist('modelType','var')
    modelType=EHY_getModelType(fileInp);
    if isempty(modelType)
        error('Could not determine modelType, please specify the modelType yourself');
    end
end

%% no requestedStations specified, all stations, otherwise, requestedStations is a cell array of string(s)
if ~isempty(requestedStations)
    if ischar(requestedStations)
        requestedStations = cellstr(requestedStations);
    end
end

%% Get station names
Data.stationNames = EHY_getStationNames(fileInp,modelType,'varName',varName);

%% No station name specified, get data from all stations
if isempty(requestedStations)
    requestedStations = Data.stationNames;
elseif strcmp(modelType,'delwaq')
    for iS = 1:length(requestedStations)
        S = regexp(Data.stationNames, regexptranslate('wildcard',requestedStations{iS}));
        requestedStations{iS} = Data.stationNames{find(~cellfun(@isempty,S),1,'first')};
    end
end
if size(requestedStations,1)<size(requestedStations,2); requestedStations=requestedStations'; end
Data.requestedStations=requestedStations;

%% Determine station numbers of the requested stations
stationNr(1:length(requestedStations),1)=NaN;
for i_stat = 1:length(requestedStations)
    if 1
         nr_stat  = get_nr(strrep(Data.stationNames,' ',''),strrep(requestedStations{i_stat},' ',''));
    else
    nr_stat  = get_nr(Data.stationNames,requestedStations{i_stat});
    end
    if isempty(nr_stat)
        Data.exist_stat(i_stat,1) = false;
        disp(['Station : ' requestedStations{i_stat} ' does not exist']);
    elseif length(nr_stat)>=1
        stationNr      (i_stat,1) = nr_stat(1);
        Data.exist_stat(i_stat,1) = true;
    elseif length(nr_stat)>= 2
        disp(['Station : ' requestedStations{i_stat} ' was found ' num2str(length(nr_stat)) ' times, using first one from obs file']);
    end
end
stationNrNoNan=stationNr(~isnan(stationNr));