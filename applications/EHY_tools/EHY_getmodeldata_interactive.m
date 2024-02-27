function varargout = EHY_getmodeldata_interactive
%% EHY_getmodeldata_interactive
%
% Interactive retrieval of model data using EHY_getmodeldata
% Example: Data = EHY_getmodeldata_interactive
%
% created by Julien Groenenboom, January 2018
%
%%

% outputFile
disp('Open the model output file')
[filename, pathname] = uigetfile('*.*','Open the model output file');
if isnumeric(filename); disp('EHY_getmodeldata_interactive stopped by user.'); return; end

% outputfile
outputfile = [pathname filename];
modelType = EHY_getModelType(outputfile);
if isempty(modelType)
    % Automatic procedure failed
    disp('Automatic procedure failed. Please provide input manually.')
    % modelType
    modelTypes = {'Delft3D FM','dfm';...
        'Delft3D 4','d3d';...
        'SIMONA','simona';...
        'SOBEK3','sobek3';...
        'SOBEK3_new','sobek3_new';...
        'IMPLIC','implic';
        'netCDF','nc'};
    option=listdlg('PromptString','Choose model type:','SelectionMode','single','ListString',...
        modelTypes(:,1),'ListSize',[300 100]);
    if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    modelType = modelTypes{option,2};
end

% varName
[variables,varAndDescr] = EHY_variablesOnFile(outputfile,modelType);
if EHY_isSFINCS(outputfile); lia = ismember(variables,{'inp','crs'}); variables(lia) = []; varAndDescr(lia) = []; end
option = listdlg('PromptString','What kind of data do you want to load?','SelectionMode','single','ListString',...
    varAndDescr,'ListSize',[500 600]);
if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
OPT.varName = variables{option};

[OPT.varName,varNameInput] = EHY_nameOnFile(outputfile,OPT.varName);
if strcmp(OPT.varName,'noMatchFound')
    error(['Requested variable (' varNameInput ') not available in model output'])
end

%% check which dimensions/info is needed from user
[~,dimsInd] = EHY_getDimsInfo(outputfile,OPT,modelType);
    
%% get required input from user
if ~isempty(dimsInd.time)
    datenums = EHY_getmodeldata_getDatenumsFromOutputfile(outputfile);
    if length(datenums)>1
        option = inputdlg({['Want to specifiy a certain output period? (Default: all data)' newline newline 'Start date [dd-mmm-yyyy HH:MM]'],'End date   [dd-mmm-yyyy HH:MM]'},'Specify output period',1,...
            {datestr(datenums(1)),datestr(datenums(end))});
        if ~isempty(option)
            if ~strcmp(datestr(datenums(1)),option{1}) || ~strcmp(datestr(datenums(end)),option{2})
                OPT.t0 = option{1};
                OPT.tend = option{2};
            end
        else
            disp('EHY_getmodeldata_interactive was stopped by user');return;
        end
    end
end

if ~isempty(dimsInd.stations)
    stationNames = cellstr(EHY_getStationNames(outputfile,modelType,'varName',OPT.varName));
    option=listdlg('PromptString','From which station would you like you to load the data? (Use CTRL to select multiple stations)','ListString',...
        stationNames,'ListSize',[500 200]);
    if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return; end
    stat_name=stationNames(option);
else
    stat_name='';
end

if ~isempty(dimsInd.layers)
    gridInfo = EHY_getGridInfo(outputfile,{'no_layers'});
    if gridInfo.no_layers>1
        optionTxt = {'All 3D-data','From 1 specific model layer','At a certain reference level'};
        option = listdlg('PromptString',{'Do you want to load:'},'SelectionMode','single','ListString',...
            optionTxt,'ListSize',[300 50]);
        if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return;
        elseif option == 1 % all 3D-data
            OPT.layer = 0;
        elseif option == 2 % Specific model layer
            nol = num2str(gridInfo.no_layers);
            OPT.layer = cell2mat(inputdlg(['Layer nr (1-' nol '):'],'',1,{nol}));
        elseif option == 3 % Certain reference level
            option = listdlg('PromptString',{'Referenced to:'},'SelectionMode','single','ListString',...
                {'Model reference level','Water level','Bed level'},'ListSize',[300 50]);
            if isempty(option); disp('EHY_getmodeldata_interactive was stopped by user');return;
            elseif option == 2 % Water level
                OPT.zRef = 'wl';
            elseif option == 3 % Bed level
                OPT.zRef = 'bed';
            end
            OPT.z = cell2mat(inputdlg('height (m) from ref. level (pos. up)','',1,{'0'}));
        end
    end
end

%%
extraText = '';
if exist('OPT','var')
    fn = fieldnames(OPT);
    for iF = 1:length(fn)
        if ischar(OPT.(fn{iF}))
            extraText = [extraText ',''' fn{iF} ''',''' OPT.(fn{iF}) ''''];
        elseif isnumeric(OPT.(fn{iF}))
            extraText = [extraText ',''' fn{iF} ''',' num2str(OPT.(fn{iF}))];
        end
    end
end

if ~isempty(stat_name)
    stations=strtrim(sprintf('''%s'',',stat_name{:}));
    stations=['{' stations(1:end-1) '}'];
else
    stations='''''';
end

if EHY_isSFINCS(outputfile); modelType = 'SFINCS'; end
disp([newline 'Note that next time you want to get this data, you can also use:'])
disp(['<strong>Data = EHY_getmodeldata(''' outputfile ''',' stations ',''' modelType '''' extraText ');</strong>' ])

disp('start retrieving the data...')
if ~exist('OPT','var') || isempty(fieldnames(OPT))
    Data = EHY_getmodeldata(outputfile,stat_name,modelType);
else
    Data = EHY_getmodeldata(outputfile,stat_name,modelType,OPT);
end

disp('Finished retrieving the data!')
assignin('base','Data',Data);
open Data
disp('Variable ''Data'' created by EHY_getmodeldata_interactive')

%% output
if nargout == 1
    Data.OPT.outputfile = outputfile;
    varargout{1} = Data;
end
