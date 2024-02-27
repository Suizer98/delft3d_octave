function ddb_editXBeachWaveSettings

ddb_refreshScreen('Waves','Settings');
handles=getHandles;

str={'Roelvink 93','Baldock','Roelvink 93b'};
handles.GUIHandles.EditBreak    = uicontrol(gcf,'Style','popupmenu', 'String',str,'Value',handles.model.xbeach.domain(ad).break,'Position',[150 120 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditAlpha    = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).alpha),'Position',[370 90 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditGamma    = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).gamma),'Position',[370 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditGammax   = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).gammax),'Position',[370 60 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.ToggleRoller = uicontrol(gcf,'Style','checkbox', 'String','Roller','Value',handles.model.xbeach.domain(ad).roller,'Position',[460 120 80 20],'Tag','UIControl');
handles.GUIHandles.ToggleWci    = uicontrol(gcf,'Style','checkbox', 'String','Wci','Value',handles.model.xbeach.domain(ad).wci,'Position',[460 90 80 20],'Tag','UIControl');
handles.GUIHandles.EditBeta     = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).beta),'Position',[630 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditN        = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).n),'Position',[370 30 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextBreak    = uicontrol(gcf,'Style','text', 'String','model','Position',[60 116 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextBeta     = uicontrol(gcf,'Style','text', 'String','Beta (-)','Position',[540 116 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextAlpha    = uicontrol(gcf,'Style','text', 'String','alpha (-)','Position',[290 86 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextGamma    = uicontrol(gcf,'Style','text', 'String','gamma (-)','Position',[290 116 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextGammax   = uicontrol(gcf,'Style','text', 'String','gammax (-)','Position',[290 56 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextN        = uicontrol(gcf,'Style','text', 'String','n (-)','Position',[290 26 80 20],'HorizontalAlignment','left','Tag','UIControl');

if handles.model.xbeach.domain(ad).roller==1; set(handles.GUIHandles.ToggleRoller,'Value',1); end;

set(handles.GUIHandles.EditBreak,'CallBack',{@EditBreak_CallBack});
set(handles.GUIHandles.EditBeta,'CallBack',{@EditBeta_CallBack});
set(handles.GUIHandles.EditAlpha,'CallBack',{@EditAlpha_CallBack});
set(handles.GUIHandles.EditGamma,'CallBack',{@EditGamma_CallBack});
set(handles.GUIHandles.EditGammax,'CallBack',{@EditGammax_CallBack});
set(handles.GUIHandles.ToggleRoller,'CallBack',{@ToggleRoller_CallBack});
set(handles.GUIHandles.ToggleWci,'CallBack',{@ToggleWci_CallBack});
set(handles.GUIHandles.EditN,'CallBack',{@EditN_CallBack});

handles=Refresh(handles);    

setHandles(handles);

%%
function EditBreak_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).break=get(hObject,'Value');
handles=Refresh(handles); 
setHandles(handles);

%%
function EditBeta_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).beta=get(hObject,'Value');
handles=Refresh(handles); 
setHandles(handles);
   
%%
function EditAlpha_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).alpha=get(hObject,'String');
setHandles(handles);

%%
function EditGamma_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).gamma=get(hObject,'String');
setHandles(handles);

%%
function EditGammax_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).gammax=get(hObject,'String');
setHandles(handles);

%%
function EditN_CallBack(hObject,eventdata);
handles=getHandles;
handles.model.xbeach.domain(ad).n=get(hObject,'String');
setHandles(handles);

%%
function ToggleWci_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).wci=get(hObject,'Value');
setHandles(handles);

%%
function ToggleRoller_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).roller=get(hObject,'Value');
handles=Refresh(handles); 
setHandles(handles);

%%
function handles=Refresh(handles)

n1=get(handles.GUIHandles.EditBreak,'Value');
n2=get(handles.GUIHandles.ToggleRoller,'Value');

switch n1,
    case {1,3}
        set(handles.GUIHandles.EditN,'Visible','on');
        set(handles.GUIHandles.TextN,'Visible','on');
    case 2
        set(handles.GUIHandles.EditN,'Visible','off');
        set(handles.GUIHandles.TextN,'Visible','off');
end

switch n2,
    case 1
        set(handles.GUIHandles.EditBeta,'Visible','on');
        set(handles.GUIHandles.TextBeta,'Visible','on');
    case 0
        set(handles.GUIHandles.EditBeta,'Visible','off');
        set(handles.GUIHandles.TextBeta,'Visible','off');
end

