function varargout = PlotOptions2DVector(varargin)
% PLOTOPTIONS2DVECTOR M-file for PlotOptions2DVector.fig
%      PLOTOPTIONS2DVECTOR, by itself, creates a new PLOTOPTIONS2DVECTOR or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONS2DVECTOR returns the handle to a new PLOTOPTIONS2DVECTOR or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONS2DVECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONS2DVECTOR.M with the given input arguments.
%
%      PLOTOPTIONS2DVECTOR('Property','Value',...) creates a new PLOTOPTIONS2DVECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptions2DVector_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptions2DVector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help PlotOptions2DVector
 
% Last Modified by GUIDE v2.5 19-Oct-2007 15:52:17
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotOptions2DVector_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotOptions2DVector_OutputFcn, ...
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
 
 
% --- Executes just before PlotOptions2DVector is made visible.
function PlotOptions2DVector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptions2DVector (see VARARGIN)
 
% Choose default command line output for PlotOptions2DVector

h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.ColorMaps=h.ColorMaps;
k=FindDatasetNr(h.Figure(handles.i).Axis(handles.j).Plot(handles.k).Name,h.DataProperties);
handles.typ=h.DataProperties(k).Type;
handles.PlotOptions=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);

PutInCentre(hObject);
 
str{1}='Vectors';
str{2}='Colored Vectors';
str{3}='Curved Arrows';
str{4}='Colored Curved Arrows';
str{5}='Magnitude';
set(handles.SelectPlotRoutine,'String',str);
 
handles.PlotRoutines{1}='PlotVectors';
handles.PlotRoutines{2}='PlotColoredVectors';
handles.PlotRoutines{3}='PlotCurvedArrows';
handles.PlotRoutines{4}='PlotColoredCurvedArrows';
handles.PlotRoutines{5}='PlotVectorMagnitude';
ii=strmatch(lower(handles.PlotOptions.PlotRoutine),lower(handles.PlotRoutines));
set(handles.SelectPlotRoutine,'Value',ii);
 
set(handles.EditUnitVector,'String',num2str(handles.PlotOptions.UnitVector));
 
handles.FieldThinningTypes={'None','Uniform','Distance'};
set(handles.SelectFieldThinning,'String',handles.FieldThinningTypes);
 
fieldthinningtypes={'none','uniform','distance'};
ii=strmatch(lower(handles.PlotOptions.FieldThinningType),lower(fieldthinningtypes));
set(handles.SelectFieldThinning,'Value',ii);

set(handles.EditFieldThinningFactor1,'String',num2str(handles.PlotOptions.FieldThinningFactor1));
set(handles.EditFieldThinningFactor2,'String',num2str(handles.PlotOptions.FieldThinningFactor2));

set(handles.EditVerticalScaling,'String',num2str(handles.PlotOptions.VerticalVectorScaling));

nrcol=size(handles.DefaultColors,2);
for i=1:nrcol
    handles.VectorColors{i}=handles.DefaultColors(i).Name;
end
set(handles.SelectVectorColor,'String',handles.VectorColors);
i=strmatch(lower(handles.PlotOptions.VectorColor),lower(handles.VectorColors),'exact');
set(handles.SelectVectorColor,'Value',i);

set(handles.EditVectorLegendLength,'String',num2str(handles.PlotOptions.VectorLegendLength));
set(handles.EditVectorLegendText,'String',handles.PlotOptions.VectorLegendText);

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

set(handles.EditDx,'String',num2str(handles.PlotOptions.DxCurVec));
set(handles.EditDt,'String',num2str(handles.PlotOptions.DtCurVec));
set(handles.EditHeadThickness,'String',num2str(handles.PlotOptions.HeadThickness));
set(handles.EditArrowThickness,'String',num2str(handles.PlotOptions.ArrowThickness));
% set(handles.EditTimeStep,'String',num2str(handles.PlotOptions.DDtCurVec));
set(handles.EditLifeSpan,'String',num2str(handles.PlotOptions.LifeSpanCurVec));
set(handles.EditRelativeSpeed,'String',num2str(handles.PlotOptions.RelSpeedCurVec));
set(handles.EditNoFramesStationary,'String',num2str(handles.PlotOptions.NoFramesStationaryCurVec));

for i=1:nrcol
    handles.FillColors{i}=handles.DefaultColors(i).Name;
    handles.EdgeColors{i}=handles.DefaultColors(i).Name;
end
handles.FillColors{nrcol+1}='none';
handles.EdgeColors{nrcol+1}='none';

