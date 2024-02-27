function ddb_editXBeachFlowBoundaries

ddb_refreshScreen('Flow','Boundaries');
handles=getHandles;

str={'Weakly Reflective','Radiating'};
handles.GUIHandles.TextFlowFront       = uicontrol(gcf,'Style','text', 'String','Sea Side','Position',[60 116 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowFront       = uicontrol(gcf,'Style','popupmenu', 'String',str,'Value',handles.model.xbeach.domain(ad).front,'Position',[140 120 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.ToggleFlowARC       = uicontrol(gcf,'Style','checkbox', 'String','ARC','Position',[280 120 80 20],'Tag','UIControl');
handles.GUIHandles.ToggleFlowOrder     = uicontrol(gcf,'Style','checkbox', 'String','Order','Position',[280 90 80 20],'Tag','UIControl');
handles.GUIHandles.ToggleFlowFree      = uicontrol(gcf,'Style','checkbox', 'String','Free','Position',[280 60 80 20],'Tag','UIControl');
handles.GUIHandles.ToggleFlowEpsi      = uicontrol(gcf,'Style','checkbox', 'String','Epsi','Position',[280 30 80 20],'Tag','UIControl');

handles.GUIHandles.TextFlowBack        = uicontrol(gcf,'Style','text', 'String','Bay Side','Position',[60 86 80 20],'HorizontalAlignment','left','Tag','UIControl');
str={'Radiating','Reflective'};
handles.GUIHandles.EditFlowBack        = uicontrol(gcf,'Style','popupmenu', 'String',str,'Value',handles.model.xbeach.domain(ad).back,'Position',[140 90 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
str={'Neumann','Reflective'};
handles.GUIHandles.TextFlowLeft        = uicontrol(gcf,'Style','text', 'String','Left side','Position',[60 56 80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowLeft        = uicontrol(gcf,'Style','popupmenu', 'String',str,'Value',handles.model.xbeach.domain(ad).left,'Position',[140 60 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowRight       = uicontrol(gcf,'Style','text', 'String','Right Side','Position',[60 26  80 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowRight       = uicontrol(gcf,'Style','popupmenu', 'String',str,'Value',handles.model.xbeach.domain(ad).right,'Position',[140 30 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.EditFlowTideloc     = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).tideloc),'Position',[570 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowTideloc     = uicontrol(gcf,'Style','text', 'String','Nr. tidal input locations (-)','Position',[420 116 150 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowZs0         = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).zs0),'Position',[500 90 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowZs0         = uicontrol(gcf,'Style','text', 'String','zs0 (m)','Position',[420 86 80 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.PushOpenFlowZs0File = uicontrol(gcf,'Style','pushbutton','String','Open zs0file','Position',[420 30 130 20],'Tag','UIControl');
handles.GUIHandles.TextOpenFlowZs0File = uicontrol(gcf,'Style','text','String',['File : ',handles.model.xbeach.domain(ad).zs0file],'Position',[570 26 400 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowPaulrevere  = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).paulrevere),'Position',[570 90 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowPaulrevere  = uicontrol(gcf,'Style','text', 'String','Paulrevere','Position',[420 86 150 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditFlowTidelen     = uicontrol(gcf,'Style','edit', 'String',num2str(handles.model.xbeach.domain(ad).tidelen),'Position',[570 60 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextFlowTidelen     = uicontrol(gcf,'Style','text', 'String','Input Length','Position',[420 56 150 20],'HorizontalAlignment','left','Tag','UIControl');

if handles.model.xbeach.domain(ad).ARC==1;   set(handles.GUIHandles.ToggleFlowARC,'Value',1); end
if handles.model.xbeach.domain(ad).order==1; set(handles.GUIHandles.ToggleFlowOrder,'Value',1); end
if handles.model.xbeach.domain(ad).carspan==1;  set(handles.GUIHandles.ToggleFlowFree,'Value',1); end
if handles.model.xbeach.domain(ad).epsi==1;  set(handles.GUIHandles.ToggleFlowEpsi,'Value',1); end

set(handles.GUIHandles.EditFlowFront,'CallBack',{@EditFlowFront_CallBack});
set(handles.GUIHandles.ToggleFlowARC,'CallBack',{@ToggleFlowARC_CallBack});
set(handles.GUIHandles.ToggleFlowOrder,'CallBack',{@ToggleFlowOrder_CallBack});
set(handles.GUIHandles.ToggleFlowFree,'CallBack',{@ToggleFlowFree_CallBack});
set(handles.GUIHandles.ToggleFlowEpsi,'CallBack',{@ToggleFlowEpsi_CallBack});
set(handles.GUIHandles.EditFlowBack,'CallBack',{@EditFlowBack_CallBack});
set(handles.GUIHandles.EditFlowLeft,'CallBack',{@EditFlowLeft_CallBack});
set(handles.GUIHandles.EditFlowRight,'CallBack',{@EditFlowRight_CallBack});
set(handles.GUIHandles.EditFlowTideloc,'CallBack',{@EditFlowTideloc_CallBack});
set(handles.GUIHandles.EditFlowZs0,'CallBack',{@EditFlowZs0_CallBack});
set(handles.GUIHandles.EditFlowPaulrevere,'CallBack',{@EditFlowPaulrevere_CallBack});
set(handles.GUIHandles.EditFlowTidelen,'CallBack',{@EditFlowTidelen_CallBack});
set(handles.GUIHandles.PushOpenFlowZs0File,'CallBack',{@PushOpenFlowZs0File_CallBack});

handles=Refresh(handles);   

setHandles(handles);

%%
function EditFlowFront_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).front=get(hObject,'Value');
setHandles(handles);

%%
function EditFlowBack_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).back=get(hObject,'Value');
setHandles(handles);

%%
function EditFlowLeft_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).left=get(hObject,'Value');
setHandles(handles);

%%
function EditFlowRight_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).right=get(hObject,'Value');
setHandles(handles);

%%
function ToggleFlowARC_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).ARC=get(hObject,'Value');
setHandles(handles);

%%
function ToggleFlowOrder_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).order=get(hObject,'Value');
setHandles(handles);

%%
function ToggleFlowFree_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).carspan=get(hObject,'Value');
setHandles(handles);

%%
function ToggleFlowEpsi_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).epsi=get(hObject,'Value');
setHandles(handles);

%%
function EditFlowTideloc_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).tideloc=str2num(get(hObject,'String'));
handles=Refresh(handles);
setHandles(handles);

%%
function PushOpenFlowZs0File_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('Select Zs0 File');
curdir=[lower(cd) '\'];
if ~strcmpi(curdir,pathname)
    filename=[pathname filename];
end
handles.model.xbeach.domain(ad).zs0file=filename;
set(handles.TextOpenFlowZs0File,'String',['File : ' filename]);
setHandles(handles);

%%
function EditFlowZs0_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).zs0=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditFlowPaulrevere_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).paulrevere=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditTidelen_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).tidelen=str2num(get(hObject,'String'));
setHandles(handles);

function handles=Refresh(handles)
n1=handles.model.xbeach.domain(ad).tideloc;

switch n1,
    case 0
         set(handles.GUIHandles.EditFlowTideloc,'Visible','on');
         set(handles.GUIHandles.TextFlowTideloc,'Visible','on');
         set(handles.GUIHandles.EditFlowZs0,'Visible','on');
         set(handles.GUIHandles.TextFlowZs0,'Visible','on');
         set(handles.GUIHandles.EditFlowPaulrevere,'Visible','off');
         set(handles.GUIHandles.TextFlowPaulrevere,'Visible','off');
         set(handles.GUIHandles.EditFlowTidelen,'Visible','off');
         set(handles.GUIHandles.TextFlowTidelen,'Visible','off');
         set(handles.GUIHandles.PushOpenFlowZs0File,'Visible','off');
         set(handles.GUIHandles.TextOpenFlowZs0File,'Visible','off');
    otherwise
         set(handles.GUIHandles.EditFlowTideloc,'Visible','on');
         set(handles.GUIHandles.TextFlowTideloc,'Visible','on');
         set(handles.GUIHandles.EditFlowZs0,'Visible','off');
         set(handles.GUIHandles.TextFlowZs0,'Visible','off');
         set(handles.GUIHandles.EditFlowPaulrevere,'Visible','on');
         set(handles.GUIHandles.TextFlowPaulrevere,'Visible','on');
         set(handles.GUIHandles.EditFlowTidelen,'Visible','on');
         set(handles.GUIHandles.TextFlowTidelen,'Visible','on');
         set(handles.GUIHandles.PushOpenFlowZs0File,'Visible','on');
         set(handles.GUIHandles.TextOpenFlowZs0File,'Visible','on');
end
         
