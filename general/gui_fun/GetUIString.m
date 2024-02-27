function strout=GetUIString(strin,varargin)
%GETUISTRING No description

ico=[];

if ~isempty(varargin)
    % Icon
    ii=strmatch('icon',lower(varargin),'exact');
    if ~isempty(ii)
        ico=varargin{ii+1};
    end
end

if ~isempty(ico)
    h=MakeNewWindow('',[300 130],'modal','icon',ico);
else
    h=MakeNewWindow('',[300 130],'modal');
end

handles.StrOut=[];

handles.Text       = uicontrol(gcf,'Style','text',      'String',strin,   'Position',[ 30  85 240 15],'Tag','UIControl');
handles.EditStrOut = uicontrol(gcf,'Style','edit',      'String','',      'Position',[ 30  60 240 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
handles.PushOK     = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[200  30  70 20]);
handles.PushCancel = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[120  30  70 20]);

set(handles.PushCancel,          'CallBack',{@PushCancel_CallBack});
set(handles.PushOK,              'CallBack',{@PushOK_CallBack});

SetUIBackgroundColors;

guidata(gcf,handles);

uiwait;

handles=guidata(gcf);
strout=handles.StrOut;

close(h);

%%
function PushOK_CallBack(hObject,eventdata)
handles=guidata(gcf);
str=get(handles.EditStrOut,'String');
handles.StrOut=str;
guidata(gcf,handles);
uiresume;

%%
function PushCancel_CallBack(hObject,eventdata)
handles=guidata(gcf);
handles.StrOut='';
guidata(gcf,handles);
uiresume;
