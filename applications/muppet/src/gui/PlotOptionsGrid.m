function varargout = PlotOptionsGrid(varargin)
% PLOTOPTIONSGRID M-file for PlotOptionsGrid.fig
%      PLOTOPTIONSGRID, by itself, creates a new PLOTOPTIONSGRID or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONSGRID returns the handle to a new PLOTOPTIONSGRID or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONSGRID('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONSGRID.M with the given input arguments.
%
%      PLOTOPTIONSGRID('Property','Value',...) creates a new PLOTOPTIONSGRID or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptionsGrid_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptionsGrid_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptionsGrid
 
% Last Modified by GUIDE v2.5 20-Apr-2006 17:56:41
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptionsGrid_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptionsGrid_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptionsGrid is made visible.
function PlotOptionsGrid_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptionsGrid (see VARARGIN)
 
% Choose default command line output for PlotOptionsGrid

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);

PutInCentre(hObject);
 
set(handles.EditLineWidth,'String',num2str(PlotOptions.LineWidth));
 
clear str
str={'-','--','-.',':','none'};
set(handles.SelectLineStyle,'String',str);
handles.LineStyles={'-','--','-.',':',''};
 
switch lower(PlotOptions.LineStyle),
    case {'-'}
        i=1;
    case {'--'}
        i=2;
    case {'-.'}
        i=3;
    case {':'}
        i=4;
    case {''}
        i=5;
end
set(handles.SelectLineStyle,'Value',i);

nrcol=size(h.DefaultColors,2);
for i=1:nrcol
    handles.Colors{i}=h.DefaultColors(i).Name;
end

set(handles.SelectColor,'String',handles.Colors);
i=strmatch(lower(PlotOptions.LineColor),lower(handles.Colors),'exact');
set(handles.SelectColor,'Value',i);

% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptionsGrid wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptionsGrid_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1)
 
 
function EditLegendText_Callback(hObject, eventdata, handles)
% hObject    handle to EditLegendText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditLegendText as text
%        str2double(get(hObject,'String')) returns contents of EditLegendText as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditLegendText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLegendText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in SelectColor.
function SelectColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectColor
 
 
% --- Executes during object creation, after setting all properties.
function SelectColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in SelectLineStyle.
function SelectLineStyle_Callback(hObject, eventdata, handles)
% hObject    handle to SelectLineStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectLineStyle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectLineStyle
 
 
% --- Executes during object creation, after setting all properties.
function SelectLineStyle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectLineStyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in SelectMarker.
function SelectMarker_Callback(hObject, eventdata, handles)
% hObject    handle to SelectMarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectMarker contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectMarker
 
 
% --- Executes during object creation, after setting all properties.
function SelectMarker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectMarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
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
k=handles.k;
 
h.Figure(i).Axis(j).Plot(k).LineWidth=str2num(get(handles.EditLineWidth,'String'));
h.Figure(i).Axis(j).Plot(k).LineColor=handles.Colors{get(handles.SelectColor,'Value')};
h.Figure(i).Axis(j).Plot(k).LineStyle=handles.LineStyles{get(handles.SelectLineStyle,'Value')};

handles.output=h;
 
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
uiresume;
 
function EditLineWidth_Callback(hObject, eventdata, handles)
% hObject    handle to EditLineWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditLineWidth as text
%        str2double(get(hObject,'String')) returns contents of EditLineWidth as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditLineWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLineWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in SelectPlotRoutine.
function SelectPlotRoutine_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPlotRoutine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectPlotRoutine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectPlotRoutine
 
 
% --- Executes during object creation, after setting all properties.
function SelectPlotRoutine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectPlotRoutine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
function EditElevation_Callback(hObject, eventdata, handles)
% hObject    handle to EditElevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditElevation as text
%        str2double(get(hObject,'String')) returns contents of EditElevation as a double


% --- Executes during object creation, after setting all properties.
function EditElevation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditElevation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


