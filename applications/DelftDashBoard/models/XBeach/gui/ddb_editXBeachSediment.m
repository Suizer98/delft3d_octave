function ddb_editXBeachSediment

ddb_refreshScreen('Sediment');

handles=getHandles;

hp = uipanel('Title','Sediment','Units','pixels','Position',[50 30 520 140],'Tag','UIControl');

handles.GUIHandles.EditSedMorfac = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).morfac), 'Position',    [150 130 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSedMorfac = uicontrol(gcf,'Style','text','String','Morfac (-)','Position',[60 126 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditSedDico = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).dico), 'Position',    [320 130 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSedDico = uicontrol(gcf,'Style','text','String','Dico (-)','Position',[240 126 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditSedDzmax = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).dzmax), 'Position',    [320 100 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSedDzmax = uicontrol(gcf,'Style','text','String','dzmax (-)','Position',[240 96 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditSedDryslp = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).dryslp), 'Position',    [490 130 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSedDryslp = uicontrol(gcf,'Style','text','String','Dryslp (-)','Position',[410 126 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditSedWetslp = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).wetslp), 'Position',    [490 100 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSedWetslp = uicontrol(gcf,'Style','text','String','Wetslp (-)','Position',[410 96 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditSedHswitch = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).hswitch), 'Position',    [490 70 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSedHswitch = uicontrol(gcf,'Style','text','String','hswitch (m)','Position',[410 66 80 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditSedMorfac,'CallBack',{@EditSedMorfac_CallBack});
set(handles.GUIHandles.EditSedDico,'CallBack',{@EditSedDico_CallBack});
set(handles.GUIHandles.EditSedDzmax,'CallBack',{@EditSedDzmax_CallBack});
set(handles.GUIHandles.EditSedDryslp,'CallBack',{@EditSedDryslp_CallBack});
set(handles.GUIHandles.EditSedWetslp,'CallBack',{@EditSedWetslp_CallBack});
set(handles.GUIHandles.EditSedHswitch,'CallBack',{@EditSedHswitch_CallBack});

setHandles(handles);

%%
function EditSedMorfac_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).morfac=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditSedDico_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).dico=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditSedDzmax_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).dzmax=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditSedDryslp_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).dryslp=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditSedWetslp_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).wetslp=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditSedHswitch_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).hswitch=str2num(get(hObject,'String'));
setHandles(handles);


