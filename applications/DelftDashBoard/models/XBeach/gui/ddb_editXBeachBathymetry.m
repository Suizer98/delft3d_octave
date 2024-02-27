function ddb_editXBeachBathymetry

ddb_refreshScreen('Domain','Bathymetry');
handles=getHandles;

handles.GUIHandles.ToggleFile       = uicontrol(gcf,'Style','radiobutton','String','File','Position',[70 120 100 20],'Tag','UIControl');
handles.GUIHandles.ToggleUniform    = uicontrol(gcf,'Style','radiobutton','String','Uniform','Position',[70  90 100 20],'Tag','UIControl');
handles.GUIHandles.PushOpenDepth    = uicontrol(gcf,'Style','pushbutton','String','Open Depth File','Position',[150 120 130 20],'Tag','UIControl');
handles.GUIHandles.TextDepthFile    = uicontrol(gcf,'Style','text','String',['File : ',handles.model.xbeach.domain(ad).depfile],'Position',[290 117  200 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditUniformDepth = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).UniformDepth),'Position',[150  90  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextUniformDepth = uicontrol(gcf,'Style','text','String','m below reference level','Position',[205  86  200 20],'HorizontalAlignment','left','Tag','UIControl');

if ~isempty(handles.model.xbeach.domain(ad).depfile)
    set(handles.GUIHandles.ToggleUniform,'Value',0);
    set(handles.GUIHandles.ToggleFile,'Value',1);
else
    set(handles.GUIHandles.ToggleUniform,'Value',1);
    set(handles.GUIHandles.ToggleFile,'Value',0);
end

set(handles.GUIHandles.ToggleFile,      'CallBack',{@ToggleFile_CallBack});
set(handles.GUIHandles.PushOpenDepth,   'CallBack',{@PushOpenDepth_CallBack});
set(handles.GUIHandles.ToggleUniform,   'CallBack',{@ToggleUniform_CallBack});
set(handles.GUIHandles.EditUniformDepth,'CallBack',{@EditUniformDepth_CallBack});

handles=Refresh(handles);    

setHandles(handles);

%%
function ToggleFile_CallBack(hObject,eventdata)
handles=getHandles;
set(handles.GUIHandles.ToggleUniform,'Value',0);
set(handles.GUIHandles.ToggleFile,'Value',1);
handles=Refresh(handles);
setHandles(handles);

%%
function PushOpenDepth_CallBack(hObject,eventdata)
handles=getHandles;
if ~isempty(handles.model.xbeach.domain(ad).GrdFileY)
    [filename, pathname, filterindex] = uigetfile('*.dep', 'Select depth file');
    if ~pathname==0
        handles.model.xbeach.domain(ad).depfile=filename;
        dp=load([pathname filename]);
        set(handles.TextDepthFile,'String',['File : ' handles.model.xbeach.domain(ad).depfile]);
        setHandles(handles);
        % ddb_plotXBeachBathymetry(ad);
    end
else
    ddb_giveWarning('Warning','First load a grid file');
end

%%
function ToggleUniform_CallBack(hObject,eventdata)
handles=getHandles;
set(handles.GUIHandles.ToggleUniform,'Value',1);
set(handles.GUIHandles.ToggleFile,'Value',0);
handles.model.xbeach.domain(ad).depfile='';
handles=Refresh(handles);    
setHandles(handles);

%%
function EditUniformDepth_CallBack(hObject,eventdata)
handles=getHandles;
handles.model.xbeach.domain(ad).UniformDepth=str2num(get(hObject,'String'));
handles=Refresh(handles);    
setHandles(handles);
%%
function handles=Refresh(handles)

if get(handles.GUIHandles.ToggleUniform,'Value')==1
    set(handles.GUIHandles.PushOpenDepth,'Enable','off');
    set(handles.GUIHandles.TextDepthFile,'Enable','off');
    set(handles.GUIHandles.EditUniformDepth,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.GUIHandles.TextUniformDepth,'Enable','on');
else
    set(handles.GUIHandles.PushOpenDepth,'Enable','on');
    set(handles.GUIHandles.TextDepthFile,'Enable','on');
    set(handles.GUIHandles.EditUniformDepth,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.GUIHandles.TextUniformDepth,'Enable','off');
end
