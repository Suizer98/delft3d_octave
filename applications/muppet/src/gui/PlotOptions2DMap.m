function varargout = PlotOptions2DMap(varargin)
% PLOTOPTIONS2DMAP M-file for PlotOptions2DMap.fig
%      PLOTOPTIONS2DMAP, by itself, creates a new PLOTOPTIONS2DMAP or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONS2DMAP returns the handle to a new PLOTOPTIONS2DMAP or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONS2DMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONS2DMAP.M with the given input arguments.
%
%      PLOTOPTIONS2DMAP('Property','Value',...) creates a new PLOTOPTIONS2DMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptions2DMap_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptions2DMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptions2DMap
 
% Last Modified by GUIDE v2.5 16-Sep-2008 17:00:09
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptions2DMap_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptions2DMap_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptions2DMap is made visible.
function PlotOptions2DMap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptions2DMap (see VARARGIN)
 
% Choose default command line output for PlotOptions2DMap

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);

PutInCentre(hObject);
 
str{1}='Contour Map';
str{2}='Contour Lines';
str{3}='Shades Map';
str{4}='Patches';
str{5}='Contour Map and Lines';
str{6}='Draw Grid';
set(handles.SelectPlotRoutine,'String',str);
 
handles.PlotRoutines{1}='PlotContourMap';
handles.PlotRoutines{2}='PlotContourLines';
handles.PlotRoutines{3}='PlotShadesMap';
handles.PlotRoutines{4}='PlotPatches';
handles.PlotRoutines{5}='PlotContourMapLines';
handles.PlotRoutines{6}='PlotGrid';
 
switch lower(handles.PlotOptions.PlotRoutine),
    case {'plotcontourmap'}
        i=1;
    case {'plotcontourlines'}
        i=2;
    case {'plotshadesmap'}
        i=3;
    case {'plotpatches'}
        i=4;
    case {'plotcontourmaplines'}
        i=5;
    case {'plotgrid'}
        i=6;
end
set(handles.SelectPlotRoutine,'Value',i);
 
set(handles.EditContourMin,'String',num2str(handles.PlotOptions.CMin));
set(handles.EditContourStep,'String',num2str(handles.PlotOptions.CStep));
set(handles.EditContourMax,'String',num2str(handles.PlotOptions.CMax));

if strcmpi(handles.PlotOptions.ContourType,'custom')
    set(handles.ToggleCustomContours,'Value',1);
else
    set(handles.ToggleCustomContours,'Value',0);
end    

