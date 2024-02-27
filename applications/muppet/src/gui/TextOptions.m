function varargout = TextOptions(varargin)
% TEXTOPTIONS M-file for TextOptions.fig
%      TEXTOPTIONS, by itself, creates a new TEXTOPTIONS or raises the existing
%      singleton*.
%
%      H = TEXTOPTIONS returns the handle to a new TEXTOPTIONS or the handle to
%      the existing singleton*.
%
%      TEXTOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEXTOPTIONS.M with the given input arguments.
%
%      TEXTOPTIONS('Property','Value',...) creates a new TEXTOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TextOptions_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TextOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TextOptions

% Last Modified by GUIDE v2.5 24-Aug-2007 21:37:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TextOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @TextOptions_OutputFcn, ...
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


% --- Executes just before TextOptions is made visible.
function TextOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TextOptions (see VARARGIN)

% Choose default command line output for TextOptions
handles.output = hObject;

handles.txt=varargin{2};
handles.DefaultColors=varargin{4};

set(handles.EditX,'String',num2str(handles.txt.Position(1)));
set(handles.EditY,'String',num2str(handles.txt.Position(2)));
set(handles.EditRotation,'String',num2str(handles.txt.Rotation));
set(handles.EditCurvature,'String',num2str(handles.txt.Curvature));
set(handles.EditText,'String',handles.txt.String);

handles.output = handles.txt;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TextOptions wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TextOptions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

close(handles.figure1)


function EditX_Callback(hObject, eventdata, handles)
% hObject    handle to EditX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditX as text
%        str2double(get(hObject,'String')) returns contents of EditX as a double


% --- Executes during object creation, after setting all properties.
function EditX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditY_Callback(hObject, eventdata, handles)
% hObject    handle to EditY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditY as text
%        str2double(get(hObject,'String')) returns contents of EditY as a double


% --- Executes during object creation, after setting all properties.
function EditY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditText_Callback(hObject, eventdata, handles)
% hObject    handle to EditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditText as text
%        str2double(get(hObject,'String')) returns contents of EditText as a double


% --- Executes during object creation, after setting all properties.
function EditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditRotation_Callback(hObject, eventdata, handles)
% hObject    handle to EditRotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditRotation as text
%        str2double(get(hObject,'String')) returns contents of EditRotation as a double


% --- Executes during object creation, after setting all properties.
function EditRotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditRotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
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

handles.txt.String=get(handles.EditText,'String');
handles.txt.Position(1)=str2num(get(handles.EditX,'String'));
handles.txt.Position(2)=str2num(get(handles.EditY,'String'));
handles.txt.Rotation=str2num(get(handles.EditRotation,'String'));
handles.txt.Curvature=str2num(get(handles.EditCurvature,'String'));

handles.output = handles.txt;

guidata(hObject, handles);

uiresume;

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;

% --- Executes on button press in PushFont.
function PushFont_Callback(hObject, eventdata, handles)
% hObject    handle to PushFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.txt.Font;
Font.Size=handles.txt.FontSize;
Font.Weight=handles.txt.FontWeight;
Font.Angle=handles.txt.FontAngle;
Font.Color=handles.txt.FontColor;
Font.HorizontalAlignment=handles.txt.HorAl;
Font.VerticalAlignment=handles.txt.VerAl;
Font.EditAlignment=1;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.txt.Font=Font.Type;
handles.txt.FontSize=Font.Size;
handles.txt.FontAngle=Font.Angle;
handles.txt.FontWeight=Font.Weight;
handles.txt.FontColor=Font.Color;
handles.txt.HorAl=Font.HorizontalAlignment;
handles.txt.VerAl=Font.VerticalAlignment;

guidata(hObject, handles);


