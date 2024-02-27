function ddb_editXBeachGrid

ddb_refreshScreen('Domain','Grid');
handles=getHandles;

str={'uniform','non-uniform'};
handles.GUIHandles.EditVardx = uicontrol(gcf,'Style','popupmenu', 'String',str,'Value',handles.model.xbeach.domain(ad).vardx+1,'Position',[70 120 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

%% vardx
handles.GUIHandles.PushOpenGridXV = uicontrol(gcf,'Style','pushbutton','String','Open X-Grid','Position',[200 120 130 20],'Tag','UIControl');
handles.GUIHandles.PushOpenGridYV = uicontrol(gcf,'Style','pushbutton','String','Open Y-Grid','Position',[200 100 130 20],'Tag','UIControl');
handles.GUIHandles.EditAlfaV      = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).alfa),'Position',[350 70 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditThetaminV  = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).thetamin),'Position',[840 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditThetamaxV  = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).thetamax),'Position',[840 90 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDthetaV    = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).dtheta),'Position',[840 60 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextMMaxV      = uicontrol(gcf,'Style','text','String',['Grid points in M direction : ' num2str(handles.model.xbeach.domain(ad).nx)],   'Position',[200 40  200 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextNMaxV      = uicontrol(gcf,'Style','text','String',['Grid points in N direction : ' num2str(handles.model.xbeach.domain(ad).ny)],   'Position',[200 20  200 20],'HorizontalAlignment','left','Tag','UIControl');   
handles.GUIHandles.TextGridFileXV = uicontrol(gcf,'Style','text','String',['File : ' handles.model.xbeach.domain(ad).xfile],'Position',[340 117  400 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextGridFileYV = uicontrol(gcf,'Style','text','String',['File : ' handles.model.xbeach.domain(ad).yfile],'Position',[340 97  400 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextAlfaV      = uicontrol(gcf,'Style','text','String','Angle of grid w.r.t. East (deg)','Position',[200 66 150 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextThetaminV  = uicontrol(gcf,'Style','text','String','thetamin (deg)','Position',[740 116 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextThetamaxV  = uicontrol(gcf,'Style','text','String','thetamax (deg)','Position',[740 86 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextDthetaV    = uicontrol(gcf,'Style','text','String','dtheta (deg)','Position',[740 56 100 20],'HorizontalAlignment','left','Tag','UIControl');

%% uniform
handles.GUIHandles.EditMMaxU      = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).nx),'Position',[350 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditNMaxU      = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).ny),'Position',[350 90 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDxU        = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).dx),'Position',[350 60 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDyU        = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).dy),'Position',[350 30 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditThetaminU  = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).thetamin),'Position',[540 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditThetamaxU  = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).thetamax),'Position',[540 90 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDthetaU    = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).dtheta),'Position',[540 60 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditAlfaU      = uicontrol(gcf,'Style','edit','String',num2str(handles.model.xbeach.domain(ad).alfa),'Position',[780 120 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextMMaxU      = uicontrol(gcf,'Style','text','String',['Grid points in M direction : '],   'Position',[200 116 150 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextNMaxU      = uicontrol(gcf,'Style','text','String',['Grid points in N direction : '],   'Position',[200 86 150 20],'HorizontalAlignment','left','Tag','UIControl');   
handles.GUIHandles.TextDxU        = uicontrol(gcf,'Style','text','String',['Dx : '],   'Position',[200 56 150 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextDyU        = uicontrol(gcf,'Style','text','String',['Dy : '],   'Position',[200 26 150 20],'HorizontalAlignment','left','Tag','UIControl');   
handles.GUIHandles.TextThetaminU  = uicontrol(gcf,'Style','text', 'String','thetamin (deg)','Position',[440 116 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextThetamaxU  = uicontrol(gcf,'Style','text', 'String','thetamax (deg)','Position',[440 86 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextDthetaU    = uicontrol(gcf,'Style','text', 'String','dtheta (deg)','Position',[440 56 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextAlfaU      = uicontrol(gcf,'Style','text', 'String','Angle of grid w.r.t. East (deg)','Position',[630 116 150 20],'HorizontalAlignment','left','Tag','UIControl');

%%
set(handles.GUIHandles.EditVardx,     'CallBack',{@EditVardx_CallBack});
set(handles.GUIHandles.PushOpenGridXV,'CallBack',{@PushOpenGridX_CallBack});
set(handles.GUIHandles.PushOpenGridYV,'CallBack',{@PushOpenGridY_CallBack});
set(handles.GUIHandles.EditAlfaV,     'CallBack',{@EditAlfa_CallBack});
set(handles.GUIHandles.EditThetaminV, 'CallBack',{@EditThetamin_CallBack});
set(handles.GUIHandles.EditThetamaxV, 'CallBack',{@EditThetamax_CallBack});
set(handles.GUIHandles.EditDthetaV,   'CallBack',{@EditDtheta_CallBack});

set(handles.GUIHandles.EditMMaxU,     'CallBack',{@EditMMax_CallBack});
set(handles.GUIHandles.EditNMaxU,     'CallBack',{@EditNMax_CallBack});
set(handles.GUIHandles.EditDxU,       'CallBack',{@EditDx_CallBack});
set(handles.GUIHandles.EditDyU,       'CallBack',{@EditDy_CallBack});
set(handles.GUIHandles.EditAlfaU,     'CallBack',{@EditAlfa_CallBack});
set(handles.GUIHandles.EditThetaminU, 'CallBack',{@EditThetamin_CallBack});
set(handles.GUIHandles.EditThetamaxU, 'CallBack',{@EditThetamax_CallBack});
set(handles.GUIHandles.EditDthetaU,   'CallBack',{@EditDtheta_CallBack});

handles = Refresh(handles);    

setHandles(handles);

%%
function EditVardx_CallBack(hObject,eventdata)
handles = guidata(findobj('Tag','MainWindow'));
handles.model.xbeach.domain(ad).vardx = get(hObject,'Value')-1;
handles = Refresh(handles); 
setHandles(handles);

%%
function PushOpenGridX_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.grd', 'Select Grid File');
if pathname~=0
    [x]=load([pathname filename]);
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filenamex=[pathname filename];
    end
    handles.model.xbeach.domain(ad).GridX = x;
    handles.model.xbeach.domain(ad).xfile = filenamex;
    set(handles.GUIHandles.TextGridFileXV,'String',['File : ' filenamex]);
    setHandles(handles);
end

%%
function PushOpenGridY_CallBack(hObject,eventdata)

handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.grd', 'Select Grid File');
if pathname~=0
    [y]=load([pathname filename]);
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filenamey=[pathname filename];
    end
    handles.model.xbeach.domain(ad).GridY = y;
    handles.model.xbeach.domain(ad).yfile = filenamey;
    handles.model.xbeach.domain(ad).mmax = size(y,1);
    handles.model.xbeach.domain(ad).nmax = size(y,2);
    set(handles.GUIHandles.TextMMaxV,'String',['Grid points in M direction:',num2str(handles.model.xbeach.domain(ad).mmax)]);
    set(handles.GUIHandles.TextNMaxV,'String',['Grid points in N direction:',num2str(handles.model.xbeach.domain(ad).nmax)]);
    set(handles.GUIHandles.TextGridFileYV,'String',['File :',filenamey]);
    setHandles(handles);
end

%%
function EditMMax_CallBack(hObject,eventdata)
handles = guidata(findobj('Tag','MainWindow'));
handles.model.xbeach.domain(ad).nx=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditNMax_CallBack(hObject,eventdata)
handles = guidata(findobj('Tag','MainWindow'));
handles.model.xbeach.domain(ad).ny=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditDx_CallBack(hObject,eventdata)
handles = guidata(findobj('Tag','MainWindow'));
handles.model.xbeach.domain(ad).dx=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditDy_CallBack(hObject,eventdata)
handles = guidata(findobj('Tag','MainWindow'));
handles.model.xbeach.domain(ad).dy=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditAlfa_CallBack(hObject,eventdata)
handles = guidata(findobj('Tag','MainWindow'));
handles.model.xbeach.domain(ad).alfa=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditThetamin_CallBack(hObject,eventdata)
handles = guidata(findobj('Tag','MainWindow'));
handles.model.xbeach.domain(ad).thetamin=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditThetamax_CallBack(hObject,eventdata)
handles = guidata(findobj('Tag','MainWindow'));
handles.model.xbeach.domain(ad).thetamax=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditDtheta_CallBack(hObject,eventdata)
handles = guidata(findobj('Tag','MainWindow'));
handles.model.xbeach.domain(ad).dtheta=str2num(get(hObject,'String'));
setHandles(handles);

function handles=Refresh(handles)

n1=get(handles.GUIHandles.EditVardx,'Value');
switch n1,
    case 1
        set(handles.GUIHandles.PushOpenGridXV,'Visible','off');
        set(handles.GUIHandles.PushOpenGridYV,'Visible','off');
        set(handles.GUIHandles.EditAlfaV,'Visible','off');
        set(handles.GUIHandles.EditThetaminV,'Visible','off');
        set(handles.GUIHandles.EditThetamaxV,'Visible','off');
        set(handles.GUIHandles.EditDthetaV,'Visible','off');
        set(handles.GUIHandles.TextMMaxV,'Visible','off');
        set(handles.GUIHandles.TextNMaxV,'Visible','off');
        set(handles.GUIHandles.TextGridFileXV,'Visible','off');
        set(handles.GUIHandles.TextGridFileYV,'Visible','off');
        set(handles.GUIHandles.TextAlfaV,'Visible','off');
        set(handles.GUIHandles.TextThetaminV,'Visible','off');
        set(handles.GUIHandles.TextThetamaxV,'Visible','off');
        set(handles.GUIHandles.TextDthetaV,'Visible','off');  
        
        set(handles.GUIHandles.EditMMaxU,'Visible','on');
        set(handles.GUIHandles.EditNMaxU,'Visible','on');
        set(handles.GUIHandles.EditDxU,'Visible','on');
        set(handles.GUIHandles.EditDyU,'Visible','on'); 
        set(handles.GUIHandles.EditAlfaU,'Visible','on');
        set(handles.GUIHandles.EditThetaminU,'Visible','on');
        set(handles.GUIHandles.EditThetamaxU,'Visible','on');
        set(handles.GUIHandles.EditDthetaU,'Visible','on');
        set(handles.GUIHandles.TextMMaxU,'Visible','on');
        set(handles.GUIHandles.TextNMaxU,'Visible','on');
        set(handles.GUIHandles.TextDxU,'Visible','on');
        set(handles.GUIHandles.TextDyU,'Visible','on');
        set(handles.GUIHandles.TextAlfaU,'Visible','on');
        set(handles.GUIHandles.TextThetaminU,'Visible','on');
        set(handles.GUIHandles.TextThetamaxU,'Visible','on');
        set(handles.GUIHandles.TextDthetaU,'Visible','on'); 
  
    case 2
        
        set(handles.GUIHandles.PushOpenGridXV,'Visible','on');
        set(handles.GUIHandles.PushOpenGridYV,'Visible','on');
        set(handles.GUIHandles.EditAlfaV,'Visible','on');
        set(handles.GUIHandles.EditThetaminV,'Visible','on');
        set(handles.GUIHandles.EditThetamaxV,'Visible','on');
        set(handles.GUIHandles.EditDthetaV,'Visible','on');
        set(handles.GUIHandles.TextMMaxV,'Visible','on');
        set(handles.GUIHandles.TextNMaxV,'Visible','on');
        set(handles.GUIHandles.TextGridFileXV,'Visible','on');
        set(handles.GUIHandles.TextGridFileYV,'Visible','on');
        set(handles.GUIHandles.TextAlfaV,'Visible','on');
        set(handles.GUIHandles.TextThetaminV,'Visible','on');
        set(handles.GUIHandles.TextThetamaxV,'Visible','on');
        set(handles.GUIHandles.TextDthetaV,'Visible','on'); 
        
        set(handles.GUIHandles.EditMMaxU,'Visible','off');
        set(handles.GUIHandles.EditNMaxU,'Visible','off');
        set(handles.GUIHandles.EditDxU,'Visible','off');
        set(handles.GUIHandles.EditDyU,'Visible','off'); 
        set(handles.GUIHandles.EditAlfaU,'Visible','off');
        set(handles.GUIHandles.EditThetaminU,'Visible','off');
        set(handles.GUIHandles.EditThetamaxU,'Visible','off');
        set(handles.GUIHandles.EditDthetaU,'Visible','off');
        set(handles.GUIHandles.TextMMaxU,'Visible','off');
        set(handles.GUIHandles.TextNMaxU,'Visible','off');
        set(handles.GUIHandles.TextDxU,'Visible','off');
        set(handles.GUIHandles.TextDyU,'Visible','off');
        set(handles.GUIHandles.TextAlfaU,'Visible','off');
        set(handles.GUIHandles.TextThetaminU,'Visible','off');
        set(handles.GUIHandles.TextThetamaxU,'Visible','off');
        set(handles.GUIHandles.TextDthetaU,'Visible','off'); 
        
end
