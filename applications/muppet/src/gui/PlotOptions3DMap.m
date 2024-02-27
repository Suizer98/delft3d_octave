function varargout = PlotOptions3DMap(varargin)
% PLOTOPTIONS3DMAP M-file for PlotOptions3DMap.fig
%      PLOTOPTIONS3DMAP, by itself, creates a new PLOTOPTIONS3DMAP or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONS3DMAP returns the handle to a new PLOTOPTIONS3DMAP or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONS3DMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONS3DMAP.M with the given input arguments.
%
%      PLOTOPTIONS3DMAP('Property','Value',...) creates a new PLOTOPTIONS3DMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptions3DMap_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptions3DMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptions3DMap
 
% Last Modified by GUIDE v2.5 30-May-2007 14:05:26
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptions3DMap_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptions3DMap_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptions3DMap is made visible.
function PlotOptions3DMap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptions3DMap (see VARARGIN)
 
% Choose default command line output for PlotOptions3DMap

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);

PutInCentre(hObject);
 
str{1}='3D Surface';
str{2}='3D Contour Lines';
str{3}='3D Surface with Contour Lines';
set(handles.SelectPlotRoutine,'String',str);
 
handles.PlotRoutines{1}='Plot3DSurface';
handles.PlotRoutines{2}='Plot3DContourLines';
handles.PlotRoutines{3}='Plot3DSurfaceLines';
 
switch lower(PlotOptions.PlotRoutine),
    case {'plot3dsurface'}
        i=1;
    case {'plot3dcontourlines'}
        i=2;
    case {'plot3dsurfacelines'}
        i=3;
end
set(handles.SelectPlotRoutine,'Value',i);
 
str{1}='flat';
str{2}='interp';
str{3}='texturemap';
str{4}='none';
set(handles.SelectShading,'String',str);
 
switch lower(PlotOptions.Shading),
    case {'flat'}
        i=1;
    case {'interp'}
        i=2;
    case {'texturemap'}
        i=3;
    case {'none'}
        i=4;
end
set(handles.SelectShading,'Value',i);

set(handles.EditContourMin,'String',num2str(PlotOptions.CMin));
set(handles.EditContourStep,'String',num2str(PlotOptions.CStep));
set(handles.EditContourMax,'String',num2str(PlotOptions.CMax));
 
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
    case {'','none'}
        i=5;
end
set(handles.SelectLineStyle,'Value',i);

nrcol=size(h.DefaultColors,2);
for i=1:nrcol
    handles.Colors{i}=h.DefaultColors(i).Name;
end
set(handles.SelectLineColor,'String',handles.Colors);
i=strmatch(lower(PlotOptions.LineColor),lower(handles.Colors),'exact');
set(handles.SelectLineColor,'Value',i);

set(handles.EditTransparency,'String',num2str(PlotOptions.Transparency));
set(handles.EditSpecularStrength,'String',num2str(PlotOptions.SpecularStrength));
 
set(handles.ToggleColor,'Value',PlotOptions.OneColor);
set(handles.PushSelectColor,'BackgroundColor',PlotOptions.Color);

set(handles.ToggleDraw3DGrid,'Value',PlotOptions.Draw3DGrid);
set(handles.SelectGridColor,'String',handles.Colors);
i=strmatch(lower(PlotOptions.LineColor),lower(handles.Colors),'exact');
set(handles.SelectGridColor,'Value',i);

handles=RefreshContours(handles);

handes.PlotOptions=PlotOptions;

% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptions3DMap wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptions3DMap_OutputFcn(hObject, eventdata, handles)
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
h.Figure(i).Axis(j).Plot(k).Contours(1)=str2num(get(handles.EditContourMin,'String'));
h.Figure(i).Axis(j).Plot(k).Contours(2)=str2num(get(handles.EditContourStep,'String'));
h.Figure(i).Axis(j).Plot(k).Contours(3)=str2num(get(handles.EditContourMax,'String'));
h.Figure(i).Axis(j).Plot(k).LineWidth=str2num(get(handles.EditLineWidth,'String'));
h.Figure(i).Axis(j).Plot(k).LineColor=handles.Colors{get(handles.SelectLineColor,'Value')};
h.Figure(i).Axis(j).Plot(k).LineStyle=handles.LineStyles{get(handles.SelectLineStyle,'Value')};
ii=get(handles.SelectGridColor,'Value');
str=handles.Colors{ii};
h.Figure(i).Axis(j).Plot(k).LineColor=str;
h.Figure(i).Axis(j).Plot(k).Draw3DGrid=get(handles.ToggleDraw3DGrid,'Value');
h.Figure(i).Axis(j).Plot(k).OneColor=get(handles.ToggleColor,'Value');
h.Figure(i).Axis(j).Plot(k).Color=get(handles.PushSelectColor,'BackgroundColor');
h.Figure(i).Axis(j).Plot(k).Transparency=str2num(get(handles.EditTransparency,'String'));
h.Figure(i).Axis(j).Plot(k).SpecularStrength=str2num(get(handles.EditSpecularStrength,'String'));
ii=get(handles.SelectShading,'Value');
str=get(handles.SelectShading,'String');
h.Figure(i).Axis(j).Plot(k).Shading=str{ii};

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
else
    set(handles.TextLabelSpacing,'Enable','on');
    set(handles.EditLabelSpacing,'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
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
 
function handles=RefreshContours(handles);
 
i=get(handles.SelectPlotRoutine,'Value');
 
switch i,
    case{1}
        set(handles.EditContourMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourStep,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectLineStyle,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectLineColor,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditLineWidth,         'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditTransparency,      'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextContours,          'Enable','off');
        set(handles.TextCMin,              'Enable','off');
        set(handles.TextCStep,             'Enable','off');
        set(handles.TextCMax,              'Enable','off');
        set(handles.SelectShading,         'Enable','on');
        set(handles.TextShading,           'Enable','on');
        set(handles.TextTransparency,      'Enable','on');
        set(handles.ToggleColor,           'Enable','on');
        set(handles.PushSelectColor,       'Enable','on');
    case{2}
        set(handles.EditContourMin,        'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditContourStep,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditContourMax,        'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectLineStyle,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectLineColor,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditLineWidth,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditTransparency,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextContours,          'Enable','on');
        set(handles.TextCMin,              'Enable','on');
        set(handles.TextCStep,             'Enable','on');
        set(handles.TextCMax,              'Enable','on');
        set(handles.SelectShading,         'Enable','off');
        set(handles.TextShading,           'Enable','off');
        set(handles.TextTransparency,      'Enable','off');
        set(handles.ToggleColor,           'Enable','off');
        set(handles.PushSelectColor,       'Enable','off');
    case{3}
        set(handles.EditContourMin,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourStep,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditContourMax,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectLineStyle,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectLineColor,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditLineWidth,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditTransparency,      'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextContours,          'Enable','off');
        set(handles.TextCMin,              'Enable','off');
        set(handles.TextCStep,             'Enable','off');
        set(handles.TextCMax,              'Enable','off');
        set(handles.SelectShading,         'Enable','on');
        set(handles.TextShading,           'Enable','on');
        set(handles.TextTransparency,      'Enable','on');
        set(handles.ToggleColor,           'Enable','on');
        set(handles.PushSelectColor,       'Enable','on');
end
 
 
% --- Executes on selection change in SelectShading.
function SelectShading_Callback(hObject, eventdata, handles)
% hObject    handle to SelectShading (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectShading contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectShading
 
 
% --- Executes during object creation, after setting all properties.
function SelectShading_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectShading (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
 
% --- Executes on button press in PushSelectColor.
function PushSelectColor_Callback(hObject, eventdata, handles)
% hObject    handle to PushSelectColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
col=uisetcolor;
set(hObject,'BackgroundColor',col);
 
guidata(hObject, handles);
 
% --- Executes on button press in ToggleColor.
function ToggleColor_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleColor
 
 
 
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
 
 


% --- Executes on button press in ToggleDraw3DGrid.
function ToggleDraw3DGrid_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleDraw3DGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleDraw3DGrid


% --- Executes on selection change in SelectGridColor.
function SelectGridColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectGridColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectGridColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectGridColor


% --- Executes during object creation, after setting all properties.
function SelectGridColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectGridColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end





function EditSpecularStrength_Callback(hObject, eventdata, handles)
% hObject    handle to EditSpecularStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSpecularStrength as text
%        str2double(get(hObject,'String')) returns contents of EditSpecularStrength as a double


% --- Executes during object creation, after setting all properties.
function EditSpecularStrength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSpecularStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
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


