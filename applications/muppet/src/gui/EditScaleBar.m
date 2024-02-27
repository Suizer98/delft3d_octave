function varargout = EditScaleBar(varargin)
% EDITSCALEBAR M-file for EditScaleBar.fig
%      EDITSCALEBAR, by itself, creates a new EDITSCALEBAR or raises the existing
%      singleton*.
%
%      H = EDITSCALEBAR returns the handle to a new EDITSCALEBAR or the handle to
%      the existing singleton*.
%
%      EDITSCALEBAR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITSCALEBAR.M with the given input arguments.
%
%      EDITSCALEBAR('Property','Value',...) creates a new EDITSCALEBAR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditScaleBar_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditScaleBar_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help EditScaleBar
 
% Last Modified by GUIDE v2.5 15-Nov-2005 14:29:29
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditScaleBar_OpeningFcn, ...
                   'gui_OutputFcn',  @EditScaleBar_OutputFcn, ...
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
 
 
% --- Executes just before EditScaleBar is made visible.
function EditScaleBar_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditScaleBar (see VARARGIN)
 
% Choose default command line output for EditScaleBar
h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.DefaultColors=h.DefaultColors;
handles.Axis=h.Figure(handles.i).Axis(handles.j);
handles.output = h;
 
PutInCentre(hObject);
 
set(handles.EditPosition1,'String',num2str(handles.Axis.ScaleBar(1),7));
set(handles.EditPosition2,'String',num2str(handles.Axis.ScaleBar(2),7));
set(handles.EditLength,'String',num2str(handles.Axis.ScaleBar(3),7));
set(handles.EditText,'String',handles.Axis.ScaleBarText);
 
str{1}='upper-left';
str{2}='lower-left';
str{3}='upper-right';
str{4}='lower-right';
set(handles.SelectPosition,'String',str);
set(handles.SelectPosition,'Value',2);
 
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes EditScaleBar wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = EditScaleBar_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1);
 
 
 
function EditPosition1_Callback(hObject, eventdata, handles)
% hObject    handle to EditPosition1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditPosition1 as text
%        str2double(get(hObject,'String')) returns contents of EditPosition1 as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditPosition1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPosition1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditPosition2_Callback(hObject, eventdata, handles)
% hObject    handle to EditPosition2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditPosition2 as text
%        str2double(get(hObject,'String')) returns contents of EditPosition2 as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditPosition2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPosition2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
function EditLength_Callback(hObject, eventdata, handles)
% hObject    handle to EditLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditLength as text
%        str2double(get(hObject,'String')) returns contents of EditLength as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
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
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditSubplotName_Callback(hObject, eventdata, handles)
% hObject    handle to EditSubplotName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditSubplotName as text
%        str2double(get(hObject,'String')) returns contents of EditSubplotName as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditSubplotName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSubplotName (see GCBO)
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

h=guidata(findobj('Name','Muppet'));
i=handles.i;
j=handles.j;

h.Figure(i).Axis(j).ScaleBar(1)=str2num(get(handles.EditPosition1,'String'));
h.Figure(i).Axis(j).ScaleBar(2)=str2num(get(handles.EditPosition2,'String'));
h.Figure(i).Axis(j).ScaleBar(3)=str2num(get(handles.EditLength,'String'));
h.Figure(i).Axis(j).ScaleBarText=get(handles.EditText,'String');
 
handles.output=h;
 
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
uiresume;
 
% --- Executes on selection change in SelectPosition.
function SelectPosition_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectPosition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectPosition
 
 
% --- Executes during object creation, after setting all properties.
function SelectPosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on button press in PushReposition.
function PushReposition_Callback(hObject, eventdata, handles)
% hObject    handle to PushReposition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
k=get(handles.SelectPosition,'Value');
 
if k==1
    x0=1.5;
    y0=handles.Axis.Position(4)-1.5;
    x1=round(0.04*handles.Axis.Scale);
elseif k==2
    x0=1.5;
    y0=1.5;
    x1=round(0.04*handles.Axis.Scale);
elseif k==3
    x0=handles.Axis.Position(3)-1.5;
    y0=handles.Axis.Position(4)-1.5;
    x1=round(0.04*handles.Axis.Scale);
elseif k==4
    x0=handles.Axis.Position(3)-1.5;
    y0=1.5;
    x1=round(0.04*handles.Axis.Scale);
end
 
handles.Axis.ScaleBar=[x0 y0 x1];
handles.Axis.ScaleBarText=[num2str(x1) ' m'];
 
set(handles.EditPosition1,'String',num2str(x0));
set(handles.EditPosition2,'String',num2str(y0));
set(handles.EditLength,'String',num2str(x1));
set(handles.EditText,'String',handles.Axis.ScaleBarText);
 
guidata(hObject, handles);
