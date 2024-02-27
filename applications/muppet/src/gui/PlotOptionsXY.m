function varargout = PlotOptionsXY(varargin)
% PLOTOPTIONSXY M-file for PlotOptionsXY.fig
%      PLOTOPTIONSXY, by itself, creates a new PLOTOPTIONSXY or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONSXY returns the handle to a new PLOTOPTIONSXY or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONSXY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONSXY.M with the given input arguments.
%
%      PLOTOPTIONSXY('Property','Value',...) creates a new PLOTOPTIONSXY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptionsXY_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptionsXY_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptionsXY
 
% Last Modified by GUIDE v2.5 01-Apr-2008 14:04:19
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptionsXY_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptionsXY_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptionsXY is made visible.
function PlotOptionsXY_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptionsXY (see VARARGIN)
 
% Choose default command line output for PlotOptionsXY
 
h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);

PutInCentre(hObject);
 
str{1}='Line';
str{2}='Spline';
str{3}='Histogram';
str{4}='Stacked Area';
set(handles.SelectPlotRoutine,'String',str);
 
handles.PlotRoutines{1}='PlotLine';
handles.PlotRoutines{2}='PlotSpline';
handles.PlotRoutines{3}='PlotHistogram';
handles.PlotRoutines{4}='PlotStackedArea';
 
a=handles.PlotOptions.PlotRoutine;
switch lower(a),
    case {'plotline'}
        i=1;
    case {'plotspline'}
        i=2;
    case {'plothistogram'}
        i=3;
    case {'plotstackedarea'}
        i=4;
end
set(handles.SelectPlotRoutine,'Value',i);
 
set(handles.EditLineWidth,'String',num2str(handles.PlotOptions.LineWidth));
 
clear str
str={'-','--','-.',':','none'};
set(handles.SelectLineStyle,'String',str);
handles.LineStyles={'-','--','-.',':','none'};
 
switch lower(handles.PlotOptions.LineStyle),
    case {'-'}
        i=1;
    case {'--'}
        i=2;
    case {'-.'}
        i=3;
    case {':'}
        i=4;
    case {'none'}
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

handles.FaceColors=handles.Colors;
handles.FaceColors{nrcol+1}='none';

set(handles.SelectFaceColor,'String',handles.FaceColors);
i=strmatch(lower(handles.PlotOptions.FillColor),lower(handles.FaceColors),'exact');
set(handles.SelectFaceColor,'Value',i);

set(handles.SelectEdgeColor,'String',handles.FaceColors);
i=strmatch(lower(handles.PlotOptions.EdgeColor),lower(handles.FaceColors),'exact');
set(handles.SelectEdgeColor,'Value',i);

clear str
str={'none','point','circle','x-mark','plus','star','square','diamond','triangle (down)', ...
     'triangle (up)','triangle (left)','triangle (right)','pentagram','hexagram'};
set(handles.SelectMarker,'String',str);
handles.Markers={'none','.','o','x','+','*','s','d','v','^','<','>','p','h'};
i=strmatch(lower(handles.PlotOptions.Marker),lower(handles.Markers),'exact');
if size(i,2)==0
    i=1;
end
set(handles.SelectMarker,'Value',i);
 
set(handles.EditLegendText,'String',handles.PlotOptions.LegendText);

set(handles.ToggleRightAxis,'Value',handles.PlotOptions.RightAxis);

ii=FindDatasetNr(handles.PlotOptions.Name,h.DataProperties);
handles.DataType=h.DataProperties(ii).Type;

if strcmpi(handles.DataType,'timeseries')
    tim=MatTime(handles.PlotOptions.TimeBar(1),handles.PlotOptions.TimeBar(2));
    datestring=datestr(tim,'yyyymmdd');
    timestring=datestr(tim,'HHMMSS');
    set(handles.EditTimeBar1,'String',datestring);
    set(handles.EditTimeBar2,'String',timestring);
