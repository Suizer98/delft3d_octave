function varargout = EditLegend(varargin)
% EDITLEGEND M-file for EditLegend.fig
%      EDITLEGEND, by itself, creates a new EDITLEGEND or raises the existing
%      singleton*.
%
%      H = EDITLEGEND returns the handle to a new EDITLEGEND or the handle to
%      the existing singleton*.
%
%      EDITLEGEND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITLEGEND.M with the given input arguments.
%
%      EDITLEGEND('Property','Value',...) creates a new EDITLEGEND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditLegend_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditLegend_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help EditLegend
 
% Last Modified by GUIDE v2.5 12-Nov-2007 20:35:59
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditLegend_OpeningFcn, ...
                   'gui_OutputFcn',  @EditLegend_OutputFcn, ...
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
 
 
% --- Executes just before EditLegend is made visible.
function EditLegend_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditLegend (see VARARGIN)
 
% Choose default command line output for EditLegend

h=varargin{2};
handles.output = h;
handles.i=h.ActiveFigure;
handles.j=h.ActiveSubplot;
handles.SubplotProperties=h.Figure(handles.i).Axis(handles.j);
handles.DefaultColors=h.DefaultColors;

PutInCentre(hObject);
 
set(handles.ToggleBorder,'Value',handles.SubplotProperties.LegendBorder);
 
str{1}='upper-left';
str{2}='lower-left';
str{3}='upper-right';
str{4}='lower-right';

str{1}='North';
str{2}='South';
str{3}='East';
str{4}='West';
str{5}='NorthEast';
str{6}='NorthWest';
str{7}='SouthEast';
str{8}='SouthWest';
str{9}='Best';
str{10}='Custom';
set(handles.SelectPosition,'String',str);

if ischar(handles.SubplotProperties.LegendPosition)
    ii=strmatch(lower(handles.SubplotProperties.LegendPosition),lower(str),'exact');
    if isempty(ii)
        ii=9;
    end
    pos=handles.SubplotProperties.Position;
    pos(1)=pos(1)+1;
    pos(2)=pos(2)+1;
    pos(3)=3;
    pos(4)=1;
    set(handles.SelectPosition,'Value',ii);
    set(handles.EditPositionX,'String',num2str(pos(1)));
    set(handles.EditPositionY,'String',num2str(pos(2)));
    set(handles.EditWidth,'String',num2str(pos(3)));
    set(handles.EditHeight,'String',num2str(pos(4)));
else
    set(handles.SelectPosition,'Value',10);
    set(handles.EditPositionX,'String',num2str(handles.SubplotProperties.LegendPosition(1)));
    set(handles.EditPositionY,'String',num2str(handles.SubplotProperties.LegendPosition(2)));
    set(handles.EditWidth,'String',num2str(handles.SubplotProperties.LegendPosition(3)));
    set(handles.EditHeight,'String',num2str(handles.SubplotProperties.LegendPosition(4)));
end

clear str;

str{1}='Vertical';
str{2}='Horizontal';
set(handles.SelectOrientation,'String',str);
if strcmpi(handles.SubplotProperties.LegendOrientation,'vertical')
    set(handles.SelectOrientation,'Value',1);
else
    set(handles.SelectOrientation,'Value',2);
end
clear str;

for i=1:length(handles.DefaultColors)
    handles.Colors{i}=handles.DefaultColors(i).Name;
end
set(handles.SelectColor,'String',handles.Colors);
i=strmatch(lower(handles.SubplotProperties.LegendColor),lower(handles.Colors),'exact');

set(handles.SelectColor,'Value',i);



handles=Refresh(handles);

% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes EditLegend wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = EditLegend_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1);
 
 
% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=guidata(findobj('Name','Muppet'));
i=handles.i;
j=handles.j;

k=get(handles.SelectPosition,'Value');
if k~=10
    a=get(handles.SelectPosition,'String');
    h.Figure(i).Axis(j).LegendPosition=a{k};
