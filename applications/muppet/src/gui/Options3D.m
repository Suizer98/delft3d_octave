function varargout = Options3D(varargin)
% OPTIONS3D M-file for Options3D.fig
%      OPTIONS3D, by itself, creates a new OPTIONS3D or raises the existing
%      singleton*.
%
%      H = OPTIONS3D returns the handle to a new OPTIONS3D or the handle to
%      the existing singleton*.
%
%      OPTIONS3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTIONS3D.M with the given input arguments.
%
%      OPTIONS3D('Property','Value',...) creates a new OPTIONS3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Options3D_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Options3D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help Options3D
 
% Last Modified by GUIDE v2.5 21-Dec-2009 21:17:11
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Options3D_OpeningFcn, ...
                   'gui_OutputFcn',  @Options3D_OutputFcn, ...
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
 
 
% --- Executes just before Options3D is made visible.
function Options3D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Options3D (see VARARGIN)
 
% Choose default command line output for Options3D

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.DefaultColors=h.DefaultColors;
handles.Axis=h.Figure(handles.i).Axis(handles.j);
handles.ActiveSubplot=h.ActiveSubplot;
handles.output = h;

PutInCentre(hObject);
 
i=handles.ActiveSubplot;

handles.CameraTargetX=handles.Axis.CameraTarget(1);
handles.CameraTargetY=handles.Axis.CameraTarget(2);
handles.CameraTargetZ=handles.Axis.CameraTarget(3);
handles.CameraAngle(1)=handles.Axis.CameraAngle(1);
handles.CameraAngle(2)=handles.Axis.CameraAngle(2);
handles.CameraViewAngle=handles.Axis.CameraViewAngle;
handles.DataAspectRatio=handles.Axis.DataAspectRatio;
handles.LightStrength=handles.Axis.LightStrength;
handles.LightAzimuth=handles.Axis.LightAzimuth;
handles.LightElevation=handles.Axis.LightElevation;
handles.ZMin=handles.Axis.ZMin;
handles.ZMax=handles.Axis.ZMax;
handles.ZTick=handles.Axis.ZTick;
handles.ZDecimals=handles.Axis.DecimZ;
 
set(handles.EditCameraTargetX,'String',num2str(handles.CameraTargetX));
set(handles.EditCameraTargetY,'String',num2str(handles.CameraTargetY));
set(handles.EditCameraTargetZ,'String',num2str(handles.CameraTargetZ));
set(handles.EditCameraAngle1,'String',num2str(handles.CameraAngle(1)));
set(handles.EditCameraAngle2,'String',num2str(handles.CameraAngle(2)));
set(handles.EditViewAngle,'String',num2str(handles.CameraViewAngle));
set(handles.EditDataAspectRatioX,'String',num2str(handles.DataAspectRatio(1)));
set(handles.EditDataAspectRatioY,'String',num2str(handles.DataAspectRatio(2)));
set(handles.EditDataAspectRatioZ,'String',num2str(handles.DataAspectRatio(3)));
set(handles.EditLightStrength,'String',num2str(handles.LightStrength));
set(handles.EditLightAzimuth,'String',num2str(handles.LightAzimuth));
set(handles.EditLightElevation,'String',num2str(handles.LightElevation));

set(handles.EditZMin,'String',num2str(handles.ZMin));
set(handles.EditZMax,'String',num2str(handles.ZMax));
set(handles.EditZTick,'String',num2str(handles.ZTick));
set(handles.EditZDecimals,'String',num2str(handles.ZDecimals));

set(handles.ToggleZGrid,'Value',handles.Axis.ZGrid);

set(handles.TogglePerspective,'Value',handles.Axis.Perspective);


% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes Options3D wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = Options3D_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1);
 
function EditCameraTargetX_Callback(hObject, eventdata, handles)
% hObject    handle to EditCameraTargetX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditCameraTargetX as text
%        str2double(get(hObject,'String')) returns contents of EditCameraTargetX as a double
 
