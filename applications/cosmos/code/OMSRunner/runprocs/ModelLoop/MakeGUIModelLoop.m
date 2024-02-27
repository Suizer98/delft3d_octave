function hm=MakeGUIModelLoop(hm)

%% Model Loop

uipanel('Title','Model Loop','Units','pixels','Position',[230 20 500 460]);

hm.toggleRunSimulation = uicontrol(gcf,'Style','checkbox','Position',[240  180 120  25],'String','Run Simulation','backgroundColor',[0.8 0.8 0.8]);
set(hm.toggleRunSimulation,'Value',hm.runSimulation);

hm.toggleExtractData = uicontrol(gcf,'Style','checkbox','Position',[240  160 120  25],'String','Extract Data','backgroundColor',[0.8 0.8 0.8]);
set(hm.toggleExtractData,'Value',hm.extractData);

hm.toggleDetermineHazards = uicontrol(gcf,'Style','checkbox','Position',[240  140 120  25],'String','Determine Hazards','backgroundColor',[0.8 0.8 0.8]);
set(hm.toggleDetermineHazards,'Value',hm.DetermineHazards);

hm.toggleRunPost = uicontrol(gcf,'Style','checkbox','Position',[240  120 120  25],'String','Run Post-Processing','backgroundColor',[0.8 0.8 0.8]);
set(hm.toggleRunPost,'Value',hm.runPost);

hm.toggleMakeWebsite = uicontrol(gcf,'Style','checkbox','Position',[240 100 120  25],'String','Make Website','backgroundColor',[0.8 0.8 0.8]);
set(hm.toggleMakeWebsite,'Value',hm.makeWebsite);

hm.toggleUploadFTP = uicontrol(gcf,'Style','checkbox','Position',[240  80 120  25],'String','Upload FTP','backgroundColor',[0.8 0.8 0.8]);
set(hm.toggleUploadFTP,'Value',hm.uploadFTP);

hm.toggleArchiveInput = uicontrol(gcf,'Style','checkbox','Position',[240  60 120  25],'String','Archive Input','backgroundColor',[0.8 0.8 0.8]);
set(hm.toggleArchiveInput,'Value',hm.archiveInput);

hm.pushStartModelLoop = uicontrol(gcf,'Style','pushbutton','Position',[650  30 70  25],'String','Start','enable','off');
hm.pushStopModelLoop  = uicontrol(gcf,'Style','pushbutton','Position',[570  30 70  25],'String','Stop','enable','off');

hm.textModelLoopStatus = uicontrol(gcf,'Style','text','Position',[240  30  300  20],'String','Status : inactive','HorizontalAlignment','left','backgroundColor',[0.8 0.8 0.8]);

set(hm.pushStartModelLoop,  'Callback',{@PushStartModelLoop_Callback});
set(hm.pushStopModelLoop,   'Callback',{@PushStopModelLoop_Callback});

set(hm.toggleRunSimulation,  'Callback',{@ToggleRunSimulation_Callback});
set(hm.toggleExtractData,    'Callback',{@ToggleExtractData_Callback});
set(hm.toggleDetermineHazards,    'Callback',{@ToggleDetermineHazards_Callback});
set(hm.toggleRunPost,        'Callback',{@ToggleRunPost_Callback});
set(hm.toggleMakeWebsite,    'Callback',{@ToggleMakeWebsite_Callback});
set(hm.toggleUploadFTP,      'Callback',{@ToggleUploadFTP_Callback});
set(hm.toggleArchiveInput,   'Callback',{@ToggleArchiveInput_Callback});

guidata(hm.mainWindow,hm);

%%
function PushStartModelLoop_Callback(hObject,eventdata)

hm=guidata(findobj('Tag','OMSMain'));

StartModelLoop(hm);

%%
function PushStopModelLoop_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
t = timerfind('Tag', 'ModelLoop');
delete(t);
set(hm.textModelLoopStatus,'String','Status : inactive');drawnow;

%%
function ToggleRunSimulation_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.runSimulation=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleExtractData_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.extractData=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleDetermineHazards_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.DetermineHazards=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleRunPost_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.runPost=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleMakeWebsite_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.makeWebsite=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleUploadFTP_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.uploadFTP=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleArchiveInput_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
hm.archiveInput=get(hObject,'Value');
guidata(findobj('Tag','OMSMain'),hm);
