function hm=MakeGUIMainLoop(hm)

%% Main Loop

uipanel('Title','Main Loop','Units','pixels','Position',[20 20 200 460]);

hm.pushStartMainLoop = uicontrol(gcf,'Style','pushbutton','Position',[140  30 70  25],'String','Start');
hm.pushStopMainLoop  = uicontrol(gcf,'Style','pushbutton','Position',[ 60  30 70  25],'String','Stop');

hm.textCycle = uicontrol(gcf,'Style','text','Position',[30  426   70  25],'String','Cycle','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
hm.editCycle = uicontrol(gcf,'Style','edit','Position',[105  430 105  25],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1]);
set(hm.editCycle,'String',datestr(hm.cycle,'yyyymmdd HHMMSS'));

hm.textInterval = uicontrol(gcf,'Style','text','Position',[30  396  70  25],'String','Interval (h)','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
hm.editInterval = uicontrol(gcf,'Style','edit','Position',[105  400 105  25],'String',num2str(hm.runInterval),'HorizontalAlignment','right','BackgroundColor',[1 1 1]);

hm.textRunTime = uicontrol(gcf,'Style','text','Position',[30  366  70  25],'String','Run Time (h)','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
hm.editRunTime = uicontrol(gcf,'Style','edit','Position',[105  370 105  25],'String',num2str(hm.runTime),'HorizontalAlignment','right','BackgroundColor',[1 1 1]);

hm.textStopTime = uicontrol(gcf,'Style','text','Position',[30  336  70  25],'String','Stop Time','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
hm.editStopTime = uicontrol(gcf,'Style','edit','Position',[105  340 105  25],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1]);
set(hm.editStopTime,'String',datestr(hm.stoptime,'yyyymmdd HHMMSS'));

hm.textMode      = uicontrol(gcf,'Style','text','Position',[30  310  60  20],'String','Cycle Mode','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);
hm.toggleRunCont = uicontrol(gcf,'Style','radiobutton','Position',[90  310 105  25],'String','Continuous');
hm.toggleRunOnce = uicontrol(gcf,'Style','radiobutton','Position',[170  310 47  25],'String','Once');
if strcmpi(hm.cycleMode,'continuous')
    set(hm.toggleRunCont,'Value',1);
    set(hm.toggleRunOnce,'Value',0);
else
    set(hm.toggleRunCont,'Value',0);
    set(hm.toggleRunOnce,'Value',1);
end

hm.toggleCatchup = uicontrol(gcf,'Style','checkbox','Position',[30  280 180  25],'String','Catch Up','BackgroundColor',[0.8 0.8 0.8]);
set(hm.toggleCatchup,'Value',hm.catchUp);

hm.toggleGetMeteo = uicontrol(gcf,'Style','checkbox','Position',[30  230 180  25],'String','Get Meteo Data','BackgroundColor',[0.8 0.8 0.8]);
set(hm.toggleGetMeteo,'Value',hm.getMeteo);

hm.toggleGetObservations = uicontrol(gcf,'Style','checkbox','Position',[30  205 180  25],'String','Get Observations','BackgroundColor',[0.8 0.8 0.8]);
set(hm.toggleGetObservations,'Value',hm.getObservations);

hm.toggleGetOceanModelData = uicontrol(gcf,'Style','checkbox','Position',[30  180 180  25],'String','Get Ocean Model Data','BackgroundColor',[0.8 0.8 0.8]);
set(hm.toggleGetOceanModelData,'Value',hm.getOceanModel);

hm.textMainLoopStatus = uicontrol(gcf,'Style','text','Position',[30  155  180  20],'String','Status : inactive','HorizontalAlignment','left','BackgroundColor',[0.8 0.8 0.8]);

set(hm.toggleRunOnce,'CallBack',{@ToggleRunOnce_Callback});
set(hm.toggleRunCont,'CallBack',{@ToggleRunCont_Callback});

set(hm.pushStartMainLoop,    'CallBack',{@PushStartMainLoop_Callback});
set(hm.pushStopMainLoop,     'CallBack',{@PushStopMainLoop_Callback});
set(hm.toggleCatchup,       'CallBack',{@ToggleCatchup_Callback});
set(hm.toggleGetMeteo,       'CallBack',{@ToggleGetMeteo_Callback});
set(hm.toggleGetObservations,'CallBack',{@ToggleGetObservations_Callback});
set(hm.toggleGetOceanModelData ,'CallBack',{@ToggleGetOceanModelData_Callback});

set(hm.editRunTime,          'CallBack',{@EditRunTime_Callback});
set(hm.editInterval,         'CallBack',{@EditInterval_Callback});
set(hm.editStopTime,          'CallBack',{@EditStopTime_Callback});

set(hm.editCycle,            'CallBack',{@EditCycle_Callback});

%%
function PushStartMainLoop_Callback(hObject,eventdata)

hm=guidata(findobj('Tag','OMSMain'));

cosmos_startMainLoop(hm);

%%
function PushStopMainLoop_Callback(hObject,eventdata)
t = timerfind('Tag', 'MainLoop');
delete(t);
t = timerfind('Tag', 'ModelLoop');
delete(t);
hm=guidata(findobj('Tag','OMSMain'));
hm.NCyc=0;
set(hm.textMainLoopStatus,'String','Status : stopped');
set(hm.textModelLoopStatus,'String','Status : inactive');
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleRunCont_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
if get(hObject,'Value')==1
    set(hm.toggleRunOnce,'Value',0);
    hm.cycleMode='continuous';
    guidata(findobj('Tag','OMSMain'),hm);
else
    set(hObject,'Value',0);
end

%%
function ToggleRunOnce_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
if get(hObject,'Value')==1
    set(hm.toggleRunCont,'Value',0);
    hm.cycleMode='once';
    guidata(findobj('Tag','OMSMain'),hm);
else
    set(hObject,'Value',0);
end

%%
function ToggleCatchup_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
ii=get(hObject,'Value');
hm.catchUp=ii;
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleGetObservations_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
ii=get(hObject,'Value');
hm.getObservations=ii;
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleGetMeteo_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
ii=get(hObject,'Value');
hm.getMeteo=ii;
guidata(findobj('Tag','OMSMain'),hm);

%%
function ToggleGetOceanModelData_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
ii=get(hObject,'Value');
hm.getOceanModel=ii;
guidata(findobj('Tag','OMSMain'),hm);

%%
function EditCycle_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
str=get(hObject,'String');
hm.cycle=datenum(str,'yyyymmdd HHMMSS');
guidata(findobj('Tag','OMSMain'),hm);

%%
function EditStopTime_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
str=get(hObject,'String');
hm.stoptime=datenum(str,'yyyymmdd HHMMSS');
guidata(findobj('Tag','OMSMain'),hm);

%%
function EditRunTime_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
str=get(hObject,'String');
hm.runTime=str2double(str);
guidata(findobj('Tag','OMSMain'),hm);

%%
function EditInterval_Callback(hObject,eventdata)
hm=guidata(findobj('Tag','OMSMain'));
str=get(hObject,'String');
hm.runInterval=str2double(str);
guidata(findobj('Tag','OMSMain'),hm);