else
    set(handles.EditTimeBar1,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.EditTimeBar2,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.TextTimeBar,'Enable','off');
    set(handles.Textyyyymmdd,'Enable','off');
    set(handles.TextHHMMSS,'Enable','off');
end

% handles.DateTime=h.DataProperties(handles.PlotOptions.AvailableDatasetNr).DateTime;

set(handles.ToggleAddDate,'Value',handles.PlotOptions.AddDate);
handles.AddDatePositions={'upper-left','upper-right','lower-left','lower-right'};
i=strmatch(lower(handles.PlotOptions.AddDatePosition),lower(handles.AddDatePositions),'exact');
set(handles.SelectAddDatePosition,'String',handles.AddDatePositions);
set(handles.SelectAddDatePosition,'Value',i);
set(handles.EditAddDatePrefix,'String',handles.PlotOptions.AddDatePrefix);
dat=datenum(2005,04,28,14,38,25);
for i=1:31
    handles.DateFormats{i}=datestr(dat,i);
end
set(handles.SelectAddDateFormat,'String',handles.DateFormats);
set(handles.SelectAddDateFormat,'Value',handles.PlotOptions.AddDateFormat);




handles=RefreshOptions(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptionsXY wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptionsXY_OutputFcn(hObject, eventdata, handles)
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
ii=get(handles.SelectPlotRoutine,'Value');
h.Figure(i).Axis(j).Plot(k).PlotRoutine=handles.PlotRoutines{ii};
h.Figure(i).Axis(j).Plot(k).LineWidth=str2num(get(handles.EditLineWidth,'String'));
h.Figure(i).Axis(j).Plot(k).LineColor=handles.Colors{get(handles.SelectColor,'Value')};
h.Figure(i).Axis(j).Plot(k).LineStyle=handles.LineStyles{get(handles.SelectLineStyle,'Value')};
h.Figure(i).Axis(j).Plot(k).Marker=handles.Markers{get(handles.SelectMarker,'Value')};
h.Figure(i).Axis(j).Plot(k).LegendText=get(handles.EditLegendText,'String');
h.Figure(i).Axis(j).Plot(k).RightAxis=get(handles.ToggleRightAxis,'Value');
h.Figure(i).Axis(j).Plot(k).FillColor=handles.FaceColors{get(handles.SelectFaceColor,'Value')};
h.Figure(i).Axis(j).Plot(k).EdgeColor=handles.FaceColors{get(handles.SelectEdgeColor,'Value')};

if strcmpi(handles.DataType,'timeseries')
    t1=str2double(get(handles.EditTimeBar1,'String'));
    if t1>100000
        h.Figure(i).Axis(j).Plot(k).TimeBar(1)=str2double(get(handles.EditTimeBar1,'String'));
        h.Figure(i).Axis(j).Plot(k).TimeBar(2)=str2double(get(handles.EditTimeBar2,'String'));
    else
        h.Figure(i).Axis(j).Plot(k).TimeBar=[0 0];
    end
end

h.Figure(i).Axis(j).Plot(k).AddDate=get(handles.ToggleAddDate,'Value');
h.Figure(i).Axis(j).Plot(k).AddDatePosition=handles.AddDatePositions{get(handles.SelectAddDatePosition,'Value')};
h.Figure(i).Axis(j).Plot(k).AddDateFormat=get(handles.SelectAddDateFormat,'Value');
h.Figure(i).Axis(j).Plot(k).AddDatePrefix=get(handles.EditAddDatePrefix,'String');

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
 
 


% --- Executes on button press in ToggleRightAxis.
function ToggleRightAxis_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleRightAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleRightAxis





function EditTimeBar1_Callback(hObject, eventdata, handles)
% hObject    handle to EditTimeBar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTimeBar1 as text
%        str2double(get(hObject,'String')) returns contents of EditTimeBar1 as a double


% --- Executes during object creation, after setting all properties.
function EditTimeBar1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTimeBar1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTimeBar2_Callback(hObject, eventdata, handles)
% hObject    handle to EditTimeBar2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTimeBar2 as text
%        str2double(get(hObject,'String')) returns contents of EditTimeBar2 as a double


% --- Executes during object creation, after setting all properties.
function EditTimeBar2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTimeBar2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on selection change in SelectFaceColor.
function SelectFaceColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFaceColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectFaceColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectFaceColor


% --- Executes during object creation, after setting all properties.
function SelectFaceColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectFaceColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectEdgeColor.
function SelectEdgeColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectEdgeColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectEdgeColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectEdgeColor


% --- Executes during object creation, after setting all properties.
function SelectEdgeColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectEdgeColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function handles=RefreshOptions(handles)

ii=get(handles.SelectPlotRoutine,'Value');

if ii==1 || ii==2
    set(handles.SelectColor,'Enable','on');
    set(handles.SelectMarker,'Enable','on');
    set(handles.SelectLineStyle,'Enable','on');
    set(handles.ToggleRightAxis,'Enable','on');
    set(handles.EditLineWidth,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.TextLineColor,'Enable','on');
    set(handles.TextMarker,'Enable','on');
    set(handles.TextLineStyle,'Enable','on');
    set(handles.TextLineWidth,'Enable','on');
    set(handles.SelectEdgeColor,'Enable','off');
    set(handles.SelectFaceColor,'Enable','off');
    set(handles.TextEdgeColor,'Enable','off');
    set(handles.TextFaceColor,'Enable','off');
else
    set(handles.SelectColor,'Enable','off');
    set(handles.SelectMarker,'Enable','off');
    set(handles.SelectLineStyle,'Enable','off');
    set(handles.ToggleRightAxis,'Enable','off');
    set(handles.EditLineWidth,'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
    set(handles.TextLineColor,'Enable','off');
    set(handles.TextMarker,'Enable','off');
    set(handles.TextLineStyle,'Enable','off');
    set(handles.TextLineWidth,'Enable','off');
    set(handles.SelectEdgeColor,'Enable','on');
    set(handles.SelectFaceColor,'Enable','on');
    set(handles.TextEdgeColor,'Enable','on');
    set(handles.TextFaceColor,'Enable','on');
end

% if handles.DateTime==0
    set(handles.ToggleAddDate,'Visible','off');
    set(handles.SelectAddDateFormat,'Visible','off');
    set(handles.SelectAddDatePosition,'Visible','off');
    set(handles.EditAddDatePrefix,'Visible','off');
    set(handles.TextAddDateFormat,'Visible','off');
% else
%     set(handles.ToggleAddDate,'Visible','on');
%     set(handles.SelectAddDateFormat,'Visible','on');
%     set(handles.SelectAddDatePosition,'Visible','on');
%     set(handles.EditAddDatePrefix,'Visible','on');
%     set(handles.TextAddDateFormat,'Visible','on');
% end

% --- Executes on button press in ToggleAddDate.
function ToggleAddDate_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAddDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAddDate


% --- Executes on selection change in SelectAddDatePosition.
function SelectAddDatePosition_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAddDatePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectAddDatePosition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectAddDatePosition


% --- Executes during object creation, after setting all properties.
function SelectAddDatePosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectAddDatePosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditAddDatePrefix_Callback(hObject, eventdata, handles)
% hObject    handle to EditAddDatePrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditAddDatePrefix as text
%        str2double(get(hObject,'String')) returns contents of EditAddDatePrefix as a double


% --- Executes during object creation, after setting all properties.
function EditAddDatePrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditAddDatePrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectAddDateFormat.
function SelectAddDateFormat_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAddDateFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectAddDateFormat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectAddDateFormat


% --- Executes during object creation, after setting all properties.
function SelectAddDateFormat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectAddDateFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


