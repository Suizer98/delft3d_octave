function varargout = EditAnimationSettings2(varargin)
% EDITANIMATIONSETTINGS2 M-file for EditAnimationSettings2.fig
%      EDITANIMATIONSETTINGS2, by itself, creates a new EDITANIMATIONSETTINGS2 or raises the existing
%      singleton*.
%
%      H = EDITANIMATIONSETTINGS2 returns the handle to a new EDITANIMATIONSETTINGS2 or the handle to
%      the existing singleton*.
%
%      EDITANIMATIONSETTINGS2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITANIMATIONSETTINGS2.M with the given input arguments.
%
%      EDITANIMATIONSETTINGS2('Property','Value',...) creates a new EDITANIMATIONSETTINGS2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditAnimationSettings_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditAnimationSettings2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help EditAnimationSettings2

% Last Modified by GUIDE v2.5 19-Jul-2011 10:51:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditAnimationSettings2_OpeningFcn, ...
                   'gui_OutputFcn',  @EditAnimationSettings2_OutputFcn, ...
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


% --- Executes just before EditAnimationSettings2 is made visible.
function EditAnimationSettings2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditAnimationSettings2 (see VARARGIN)

% Choose default command line output for EditAnimationSettings2
handles.output = hObject;

handles.AnimationSettings=varargin{2};

PutInCentre(hObject);
 
set(handles.EditFileName,'String',handles.AnimationSettings.FileName);
set(handles.EditPrefix,'String',handles.AnimationSettings.Prefix);
set(handles.EditFrameRate,'String',num2str(handles.AnimationSettings.FrameRate));

% set(handles.EditFirst,'String',num2str(handles.AnimationSettings.FirstStep));
% set(handles.EditLast,'String',num2str(handles.AnimationSettings.LastStep));
% set(handles.EditIncrement,'String',num2str(handles.AnimationSettings.Increment));

set(handles.EditFirst,'String',datestr(handles.AnimationSettings.startTime,'yyyymmdd HHMMSS'));
set(handles.EditLast,'String',datestr(handles.AnimationSettings.stopTime,'yyyymmdd HHMMSS'));
set(handles.EditIncrement,'String',num2str(handles.AnimationSettings.timeStep));

k=handles.AnimationSettings.makeKMZ;
set(handles.ToggleMakeKMZ,'Value',k);

k=handles.AnimationSettings.KeepFigures;
set(handles.ToggleKeepFigures,'Value',k);

if handles.AnimationSettings.KeepFigures;
    set(handles.TextPrefix,'Enable','on');
    set(handles.EditPrefix,'Enable','on','BackgroundColor',[1 1 1]);