[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.CameraTargetX=val;
else
    set(hObject,'String',num2str(handles.CameraTargetX));
end
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function EditCameraTargetX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCameraTargetX (see GCBO)
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
i=h.ActiveFigure;
j=handles.ActiveSubplot;

h.Figure(i).Axis(j).CameraTarget=[handles.CameraTargetX handles.CameraTargetY handles.CameraTargetZ];
h.Figure(i).Axis(j).CameraAngle=handles.CameraAngle;
h.Figure(i).Axis(j).CameraViewAngle=handles.CameraViewAngle;
h.Figure(i).Axis(j).DataAspectRatio=handles.DataAspectRatio;
h.Figure(i).Axis(j).LightStrength=handles.LightStrength;
h.Figure(i).Axis(j).LightAzimuth=handles.LightAzimuth;
h.Figure(i).Axis(j).LightElevation=handles.LightElevation;
h.Figure(i).Axis(j).ZMin=handles.ZMin;
h.Figure(i).Axis(j).ZMax=handles.ZMax;
h.Figure(i).Axis(j).ZTick=handles.ZTick;
h.Figure(i).Axis(j).DecimZ=handles.ZDecimals;
h.Figure(i).Axis(j).ZGrid=get(handles.ToggleZGrid,'Value');
h.Figure(i).Axis(j).Perspective=get(handles.TogglePerspective,'Value');

handles.output=h;
 
guidata(hObject, handles);
 
uiresume;
 
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
uiresume;
 
function EditCameraTargetY_Callback(hObject, eventdata, handles)
% hObject    handle to EditCameraTargetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditCameraTargetY as text
%        str2double(get(hObject,'String')) returns contents of EditCameraTargetY as a double
 
[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.CameraTargetY=val;
else
    set(hObject,'String',num2str(handles.CameraTargetY));
end
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function EditCameraTargetY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCameraTargetY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditCameraTargetZ_Callback(hObject, eventdata, handles)
% hObject    handle to EditCameraTargetZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditCameraTargetZ as text
%        str2double(get(hObject,'String')) returns contents of EditCameraTargetZ as a double
 
[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.CameraTargetZ=val;
else
    set(hObject,'String',num2str(handles.CameraTargetZ));
end
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function EditCameraTargetZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCameraTargetZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditCameraAngle1_Callback(hObject, eventdata, handles)
% hObject    handle to EditCameraAngle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditCameraAngle1 as text
%        str2double(get(hObject,'String')) returns contents of EditCameraAngle1 as a double
 
[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.CameraAngle(1)=val;
else
    set(hObject,'String',num2str(handles.CameraAngle(1)));
end
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function EditCameraAngle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCameraAngle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
function EditViewAngle_Callback(hObject, eventdata, handles)
% hObject    handle to EditViewAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditViewAngle as text
%        str2double(get(hObject,'String')) returns contents of EditViewAngle as a double
 
[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.CameraViewAngle=val;
else
    set(hObject,'String',num2str(handles.CameraViewAngle));
end
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function EditViewAngle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditViewAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditDataAspectRatioX_Callback(hObject, eventdata, handles)
% hObject    handle to EditDataAspectRatioX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditDataAspectRatioX as text
%        str2double(get(hObject,'String')) returns contents of EditDataAspectRatioX as a double
 
[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.DataAspectRatio(1)=val;
else
    set(hObject,'String',num2str(handles.DataAspectRatio(1)));
end
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function EditDataAspectRatioX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDataAspectRatioX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditLightStrength_Callback(hObject, eventdata, handles)
% hObject    handle to EditLightStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditLightStrength as text
%        str2double(get(hObject,'String')) returns contents of EditLightStrength as a double
 
[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.LightStrength=val;
else
    set(hObject,'String',num2str(handles.LightStrength));
end
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function EditLightStrength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLightStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
 
 
function EditCameraAngle2_Callback(hObject, eventdata, handles)
% hObject    handle to EditCameraAngle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditCameraAngle2 as text
%        str2double(get(hObject,'String')) returns contents of EditCameraAngle2 as a double
 
[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.CameraAngle(2)=val;
else
    set(hObject,'String',num2str(handles.CameraAngle(2)));
end
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function EditCameraAngle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCameraAngle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 



function EditZMin_Callback(hObject, eventdata, handles)
% hObject    handle to EditZMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditZMin as text
%        str2double(get(hObject,'String')) returns contents of EditZMin as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.ZMin=val;
else
    set(hObject,'String',num2str(handles.ZMin));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditZMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditZMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditZMax_Callback(hObject, eventdata, handles)
% hObject    handle to EditZMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditZMax as text
%        str2double(get(hObject,'String')) returns contents of EditZMax as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.ZMax=val;
else
    set(hObject,'String',num2str(handles.ZMax));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditZMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditZMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditZTick_Callback(hObject, eventdata, handles)
% hObject    handle to EditZTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditZTick as text
%        str2double(get(hObject,'String')) returns contents of EditZTick as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.ZTick=val;
else
    set(hObject,'String',num2str(handles.ZTick));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditZTick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditZTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditZDecimals_Callback(hObject, eventdata, handles)
% hObject    handle to EditZDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditZDecimals as text
%        str2double(get(hObject,'String')) returns contents of EditZDecimals as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.ZDecimals=val;
else
    set(hObject,'String',num2str(handles.ZDecimals));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditZDecimals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditZDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditDataAspectRatioY_Callback(hObject, eventdata, handles)
% hObject    handle to EditDataAspectRatioY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDataAspectRatioY as text
%        str2double(get(hObject,'String')) returns contents of EditDataAspectRatioY as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.DataAspectRatio(2)=val;
else
    set(hObject,'String',num2str(handles.DataAspectRatio(2)));
end
guidata(hObject, handles);
 

% --- Executes during object creation, after setting all properties.
function EditDataAspectRatioY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDataAspectRatioY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditDataAspectRatioZ_Callback(hObject, eventdata, handles)
% hObject    handle to EditDataAspectRatioZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDataAspectRatioZ as text
%        str2double(get(hObject,'String')) returns contents of EditDataAspectRatioZ as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.DataAspectRatio(3)=val;
else
    set(hObject,'String',num2str(handles.DataAspectRatio(3)));
end
guidata(hObject, handles);
 

% --- Executes during object creation, after setting all properties.
function EditDataAspectRatioZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDataAspectRatioZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in ToggleZGrid.
function ToggleZGrid_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleZGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleZGrid




% --- Executes on button press in TogglePerspective.
function TogglePerspective_Callback(hObject, eventdata, handles)
% hObject    handle to TogglePerspective (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglePerspective





function EditLightAzimuth_Callback(hObject, eventdata, handles)
% hObject    handle to EditLightAzimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditLightAzimuth as text
%        str2double(get(hObject,'String')) returns contents of EditLightAzimuth as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.LightAzimuth=val;
else
    set(hObject,'String',num2str(handles.LightAzimuth));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditLightAzimuth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLightAzimuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditLightElevation_Callback(hObject, eventdata, handles)
% hObject    handle to EditLightElevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditLightElevation as text
%        str2double(get(hObject,'String')) returns contents of EditLightElevation as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.LightElevation=val;
else
    set(hObject,'String',num2str(handles.LightElevation));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditLightElevation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLightElevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


