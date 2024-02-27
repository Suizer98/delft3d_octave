function ModelManager

% Compile with: mcc -m -B sgl ModelManager.m

handles.modelManagerVersion='1.01';

%hm.modelDirectory='D:\work\OperationalModelSystem\OMSMain\';
hm=ReadOMSMainConfigFile;

hm.d3dpath=[getenv('D3D_HOME') '\' getenv('ARCH') '\'];

% hm=GetCoordinateSystems(hm);

hm.mainWindow=MakeNewWindow('ModelManager',[750 500]);
set(hm.mainWindow,'Tag','MainWindow');

hm=ReadModelsAndContinents(hm);
hm=ReadPredictionsAndObservations(hm);


guidata(hm.mainWindow,hm);

InitializeScreen;
