function varargout = EditDefaultColors(varargin)
% EDITDEFAULTCOLORS M-file for EditDefaultColors.fig
%      EDITDEFAULTCOLORS, by itself, creates a new EDITDEFAULTCOLORS or raises the existing
%      singleton*.
%
%      H = EDITDEFAULTCOLORS returns the handle to a new EDITDEFAULTCOLORS or the handle to
%      the existing singleton*.
%
%      EDITDEFAULTCOLORS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITDEFAULTCOLORS.M with the given input arguments.
%
%      EDITDEFAULTCOLORS('Property','Value',...) creates a new EDITDEFAULTCOLORS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditDefaultColors_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditDefaultColors_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EditDefaultColors

% Last Modified by GUIDE v2.5 14-Aug-2007 17:31:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditDefaultColors_OpeningFcn, ...
                   'gui_OutputFcn',  @EditDefaultColors_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EditDefaultColors is made visible.
function EditDefaultColors_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditDefaultColors (see VARARGIN)

% Choose default command line output for EditDefaultColors
handles.output = hObject;

handles.DefaultColors=varargin{2};

for i=1:length(handles.DefaultColors)
    handles.ColorNames{i}=handles.DefaultColors(i).Name;
    handles.Colors(i,:)=handles.DefaultColors(i).Val;
end
set(handles.ListColors,'String',handles.ColorNames);

Refresh(handles);

PutInCentre(hObject);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditDefaultColors wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EditDefaultColors_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

close(handles.figure1);

% --- Executes on selection change in ListColors.
function ListColors_Callback(hObject, eventdata, handles)
% hObject    handle to ListColors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListColors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListColors

Refresh(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ListColors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListColors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditR_Callback(hObject, eventdata, handles)
% hObject    handle to EditR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditR as text
%        str2double(get(hObject,'String')) returns contents of EditR as a double

i=get(handles.ListColors,'Value');

r=CheckInput(hObject,0,255,255*handles.Colors(i,1));

handles.Colors(i,1)=r/255;

Refresh(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditG_Callback(hObject, eventdata, handles)
% hObject    handle to EditG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditG as text
%        str2double(get(hObject,'String')) returns contents of EditG as a double

i=get(handles.ListColors,'Value');

g=CheckInput(hObject,0,255,255*handles.Colors(i,2));

handles.Colors(i,2)=g/255;

Refresh(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditB_Callback(hObject, eventdata, handles)
% hObject    handle to EditB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditB as text
%        str2double(get(hObject,'String')) returns contents of EditB as a double

i=get(handles.ListColors,'Value');

b=CheckInput(hObject,0,255,255*handles.Colors(i,3));

handles.Colors(i,3)=b/255;

Refresh(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditName_Callback(hObject, eventdata, handles)
% hObject    handle to EditName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditName as text
%        str2double(get(hObject,'String')) returns contents of EditName as a double

i=get(handles.ListColors,'Value');
str=get(handles.ListColors,'String');
str{i}=get(hObject,'String');
set(handles.ListColors,'String',str);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nr0=length(get(handles.ListColors,'String'));
str=get(handles.ListColors,'String');

for i=1:nr0
    handles.DefaultColors(i).Name=str{i};
    handles.DefaultColors(i).Val=handles.Colors(i,:);
end

handles.output=handles.DefaultColors;
 
guidata(hObject, handles);
 
uiresume;
 


% --- Executes on button press in PushDelete.
function PushDelete_Callback(hObject, eventdata, handles)
% hObject    handle to PushDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

i=get(handles.ListColors,'Value');
nr0=length(get(handles.ListColors,'String'));
str=get(handles.ListColors,'String');

for k=i:nr0-1
    str{k}=str{k+1};
    handles.Colors(k,:)=handles.Colors(k+1,:);
end

for kk=1:nr0-1
    str2{kk}=str{kk};
end
if i==nr0
    set(handles.ListColors,'Value',i-1);
end    
set(handles.ListColors,'String',str2);

Refresh(handles);

guidata(hObject, handles);



% --- Executes on button press in PushInsertAbove.
function PushInsertAbove_Callback(hObject, eventdata, handles)
% hObject    handle to PushInsertAbove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

i=get(handles.ListColors,'Value');
nr0=length(get(handles.ListColors,'String'));
str=get(handles.ListColors,'String');

for k=nr0+1:-1:i+1
    str{k}=str{k-1};
    handles.Colors(k,:)=handles.Colors(k-1,:);
end

str{i}='Untitled';
handles.Colors(i,:)=[0 0 0];

set(handles.ListColors,'String',str);

Refresh(handles);

guidata(hObject, handles);


% --- Executes on button press in PushInsertBelow.
function PushInsertBelow_Callback(hObject, eventdata, handles)
% hObject    handle to PushInsertBelow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

i=get(handles.ListColors,'Value');
nr0=length(get(handles.ListColors,'String'));
str=get(handles.ListColors,'String');

for k=nr0+1:-1:i+2
    str{k}=str{k-1};
    handles.Colors(k,:)=handles.Colors(k-1,:);
end

str{i+1}='Untitled';
handles.Colors(i+1,:)=[0 0 0];

set(handles.ListColors,'String',str);
set(handles.ListColors,'Value',i+1);

Refresh(handles);

guidata(hObject, handles);


% --- Executes on button press in PushSave.
function PushSave_Callback(hObject, eventdata, handles)
% hObject    handle to PushSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

g=guidata(findobj('Tag','MainWindow'));
[filename, pathname, filterindex] = uiputfile({'*.def','Def Files (*.def)'},'Save as',[g.MuppetPath 'settings' filesep 'defaults' filesep 'colors.def']);

if filterindex==1

    fname=[pathname filename];
    fid=fopen(fname,'w');
    
    time=clock;
    datestring=datestr(datenum(clock),31);

    usrstring='- Unknown user';
    usr=getenv('username');

    if size(usr,1)>0
        usrstring=[' - File created by ' usr];
    end

    txt=['# Default colors' usrstring ' - ' datestring];
    fprintf(fid,'%s \n',txt);

    str=get(handles.ListColors,'String');
    nc=length(str);
    for i=1:nc
        gg='                       ';
        ii=length(str{i});
        gg(1:ii)=str{i};
        frmt='%5i';
        txt=[gg sprintf(frmt,255*handles.Colors(i,1)) sprintf(frmt,255*handles.Colors(i,2)) sprintf(frmt,255*handles.Colors(i,3)) ];
        fprintf(fid,'%s\n',txt);
    end
    fclose(fid);
    
end

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output=handles.DefaultColors;
 
guidata(hObject, handles);
 
uiresume;
 

% --- Executes on button press in DisplayColor.
function DisplayColor_Callback(hObject, eventdata, handles)
% hObject    handle to DisplayColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cl=uisetcolor;

if length(cl)>1
    i=get(handles.ListColors,'Value');
    handles.Colors(i,1)=cl(1);
    handles.Colors(i,2)=cl(2);
    handles.Colors(i,3)=cl(3);
    Refresh(handles);
    guidata(hObject, handles);
end


function Refresh(handles)

i=get(handles.ListColors,'Value');
str=get(handles.ListColors,'String');
set(handles.EditName,'String',str{i});

r=handles.Colors(i,1)*255;
g=handles.Colors(i,2)*255;
b=handles.Colors(i,3)*255;

set(handles.EditR,'String',num2str(r));
set(handles.EditG,'String',num2str(g));
set(handles.EditB,'String',num2str(b));

set(handles.DisplayColor,'BackgroundColor',[r/255 g/255 b/255]);