set(handles.ToggleElevationLabels,'Value',handles.PlotOptions.ContourLabels);
set(handles.EditLabelSpacing,'String',num2str(handles.PlotOptions.LabelSpacing));
if handles.PlotOptions.ContourLabels==0
    set(handles.TextLabelSpacing,'Enable','off');
    set(handles.EditLabelSpacing,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
end
 
set(handles.EditLineWidth,'String',num2str(handles.PlotOptions.LineWidth));
 
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
    case {'','none'}
        i=5;
end
set(handles.SelectLineStyle,'Value',i);

nrcol=size(h.DefaultColors,2);
handles.Colors{1}='auto';
for i=1:nrcol
    handles.Colors{i+1}=h.DefaultColors(i).Name;
end

set(handles.SelectLineColor,'String',handles.Colors);
i=strmatch(lower(handles.PlotOptions.LineColor),lower(handles.Colors),'exact');
set(handles.SelectLineColor,'Value',i);

set(handles.EditThinningFactor,'String',num2str(handles.PlotOptions.FieldThinningFactor1));

set(handles.ToggleAddDate,'Value',handles.PlotOptions.AddDate);
handles.AddDatePositions={'upper-left','upper-right','lower-left','lower-right'};
i=strmatch(lower(handles.PlotOptions.AddDatePosition),lower(handles.AddDatePositions),'exact');
set(handles.SelectAddDatePosition,'String',handles.AddDatePositions);
set(handles.SelectAddDatePosition,'Value',i);
set(handles.EditAddDatePrefix,'String',handles.PlotOptions.AddDatePrefix);
set(handles.EditAddDateSuffix,'String',handles.PlotOptions.AddDateSuffix);
dat=datenum(2005,04,28,14,38,25);
for i=1:31
    handles.DateFormats{i}=datestr(dat,i);
end
set(handles.SelectAddDateFormat,'String',handles.DateFormats);
set(handles.SelectAddDateFormat,'Value',handles.PlotOptions.AddDateFormat);

handles=RefreshContours(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptions2DMap wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptions2DMap_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1)
 
% --- Executes on selection change in SelectPlotRoutine.
function SelectPlotRoutine_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPlotRoutine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectPlotRoutine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectPlotRoutine
 
handles=RefreshContours(handles);
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
 
h.Figure(i).Axis(j).Plot(k).CMin=str2num(get(handles.EditContourMin,'String'));
h.Figure(i).Axis(j).Plot(k).CStep=str2num(get(handles.EditContourStep,'String'));
h.Figure(i).Axis(j).Plot(k).CMax=str2num(get(handles.EditContourMax,'String'));
 
h.Figure(i).Axis(j).Plot(k).LineWidth=str2num(get(handles.EditLineWidth,'String'));
h.Figure(i).Axis(j).Plot(k).LineColor=handles.Colors{get(handles.SelectLineColor,'Value')};
h.Figure(i).Axis(j).Plot(k).LineStyle=handles.LineStyles{get(handles.SelectLineStyle,'Value')};
 
h.Figure(i).Axis(j).Plot(k).ContourLabels=get(handles.ToggleElevationLabels,'Value');
h.Figure(i).Axis(j).Plot(k).LabelSpacing=str2num(get(handles.EditLabelSpacing,'String'));

h.Figure(i).Axis(j).Plot(k).FieldThinningFactor1=str2num(get(handles.EditThinningFactor,'String'));

h.Figure(i).Axis(j).Plot(k).Contours=handles.PlotOptions.Contours;

if get(handles.ToggleCustomContours,'Value')==1
    h.Figure(i).Axis(j).Plot(k).ContourType='custom';
else
    h.Figure(i).Axis(j).Plot(k).ContourType='limits';
end    

h.Figure(i).Axis(j).Plot(k).AddDate=get(handles.ToggleAddDate,'Value');
h.Figure(i).Axis(j).Plot(k).AddDatePosition=handles.AddDatePositions{get(handles.SelectAddDatePosition,'Value')};
h.Figure(i).Axis(j).Plot(k).AddDateFormat=get(handles.SelectAddDateFormat,'Value');
h.Figure(i).Axis(j).Plot(k).AddDatePrefix=get(handles.EditAddDatePrefix,'String');
h.Figure(i).Axis(j).Plot(k).AddDateSuffix=get(handles.EditAddDateSuffix,'String');
h.Figure(i).Axis(j).Plot(k).AddDateFont=handles.PlotOptions.AddDateFont;
h.Figure(i).Axis(j).Plot(k).AddDateFontSize=handles.PlotOptions.AddDateFontSize;
h.Figure(i).Axis(j).Plot(k).AddDateFontAngle=handles.PlotOptions.AddDateFontAngle;
h.Figure(i).Axis(j).Plot(k).AddDateFontWeight=handles.PlotOptions.AddDateFontWeight;
h.Figure(i).Axis(j).Plot(k).AddDateFontColor=handles.PlotOptions.AddDateFontColor;



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
 
function EditContourMin_Callback(hObject, eventdata, handles)
% hObject    handle to EditContourMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditContourMin as text
%        str2double(get(hObject,'String')) returns contents of EditContourMin as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditContourMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditContourMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditContourStep_Callback(hObject, eventdata, handles)
% hObject    handle to EditContourStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditContourStep as text
%        str2double(get(hObject,'String')) returns contents of EditContourStep as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditContourStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditContourStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditContourMax_Callback(hObject, eventdata, handles)
% hObject    handle to EditContourMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditContourMax as text
%        str2double(get(hObject,'String')) returns contents of EditContourMax as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditContourMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditContourMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
 
% --- Executes on button press in ToggleElevationLabels.
function ToggleElevationLabels_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleElevationLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleElevationLabels
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
 
k=get(hObject,'Value');
 
if k==0
    set(handles.TextLabelSpacing,'Enable','off');
    set(handles.EditLabelSpacing,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.SelectLabelFont,'Enable','off');
else
    set(handles.TextLabelSpacing,'Enable','on');
    set(handles.EditLabelSpacing,'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
    set(handles.SelectLabelFont,'Enable','on');
end
 
guidata(hObject, handles);
 
 
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
 
 
 
 
 
function EditLabelSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to EditLabelSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditLabelSpacing as text
%        str2double(get(hObject,'String')) returns contents of EditLabelSpacing as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditLabelSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLabelSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
 
function handles=RefreshContours(handles)
 
i=get(handles.SelectPlotRoutine,'Value');
 
switch i,
    case{1}
        set(handles.EditContourMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourStep,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectLineColor,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectLineStyle,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditLineWidth,         'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditLabelSpacing,      'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.ToggleElevationLabels, 'Enable','on');
        set(handles.SelectLabelFont,       'Enable','on');
        set(handles.TextContours,          'Enable','off');
        set(handles.TextCMin,              'Enable','off');
        set(handles.TextCStep,             'Enable','off');
        set(handles.TextCMax,              'Enable','off');
        set(handles.EditCustomContours,    'Enable','off');
        set(handles.ToggleCustomContours,  'Enable','off');
    case{2}
        set(handles.EditLineWidth,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectLineColor,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectLineStyle,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditLabelSpacing,      'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.ToggleElevationLabels, 'Enable','on');
        set(handles.SelectLabelFont,       'Enable','on');
        if get(handles.ToggleCustomContours,'Value')==0
            set(handles.EditContourMin,        'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
            set(handles.EditContourStep,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
            set(handles.EditContourMax,        'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
            set(handles.TextContours,          'Enable','on');
            set(handles.TextCMin,              'Enable','on');
            set(handles.TextCStep,             'Enable','on');
            set(handles.TextCMax,              'Enable','on');
        else
            set(handles.EditContourMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
            set(handles.EditContourStep,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
            set(handles.EditContourMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
            set(handles.TextContours,          'Enable','off');
            set(handles.TextCMin,              'Enable','off');
            set(handles.TextCStep,             'Enable','off');
            set(handles.TextCMax,              'Enable','off');
        end
        set(handles.EditCustomContours,    'Enable','on');
        set(handles.ToggleCustomContours,  'Enable','on');
    case{3,4}
        set(handles.EditContourMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourStep,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectLineColor,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectLineStyle,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditLineWidth,         'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.ToggleElevationLabels, 'Enable','off','Value',0);
        set(handles.EditLabelSpacing,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectLabelFont,       'Enable','off');
        set(handles.TextContours,          'Enable','off');
        set(handles.TextCMin,              'Enable','off');
        set(handles.TextCStep,             'Enable','off');
        set(handles.TextCMax,              'Enable','off');
        set(handles.EditCustomContours,    'Enable','off');
        set(handles.ToggleCustomContours,  'Enable','off');
    case{5}
        set(handles.EditContourMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourStep,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditLineWidth,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectLineColor,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectLineStyle,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditLabelSpacing,      'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.ToggleElevationLabels, 'Enable','on');
        set(handles.SelectLabelFont,       'Enable','on');
        set(handles.TextContours,          'Enable','on');
        set(handles.TextCMin,              'Enable','off');
        set(handles.TextCStep,             'Enable','off');
        set(handles.TextCMax,              'Enable','off');
        set(handles.EditCustomContours,    'Enable','off');
        set(handles.ToggleCustomContours,  'Enable','off');
    case{6}
        set(handles.EditContourMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourStep,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditLineWidth,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectLineColor,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectLineStyle,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.ToggleElevationLabels, 'Enable','off','Value',0);
        set(handles.EditLabelSpacing,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectLabelFont,       'Enable','off');
        set(handles.TextContours,          'Enable','off');
        set(handles.TextCMin,              'Enable','off');
        set(handles.TextCStep,             'Enable','off');
        set(handles.TextCMax,              'Enable','off');
        set(handles.EditCustomContours,    'Enable','off');
        set(handles.ToggleCustomContours,  'Enable','off');
end


% --- Executes on button press in ToggleCustomContours.
function ToggleCustomContours_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleCustomContours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleCustomContours

handles=RefreshContours(handles);
guidata(hObject, handles);

% --- Executes on button press in EditCustomContours.
function EditCustomContours_Callback(hObject, eventdata, handles)
% hObject    handle to EditCustomContours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cmin=handles.PlotOptions.CMin;
cmax=handles.PlotOptions.CMax;
cstep=handles.PlotOptions.CStep;
oricont=handles.PlotOptions.Contours;
%if size(oricont,2)==1 || isempty(oricont)
if isempty(oricont)
    oricont=cmin:cstep:cmax;
end

contours=EditCustomContours('oricont',oricont,'cmin',cmin,'cmax',cmax,'cstep',cstep);

handles.PlotOptions.Contours=contours;

guidata(hObject, handles);




function EditThinningFactor_Callback(hObject, eventdata, handles)
% hObject    handle to EditThinningFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditThinningFactor as text
%        str2double(get(hObject,'String')) returns contents of EditThinningFactor as a double


% --- Executes during object creation, after setting all properties.
function EditThinningFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditThinningFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




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




% --- Executes on selection change in SelectLineColor.
function SelectLineColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectLineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectLineColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectLineColor


% --- Executes during object creation, after setting all properties.
function SelectLineColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectLineColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in SelectLabelFont.
function SelectLabelFont_Callback(hObject, eventdata, handles)
% hObject    handle to SelectLabelFont (see GCBO)
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



% --- Executes on button press in SelectDateFont.
function SelectDateFont_Callback(hObject, eventdata, handles)
% hObject    handle to SelectDateFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.PlotOptions.AddDateFont;
Font.Size=handles.PlotOptions.AddDateFontSize;
Font.Angle=handles.PlotOptions.AddDateFontAngle;
Font.Weight=handles.PlotOptions.AddDateFontWeight;
Font.Color=handles.PlotOptions.AddDateFontColor;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.PlotOptions.AddDateFont=Font.Type;
handles.PlotOptions.AddDateFontSize=Font.Size;
handles.PlotOptions.AddDateFontAngle=Font.Angle;
handles.PlotOptions.AddDateFontWeight=Font.Weight;
handles.PlotOptions.AddDateFontColor=Font.Color;

guidata(hObject, handles);


function EditAddDateSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to EditAddDateSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditAddDateSuffix as text
%        str2double(get(hObject,'String')) returns contents of EditAddDateSuffix as a double


% --- Executes during object creation, after setting all properties.
function EditAddDateSuffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditAddDateSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


