function varargout = PlotOptionsKubint(varargin)
% PLOTOPTIONSKUBINT M-file for PlotOptionsKubint.fig
%      PLOTOPTIONSKUBINT, by itself, creates a new PLOTOPTIONSKUBINT or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONSKUBINT returns the handle to a new PLOTOPTIONSKUBINT or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONSKUBINT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONSKUBINT.M with the given input arguments.
%
%      PLOTOPTIONSKUBINT('Property','Value',...) creates a new PLOTOPTIONSKUBINT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptionsKubint_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptionsKubint_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptionsKubint
 
% Last Modified by GUIDE v2.5 09-Mar-2006 21:54:28
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptionsKubint_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptionsKubint_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptionsKubint is made visible.
function PlotOptionsKubint_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptionsKubint (see VARARGIN)
 
% Choose default command line output for PlotOptionsKubint

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);
 
PutInCentre(hObject);
 
set(handles.EditLineWidth,'String',num2str(handles.PlotOptions.LineWidth));
 
clear str

nrcol=size(handles.DefaultColors,2);
for i=1:nrcol
    handles.Colors{i}=handles.DefaultColors(i).Name;
end

set(handles.SelectColor,'String',handles.Colors);
i=strmatch(lower(handles.PlotOptions.LineColor),lower(handles.Colors),'exact');
set(handles.SelectColor,'Value',i);

set(handles.ToggleFillPolygons,'Value',handles.PlotOptions.KubFill);
set(handles.EditRoundNumbers,'String',num2str(handles.PlotOptions.Multiply));
set(handles.EditDecimals,'String',num2str(handles.PlotOptions.Decim));
 
handles.AreaText=handles.PlotOptions.AreaText;
 
handles=RefreshOptions(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptionsKubint wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptionsKubint_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1)
 
 
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
h.Figure(i).Axis(j).Plot(k).KubFill=get(handles.ToggleFillPolygons,'Value');
h.Figure(i).Axis(j).Plot(k).AreaText=handles.AreaText;
h.Figure(i).Axis(j).Plot(k).Decim=str2num(get(handles.EditDecimals,'String'));
h.Figure(i).Axis(j).Plot(k).Multiply=str2num(get(handles.EditRoundNumbers,'String'));
h.Figure(i).Axis(j).Plot(k).Font=handles.PlotOptions.Font;
h.Figure(i).Axis(j).Plot(k).FontSize=handles.PlotOptions.FontSize;
h.Figure(i).Axis(j).Plot(k).FontAngle=handles.PlotOptions.FontAngle;
h.Figure(i).Axis(j).Plot(k).FontWeight=handles.PlotOptions.FontWeight;
h.Figure(i).Axis(j).Plot(k).FontColor=handles.PlotOptions.FontColor;
 
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
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.PlotOptions.Font=Font.Type;
handles.PlotOptions.FontSize=Font.Size;
handles.PlotOptions.FontAngle=Font.Angle;
handles.PlotOptions.FontWeight=Font.Weight;
handles.PlotOptions.FontColor=Font.Color;
handles.PlotOptions.HorAl=Font.HorizontalAlignment;
handles.PlotOptions.VerAl=Font.VerticalAlignment;

guidata(hObject, handles);

 
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
 
 
% --- Executes on button press in ToggleFillPolygons.
function ToggleFillPolygons_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleFillPolygons (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleFillPolygons
 
 
 
 
% --- Executes on button press in ToggleAreaText.
function ToggleAreaText_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAreaText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleAreaText
 
 
 
function EditRoundNumbers_Callback(hObject, eventdata, handles)
% hObject    handle to EditRoundNumbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditRoundNumbers as text
%        str2double(get(hObject,'String')) returns contents of EditRoundNumbers as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditRoundNumbers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditRoundNumbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
 
% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
 
% --- Executes on button press in ToggleTextQuantity.
function ToggleTextQuantity_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleTextQuantity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleTextQuantity
 
i=get(hObject,'Value');
switch i,
    case 1
        set(handles.ToggleTextQuantity,   'Value',1);
        set(handles.ToggleTextAreaNumber, 'Value',0);
        set(handles.ToggleTextNone,       'Value',0);
end
handles.AreaText=1;
handles=RefreshOptions(handles);
 
guidata(hObject, handles);
 
% --- Executes on button press in ToggleTextAreaNumber.
function ToggleTextAreaNumber_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleTextAreaNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleTextAreaNumber
 
i=get(hObject,'Value');
switch i,
    case 1
        set(handles.ToggleTextQuantity,   'Value',0);
        set(handles.ToggleTextAreaNumber, 'Value',1);
        set(handles.ToggleTextNone,       'Value',0);
end
handles.AreaText=2;
handles=RefreshOptions(handles);
 
guidata(hObject, handles);
 
% --- Executes on button press in ToggleTextNone.
function ToggleTextNone_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleTextNone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleTextNone
 
i=get(hObject,'Value');
switch i,
    case 1
        set(handles.ToggleTextQuantity,   'Value',0);
        set(handles.ToggleTextAreaNumber, 'Value',0);
        set(handles.ToggleTextNone,       'Value',1);
end
handles.AreaText=3;
handles=RefreshOptions(handles);
 
guidata(hObject, handles);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
 
function handles=RefreshOptions(handles);
 
i=handles.AreaText;
 
switch i,
    case{1}
        set(handles.ToggleTextQuantity,   'Value',1);
        set(handles.ToggleTextAreaNumber, 'Value',0);
        set(handles.ToggleTextNone,       'Value',0);
        set(handles.ToggleTextNone,       'Value',0);
        set(handles.SelectFont,           'Enable','on');
        set(handles.TextRoundNumbers,     'Enable','on');
        set(handles.EditRoundNumbers,     'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextDecimals,         'Enable','on');
        set(handles.EditDecimals,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
    case{2}
        set(handles.ToggleTextQuantity,   'Value',0);
        set(handles.ToggleTextAreaNumber, 'Value',1);
        set(handles.ToggleTextNone,       'Value',0);
        set(handles.SelectFont,           'Enable','on');
        set(handles.TextRoundNumbers,     'Enable','off');
        set(handles.EditRoundNumbers,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextDecimals,         'Enable','off');
        set(handles.EditDecimals,         'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
    case{3}
        set(handles.ToggleTextQuantity,   'Value',0);
        set(handles.ToggleTextAreaNumber, 'Value',0);
        set(handles.ToggleTextNone,       'Value',1);
        set(handles.SelectFont,           'Enable','off');
        set(handles.TextRoundNumbers,     'Enable','off');
        set(handles.EditRoundNumbers,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextDecimals,         'Enable','off');
        set(handles.EditDecimals,         'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
end
 
 
 
function EditDecimals_Callback(hObject, eventdata, handles)
% hObject    handle to EditDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditDecimals as text
%        str2double(get(hObject,'String')) returns contents of EditDecimals as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditDecimals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
