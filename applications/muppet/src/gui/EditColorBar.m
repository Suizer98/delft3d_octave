function varargout = EditColorBar(varargin)
% EDITCOLORBAR M-file for EditColorBar.fig
%      EDITCOLORBAR, by itself, creates a new EDITCOLORBAR or raises the existing
%      singleton*.
%
%      H = EDITCOLORBAR returns the handle to a new EDITCOLORBAR or the handle to
%      the existing singleton*.
%
%      EDITCOLORBAR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITCOLORBAR.M with the given input arguments.
%
%      EDITCOLORBAR('Property','Value',...) creates a new EDITCOLORBAR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditColorBar_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditColorBar_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help EditColorBar
 
% Last Modified by GUIDE v2.5 12-Dec-2007 20:32:34
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditColorBar_OpeningFcn, ...
                   'gui_OutputFcn',  @EditColorBar_OutputFcn, ...
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
 
 
% --- Executes just before EditColorBar is made visible.
function EditColorBar_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditColorBar (see VARARGIN)
 
% Choose default command line output for EditColorBar
h=varargin{2};
handles.output = h;

if length(varargin)==2
    handles.iopt=1;
else
    handles.iopt=2;
end    
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.k=h.ActiveDatasetInSubplot;
handles.DefaultColors=h.DefaultColors;
if handles.iopt==1
    handles.Axis=h.Figure(handles.i).Axis(handles.j);
else
    if handles.k>0
        handles.Axis=h.Figure(handles.i).Axis(handles.j).Plot(handles.k);
    else
        uiresume;
    end
end    
 
PutInCentre(hObject);

set(handles.EditPosition1,'String',handles.Axis.ColorBarPosition(1));
set(handles.EditPosition2,'String',handles.Axis.ColorBarPosition(2));
set(handles.EditPosition3,'String',handles.Axis.ColorBarPosition(3));
set(handles.EditPosition4,'String',handles.Axis.ColorBarPosition(4));
 
str={'auto','0','1','2','3','4','5'};
 
k=handles.Axis.ColorBarDecimals;
set(handles.SelectDecimals,'String',str);
set(handles.SelectDecimals,'Value',k+2);

set(handles.EditLabelIncrement,'String',num2str(handles.Axis.ColorBarLabelIncrement));

m=handles.Axis.ColorBarType;
 
switch handles.Axis.ColorBarType,
    case 1
        set(handles.ButtonColorBar,'Value',1);
        set(handles.ButtonBoxesWithBorder,'Value',0);
        set(handles.ButtonBoxesWithoutBorder,'Value',0);
    case 2
        set(handles.ButtonColorBar,'Value',0);
        set(handles.ButtonBoxesWithBorder,'Value',1);
        set(handles.ButtonBoxesWithoutBorder,'Value',0);
    case 3
        set(handles.ButtonColorBar,'Value',0);
        set(handles.ButtonBoxesWithBorder,'Value',0);
        set(handles.ButtonBoxesWithoutBorder,'Value',1);
end

nrcol=size(handles.DefaultColors,2);
for i=1:nrcol
    handles.Colors{i}=handles.DefaultColors(i).Name;
end

set(handles.EditColorBarLabel,'String',handles.Axis.ColorBarLabel);

set(handles.EditUnit,'String',handles.Axis.ColorBarUnit);

% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes EditColorBar wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = EditColorBar_OutputFcn(hObject, eventdata, handles)
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
 
 
function EditPosition3_Callback(hObject, eventdata, handles)
% hObject    handle to EditPosition3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditPosition3 as text
%        str2double(get(hObject,'String')) returns contents of EditPosition3 as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditPosition3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPosition3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditPosition4_Callback(hObject, eventdata, handles)
% hObject    handle to EditPosition4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditPosition4 as text
%        str2double(get(hObject,'String')) returns contents of EditPosition4 as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditPosition4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPosition4 (see GCBO)
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
k=handles.k;
if handles.iopt==1
    h.Figure(i).Axis(j).ColorBarPosition(1)=str2num(get(handles.EditPosition1,'String'));
    h.Figure(i).Axis(j).ColorBarPosition(2)=str2num(get(handles.EditPosition2,'String'));
    h.Figure(i).Axis(j).ColorBarPosition(3)=str2num(get(handles.EditPosition3,'String'));
    h.Figure(i).Axis(j).ColorBarPosition(4)=str2num(get(handles.EditPosition4,'String'));
    kk=get(handles.ButtonColorBar,'Value');
    if kk==1
        h.Figure(i).Axis(j).ColorBarType=1;
    end
    kk=get(handles.ButtonBoxesWithBorder,'Value');
    if kk==1
        h.Figure(i).Axis(j).ColorBarType=2;
    end
    kk=get(handles.ButtonBoxesWithoutBorder,'Value');
    if kk==1
        h.Figure(i).Axis(j).ColorBarType=3;
    end
    h.Figure(i).Axis(j).ColorBarLabel=get(handles.EditColorBarLabel,'String');
    h.Figure(i).Axis(j).ColorBarLabelIncrement=str2num(get(handles.EditLabelIncrement,'String'));
    nr=[-1:1:5];
    h.Figure(i).Axis(j).ColorBarDecimals=nr(get(handles.SelectDecimals,'Value'));
    h.Figure(i).Axis(j).ColorBarFont=handles.Axis.ColorBarFont;
    h.Figure(i).Axis(j).ColorBarFontSize=handles.Axis.ColorBarFontSize;
    h.Figure(i).Axis(j).ColorBarFontAngle=handles.Axis.ColorBarFontAngle;
    h.Figure(i).Axis(j).ColorBarFontWeight=handles.Axis.ColorBarFontWeight;
    h.Figure(i).Axis(j).ColorBarFontColor=handles.Axis.ColorBarFontColor;
    h.Figure(i).Axis(j).ColorBarUnit=get(handles.EditUnit,'String');
else
    h.Figure(i).Axis(j).Plot(k).ColorBarPosition(1)=str2num(get(handles.EditPosition1,'String'));
    h.Figure(i).Axis(j).Plot(k).ColorBarPosition(2)=str2num(get(handles.EditPosition2,'String'));
    h.Figure(i).Axis(j).Plot(k).ColorBarPosition(3)=str2num(get(handles.EditPosition3,'String'));
    h.Figure(i).Axis(j).Plot(k).ColorBarPosition(4)=str2num(get(handles.EditPosition4,'String'));
    kk=get(handles.ButtonColorBar,'Value');
    if kk==1
        h.Figure(i).Axis(j).Plot(k).ColorBarType=1;
    end
    kk=get(handles.ButtonBoxesWithBorder,'Value');
    if kk==1
        h.Figure(i).Axis(j).Plot(k).ColorBarType=2;
    end
    kk=get(handles.ButtonBoxesWithoutBorder,'Value');
    if kk==1
        h.Figure(i).Axis(j).Plot(k).ColorBarType=3;
    end
    h.Figure(i).Axis(j).Plot(k).ColorBarLabel=get(handles.EditColorBarLabel,'String');
    h.Figure(i).Axis(j).Plot(k).ColorBarLabelIncrement=str2num(get(handles.EditLabelIncrement,'String'));
    nr=[-1:1:5];
    h.Figure(i).Axis(j).Plot(k).ColorBarDecimals=nr(get(handles.SelectDecimals,'Value'));
    h.Figure(i).Axis(j).Plot(k).ColorBarFont=handles.Axis.ColorBarFont;
    h.Figure(i).Axis(j).Plot(k).ColorBarFontSize=handles.Axis.ColorBarFontSize;
    h.Figure(i).Axis(j).Plot(k).ColorBarFontAngle=handles.Axis.ColorBarFontAngle;
    h.Figure(i).Axis(j).Plot(k).ColorBarFontWeight=handles.Axis.ColorBarFontWeight;
    h.Figure(i).Axis(j).Plot(k).ColorBarFontColor=handles.Axis.ColorBarFontColor;
    h.Figure(i).Axis(j).Plot(k).ColorBarUnit=get(handles.EditUnit,'String');
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

% --- Executes on selection change in SelectDecimals.
function SelectDecimals_Callback(hObject, eventdata, handles)
% hObject    handle to SelectDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectDecimals contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectDecimals
 
 
% --- Executes during object creation, after setting all properties.
function SelectDecimals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
% --- Executes on button press in ButtonColorBar.
function ButtonColorBar_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonColorBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ButtonColorBar
 
set(handles.ButtonColorBar,'Value',1);
set(handles.ButtonBoxesWithBorder,'Value',0);
set(handles.ButtonBoxesWithoutBorder,'Value',0);
 
guidata(hObject, handles);
 
% --- Executes on button press in ButtonBoxesWithBorder.
function ButtonBoxesWithBorder_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonBoxesWithBorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ButtonBoxesWithBorder
 
set(handles.ButtonColorBar,'Value',0);
set(handles.ButtonBoxesWithBorder,'Value',1);
set(handles.ButtonBoxesWithoutBorder,'Value',0);
 
guidata(hObject, handles);
 
% --- Executes on button press in ButtonBoxesWithoutBorder.
function ButtonBoxesWithoutBorder_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonBoxesWithoutBorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ButtonBoxesWithoutBorder
 
set(handles.ButtonColorBar,'Value',0);
set(handles.ButtonBoxesWithBorder,'Value',0);
set(handles.ButtonBoxesWithoutBorder,'Value',1);
 
guidata(hObject, handles);
 



function EditColorBarLabel_Callback(hObject, eventdata, handles)
% hObject    handle to EditColorBarLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditColorBarLabel as text
%        str2double(get(hObject,'String')) returns contents of EditColorBarLabel as a double


% --- Executes during object creation, after setting all properties.
function EditColorBarLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditColorBarLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in EditFont.
function EditFont_Callback(hObject, eventdata, handles)
% hObject    handle to EditFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.Axis.ColorBarFont;
Font.Size=handles.Axis.ColorBarFontSize;
Font.Weight=handles.Axis.ColorBarFontWeight;
Font.Angle=handles.Axis.ColorBarFontAngle;
Font.Color=handles.Axis.ColorBarFontColor;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.Axis.ColorBarFont=Font.Type;
handles.Axis.ColorBarFontSize=Font.Size;
handles.Axis.ColorBarFontAngle=Font.Angle;
handles.Axis.ColorBarFontWeight=Font.Weight;
handles.Axis.ColorBarFontColor=Font.Color;

guidata(hObject, handles);



function EditLabelIncrement_Callback(hObject, eventdata, handles)
% hObject    handle to EditLabelIncrement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditLabelIncrement as text
%        str2double(get(hObject,'String')) returns contents of EditLabelIncrement as a double


% --- Executes during object creation, after setting all properties.
function EditLabelIncrement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLabelIncrement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function EditUnit_Callback(hObject, eventdata, handles)
% hObject    handle to EditUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditUnit as text
%        str2double(get(hObject,'String')) returns contents of EditUnit as a double


% --- Executes during object creation, after setting all properties.
function EditUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectLabelPosition.
function SelectLabelPosition_Callback(hObject, eventdata, handles)
% hObject    handle to SelectLabelPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectLabelPosition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectLabelPosition


% --- Executes during object creation, after setting all properties.
function SelectLabelPosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectLabelPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

