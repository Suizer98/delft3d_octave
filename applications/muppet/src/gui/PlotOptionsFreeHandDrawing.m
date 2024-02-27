function varargout = PlotOptionsFreeHandDrawing(varargin)
% PLOTOPTIONSFREEHANDDRAWING M-file for PlotOptionsFreeHandDrawing.fig
%      PLOTOPTIONSFREEHANDDRAWING, by itself, creates a new PLOTOPTIONSFREEHANDDRAWING or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONSFREEHANDDRAWING returns the handle to a new PLOTOPTIONSFREEHANDDRAWING or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONSFREEHANDDRAWING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONSFREEHANDDRAWING.M with the given input arguments.
%
%      PLOTOPTIONSFREEHANDDRAWING('Property','Value',...) creates a new PLOTOPTIONSFREEHANDDRAWING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptionsFreeHandDrawing_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptionsFreeHandDrawing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptionsFreeHandDrawing
 
% Last Modified by GUIDE v2.5 30-Aug-2007 21:48:09
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptionsFreeHandDrawing_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptionsFreeHandDrawing_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptionsFreeHandDrawing is made visible.
function PlotOptionsFreeHandDrawing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptionsFreeHandDrawing (see VARARGIN)
 
% Choose default command line output for PlotOptionsFreeHandDrawing

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);

PutInCentre(hObject);
str={'Polyline','Spline','Curved Arrow','Curved Double Arrow'};
handles.PlotRoutines={'DrawPolyline','DrawSpline','DrawCurvedArrow','DrawCurvedDoubleArrow'};
set(handles.SelectPlotRoutine,'String',str);
i=strmatch(lower(handles.PlotOptions.PlotRoutine),lower(handles.PlotRoutines),'exact');
set(handles.SelectPlotRoutine,'Value',i); 

set(handles.EditLineWidth,'String',num2str(handles.PlotOptions.LineWidth));
set(handles.EditArrowWidth,'String',num2str(handles.PlotOptions.ArrowWidth));
set(handles.EditHeadWidth,'String',num2str(handles.PlotOptions.HeadWidth));
clear str
str={'-','--','-.',':','none'};
set(handles.SelectLineStyle,'String',str);
handles.LineStyles={'-','--','-.',':',''};
 
switch lower(handles.PlotOptions.LineStyle),
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

nrcol=size(handles.DefaultColors,2);
for i=1:nrcol
    handles.Colors{i}=handles.DefaultColors(i).Name;
end

set(handles.SelectColor,'String',handles.Colors);
i=strmatch(lower(handles.PlotOptions.LineColor),lower(handles.Colors),'exact');
set(handles.SelectColor,'Value',i);

set(handles.ToggleFillPolygons,'Value',handles.PlotOptions.FillPolygons);
 
if ~ischar(lower(handles.PlotOptions.FillColor))
    handles.PlotOptions(handles.i,handles.j).FillColor='black';
end
set(handles.SelectFillColor,'String',handles.Colors);
i=strmatch(lower(handles.PlotOptions.FillColor),lower(handles.Colors),'exact');
set(handles.SelectFillColor,'Value',i);

if handles.PlotOptions.FillPolygons==0
    set(handles.SelectFillColor,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
else
    set(handles.SelectFillColor,'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
end

set(handles.EditLegendText,'String',handles.PlotOptions.LegendText);
 
set(handles.EditElevation,'String',num2str(handles.PlotOptions.PolygonElevation));
 
handles=RefreshOptions(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptionsFreeHandDrawing wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptionsFreeHandDrawing_OutputFcn(hObject, eventdata, handles)
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
h.Figure(i).Axis(j).Plot(k).HeadWidth=str2num(get(handles.EditHeadWidth,'String'));
h.Figure(i).Axis(j).Plot(k).ArrowWidth=str2num(get(handles.EditArrowWidth,'String'));
h.Figure(i).Axis(j).Plot(k).LineColor=handles.Colors{get(handles.SelectColor,'Value')};
h.Figure(i).Axis(j).Plot(k).LineStyle=handles.LineStyles{get(handles.SelectLineStyle,'Value')};
h.Figure(i).Axis(j).Plot(k).FillColor=handles.Colors{get(handles.SelectFillColor,'Value')};
h.Figure(i).Axis(j).Plot(k).LegendText=get(handles.EditLegendText,'String');
h.Figure(i).Axis(j).Plot(k).FillPolygons=get(handles.ToggleFillPolygons,'Value');
h.Figure(i).Axis(j).Plot(k).PolygonElevation=str2num(get(handles.EditElevation,'String'));
h.Figure(i).Axis(j).Plot(k).PlotRoutine=handles.PlotRoutines{get(handles.SelectPlotRoutine,'Value')};
 
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
 
handles=RefreshOptions(handles);

guidata(hObject, handles);

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
 
 
 
 
% --- Executes on button press in SelectFillColor.
function SelectFillColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFillColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% col=uisetcolor;
% set(hObject,'BackgroundColor',col);
%  
% guidata(hObject, handles);
%  
% --- Executes on button press in ToggleFillPolygons.
function ToggleFillPolygons_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleFillPolygons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleFillPolygons
 
handles=RefreshOptions(handles);

guidata(hObject, handles);


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




% --- Executes during object creation, after setting all properties.
function SelectFillColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectFillColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function EditArrowWidth_Callback(hObject, eventdata, handles)
% hObject    handle to EditArrowWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditArrowWidth as text
%        str2double(get(hObject,'String')) returns contents of EditArrowWidth as a double


% --- Executes during object creation, after setting all properties.
function EditArrowWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditArrowWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditHeadWidth_Callback(hObject, eventdata, handles)
% hObject    handle to EditHeadWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditHeadWidth as text
%        str2double(get(hObject,'String')) returns contents of EditHeadWidth as a double


% --- Executes during object creation, after setting all properties.
function EditHeadWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditHeadWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles=RefreshOptions(handles)

if get(handles.ToggleFillPolygons,'Value')==0
    set(handles.SelectFillColor,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
else
    set(handles.SelectFillColor,'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
end

if get(handles.SelectPlotRoutine,'Value')==3 | get(handles.SelectPlotRoutine,'Value')==4
    set(handles.EditArrowWidth,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.EditHeadWidth,'Enable','on','BackgroundColor',[1 1 1]);
else
    set(handles.EditArrowWidth,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.EditHeadWidth,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
end



