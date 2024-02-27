function varargout = PlotOptionsText(varargin)
% PLOTOPTIONSTEXT M-file for PlotOptionsText.fig
%      PLOTOPTIONSTEXT, by itself, creates a new PLOTOPTIONSTEXT or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONSTEXT returns the handle to a new PLOTOPTIONSTEXT or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONSTEXT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONSTEXT.M with the given input arguments.
%
%      PLOTOPTIONSTEXT('Property','Value',...) creates a new PLOTOPTIONSTEXT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptionsText_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptionsText_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlotOptionsText

% Last Modified by GUIDE v2.5 24-Aug-2007 21:37:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptionsText_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptionsText_OutputFcn, ...
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


% --- Executes just before PlotOptionsText is made visible.
function PlotOptionsText_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptionsText (see VARARGIN)

% Choose default command line output for PlotOptionsText

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);
handles.kk=h.ActiveAvailableDataset;
handles.h=h;

set(handles.EditX,'String',num2str(h.DataProperties(handles.kk).Position(1)));
set(handles.EditY,'String',num2str(h.DataProperties(handles.kk).Position(2)));
set(handles.EditRotation,'String',num2str(h.DataProperties(handles.kk).Rotation));
set(handles.EditCurvature,'String',num2str(h.DataProperties(handles.kk).Curvature));
set(handles.EditText,'String',h.DataProperties(handles.kk).String);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PlotOptionsText wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PlotOptionsText_OutputFcn(hObject, eventdata, handles) 
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

h=handles.h;
i=handles.i;
j=handles.j;
k=handles.k;

h.DataProperties(handles.kk).String=get(handles.EditText,'String');
h.DataProperties(handles.kk).Position(1)=str2num(get(handles.EditX,'String'));
h.DataProperties(handles.kk).Position(2)=str2num(get(handles.EditY,'String'));
h.DataProperties(handles.kk).Rotation=str2num(get(handles.EditRotation,'String'));
h.DataProperties(handles.kk).Curvature=str2num(get(handles.EditCurvature,'String'));
h.Figure(i).Axis(j).Plot(k).Font=handles.PlotOptions.Font;
h.Figure(i).Axis(j).Plot(k).FontSize=handles.PlotOptions.FontSize;
h.Figure(i).Axis(j).Plot(k).FontAngle=handles.PlotOptions.FontAngle;
h.Figure(i).Axis(j).Plot(k).FontWeight=handles.PlotOptions.FontWeight;
h.Figure(i).Axis(j).Plot(k).FontColor=handles.PlotOptions.FontColor;
h.Figure(i).Axis(j).Plot(k).HorAl=handles.PlotOptions.HorAl;
h.Figure(i).Axis(j).Plot(k).VerAl=handles.PlotOptions.VerAl;

handles.output = h;

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

Font.Type=handles.PlotOptions.Font;
Font.Size=handles.PlotOptions.FontSize;
Font.Angle=handles.PlotOptions.FontAngle;
Font.Weight=handles.PlotOptions.FontWeight;
Font.Color=handles.PlotOptions.FontColor;
Font.HorizontalAlignment=handles.PlotOptions.HorAl;
Font.VerticalAlignment=handles.PlotOptions.VerAl;
Font.EditAlignment=1;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.PlotOptions.Font=Font.Type;
handles.PlotOptions.FontSize=Font.Size;
handles.PlotOptions.FontAngle=Font.Angle;
handles.PlotOptions.FontWeight=Font.Weight;
handles.PlotOptions.FontColor=Font.Color;
handles.PlotOptions.HorAl=Font.HorizontalAlignment;
handles.PlotOptions.VerAl=Font.VerticalAlignment;

guidata(hObject, handles);