else
    set(handles.TextPrefix,'Enable','off');
    set(handles.EditPrefix,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
end

set(handles.SelectBits,'String',{'8-bits','24-bits'});
if handles.AnimationSettings.NBits==8
    set(handles.SelectBits,'Value',1);
else
    set(handles.SelectBits,'Value',2);
end    

handles.output=handles.AnimationSettings;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditAnimationSettings2 wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EditAnimationSettings2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

close(handles.figure1)


function EditFileName_Callback(hObject, eventdata, handles)
% hObject    handle to EditFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFileName as text
%        str2double(get(hObject,'String')) returns contents of EditFileName as a double


% --- Executes during object creation, after setting all properties.
function EditFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.AnimationSettings.FileName=get(handles.EditFileName,'String');
handles.AnimationSettings.Prefix=get(handles.EditPrefix,'String');
handles.AnimationSettings.FrameRate=str2num(get(handles.EditFrameRate,'String'));
% handles.AnimationSettings.FirstStep=str2num(get(handles.EditFirst,'String'));
% handles.AnimationSettings.LastStep=str2num(get(handles.EditLast,'String'));
% handles.AnimationSettings.Increment=str2num(get(handles.EditIncrement,'String'));

handles.AnimationSettings.startTime=datenum(get(handles.EditFirst,'String'),'yyyymmdd HHMMSS');
handles.AnimationSettings.stopTime=datenum(get(handles.EditLast,'String'),'yyyymmdd HHMMSS');
handles.AnimationSettings.timeStep=str2num(get(handles.EditIncrement,'String'));

ii=get(handles.SelectBits,'Value');
if ii==1
    handles.AnimationSettings.NBits=8;
else
    handles.AnimationSettings.NBits=24;
end

handles.AnimationSettings.KeepFigures=get(handles.ToggleKeepFigures,'Value');
handles.AnimationSettings.makeKMZ=get(handles.ToggleMakeKMZ,'Value');

handles.output=handles.AnimationSettings;
 
guidata(hObject, handles);

uiresume;

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;


function EditFrameRate_Callback(hObject, eventdata, handles)
% hObject    handle to EditFrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFrameRate as text
%        str2double(get(hObject,'String')) returns contents of EditFrameRate as a double


% --- Executes during object creation, after setting all properties.
function EditFrameRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditFirst_Callback(hObject, eventdata, handles)
% hObject    handle to EditFirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFirst as text
%        str2double(get(hObject,'String')) returns contents of EditFirst as a double


% --- Executes during object creation, after setting all properties.
function EditFirst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditLast_Callback(hObject, eventdata, handles)
% hObject    handle to EditLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditLast as text
%        str2double(get(hObject,'String')) returns contents of EditLast as a double


% --- Executes during object creation, after setting all properties.
function EditLast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in ToggleKeepFigures.
function ToggleKeepFigures_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleKeepFigures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleKeepFigures

if get(hObject,'Value')
    set(handles.TextPrefix,'Enable','on');
    set(handles.EditPrefix,'Enable','on','BackgroundColor',[1 1 1]);
else
    set(handles.TextPrefix,'Enable','off');
    set(handles.EditPrefix,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
end

guidata(hObject, handles);

% --- Executes on button press in PushCodecOptions.
function PushCodecOptions_Callback(hObject, eventdata, handles)
% hObject    handle to PushCodecOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ii=get(handles.SelectBits,'Value');
if ii==1
    handles.AviOps = writeavi('getoptions', 8);
else
    handles.AviOps = writeavi('getoptions', 24);
end

if handles.AviOps.fccHandler~=0
    handles.AnimationSettings.fccHandler=handles.AviOps.fccHandler;
    handles.AnimationSettings.KeyFrames=handles.AviOps.KeyFrames;
    handles.AnimationSettings.Quality=handles.AviOps.Quality;
    handles.AnimationSettings.BytesPerSec=handles.AviOps.BytesPerSec;
    handles.AnimationSettings.Parameters=handles.AviOps.Parameters;
    guidata(hObject, handles);
end

% --- Executes on button press in PushSave.
function PushSave_Callback(hObject, eventdata, handles)
% hObject    handle to PushSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname]=uiputfile('*.ani');

if pathname~=0

    fid = fopen([pathname filename],'w');

    time=clock;
    datestring=datestr(datenum(clock),31);

    usrstring='- Unknown user';
    usr=getenv('username');

    if size(usr,1)>0
        usrstring=[' - File created by ' usr];
    end

    txt=['# Animation Settings' usrstring ' - ' datestring];
    fprintf(fid,'%s \n',txt);

    txt='';
    fprintf(fid,'%s \n',txt);

    txt=['FileName       ' get(handles.EditFileName,'String')];
    fprintf(fid,'%s \n',txt);

    txt=['FirstStep      ' num2str(get(handles.EditFirst,'String'))];
    fprintf(fid,'%s \n',txt);

    txt=['LastStep       ' num2str(get(handles.EditLast,'String'))];
    fprintf(fid,'%s \n',txt);

    txt=['Increment      ' num2str(get(handles.EditIncrement,'String'))];
    fprintf(fid,'%s \n',txt);
    
    txt=['FrameRate      ' num2str(get(handles.EditFrameRate,'String'))];
    fprintf(fid,'%s \n',txt);
    
    ii=get(handles.SelectBits,'Value');
    if ii==1
        txt=['NBits          8'];
    else
        txt=['NBits          24'];
    end    
    fprintf(fid,'%s \n',txt);
    
    if get(handles.ToggleKeepFigures,'Value')
        txt=['KeepFigures    yes'];
        fprintf(fid,'%s \n',txt);
        txt=['FigurePrefix   ' get(handles.EditPrefix,'String')];
        fprintf(fid,'%s \n',txt);
    else
        txt=['KeepFigures    no'];
        fprintf(fid,'%s \n',txt);
    end

    if get(handles.ToggleMakeKMZ,'Value')
        txt=['MakeKMZ        yes'];
        fprintf(fid,'%s \n',txt);
    else
        txt=['MakeKMZ        no'];
        fprintf(fid,'%s \n',txt);
    end        

    txt=[''];
    fprintf(fid,'%s \n',txt);

    txt=['# Do not change the following codec settings!'];
    fprintf(fid,'%s \n',txt);

    txt=[''];
    fprintf(fid,'%s \n',txt);

    txt=['fccHandler     ' num2str(handles.AnimationSettings.fccHandler)];
    fprintf(fid,'%s \n',txt);

    txt=['KeyFrames      ' num2str(handles.AnimationSettings.KeyFrames)];
    fprintf(fid,'%s \n',txt);
    
    txt=['Quality        ' num2str(handles.AnimationSettings.KeyFrames)];
    fprintf(fid,'%s \n',txt);
    
    txt=['BytesPerSec    ' num2str(handles.AnimationSettings.BytesPerSec)];
    fprintf(fid,'%s \n',txt);
    
    txt=['Parameters     ' num2str(handles.AnimationSettings.Parameters)];
    fprintf(fid,'%s \n',txt);
    
    fclose(fid);

end

function EditIncrement_Callback(hObject, eventdata, handles)
% hObject    handle to EditIncrement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditIncrement as text
%        str2double(get(hObject,'String')) returns contents of EditIncrement as a double


% --- Executes during object creation, after setting all properties.
function EditIncrement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditIncrement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to EditLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditLast as text
%        str2double(get(hObject,'String')) returns contents of EditLast as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in PushOpen.
function PushOpen_Callback(hObject, eventdata, handles)
% hObject    handle to PushOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname]=uigetfile('*.ani');

