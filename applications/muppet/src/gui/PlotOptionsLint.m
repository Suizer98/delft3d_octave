function varargout = PlotOptionsLint(varargin)
% PLOTOPTIONSLINT M-file for PlotOptionsLint.fig
%      PLOTOPTIONSLINT, by itself, creates a new PLOTOPTIONSLINT or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONSLINT returns the handle to a new PLOTOPTIONSLINT or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONSLINT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONSLINT.M with the given input arguments.
%
%      PLOTOPTIONSLINT('Property','Value',...) creates a new PLOTOPTIONSLINT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptionsLint_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptionsLint_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptionsLint
 
% Last Modified by GUIDE v2.5 20-Feb-2008 11:19:39
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptionsLint_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptionsLint_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptionsLint is made visible.
function PlotOptionsLint_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptionsLint (see VARARGIN)
 
% Choose default command line output for PlotOptionsLint

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);
 
PutInCentre(hObject);
 
set(handles.EditLineWidth,'String',num2str(handles.PlotOptions.LineWidth));

nrcol=size(handles.DefaultColors,2);
for i=1:nrcol
    handles.Colors{i}=handles.DefaultColors(i).Name;
end

set(handles.SelectColor,'String',handles.Colors);
i=strmatch(lower(handles.PlotOptions.LineColor),lower(handles.Colors),'exact');
set(handles.SelectColor,'Value',i);
 
set(handles.SelectFillColor,'String',handles.Colors);
i=strmatch(lower(handles.PlotOptions.ArrowColor),lower(handles.Colors),'exact');
set(handles.SelectFillColor,'Value',i);
 
set(handles.ToggleFillArrows,'Value',handles.PlotOptions.FillPolygons);
set(handles.EditRoundNumbers,'String',num2str(handles.PlotOptions.Multiply));
set(handles.EditDecimals,'String',num2str(handles.PlotOptions.Decim));
set(handles.EditLintScale,'String',num2str(handles.PlotOptions.LintScale));
set(handles.EditUnitArrow,'String',num2str(handles.PlotOptions.UnitArrow));
 
set(handles.ToggleAddNumbers,'Value',handles.PlotOptions.AddText);
  
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptionsLint wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptionsLint_OutputFcn(hObject, eventdata, handles)
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
h.Figure(i).Axis(j).Plot(k).LintScale=str2num(get(handles.EditLintScale,'String'));
h.Figure(i).Axis(j).Plot(k).UnitArrow=str2num(get(handles.EditUnitArrow,'String'));
h.Figure(i).Axis(j).Plot(k).Multiply=str2num(get(handles.EditRoundNumbers,'String'));
h.Figure(i).Axis(j).Plot(k).LineColor=handles.Colors{get(handles.SelectColor,'Value')};
h.Figure(i).Axis(j).Plot(k).LintFill=get(handles.ToggleFillArrows,'Value');
h.Figure(i).Axis(j).Plot(k).AddText=get(handles.ToggleAddNumbers,'Value');
h.Figure(i).Axis(j).Plot(k).FillPolygons=get(handles.ToggleFillArrows,'Value');
ii=get(handles.SelectFillColor,'Value');
h.Figure(i).Axis(j).Plot(k).ArrowColor=handles.Colors{ii};
h.Figure(i).Axis(j).Plot(k).Decim=str2num(get(handles.EditDecimals,'String'));
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
 
 
% --- Executes on button press in ToggleFillArrows.
function ToggleFillArrows_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleFillArrows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleFillArrows
 
handles=RefreshOptions(handles);
 
guidata(hObject, handles);
 
 
 
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
 
 
 
 
 
function EditLintScale_Callback(hObject, eventdata, handles)
% hObject    handle to EditLintScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditLintScale as text
%        str2double(get(hObject,'String')) returns contents of EditLintScale as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditLintScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLintScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on button press in ToggleAddNumbers.
function ToggleAddNumbers_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAddNumbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleAddNumbers
 
handles=RefreshOptions(handles);
 
guidata(hObject, handles);
 
% --- Executes on selection change in SelectFillColor.
function SelectFillColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFillColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectFillColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectFillColor
 
 
% --- Executes during object creation, after setting all properties.
function SelectFillColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectFillColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
 
function handles=RefreshOptions(handles);
 
i=get(handles.ToggleFillArrows,'Value');
if i==1
    set(handles.SelectFillColor,     'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
else
    set(handles.SelectFillColor,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
end
 
i=get(handles.ToggleAddNumbers,'Value');
if i==1
    set(handles.SelectFont,           'Enable','on');
    set(handles.TextRoundNumbers,     'Enable','on');
    set(handles.TextDecimals,         'Enable','on');
    set(handles.EditRoundNumbers,     'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
    set(handles.EditDecimals,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
else
    set(handles.SelectFont,           'Enable','off');
    set(handles.TextRoundNumbers,     'Enable','off');
    set(handles.TextDecimals,         'Enable','off');
    set(handles.EditRoundNumbers,     'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
    set(handles.EditDecimals,         'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
end
 



function EditUnitArrow_Callback(hObject, eventdata, handles)
% hObject    handle to EditUnitArrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditUnitArrow as text
%        str2double(get(hObject,'String')) returns contents of EditUnitArrow as a double


% --- Executes during object creation, after setting all properties.
function EditUnitArrow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditUnitArrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