set(handles.SelectEdgeColor,'String',handles.EdgeColors);
i=strmatch(lower(handles.PlotOptions.LineColor),lower(handles.EdgeColors),'exact');
set(handles.SelectEdgeColor,'Value',i);

set(handles.SelectFillColor,'String',handles.FillColors);
i=strmatch(lower(handles.PlotOptions.FillColor),lower(handles.FillColors),'exact');
set(handles.SelectFillColor,'Value',i);

set(handles.EditCMin,'String',num2str(handles.PlotOptions.CMin));
set(handles.EditCMax,'String',num2str(handles.PlotOptions.CMax));
set(handles.EditCStep,'String',num2str(handles.PlotOptions.CStep));

for m=1:size(handles.ColorMaps,2)
    colmaps{m}=handles.ColorMaps(m).Name;
end
i=strmatch(lower(handles.PlotOptions.ColorMap),lower(colmaps),'exact');
set(handles.SelectColorMap,'String',colmaps);
set(handles.SelectColorMap,'Value',i);

set(handles.ToggleColorBar,'Value',handles.PlotOptions.PlotColorBar);

handles=RefreshOptions(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes PlotOptions2DVector wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = PlotOptions2DVector_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1);
 
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
h.Figure(i).Axis(j).Plot(k).UnitVector=str2num(get(handles.EditUnitVector,'String'));
h.Figure(i).Axis(j).Plot(k).FieldThinningType=handles.FieldThinningTypes{get(handles.SelectFieldThinning,'Value')};
h.Figure(i).Axis(j).Plot(k).FieldThinningFactor1=str2num(get(handles.EditFieldThinningFactor1,'String'));
if strcmp(lower(handles.typ),'3dcrosssectionvector')
    h.Figure(i).Axis(j).Plot(k).FieldThinningFactor2=str2num(get(handles.EditFieldThinningFactor2,'String'));
else
    h.Figure(i).Axis(j).Plot(k).FieldThinningFactor2=h.Figure(i).Axis(j).Plot(k).FieldThinningFactor1;
end
h.Figure(i).Axis(j).Plot(k).VerticalVectorScaling=str2num(get(handles.EditVerticalScaling,'String'));
h.Figure(i).Axis(j).Plot(k).VectorColor=handles.VectorColors{get(handles.SelectVectorColor,'Value')};
h.Figure(i).Axis(j).Plot(k).VectorLegendLength=str2num(get(handles.EditVectorLegendLength,'String'));
h.Figure(i).Axis(j).Plot(k).VectorLegendText=get(handles.EditVectorLegendText,'String');
h.Figure(i).Axis(j).Plot(k).DxCurVec=str2num(get(handles.EditDx,'String'));
h.Figure(i).Axis(j).Plot(k).DtCurVec=str2num(get(handles.EditDt,'String'));
h.Figure(i).Axis(j).Plot(k).LineColor=handles.EdgeColors{get(handles.SelectEdgeColor,'Value')};
h.Figure(i).Axis(j).Plot(k).FillColor=handles.FillColors{get(handles.SelectFillColor,'Value')};
h.Figure(i).Axis(j).Plot(k).HeadThickness=str2num(get(handles.EditHeadThickness,'String'));
h.Figure(i).Axis(j).Plot(k).ArrowThickness=str2num(get(handles.EditArrowThickness,'String'));
%h.Figure(i).Axis(j).Plot(k).DDtCurVec=str2num(get(handles.EditTimeStep,'String'));
h.Figure(i).Axis(j).Plot(k).LifeSpanCurVec=str2num(get(handles.EditLifeSpan,'String'));
h.Figure(i).Axis(j).Plot(k).RelSpeedCurVec=str2num(get(handles.EditRelativeSpeed,'String'));
h.Figure(i).Axis(j).Plot(k).NoFramesStationaryCurVec=str2num(get(handles.EditNoFramesStationary,'String'));
h.Figure(i).Axis(j).Plot(k).AddDate=get(handles.ToggleAddDate,'Value');
h.Figure(i).Axis(j).Plot(k).AddDatePosition=handles.AddDatePositions{get(handles.SelectAddDatePosition,'Value')};
h.Figure(i).Axis(j).Plot(k).AddDatePrefix=get(handles.EditAddDatePrefix,'String');
h.Figure(i).Axis(j).Plot(k).AddDateFormat=get(handles.SelectAddDateFormat,'Value');
h.Figure(i).Axis(j).Plot(k).CMin=str2num(get(handles.EditCMin,'String'));
h.Figure(i).Axis(j).Plot(k).CMax=str2num(get(handles.EditCMax,'String'));
h.Figure(i).Axis(j).Plot(k).CStep=str2num(get(handles.EditCStep,'String'));
h.Figure(i).Axis(j).Plot(k).PlotColorBar=get(handles.ToggleColorBar,'Value');
str=get(handles.SelectColorMap,'String');
ii=get(handles.SelectColorMap,'Value');
h.Figure(i).Axis(j).Plot(k).ColMap=str{ii};
if ~strcmp(lower(h.Figure(i).Axis(j).Plot(k).PlotRoutine),'plotcoloredcurvedarrows') & ~strcmp(lower(h.Figure(i).Axis(j).Plot(k).PlotRoutine),'plotcoloredvectors')
    h.Figure(i).Axis(j).Plot(k).PlotColorBar=0;
