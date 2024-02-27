function cosmos

delete(timerfind);

warning('off','MATLAB:hg:ColorSpec_None');

hm=cosmos_readConfigFile;
hm=cosmos_readScenario(hm,'first');

makedir([hm.scenarioDir 'joblist']);
makedir([hm.scenarioDir 'cyclelist']);

% Read all data
wb = waitbox('Loading tide database ...');
hm=getTideStations(hm);
close(wb);

wb = waitbox('Loading observations database ...');
hm=getObservationStations(hm);
close(wb);

hm.mainWindow=MakeNewWindow('CoSMoS',[750 500]);

set(hm.mainWindow,'CloseRequestFcn',@closeOMS);
set(hm.mainWindow,'Tag','OMSMain');

hm.runSimulation=1;
hm.extractData=1;
hm.DetermineHazards=1;
hm.runPost=1;
hm.makeWebsite=1;
hm.uploadFTP=1;
hm.archiveInput=0;
hm.catchUp=0;

hm.NCyc=0;

hm=MakeGUIMainLoop(hm);
hm=MakeGUIModelLoop(hm);

guidata(hm.mainWindow,hm);

%%
function closeOMS(src,evnt)
delete(timerfind);
fclose all;
closereq;
