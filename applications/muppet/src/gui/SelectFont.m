function varargout = SelectFont(varargin)
% SELECTFONT M-file for SelectFont.fig
%      SELECTFONT, by itself, creates a new SELECTFONT or raises the existing
%      singleton*.
%
%      H = SELECTFONT returns the handle to a new SELECTFONT or the handle to
%      the existing singleton*.
%
%      SELECTFONT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTFONT.M with the given input arguments.
%
%      SELECTFONT('Property','Value',...) creates a new SELECTFONT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectFont_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectFont_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help SelectFont
 
% Last Modified by GUIDE v2.5 16-Aug-2007 20:31:07
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectFont_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectFont_OutputFcn, ...
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
 
 
% --- Executes just before SelectFont is made visible.
function SelectFont_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectFont (see VARARGIN)
 
% Choose default command line output for SelectFont
handles.output = hObject;
 
handles.Font=varargin{2};
handles.DefaultColors=varargin{4};

PutInCentre(hObject);
 
fonts=listfonts;
set(handles.SelectFont,'String',fonts);
i=strmatch(lower(handles.Font.Type),lower(fonts),'exact');
set(handles.SelectFont,'Value',i);
 
for j=1:100
    str{j}=num2str(j);
end
set(handles.SelectFontSize,'String',str);
set(handles.SelectFontSize,'Value',handles.Font.Size);
 
if strcmp(lower(handles.Font.Angle),'italic')==1
    set(handles.ToggleItalic,'Value',1);
else
    set(handles.ToggleItalic,'Value',0);
end
 
if strcmp(lower(handles.Font.Weight),'bold')==1
    set(handles.ToggleBold,'Value',1);
else
    set(handles.ToggleBold,'Value',0);
end

nrcol=size(handles.DefaultColors,2);
for i=1:nrcol
    handles.Colors{i}=handles.DefaultColors(i).Name;
end

set(handles.SelectColor,'String',handles.Colors);
i=strmatch(lower(handles.Font.Color),lower(handles.Colors),'exact');
set(handles.SelectColor,'Value',i);

str={'left','center','right'};
set(handles.SelectHorizontalAlignment,'String',str);
i=1;
for j=1:3
    switch lower(handles.Font.HorizontalAlignment),
        case lower(str{j})
            i=j;
    end
end
set(handles.SelectHorizontalAlignment,'Value',i);

str={'middle','top','bottom','baseline'};
set(handles.SelectVerticalAlignment,'String',str);
i=1;
for j=1:4
    switch lower(handles.Font.VerticalAlignment),
        case lower(str{j})
            i=j;
    end
end
set(handles.SelectVerticalAlignment,'Value',i);

if handles.Font.EditAlignment==0
    set(handles.TextHorizontalAlignment,'Visible','off');
    set(handles.TextVerticalAlignment,'Visible','off');
    set(handles.SelectHorizontalAlignment,'Visible','off');
    set(handles.SelectVerticalAlignment,'Visible','off');
end

i=get(handles.SelectColor,'Value');
Colors=get(handles.SelectColor,'String');
strct.Color=Colors{i};
handles.SampleColor=FindColor(strct,'Color',handles.DefaultColors);

RefreshPanel(handles);

% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes SelectFont wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = SelectFont_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1)
 
% --- Executes on selection change in SelectFont.
function SelectFont_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectFont contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectFont
 
RefreshPanel(handles);
 
% --- Executes during object creation, after setting all properties.
function SelectFont_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in SelectFontSize.
function SelectFontSize_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFontSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectFontSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectFontSize
 
RefreshPanel(handles);

% --- Executes during object creation, after setting all properties.
function SelectFontSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectFontSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
 
 
% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
 
 
% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on button press in PuskOK.
function PuskOK_Callback(hObject, eventdata, handles)
% hObject    handle to PuskOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
i=get(handles.SelectFont,'Value');
str=get(handles.SelectFont,'String');
handles.Font.Type=str{i};
 
i=get(handles.SelectFontSize,'Value');
str=get(handles.SelectFontSize,'String');
handles.Font.Size=str2num(str{i});
 
handles.Font.Color=handles.Colors{get(handles.SelectColor,'Value')};
 
i=get(handles.ToggleItalic,'Value');
if i==1
    handles.Font.Angle='italic';
else
    handles.Font.Angle='normal';
end
 
i=get(handles.ToggleBold,'Value');
if i==1
    handles.Font.Weight='bold';
else
    handles.Font.Weight='normal';
end

i=get(handles.SelectHorizontalAlignment,'Value');
str=get(handles.SelectHorizontalAlignment,'String');
handles.Font.HorizontalAlignment=str{i};

i=get(handles.SelectVerticalAlignment,'Value');
str=get(handles.SelectVerticalAlignment,'String');
handles.Font.VerticalAlignment=str{i};

handles.output=handles.Font;
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles.output=handles.Font;
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in ToggleItalic.
function ToggleItalic_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleItalic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleItalic
 
RefreshPanel(handles);

% --- Executes on button press in ToggleBold.
function ToggleBold_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleBold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleBold
 
RefreshPanel(handles);
 
% --- Executes on selection change in SelectColor.
function SelectColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectColor

i=get(hObject,'Value');
Colors=get(hObject,'String');
strct.Color=Colors{i};
handles.SampleColor=FindColor(strct,'Color',handles.DefaultColors);
guidata(hObject, handles);
 
RefreshPanel(handles);


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
 
 


% --- Executes on selection change in SelectHorizontalAlignment.
function SelectHorizontalAlignment_Callback(hObject, eventdata, handles)
% hObject    handle to SelectHorizontalAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectHorizontalAlignment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectHorizontalAlignment

RefreshPanel(handles);

% --- Executes during object creation, after setting all properties.
function SelectHorizontalAlignment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectHorizontalAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectVerticalAlignment.
function SelectVerticalAlignment_Callback(hObject, eventdata, handles)
% hObject    handle to SelectVerticalAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectVerticalAlignment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectVerticalAlignment

RefreshPanel(handles);

% --- Executes during object creation, after setting all properties.
function SelectVerticalAlignment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectVerticalAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function RefreshPanel(handles)

i=get(handles.SelectFont,'Value');
str=get(handles.SelectFont,'String');
Font=str{i};
 
i=get(handles.SelectFontSize,'Value');
str=get(handles.SelectFontSize,'String');
Size=str2num(str{i});
 
Color=handles.SampleColor;

i=get(handles.ToggleItalic,'Value');
if i==1
    FontAngle='italic';
else
    FontAngle='normal';
end
 
i=get(handles.ToggleBold,'Value');
if i==1
    FontWeight='bold';
else
    FontWeight='normal';
end

i=get(handles.SelectHorizontalAlignment,'Value');
str=get(handles.SelectHorizontalAlignment,'String');
HorizontalAlignment=str{i};

i=get(handles.SelectVerticalAlignment,'Value');
str=get(handles.SelectVerticalAlignment,'String');
VerticalAlignment=str{i};

set(handles.DisplayFont,'FontName',Font);
set(handles.DisplayFont,'FontSize',Size);
set(handles.DisplayFont,'FontWeight',FontWeight);
set(handles.DisplayFont,'FontAngle',FontAngle);
set(handles.DisplayFont,'ForegroundColor',Color);
set(handles.DisplayFont,'HorizontalAlignment',HorizontalAlignment);
%set(handles.DisplayFont,'VerticalAlignment',VerticalAlignment);


