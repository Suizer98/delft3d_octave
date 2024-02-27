function ddb_editXBeachPhysParams

ddb_refreshScreen('Phys. Params');
handles=getHandles;

hp = uipanel('Title','Physical Params','Units','pixels','Position',[50 30 420 140],'Tag','UIControl');

handles.GUIHandles.EditGravity = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).g),'Position',[180 130 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDensity = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).rho),'Position',[180 100 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDensitySand = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).rhos),'Position',[390 130 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditNUH = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).nuh),'Position',[180 70 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditD50 = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).D50),'Position',[390 100 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditD90 = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).D90),'Position',[390 70 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditPor = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).por),'Position',[390 40 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextGravity = uicontrol(gcf,'Style','text', 'String','Gravity (m/s^2)','Position',[60 126 120 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextDensity = uicontrol(gcf,'Style','text', 'String','Density water (kg/m^3)','Position',[60 96 120 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextDensitySand = uicontrol(gcf,'Style','text', 'String','Density Sand (kg/m^3)','Position',[270 126 120 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextNUH = uicontrol(gcf,'Style','text', 'String','nuh (m^2/s)','Position',[60 66 120 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextD50 = uicontrol(gcf,'Style','text', 'String','D50 (m)','Position',[270 96 120 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextD90 = uicontrol(gcf,'Style','text', 'String','D90 (m)','Position',[270 66 120 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextPor = uicontrol(gcf,'Style','text', 'String','Porosity (-)','Position',[270 36 120 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditGravity,'CallBack',{@EditGravity_CallBack});
set(handles.GUIHandles.EditDensity,'CallBack',{@EditDensity_CallBack});
set(handles.GUIHandles.EditDensitySand,'CallBack',{@EditDensitySand_CallBack});
set(handles.GUIHandles.EditNUH,'CallBack',{@EditNUH_CallBack});
set(handles.GUIHandles.EditD50,'CallBack',{@EditD50_CallBack});
set(handles.GUIHandles.EditD90,'CallBack',{@EditD90_CallBack});
set(handles.GUIHandles.EditPor,'CallBack',{@EditPor_CallBack});

setHandles(handles);

%%
function EditGravity_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).g=get(hObject,'String');
setHandles(handles);

%%
function EditDensity_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).rho=get(hObject,'String');
setHandles(handles);

%%
function EditDensitySand_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).rhos=get(hObject,'String');
setHandles(handles);

%%
function EditNUH_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).nuh=get(hObject,'String');
setHandles(handles);

%%
function EditD50_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).D50=get(hObject,'String');
setHandles(handles);

%%
function EditD90_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).D90=get(hObject,'String');
setHandles(handles);

%%
function EditPor_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).por=get(hObject,'String');
setHandles(handles);

