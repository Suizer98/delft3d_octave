function cosmos_runMainLoop_cyclones(hObject, eventdata)

% Clear data, close hidden windows etc.
disp('Clearing memory ...');
ff=findobj(0,'type','figure','Visible','off');
if ~isempty(ff)
    close(ff);
end
fclose all;
figs=findall(0,'Type','figure');
for i=1:length(figs)
    name=get(figs(i),'Name');
    if ~strcmpi(name,'CoSMoS')
        close(figs(i));
    end 
end

hm=guidata(findobj('Tag','OMSMain'));

disp('Start main loop ...');

hm.cycStr=[datestr(hm.cycle,'yyyymmdd') '_' datestr(hm.cycle,'HH') 'z'];

%% Read cycle info
cycledir=[hm.scenarioDir 'cyclelist' filesep];
if ~exist(cycledir,'dir')
    mkdir(cycledir);
end
cyclefile=[cycledir hm.cycStr '.txt'];
if exist(cyclefile,'file')
    % This cycle has already been started before
    % Read cycle text file to determine catchup cycle and next cycle
    fid=fopen(cyclefile,'r');
    hm.catchupCycle=datenum(fgetl(fid),'yyyymmdd HHMMSS');
    hm.nextCycle=datenum(fgetl(fid),'yyyymmdd HHMMSS');
    fclose(fid);

else
    % First time this cycle is run
    % Determine catchup cycle and next cycle and write to file
    % Check if we're playing catch-up
    if hm.catchUp
        hm.catchupCycle=rounddown(now-hm.delay/24,hm.runInterval/24);
    else
        hm.catchupCycle=hm.cycle;
    end
    hm.nextCycle=hm.catchupCycle+hm.runInterval/24;
    fid=fopen(cyclefile,'wt');
    fprintf(fid,'%s\n',datestr(hm.catchupCycle,'yyyymmdd HHMMSS'));
    fprintf(fid,'%s\n',datestr(hm.nextCycle,'yyyymmdd HHMMSS'));
    fclose(fid);
end

%% Reading data
disp('Reading models ...');
set(hm.textMainLoopStatus,'String','Status : Reading models ...');drawnow;

hm=cosmos_readMeteo(hm);
hm=cosmos_readOceanModels(hm);
hm=cosmos_readParameters(hm);
hm=cosmos_readContinents(hm);
hm=cosmos_readModels(hm);

%% Time Management
hm.NCyc=hm.NCyc+1;

set(hm.editCycle,'String',datestr(hm.cycle,'yyyymmdd HHMMSS'));

%% Set initial durations and what needs to be done for each model
for i=1:hm.nrModels
    hm.models(i).status='waiting';
    hm.models(i).runSimulation=hm.runSimulation;
    hm.models(i).extractData=hm.extractData;
    hm.models(i).DetermineHazards=hm.DetermineHazards;
    hm.models(i).runPost=hm.runPost;
    hm.models(i).makeWebsite=hm.makeWebsite;
    hm.models(i).uploadFTP=hm.uploadFTP;
    hm.models(i).archiveInput=hm.archiveInput;
    hm.models(i).simStart=datestr(now);
    hm.models(i).simStop=datestr(now);
    hm.models(i).runDuration=0;
    hm.models(i).moveDuration=0;
    hm.models(i).processDuration=0;
    hm.models(i).plotDuration=0;
    hm.models(i).extractDuration=0;
    hm.models(i).uploadDuration=0;
end

%% Check finished models
flist=dir([hm.scenarioDir 'joblist' filesep 'finished.' datestr(hm.cycle,'yyyymmdd.HHMMSS') '.*']);
if ~isempty(flist)
    for i=1:length(flist)
        mdl=flist(i).name(26:end);
        nr=findstrinstruct(hm.models,'name',mdl);
        if ~isempty(nr)
            hm.models(nr).status='finished';
            hm.models(nr).runSimulation=0;
        end
    end
end

for i=1:hm.nrModels
    if hm.models(i).priority==0
        hm.models(i).runSimulation=0;
    end
end

%% Check which simulations (just the computing part) already ran
for i=1:hm.nrModels
    if strcmpi(hm.models(i).status,'waiting') && hm.models(i).runSimulation==0 && hm.models(i).priority>0
        hm.models(i).status='simulationfinished';
    end
end

% %% Check which simulations inside the job dir have finished, so that
% %% model loop does not try to run them
% [hm,finishedList]=cosmos_checkForFinishedSimulations(hm);
% for i=1:length(finishedList)
%     hm.models(finishedList(i)).status='simulationfinished';
% end

%% Start and stop times
disp('Getting start and stop times ...');
set(hm.textModelLoopStatus,'String','Status : Getting start and stop times ...');drawnow;
hm=cosmos_getStartStopTimes(hm);
disp('Finished getting start and stop times');

%% Determine time zones
hm=cosmos_determineTimeZones(hm);

%% Update, commit and upload scenarios.xml
if hm.makeWebsite
    cosmos_updateScenariosDotXML(hm);
end

%% Meteo
hm.getMeteo=get(hm.toggleGetMeteo,'Value');
if hm.getMeteo
    set(hm.textModelLoopStatus,'String','Status : Getting meteo data ...');drawnow;
    cosmos_getMeteoData(hm);
end

%% Ocean Model data
if hm.getOceanModel
    set(hm.textModelLoopStatus,'String','Status : Getting ocean model data ...');drawnow;
    cosmos_getOceanModelData(hm);
end

%% Predictions and Observations
if get(hm.toggleGetObservations,'Value')
    set(hm.textModelLoopStatus,'String','Status : Getting observations ...');drawnow;
    cosmos_getObservations(hm);
    set(hm.textModelLoopStatus,'String','Status : Making predictions ...');drawnow;
    cosmos_getPredictions(hm);
end

%% Restart times (times to generate restart files)
hm=cosmos_getRestartTimes(hm);

%% Run model loop (start in 5 seconds)
starttime=now+5/86400;
t = timer;
set(t,'ExecutionMode','fixedRate','BusyMode','drop','period',5);
set(t,'TimerFcn',{@cosmos_runModelLoop},'Tag','ModelLoop');
startat(t,starttime);
set(hm.textModelLoopStatus,'String','Status : active');drawnow;

set(hm.textMainLoopStatus,'String','Status : running');drawnow;

guidata(findobj('Tag','OMSMain'),hm);
