function ddb_editXBeachTimeFrame

ddb_refreshScreen('Time Frame');
handles=getHandles;

hp                        = uipanel('Title','Time Frame','Units','pixels','Position',[50 30 220 140],'Tag','UIControl');
handles.GUIHandles.TextReferenceDate = uicontrol(gcf,'Style','text','String','Reference Date',     'Position',    [ 60 127  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextStartTime     = uicontrol(gcf,'Style','text','String','Start Time',         'Position',    [ 60  97  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextStopTime      = uicontrol(gcf,'Style','text','String','Stop Time',          'Position',    [ 60  67  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextMorStart      = uicontrol(gcf,'Style','text','String','Start Time MOR',     'Position',    [ 60  37  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditReferenceDate = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.model.xbeach.domain(ad).ItDate,'itdate'), 'Position',    [150 130 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditStartTime     = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).tstart),'Position',  [150 100 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditStopTime      = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).tstop),'Position',   [150  70 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditMorStart      = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).morstart),'Position',[150  40 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.EditReferenceDate,'CallBack',{@EditReferenceDate_CallBack});
set(handles.GUIHandles.EditStartTime,    'CallBack',{@EditStartTime_CallBack});
set(handles.GUIHandles.EditStopTime,     'CallBack',{@EditStopTime_CallBack});
set(handles.GUIHandles.EditMorStart,     'CallBack',{@EditMorStart_CallBack});

%%
function EditReferenceDate_CallBack(hObject,eventdata)

handles=getHandles;
handles.model.xbeach.domain(ad).ItDate=D3DTimeString(get(hObject,'String'));
setHandles(handles);

%%
function EditStartTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).tstart=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditStopTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).tstop=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditMorStart_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).morstart=str2num(get(hObject,'String'));
setHandles(handles);
