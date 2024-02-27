function ddb_editXBeachFlowSettings

ddb_refreshScreen('Flow','Settings');
handles=getHandles;

handles.GUIHandles.EditFlowC = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).C), 'Position',    [150 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowC = uicontrol(gcf,'Style','text','String','Chezy (-)','Position',[60 116  80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowCFL = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).CFL), 'Position',    [320 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowCFL = uicontrol(gcf,'Style','text','String','CFL (-)','Position',[240 116 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowEps = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).eps), 'Position',    [320 90 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowEps = uicontrol(gcf,'Style','text','String','eps (m)','Position',[240 86  80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowHmin = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).hmin), 'Position',    [320 60 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowHmin = uicontrol(gcf,'Style','text','String','hmin (m)','Position',[240 56  80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowUmin = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).umin), 'Position',    [320 30 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowUmin = uicontrol(gcf,'Style','text','String','umin (m/s)','Position',[240 26  80 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditFlowC,'CallBack',{@EditFlowC_CallBack});
set(handles.GUIHandles.EditFlowCFL,'CallBack',{@EditFlowCFL_CallBack});
set(handles.GUIHandles.EditFlowEps,'CallBack',{@EditFlowEps_CallBack});
set(handles.GUIHandles.EditFlowHmin,'CallBack',{@EditFlowHmin_CallBack});
set(handles.GUIHandles.EditFlowUmin,'CallBack',{@EditFlowUmin_CallBack});

setHandles(handles);

%%
function EditFlowC_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).C=str2num(get(hObject,'String'));
setHandles(handles);

%
function EditFlowCFL_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).CFL=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditFlowEps_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).eps=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditFlowHmin_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).hmin=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditFlowUmin_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).umin=str2num(get(hObject,'String'));
setHandles(handles);