if pathname~=0

    handles.AnimationSettings=ReadAnimationSettings([pathname filename]);

    set(handles.EditFileName,'String',handles.AnimationSettings.FileName);
    set(handles.EditPrefix,'String',handles.AnimationSettings.Prefix);
    set(handles.EditFrameRate,'String',num2str(handles.AnimationSettings.FrameRate));
    set(handles.EditFirst,'String',num2str(handles.AnimationSettings.FirstStep));
    set(handles.EditLast,'String',num2str(handles.AnimationSettings.LastStep));
    set(handles.EditIncrement,'String',num2str(handles.AnimationSettings.Increment));
    
    if handles.AnimationSettings.NBits==8
        set(handles.SelectBits,'Value',1);
    else
        set(handles.SelectBits,'Value',2);
    end    

    k=handles.AnimationSettings.KeepFigures;
    set(handles.ToggleKeepFigures,'Value',k);

    k=handles.AnimationSettings.makeKMZ;
    set(handles.ToggleMakeKMZ,'Value',k);

    if handles.AnimationSettings.KeepFigures;
        set(handles.TextPrefix,'Enable','on');
        set(handles.EditPrefix,'Enable','on','BackgroundColor',[1 1 1]);
    else
        set(handles.TextPrefix,'Enable','off');
        set(handles.EditPrefix,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    end
    guidata(hObject, handles);

end



% --- Executes on selection change in SelectBits.
function SelectBits_Callback(hObject, eventdata, handles)
% hObject    handle to SelectBits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectBits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectBits


% --- Executes during object creation, after setting all properties.
function SelectBits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectBits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in ToggleMakeKMZ.
function ToggleMakeKMZ_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleMakeKMZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleMakeKMZ

