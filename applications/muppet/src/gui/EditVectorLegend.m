function varargout = EditVectorLegend(varargin)
% EDITVECTORLEGEND M-file for EditVectorLegend.fig
%      EDITVECTORLEGEND, by itself, creates a new EDITVECTORLEGEND or raises the existing
%      singleton*.
%
%      H = EDITVECTORLEGEND returns the handle to a new EDITVECTORLEGEND or the handle to
%      the existing singleton*.
%
%      EDITVECTORLEGEND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITVECTORLEGEND.M with the given input arguments.
%
%      EDITVECTORLEGEND('Property','Value',...) creates a new EDITVECTORLEGEND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditVectorLegend_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditVectorLegend_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help EditVectorLegend
 
% Last Modified by GUIDE v2.5 19-Jun-2008 17:09:50
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditVectorLegend_OpeningFcn, ...
                   'gui_OutputFcn',  @EditVectorLegend_OutputFcn, ...
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
 
 
% --- Executes just before EditVectorLegend is made visible.
function EditVectorLegend_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditVectorLegend (see VARARGIN)
 
% Choose default command line output for EditVectorLegend
h=varargin{2};
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.DefaultColors=h.DefaultColors;
handles.Axis=h.Figure(handles.i).Axis(handles.j);
handles.output = h;
 
PutInCentre(hObject);
 
set(handles.EditPosition1,'String',num2str(handles.Axis.VectorLegendPosition(1),7));
set(handles.EditPosition2,'String',num2str(handles.Axis.VectorLegendPosition(2),7));
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes EditVectorLegend wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = EditVectorLegend_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1);
 
 
 
function EditPosition1_Callback(hObject, eventdata, handles)
% hObject    handle to EditPosition1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditPosition1 as text
%        str2double(get(hObject,'String')) returns contents of EditPosition1 as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditPosition1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPosition1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditPosition2_Callback(hObject, eventdata, handles)
% hObject    handle to EditPosition2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditPosition2 as text
%        str2double(get(hObject,'String')) returns contents of EditPosition2 as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditPosition2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPosition2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
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

h.Figure(i).Axis(j).VectorLegendPosition(1)=str2num(get(handles.EditPosition1,'String'));
h.Figure(i).Axis(j).VectorLegendPosition(2)=str2num(get(handles.EditPosition2,'String'));

h.Figure(i).Axis(j).VectorLegendFont=handles.Axis.VectorLegendFont;
h.Figure(i).Axis(j).VectorLegendFontSize=handles.Axis.VectorLegendFontSize;
h.Figure(i).Axis(j).VectorLegendFontAngle=handles.Axis.VectorLegendFontAngle;
h.Figure(i).Axis(j).VectorLegendFontWeight=handles.Axis.VectorLegendFontWeight;
h.Figure(i).Axis(j).VectorLegendFontColor=handles.Axis.VectorLegendFontColor;

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

Font.Type=handles.Axis.VectorLegendFont;
Font.Size=handles.Axis.VectorLegendFontSize;
Font.Weight=handles.Axis.VectorLegendFontWeight;
Font.Angle=handles.Axis.VectorLegendFontAngle;
Font.Color=handles.Axis.VectorLegendFontColor;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.Axis.VectorLegendFont=Font.Type;
handles.Axis.VectorLegendFontSize=Font.Size;
handles.Axis.VectorLegendFontAngle=Font.Angle;
handles.Axis.VectorLegendFontWeight=Font.Weight;
handles.Axis.VectorLegendFontColor=Font.Color;

guidata(hObject, handles);

