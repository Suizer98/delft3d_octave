function varargout = PlotOptionsRose(varargin)
% PLOTOPTIONSROSE M-file for PlotOptionsRose.fig
%      PLOTOPTIONSROSE, by itself, creates a new PLOTOPTIONSROSE or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONSROSE returns the handle to a new PLOTOPTIONSROSE or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONSROSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONSROSE.M with the given input arguments.
%
%      PLOTOPTIONSROSE('Property','Value',...) creates a new PLOTOPTIONSROSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptionsRose_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptionsRose_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptionsRose
 
% Last Modified by GUIDE v2.5 25-May-2007 18:27:28
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptionsRose_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptionsRose_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptionsRose is made visible.
function PlotOptionsRose_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptionsRose (see VARARGIN)
 
% Choose default command line output for PlotOptionsRose

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);
 
PutInCentre(hObject);
 
set(handles.EditMaximumRadius,'String',num2str(handles.PlotOptions.MaxRadius));
set(handles.EditRadiusStep,'String',num2str(handles.PlotOptions.RadiusStep));

set(handles.ToggleColors,'Value',handles.PlotOptions.ColoredWindRose);
set(handles.ToggleLegend,'Value',handles.PlotOptions.AddWindRoseLegend);
set(handles.TogglePlotTotals,'Value',handles.PlotOptions.AddWindRoseTotals);

% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptionsRose wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptionsRose_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1)
 
% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=guidata(findobj('Name','Muppet'));
i=handles.i;
j=handles.j;
k=handles.k;

h.Figure(i).Axis(j).Plot(k).RadiusStep=str2num(get(handles.EditRadiusStep,'String'));
h.Figure(i).Axis(j).Plot(k).MaxRadius=str2num(get(handles.EditMaximumRadius,'String'));

h.Figure(i).Axis(j).Plot(k).ColoredWindRose=get(handles.ToggleColors,'Value');
h.Figure(i).Axis(j).Plot(k).AddWindRoseLegend=get(handles.ToggleLegend,'Value');
h.Figure(i).Axis(j).Plot(k).AddWindRoseTotals=get(handles.TogglePlotTotals,'Value');
 
handles.output=h;
 
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
uiresume;
 
 
function EditMaximumRadius_Callback(hObject, eventdata, handles)
% hObject    handle to EditMaximumRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMaximumRadius as text
%        str2double(get(hObject,'String')) returns contents of EditMaximumRadius as a double


% --- Executes during object creation, after setting all properties.
function EditMaximumRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMaximumRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditRadiusStep_Callback(hObject, eventdata, handles)
% hObject    handle to EditRadiusStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditRadiusStep as text
%        str2double(get(hObject,'String')) returns contents of EditRadiusStep as a double


% --- Executes during object creation, after setting all properties.
function EditRadiusStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditRadiusStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in ToggleColors.
function ToggleColors_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleColors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleColors



% --- Executes on button press in TogglePlotTotals.
function TogglePlotTotals_Callback(hObject, eventdata, handles)
% hObject    handle to TogglePlotTotals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglePlotTotals


% --- Executes on button press in ToggleLegend.
function ToggleLegend_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleLegend


