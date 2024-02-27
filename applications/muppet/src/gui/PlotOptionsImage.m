function varargout = PlotOptionsImage(varargin)
% PLOTOPTIONSIMAGE M-file for PlotOptionsImage.fig
%      PLOTOPTIONSIMAGE, by itself, creates a new PLOTOPTIONSIMAGE or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONSIMAGE returns the handle to a new PLOTOPTIONSIMAGE or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONSIMAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONSIMAGE.M with the given input arguments.
%
%      PLOTOPTIONSIMAGE('Property','Value',...) creates a new PLOTOPTIONSIMAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptionsImage_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptionsImage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptionsImage
 
% Last Modified by GUIDE v2.5 18-Apr-2006 10:54:33
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptionsImage_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptionsImage_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptionsImage is made visible.
function PlotOptionsImage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptionsImage (see VARARGIN)
 
% Choose default command line output for PlotOptionsImage

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);

PutInCentre(hObject);
 
set(handles.EditTransparency,'String',num2str(handles.PlotOptions.Transparency));
set(handles.EditWhiteVal,'String',num2str(handles.PlotOptions.WhiteVal));
set(handles.EditLevel,'String',num2str(handles.PlotOptions.Elevation));
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptionsImage wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptionsImage_OutputFcn(hObject, eventdata, handles)
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

h.Figure(i).Axis(j).Plot(k).Transparency=str2num(get(handles.EditTransparency,'String'));
h.Figure(i).Axis(j).Plot(k).WhiteVal=str2num(get(handles.EditWhiteVal,'String'));
h.Figure(i).Axis(j).Plot(k).Elevation=str2num(get(handles.EditLevel,'String'));
 
handles.output=h;
 
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
uiresume;
 
function EditTransparency_Callback(hObject, eventdata, handles)
% hObject    handle to EditTransparency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditTransparency as text
%        str2double(get(hObject,'String')) returns contents of EditTransparency as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditTransparency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTransparency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 

function EditWhiteVal_Callback(hObject, eventdata, handles)
% hObject    handle to EditWhiteVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditWhiteVal as text
%        str2double(get(hObject,'String')) returns contents of EditWhiteVal as a double


% --- Executes during object creation, after setting all properties.
function EditWhiteVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditWhiteVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditLevel_Callback(hObject, eventdata, handles)
% hObject    handle to EditLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditLevel as text
%        str2double(get(hObject,'String')) returns contents of EditLevel as a double


% --- Executes during object creation, after setting all properties.
function EditLevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


