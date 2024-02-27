function varargout = EditRightAxis(varargin)
% EDITRIGHTAXIS M-file for EditRightAxis.fig
%      EDITRIGHTAXIS, by itself, creates a new EDITRIGHTAXIS or raises the existing
%      singleton*.
%
%      H = EDITRIGHTAXIS returns the handle to a new EDITRIGHTAXIS or the handle to
%      the existing singleton*.
%
%      EDITRIGHTAXIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITRIGHTAXIS.M with the given input arguments.
%
%      EDITRIGHTAXIS('Property','Value',...) creates a new EDITRIGHTAXIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditRightAxis_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditRightAxis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help EditRightAxis

% Last Modified by GUIDE v2.5 17-Apr-2006 18:23:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditRightAxis_OpeningFcn, ...
                   'gui_OutputFcn',  @EditRightAxis_OutputFcn, ...
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


% --- Executes just before EditRightAxis is made visible.
function EditRightAxis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditRightAxis (see VARARGIN)

% Choose default command line output for EditRightAxis
h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.DefaultColors=h.DefaultColors;
handles.Axis=h.Figure(handles.i).Axis(handles.j);
handles.output = h;

PutInCentre(hObject);

set(handles.EditYMin,'String',num2str(handles.Axis.YMinRight));
set(handles.EditYMax,'String',num2str(handles.Axis.YMaxRight));
set(handles.EditYTick,'String',num2str(handles.Axis.YTickRight));
set(handles.EditDecimY,'String',num2str(handles.Axis.DecimYRight));
set(handles.EditYLabel,'String',handles.Axis.YLabelRight);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditRightAxis wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EditRightAxis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1)

function EditYLabel_Callback(hObject, eventdata, handles)
% hObject    handle to EditYLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditYLabel as text
%        str2double(get(hObject,'String')) returns contents of EditYLabel as a double


% --- Executes during object creation, after setting all properties.
function EditYLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in SelectFont.
function SelectFont_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.Axis.YLabelFontRight;
Font.Size=handles.Axis.YLabelFontSizeRight;
Font.Angle=handles.Axis.YLabelFontAngleRight;
Font.Weight=handles.Axis.YLabelFontWeightRight;
Font.Color=handles.Axis.YLabelFontColorRight;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.Axis.YLabelFontRight=Font.Type;
handles.Axis.YLabelFontSizeRight=Font.Size;
handles.Axis.YLabelFontAngleRight=Font.Angle;
handles.Axis.YLabelFontWeightRight=Font.Weight;
handles.Axis.YLabelFontColorRight=Font.Color;
 
guidata(hObject, handles);

% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=guidata(findobj('Name','Muppet'));
i=h.ActiveFigure;
j=h.ActiveSubplot;

h.Figure(i).Axis(j).YMinRight=str2num(get(handles.EditYMin,'String'));
h.Figure(i).Axis(j).YMaxRight=str2num(get(handles.EditYMax,'String'));
h.Figure(i).Axis(j).YTickRight=str2num(get(handles.EditYTick,'String'));
h.Figure(i).Axis(j).DecimYRight=str2num(get(handles.EditDecimY,'String'));
h.Figure(i).Axis(j).YLabelRight=get(handles.EditYLabel,'String');
h.Figure(i).Axis(j).YLabelFontRight=handles.Axis.YLabelFontRight;
h.Figure(i).Axis(j).YLabelFontSizeRight=handles.Axis.YLabelFontSizeRight;
h.Figure(i).Axis(j).YLabelFontAngleRight=handles.Axis.YLabelFontAngleRight;
h.Figure(i).Axis(j).YLabelFontWeightRight=handles.Axis.YLabelFontWeightRight;
h.Figure(i).Axis(j).YLabelFontColorRight=handles.Axis.YLabelFontColorRight;

handles.output=h;
 
guidata(hObject, handles);
 
uiresume;

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;

function EditYMin_Callback(hObject, eventdata, handles)
% hObject    handle to EditYMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditYMin as text
%        str2double(get(hObject,'String')) returns contents of EditYMin as a double


% --- Executes during object creation, after setting all properties.
function EditYMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditYMax_Callback(hObject, eventdata, handles)
% hObject    handle to EditYMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditYMax as text
%        str2double(get(hObject,'String')) returns contents of EditYMax as a double


% --- Executes during object creation, after setting all properties.
function EditYMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditYTick_Callback(hObject, eventdata, handles)
% hObject    handle to EditYTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditYTick as text
%        str2double(get(hObject,'String')) returns contents of EditYTick as a double


% --- Executes during object creation, after setting all properties.
function EditYTick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditDecimY_Callback(hObject, eventdata, handles)
% hObject    handle to EditDecimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDecimY as text
%        str2double(get(hObject,'String')) returns contents of EditDecimY as a double


% --- Executes during object creation, after setting all properties.
function EditDecimY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDecimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


