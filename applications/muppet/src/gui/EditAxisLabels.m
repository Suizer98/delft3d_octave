function varargout = EditAxisLabels(varargin)
% EDITAXISLABELS M-file for EditAxisLabels.fig
%      EDITAXISLABELS, by itself, creates a new EDITAXISLABELS or raises the existing
%      singleton*.
%
%      H = EDITAXISLABELS returns the handle to a new EDITAXISLABELS or the handle to
%      the existing singleton*.
%
%      EDITAXISLABELS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITAXISLABELS.M with the given input arguments.
%
%      EDITAXISLABELS('Property','Value',...) creates a new EDITAXISLABELS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditAxisLabels_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditAxisLabels_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EditAxisLabels

% Last Modified by GUIDE v2.5 14-Aug-2007 12:54:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditAxisLabels_OpeningFcn, ...
                   'gui_OutputFcn',  @EditAxisLabels_OutputFcn, ...
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


% --- Executes just before EditAxisLabels is made visible.
function EditAxisLabels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditAxisLabels (see VARARGIN)

% Choose default command line output for EditAxisLabels
h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.DefaultColors=h.DefaultColors;
handles.Axis=h.Figure(handles.i).Axis(handles.j);
handles.output = h;

PutInCentre(hObject);
 
set(handles.EditMultiplyX,'String',handles.Axis.XTickMultiply);
set(handles.EditMultiplyY,'String',handles.Axis.YTickMultiply);
set(handles.EditAddX,'String',handles.Axis.XTickAdd);
set(handles.EditAddY,'String',handles.Axis.YTickAdd);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditAxisLabels wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EditAxisLabels_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1);



function EditMultiplyX_Callback(hObject, eventdata, handles)
% hObject    handle to EditMultiplyX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMultiplyX as text
%        str2double(get(hObject,'String')) returns contents of EditMultiplyX as a double


% --- Executes during object creation, after setting all properties.
function EditMultiplyX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMultiplyX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditMultiplyY_Callback(hObject, eventdata, handles)
% hObject    handle to EditMultiplyY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMultiplyY as text
%        str2double(get(hObject,'String')) returns contents of EditMultiplyY as a double


% --- Executes during object creation, after setting all properties.
function EditMultiplyY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMultiplyY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditAddX_Callback(hObject, eventdata, handles)
% hObject    handle to EditAddX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditAddX as text
%        str2double(get(hObject,'String')) returns contents of EditAddX as a double


% --- Executes during object creation, after setting all properties.
function EditAddX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditAddX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditAddY_Callback(hObject, eventdata, handles)
% hObject    handle to EditAddY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditAddY as text
%        str2double(get(hObject,'String')) returns contents of EditAddY as a double


% --- Executes during object creation, after setting all properties.
function EditAddY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditAddY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushFont.
function PushFont_Callback(hObject, eventdata, handles)
% hObject    handle to PushFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.Axis.AxesFont;
Font.Size=handles.Axis.AxesFontSize;
Font.Angle=handles.Axis.AxesFontAngle;
Font.Weight=handles.Axis.AxesFontWeight;
Font.Color=handles.Axis.AxesFontColor;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.Axis.AxesFont=Font.Type;
handles.Axis.AxesFontSize=Font.Size;
handles.Axis.AxesFontAngle=Font.Angle;
handles.Axis.AxesFontWeight=Font.Weight;
handles.Axis.AxesFontColor=Font.Color;

guidata(hObject, handles);

% --- Executes on button press in PuskOK.
function PuskOK_Callback(hObject, eventdata, handles)
% hObject    handle to PuskOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=guidata(findobj('Name','Muppet'));
i=h.ActiveFigure;
j=h.ActiveSubplot;

h.Figure(i).Axis(j).XTickMultiply=str2num(get(handles.EditMultiplyX,'String'));
h.Figure(i).Axis(j).YTickMultiply=str2num(get(handles.EditMultiplyY,'String'));
h.Figure(i).Axis(j).XTickAdd=str2num(get(handles.EditAddX,'String'));
h.Figure(i).Axis(j).YTickAdd=str2num(get(handles.EditAddY,'String'));
h.Figure(i).Axis(j).AxesFont=handles.Axis.AxesFont;
h.Figure(i).Axis(j).AxesFontSize=handles.Axis.AxesFontSize;
h.Figure(i).Axis(j).AxesFontAngle=handles.Axis.AxesFontAngle;
h.Figure(i).Axis(j).AxesFontWeight=handles.Axis.AxesFontWeight;
h.Figure(i).Axis(j).AxesFontColor=handles.Axis.AxesFontColor;

handles.output=h;

guidata(hObject, handles);
 
uiresume;

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;
 