end

handles.output=h;
 
guidata(hObject, handles);
 
uiresume;
 
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
uiresume;
 
% --- Executes on selection change in SelectVectorColor.
function SelectVectorColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectVectorColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectVectorColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectVectorColor
 
 
% --- Executes during object creation, after setting all properties.
function SelectVectorColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectVectorColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
 
 
function EditUnitVector_Callback(hObject, eventdata, handles)
% hObject    handle to EditUnitVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditUnitVector as text
%        str2double(get(hObject,'String')) returns contents of EditUnitVector as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditUnitVector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditUnitVector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in SelectFieldThinning.
function SelectFieldThinning_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFieldThinning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectFieldThinning contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectFieldThinning
 
handles=RefreshOptions(handles);
guidata(hObject, handles);
 
 
% --- Executes during object creation, after setting all properties.
function SelectFieldThinning_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectFieldThinning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditFieldThinningFactor1_Callback(hObject, eventdata, handles)
% hObject    handle to EditFieldThinningFactor1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditFieldThinningFactor1 as text
%        str2double(get(hObject,'String')) returns contents of EditFieldThinningFactor1 as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditFieldThinningFactor1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFieldThinningFactor1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
 
 
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
 
 



function EditVectorLegendLength_Callback(hObject, eventdata, handles)
% hObject    handle to EditVectorLegendLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditVectorLegendLength as text
%        str2double(get(hObject,'String')) returns contents of EditVectorLegendLength as a double


% --- Executes during object creation, after setting all properties.
function EditVectorLegendLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditVectorLegendLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditVectorLegendText_Callback(hObject, eventdata, handles)
% hObject    handle to EditVectorLegendText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditVectorLegendText as text
%        str2double(get(hObject,'String')) returns contents of EditVectorLegendText as a double


% --- Executes during object creation, after setting all properties.
function EditVectorLegendText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditVectorLegendText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end





function EditFieldThinningFactor2_Callback(hObject, eventdata, handles)
% hObject    handle to EditFieldThinningFactor2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFieldThinningFactor2 as text
%        str2double(get(hObject,'String')) returns contents of EditFieldThinningFactor2 as a double


% --- Executes during object creation, after setting all properties.
function EditFieldThinningFactor2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFieldThinningFactor2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditVerticalScaling_Callback(hObject, eventdata, handles)
% hObject    handle to EditVerticalScaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditVerticalScaling as text
%        str2double(get(hObject,'String')) returns contents of EditVerticalScaling as a double


% --- Executes during object creation, after setting all properties.
function EditVerticalScaling_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditVerticalScaling (see GCBO)
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


function EditDx_Callback(hObject, eventdata, handles)
% hObject    handle to EditDx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDx as text
%        str2double(get(hObject,'String')) returns contents of EditDx as a double


% --- Executes during object creation, after setting all properties.
function EditDx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditDt_Callback(hObject, eventdata, handles)
% hObject    handle to EditDt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDt as text
%        str2double(get(hObject,'String')) returns contents of EditDt as a double


% --- Executes during object creation, after setting all properties.
function EditDt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditHeadThickness_Callback(hObject, eventdata, handles)
% hObject    handle to EditHeadThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditHeadThickness as text
%        str2double(get(hObject,'String')) returns contents of EditHeadThickness as a double


% --- Executes during object creation, after setting all properties.
function EditHeadThickness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditHeadThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditArrowThickness_Callback(hObject, eventdata, handles)
% hObject    handle to EditArrowThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditArrowThickness as text
%        str2double(get(hObject,'String')) returns contents of EditArrowThickness as a double