else
    h.Figure(i).Axis(j).LegendPosition=[];
    h.Figure(i).Axis(j).LegendPosition(1)=str2num(get(handles.EditPositionX,'String'));
    h.Figure(i).Axis(j).LegendPosition(2)=str2num(get(handles.EditPositionY,'String'));
    h.Figure(i).Axis(j).LegendPosition(3)=str2num(get(handles.EditWidth,'String'));
    h.Figure(i).Axis(j).LegendPosition(4)=str2num(get(handles.EditHeight,'String'));
end

k=get(handles.SelectOrientation,'Value');
a=get(handles.SelectOrientation,'String');
h.Figure(i).Axis(j).LegendOrientation=a{k};

h.Figure(i).Axis(j).LegendBorder=get(handles.ToggleBorder,'Value');
h.Figure(i).Axis(j).LegendColor=handles.Colors{get(handles.SelectColor,'Value')};

h.Figure(i).Axis(j).LegendFont=handles.SubplotProperties.LegendFont;
h.Figure(i).Axis(j).LegendFontSize=handles.SubplotProperties.LegendFontSize;
h.Figure(i).Axis(j).LegendFontAngle=handles.SubplotProperties.LegendFontAngle;
h.Figure(i).Axis(j).LegendFontWeight=handles.SubplotProperties.LegendFontWeight;
h.Figure(i).Axis(j).LegendFontColor=handles.SubplotProperties.LegendFontColor;

handles.output=h;
 
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
uiresume;
 
% --- Executes on selection change in SelectPosition.
function SelectPosition_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectPosition contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectPosition
 
handles=Refresh(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectPosition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on button press in ToggleBorder.
function ToggleBorder_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleBorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleBorder
 
 


% --- Executes on button press in SelectFont.
function SelectFont_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.SubplotProperties.LegendFont;
Font.Size=handles.SubplotProperties.LegendFontSize;
Font.Weight=handles.SubplotProperties.LegendFontWeight;
Font.Angle=handles.SubplotProperties.LegendFontAngle;
Font.Color=handles.SubplotProperties.LegendFontColor;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.SubplotProperties.LegendFont=Font.Type;
handles.SubplotProperties.LegendFontSize=Font.Size;
handles.SubplotProperties.LegendFontAngle=Font.Angle;
handles.SubplotProperties.LegendFontWeight=Font.Weight;
handles.SubplotProperties.LegendFontColor=Font.Color;

guidata(hObject, handles);



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
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in SelectOrientation.
function SelectOrientation_Callback(hObject, eventdata, handles)
% hObject    handle to SelectOrientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectOrientation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectOrientation


% --- Executes during object creation, after setting all properties.
function SelectOrientation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectOrientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function EditPositionX_Callback(hObject, eventdata, handles)
% hObject    handle to EditPositionX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPositionX as text
%        str2double(get(hObject,'String')) returns contents of EditPositionX as a double


% --- Executes during object creation, after setting all properties.
function EditPositionX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPositionX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditPositionY_Callback(hObject, eventdata, handles)
% hObject    handle to EditPositionY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPositionY as text
%        str2double(get(hObject,'String')) returns contents of EditPositionY as a double


% --- Executes during object creation, after setting all properties.
function EditPositionY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPositionY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditWidth_Callback(hObject, eventdata, handles)
% hObject    handle to EditWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditWidth as text
%        str2double(get(hObject,'String')) returns contents of EditWidth as a double


% --- Executes during object creation, after setting all properties.
function EditWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditHeight_Callback(hObject, eventdata, handles)
% hObject    handle to EditHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditHeight as text
%        str2double(get(hObject,'String')) returns contents of EditHeight as a double


% --- Executes during object creation, after setting all properties.
function EditHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles=Refresh(handles)

ii=get(handles.SelectPosition,'Value');
if ii==10
    set(handles.EditPositionX,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.EditPositionY,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.EditWidth,'Enable','on','BackgroundColor',[1 1 1]);
    set(handles.EditHeight,'Enable','on','BackgroundColor',[1 1 1]);
else
    set(handles.EditPositionX,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.EditPositionY,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.EditWidth,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    set(handles.EditHeight,'Enable','off','BackgroundColor',[0.8 0.8 0.8]);
end
