function varargout = PlotOptionsSamples(varargin)
% PLOTOPTIONSSAMPLES M-file for PlotOptionsSamples.fig
%      PLOTOPTIONSSAMPLES, by itself, creates a new PLOTOPTIONSSAMPLES or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONSSAMPLES returns the handle to a new PLOTOPTIONSSAMPLES or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONSSAMPLES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONSSAMPLES.M with the given input arguments.
%
%      PLOTOPTIONSSAMPLES('Property','Value',...) creates a new PLOTOPTIONSSAMPLES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptionsSamples_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptionsSamples_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptionsSamples
 
% Last Modified by GUIDE v2.5 23-May-2007 21:58:04
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptionsSamples_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptionsSamples_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptionsSamples is made visible.
function PlotOptionsSamples_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptionsSamples (see VARARGIN)
 
% Choose default command line output for PlotOptionsSamples

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);
 
PutInCentre(hObject);
 
set(handles.ToggleAddText,'Value',handles.PlotOptions.AddText);

handles.TextPositions{1}='North';
handles.TextPositions{2}='South';
handles.TextPositions{3}='East';
handles.TextPositions{4}='West';
handles.TextPositions{5}='NorthEast';
handles.TextPositions{6}='NorthWest';
handles.TextPositions{7}='SouthEast';
handles.TextPositions{8}='SouthWest';
handles.TextPositions{9}='middle';
 
set(handles.SelectTextPosition,'String',handles.TextPositions);
i=strmatch(lower(handles.PlotOptions.TextPosition),lower(handles.TextPositions),'exact');
set(handles.SelectTextPosition,'Value',i);

handles.Markers={'.','o','x','+','*','s','d','v','^','<','>','p','h','none'};
str={'point','circle','x-mark','plus','star','square','diamond','triangle (down)', ...
     'triangle (up)','triangle (left)','triangle (right)','pentagram','hexagram','none'};
set(handles.SelectMarker,'String',str);
i=strmatch(lower(handles.PlotOptions.Marker),lower(handles.Markers),'exact');
set(handles.SelectMarker,'Value',i);

set(handles.EditMarkerSize,'String',handles.PlotOptions.MarkerSize);

nrcol=size(handles.DefaultColors,2);
handles.FaceColors{1}='auto';
handles.EdgeColors{1}='none';
for i=1:nrcol
    handles.FaceColors{i+1}=handles.DefaultColors(i).Name;
    handles.EdgeColors{i+1}=handles.DefaultColors(i).Name;
end
handles.FaceColors{nrcol+2}='none';

set(handles.SelectMarkerEdgeColor,'String',handles.EdgeColors);
i=strmatch(lower(handles.PlotOptions.MarkerEdgeColor),lower(handles.EdgeColors),'exact');
set(handles.SelectMarkerEdgeColor,'Value',i);

set(handles.SelectMarkerFaceColor,'String',handles.FaceColors);
i=strmatch(lower(handles.PlotOptions.MarkerFaceColor),lower(handles.FaceColors),'exact');
set(handles.SelectMarkerFaceColor,'Value',i);

set(handles.EditLegendText,'String',handles.PlotOptions.LegendText);

% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptionsSamples wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptionsSamples_OutputFcn(hObject, eventdata, handles)
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

h.Figure(i).Axis(j).Plot(k).AddText=get(handles.ToggleAddText,'Value');
h.Figure(i).Axis(j).Plot(k).TextPosition=handles.TextPositions{get(handles.SelectTextPosition,'Value')};
h.Figure(i).Axis(j).Plot(k).Marker=handles.Markers{get(handles.SelectMarker,'Value')};
h.Figure(i).Axis(j).Plot(k).MarkerEdgeColor=handles.EdgeColors{get(handles.SelectMarkerEdgeColor,'Value')};
h.Figure(i).Axis(j).Plot(k).MarkerFaceColor=handles.FaceColors{get(handles.SelectMarkerFaceColor,'Value')};
h.Figure(i).Axis(j).Plot(k).MarkerSize=str2num(get(handles.EditMarkerSize,'String'));
h.Figure(i).Axis(j).Plot(k).LegendText=get(handles.EditLegendText,'String');
h.Figure(i).Axis(j).Plot(k).Font=handles.PlotOptions.Font;
h.Figure(i).Axis(j).Plot(k).FontSize=handles.PlotOptions.FontSize;
h.Figure(i).Axis(j).Plot(k).FontAngle=handles.PlotOptions.FontAngle;
h.Figure(i).Axis(j).Plot(k).FontWeight=handles.PlotOptions.FontWeight;
h.Figure(i).Axis(j).Plot(k).FontColor=handles.PlotOptions.FontColor;
h.Figure(i).Axis(j).Plot(k).HorAl=handles.PlotOptions.HorAl;
h.Figure(i).Axis(j).Plot(k).VerAl=handles.PlotOptions.VerAl;
 
handles.output=h;
 
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
uiresume;
 
% --- Executes on button press in SelectFont.
function SelectFont_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFont (see GCBO)
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
 
 
function EditMarkerSize_Callback(hObject, eventdata, handles)
% hObject    handle to EditMarkerSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMarkerSize as text
%        str2double(get(hObject,'String')) returns contents of EditMarkerSize as a double


% --- Executes during object creation, after setting all properties.
function EditMarkerSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMarkerSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectTextPosition.
function SelectTextPosition_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTextPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectTextPosition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectTextPosition


% --- Executes during object creation, after setting all properties.
function SelectTextPosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectTextPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectMarkerEdgeColor.
function SelectMarkerEdgeColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectMarkerEdgeColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectMarkerEdgeColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectMarkerEdgeColor


% --- Executes during object creation, after setting all properties.
function SelectMarkerEdgeColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectMarkerEdgeColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in ToggleAddText.
function ToggleAddText_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAddText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAddText




% --- Executes on selection change in SelectMarkerFaceColor.
function SelectMarkerFaceColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectMarkerFaceColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectMarkerFaceColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectMarkerFaceColor


% --- Executes during object creation, after setting all properties.
function SelectMarkerFaceColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectMarkerFaceColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