% --- Executes during object creation, after setting all properties.
function EditArrowThickness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditArrowThickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function EditTimeStep_Callback(hObject, eventdata, handles)
% hObject    handle to EditTimeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTimeStep as text
%        str2double(get(hObject,'String')) returns contents of EditTimeStep as a double


% --- Executes during object creation, after setting all properties.
function EditTimeStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTimeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditLifeSpan_Callback(hObject, eventdata, handles)
% hObject    handle to EditLifeSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditLifeSpan as text
%        str2double(get(hObject,'String')) returns contents of EditLifeSpan as a double


% --- Executes during object creation, after setting all properties.
function EditLifeSpan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLifeSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function EditRelativeSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to EditRelativeSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditRelativeSpeed as text
%        str2double(get(hObject,'String')) returns contents of EditRelativeSpeed as a double


% --- Executes during object creation, after setting all properties.
function EditRelativeSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditRelativeSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function EditNoFramesStationary_Callback(hObject, eventdata, handles)
% hObject    handle to EditNoFramesStationary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditNoFramesStationary as text
%        str2double(get(hObject,'String')) returns contents of EditNoFramesStationary as a double


% --- Executes during object creation, after setting all properties.
function EditNoFramesStationary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNoFramesStationary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditCMax_Callback(hObject, eventdata, handles)
% hObject    handle to EditCMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditCMax as text
%        str2double(get(hObject,'String')) returns contents of EditCMax as a double


% --- Executes during object creation, after setting all properties.
function EditCMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditCStep_Callback(hObject, eventdata, handles)
% hObject    handle to EditCStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditCStep as text
%        str2double(get(hObject,'String')) returns contents of EditCStep as a double


% --- Executes during object creation, after setting all properties.
function EditCStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectColorMap.
function SelectColorMap_Callback(hObject, eventdata, handles)
% hObject    handle to SelectColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectColorMap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectColorMap


% --- Executes during object creation, after setting all properties.
function SelectColorMap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ToggleColorBar.
function ToggleColorBar_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleColorBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleColorBar


% --- Executes on button press in PushEditColorBar.
function PushEditColorBar_Callback(hObject, eventdata, handles)
% hObject    handle to PushEditColorBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=guidata(findobj('Name','Muppet'));
h=EditColorBar('handles',h,'iopt',2);
guidata(findobj('Name','Muppet'),h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
 
function handles=RefreshOptions(handles);
 
i=get(handles.SelectFieldThinning,'Value');
 
set(handles.EditFieldThinningFactor1, 'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.TextFieldThinningFactor1, 'Enable','off');
set(handles.EditFieldThinningFactor2, 'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
set(handles.TextFieldThinningFactor2, 'Enable','off');

switch i,
    case{1}
        set(handles.EditFieldThinningFactor1, 'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextFieldThinningFactor1, 'Enable','off');
    case{2}
        set(handles.EditFieldThinningFactor1, 'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextFieldThinningFactor1, 'Enable','on', 'String','Factor X')
        if strcmp(lower(handles.typ),'3dcrosssectionvector')
            set(handles.EditFieldThinningFactor2, 'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
            set(handles.TextFieldThinningFactor2, 'Enable','on', 'String','Factor Y');
        end
    case{3}
        set(handles.EditFieldThinningFactor1, 'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextFieldThinningFactor1, 'Enable','on', 'String','Distance')
end
 
j=get(handles.SelectPlotRoutine,'Value');
 
switch j,
    case{1}
        set(handles.EditUnitVector,          'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextUnitVector,          'Enable','on');
        set(handles.TextFieldThinning,       'Enable','on');
        set(handles.TextVectorColor,         'Enable','on');
        set(handles.SelectFieldThinning,     'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectVectorColor,       'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);

        set(handles.TextLegendLength,        'Enable','on');
        set(handles.TextLegendText,          'Enable','on');
        set(handles.EditVectorLegendLength,  'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditVectorLegendText,    'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        
        set(handles.TextDistance,            'Enable','off');
        set(handles.TextLength,              'Enable','off');
        set(handles.TextFillColor,           'Enable','off');
        set(handles.TextEdgeColor,           'Enable','off');
        set(handles.EditDx,                  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditDt,                  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectFillColor,         'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectEdgeColor,         'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextHeadThickness,       'Enable','off');
        set(handles.TextArrowThickness,      'Enable','off');
        set(handles.EditHeadThickness,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditArrowThickness,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextTimeStep,            'Enable','off');
        set(handles.TextLifeSpan,            'Enable','off');
        set(handles.EditTimeStep,            'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditLifeSpan,            'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextRelativeSpeed,       'Enable','off');
        set(handles.EditRelativeSpeed,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextNoFramesStationary,  'Enable','off');
        set(handles.EditNoFramesStationary,  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);

        set(handles.TextCMin,                'Enable','off');
        set(handles.TextCMax,                'Enable','off');
        set(handles.TextCStep,               'Enable','off');
        set(handles.EditCMin,                'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditCMax,                'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditCStep,               'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectColorMap,          'Enable','off');       
        set(handles.ToggleColorBar,          'Enable','off');       
        set(handles.PushEditColorBar,        'Enable','off');       
        
    case{2}
        set(handles.EditUnitVector,          'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextUnitVector,          'Enable','on');
        set(handles.TextFieldThinning,       'Enable','on');
        set(handles.TextVectorColor,         'Enable','off');
        set(handles.SelectFieldThinning,     'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectVectorColor,       'Enable','off', 'BackGroundColor',[1.0 1.0 1.0]);

        set(handles.TextLegendLength,        'Enable','on');
        set(handles.TextLegendText,          'Enable','on');
        set(handles.EditVectorLegendLength,  'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditVectorLegendText,    'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        
        set(handles.TextDistance,            'Enable','off');
        set(handles.TextLength,              'Enable','off');
        set(handles.TextFillColor,           'Enable','off');
        set(handles.TextEdgeColor,           'Enable','off');
        set(handles.EditDx,                  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditDt,                  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectFillColor,         'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectEdgeColor,         'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextHeadThickness,       'Enable','off');
        set(handles.TextArrowThickness,      'Enable','off');
        set(handles.EditHeadThickness,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditArrowThickness,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextTimeStep,            'Enable','off');
        set(handles.TextLifeSpan,            'Enable','off');
        set(handles.EditTimeStep,            'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditLifeSpan,            'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextRelativeSpeed,       'Enable','off');
        set(handles.EditRelativeSpeed,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextNoFramesStationary,  'Enable','off');
        set(handles.EditNoFramesStationary,  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);

%         set(handles.TextCMin,                'Enable','off');
%         set(handles.TextCMax,                'Enable','off');
%         set(handles.TextCStep,               'Enable','off');
%         set(handles.EditCMin,                'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
%         set(handles.EditCMax,                'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
%         set(handles.EditCStep,               'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
%         set(handles.SelectColorMap,          'Enable','off');       
%         set(handles.ToggleColorBar,          'Enable','off');       
%         set(handles.PushEditColorBar,        'Enable','off');       

        set(handles.TextCMin,                'Enable','on');
        set(handles.TextCMax,                'Enable','on');
        set(handles.TextCStep,               'Enable','on');
        set(handles.EditCMin,                'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditCMax,                'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditCStep,               'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectColorMap,          'Enable','on');       
        set(handles.ToggleColorBar,          'Enable','on');       
        set(handles.PushEditColorBar,        'Enable','on');

    case{3}
        set(handles.EditUnitVector,          'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectFieldThinning,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditFieldThinningFactor1, 'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextUnitVector,          'Enable','off');
        set(handles.TextFieldThinning,       'Enable','off');
        set(handles.TextFieldThinningFactor1, 'Enable','off');
        set(handles.TextVectorColor,         'Enable','off');
        set(handles.SelectVectorColor,       'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);

        set(handles.TextLegendLength,        'Enable','on');
        set(handles.TextLegendText,          'Enable','on');
        set(handles.EditVectorLegendLength,  'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditVectorLegendText,    'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        
        set(handles.TextDistance,            'Enable','on');
        set(handles.TextLength,              'Enable','on');
        set(handles.TextFillColor,           'Enable','on');
        set(handles.TextEdgeColor,           'Enable','on');
        set(handles.EditDx,                  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditDt,                  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectFillColor,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectEdgeColor,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextHeadThickness,       'Enable','on');
        set(handles.TextArrowThickness,      'Enable','on');
        set(handles.EditHeadThickness,       'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditArrowThickness,      'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextTimeStep,            'Enable','on');
        set(handles.TextLifeSpan,            'Enable','on');
        set(handles.EditTimeStep,            'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditLifeSpan,            'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextRelativeSpeed,       'Enable','on');
        set(handles.EditRelativeSpeed,       'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextNoFramesStationary,  'Enable','on');
        set(handles.EditNoFramesStationary,  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        
        set(handles.TextCMin,                'Enable','off');
        set(handles.TextCMax,                'Enable','off');
        set(handles.TextCStep,               'Enable','off');
        set(handles.EditCMin,                'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditCMax,                'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditCStep,               'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectColorMap,          'Enable','off');       
        set(handles.ToggleColorBar,          'Enable','off');       
        set(handles.PushEditColorBar,        'Enable','off');       

    case{4}
        set(handles.EditUnitVector,          'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectFieldThinning,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditFieldThinningFactor1, 'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextUnitVector,          'Enable','off');
        set(handles.TextFieldThinning,       'Enable','off');
        set(handles.TextFieldThinningFactor1, 'Enable','off');
        set(handles.TextVectorColor,         'Enable','off');
        set(handles.SelectVectorColor,       'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);

        set(handles.TextLegendLength,        'Enable','on');
        set(handles.TextLegendText,          'Enable','on');
        set(handles.EditVectorLegendLength,  'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditVectorLegendText,    'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        
        set(handles.TextDistance,            'Enable','on');
        set(handles.TextLength,              'Enable','on');
        set(handles.TextFillColor,           'Enable','on');
        set(handles.TextEdgeColor,           'Enable','on');
        set(handles.EditDx,                  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditDt,                  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectFillColor,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectEdgeColor,         'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextHeadThickness,       'Enable','on');
        set(handles.TextArrowThickness,      'Enable','on');
        set(handles.EditHeadThickness,       'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditArrowThickness,      'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextTimeStep,            'Enable','on');
        set(handles.TextLifeSpan,            'Enable','on');
        set(handles.EditTimeStep,            'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditLifeSpan,            'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextRelativeSpeed,       'Enable','on');
        set(handles.EditRelativeSpeed,       'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
        set(handles.TextNoFramesStationary,  'Enable','on');
        set(handles.EditNoFramesStationary,  'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
       
        set(handles.TextCMin,                'Enable','on');
        set(handles.TextCMax,                'Enable','on');
        set(handles.TextCStep,               'Enable','on');
        set(handles.EditCMin,                'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditCMax,                'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.EditCStep,               'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
        set(handles.SelectColorMap,          'Enable','on');       
        set(handles.ToggleColorBar,          'Enable','on');       
        set(handles.PushEditColorBar,        'Enable','on');

    case{5}
        set(handles.EditUnitVector,          'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectFieldThinning,     'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditFieldThinningFactor1, 'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextUnitVector,          'Enable','off');
        set(handles.TextFieldThinning,       'Enable','off');
        set(handles.TextFieldThinningFactor1, 'Enable','off');
        set(handles.TextVectorColor,         'Enable','off');
        set(handles.SelectVectorColor,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);

        set(handles.TextLegendLength,        'Enable','off');
        set(handles.TextLegendText,          'Enable','off');
        set(handles.EditVectorLegendLength,   'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditVectorLegendText,     'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        
        set(handles.TextDistance,            'Enable','off');
        set(handles.TextLength,              'Enable','off');
        set(handles.TextFillColor,           'Enable','off');
        set(handles.TextEdgeColor,           'Enable','off');
        set(handles.EditDx,                  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditDt,                  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectFillColor,         'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectEdgeColor,         'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextHeadThickness,       'Enable','off');
        set(handles.TextArrowThickness,      'Enable','off');
        set(handles.EditHeadThickness,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditArrowThickness,      'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextTimeStep,            'Enable','off');
        set(handles.TextLifeSpan,            'Enable','off');
        set(handles.EditTimeStep ,           'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditLifeSpan,            'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextRelativeSpeed,       'Enable','off');
        set(handles.EditRelativeSpeed,       'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
        set(handles.TextNoFramesStationary,  'Enable','off');
        set(handles.EditNoFramesStationary,  'Enable','off','BackGroundColor',[0.831 0.816 0.784]);

        set(handles.TextCMin,                'Enable','off');
        set(handles.TextCMax,                'Enable','off');
        set(handles.TextCStep,               'Enable','off');
        set(handles.EditCMin,                'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditCMax,                'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.EditCStep,               'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
        set(handles.SelectColorMap,          'Enable','off');       
        set(handles.ToggleColorBar,          'Enable','off');       
        set(handles.PushEditColorBar,        'Enable','off');       
        
end
 
if strcmp(lower(handles.typ),'3dcrosssectionvector')
    set(handles.EditVerticalScaling, 'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
    set(handles.TextVerticalScaling, 'Enable','on');
else
    set(handles.EditVerticalScaling, 'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.TextVerticalScaling, 'Enable','off');
end   
 


