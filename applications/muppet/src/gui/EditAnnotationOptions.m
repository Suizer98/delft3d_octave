function varargout = EditAnnotationOptions(varargin)
% EDITANNOTATIONOPTIONS M-file for EditAnnotationOptions.fig
%      EDITANNOTATIONOPTIONS, by itself, creates a new EDITANNOTATIONOPTIONS or raises the existing
%      singleton*.
%
%      H = EDITANNOTATIONOPTIONS returns the handle to a new EDITANNOTATIONOPTIONS or the handle to
%      the existing singleton*.
%
%      EDITANNOTATIONOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITANNOTATIONOPTIONS.M with the given input arguments.
%
%      EDITANNOTATIONOPTIONS('Property','Value',...) creates a new EDITANNOTATIONOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditAnnotationOptions_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditAnnotationOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help EditAnnotationOptions

% Last Modified by GUIDE v2.5 19-Nov-2007 00:01:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditAnnotationOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @EditAnnotationOptions_OutputFcn, ...
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


% --- Executes just before EditAnnotationOptions is made visible.
function EditAnnotationOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditAnnotationOptions (see VARARGIN)

% Choose default command line output for EditAnnotationOptions

h=varargin{2};
handles.i=varargin{4};
handles.j=varargin{6};
handles.output = h;
handles.DefaultColors=h.DefaultColors;
handles.Annotation=h.Figure(handles.i).Annotation(handles.j);

PutInCentre(hObject);

set(handles.EditX1,'String',num2str(handles.Annotation.Position(1)));
set(handles.EditY1,'String',num2str(handles.Annotation.Position(2)));
set(handles.EditX2,'String',num2str(handles.Annotation.Position(3)));
set(handles.EditY2,'String',num2str(handles.Annotation.Position(4)));
set(handles.TextX,'String','X');
set(handles.TextY,'String','Y');

switch lower(handles.Annotation.Type),
    
    case {'textbox','rectangle','ellipse'}
        set(handles.TextPosition1,'String','Position');
        set(handles.TextPosition2,'String','Size');

    case {'line','arrow','doublearrow'}
        set(handles.TextPosition1,'String','First Point');
        set(handles.TextPosition2,'String','Second Point');
end

handles.LineStyles={'-','--','-.',':'};
set(handles.SelectLineStyle,'String',handles.LineStyles);
i=strmatch(lower(handles.Annotation.LineStyle),lower(handles.LineStyles),'exact');
set(handles.SelectLineStyle,'Value',i);

set(handles.EditLineWidth,'String',num2str(handles.Annotation.LineWidth));

nrcol=size(handles.DefaultColors,2);
for i=1:nrcol
    handles.Colors{i}=handles.DefaultColors(i).Name;
end
handles.BackgroundColors=handles.Colors;
handles.BackgroundColors{i+1}='none';

handles.LineColors=handles.Colors;
switch lower(handles.Annotation.Type),
    case {'rectangle','ellipse'}
        handles.LineColors{i+1}='none';
end

set(handles.SelectLineColor,'String',handles.LineColors);
i=strmatch(lower(handles.Annotation.LineColor),lower(handles.LineColors),'exact');
set(handles.SelectLineColor,'Value',i);

set(handles.SelectBackgroundColor,'String',handles.BackgroundColors);
i=strmatch(lower(handles.Annotation.BackgroundColor),lower(handles.BackgroundColors),'exact');
set(handles.SelectBackgroundColor,'Value',i);

handles.LineStyles={'-','--','-.',':'};
set(handles.SelectLineStyle,'String',handles.LineStyles);
i=strmatch(lower(handles.Annotation.LineStyle),lower(handles.LineStyles),'exact');
set(handles.SelectLineStyle,'Value',i);

handles.HeadStyles={'none','plain','ellipse','vback1','vback2','vback3','cback1','cback2','cback3' ...
    'fourstar','rectangle','diamond','rose','hypocycloid','astroid','deltoid'};

set(handles.SelectHeadStyle1,'String',handles.HeadStyles);
i=strmatch(lower(handles.Annotation.Head1Style),lower(handles.HeadStyles),'exact');
set(handles.SelectHeadStyle1,'Value',i);
set(handles.SelectHeadStyle2,'String',handles.HeadStyles);
i=strmatch(lower(handles.Annotation.Head2Style),lower(handles.HeadStyles),'exact');
set(handles.SelectHeadStyle2,'Value',i);

set(handles.EditHeadWidth1,'String',num2str(handles.Annotation.Head1Width));
set(handles.EditHeadWidth2,'String',num2str(handles.Annotation.Head2Width));
set(handles.EditHeadLength1,'String',num2str(handles.Annotation.Head1Length));
set(handles.EditHeadLength2,'String',num2str(handles.Annotation.Head1Length));

set(handles.ToggleBox,'Value',handles.Annotation.Box);

switch lower(handles.Annotation.Type),
    
    case {'textbox'}
        set(handles.TextHeadWidth,   'Enable','off');
        set(handles.TextHeadLength,  'Enable','off');
        set(handles.TextHeadStyle,   'Enable','off');
        set(handles.EditHeadWidth1,  'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.EditHeadLength1, 'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.SelectHeadStyle1,'Enable','off');
        set(handles.EditHeadWidth2,  'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.EditHeadLength2, 'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.SelectHeadStyle2,'Enable','off');
        if ~handles.Annotation.Box
            set(handles.TextLineColor,        'Enable','off');
            set(handles.SelectLineColor,      'Enable','off');
            set(handles.TextBackgroundColor,  'Enable','off');
            set(handles.SelectBackgroundColor,'Enable','off');
            set(handles.TextLineStyle,        'Enable','off');
            set(handles.SelectLineStyle,      'Enable','off');
            set(handles.TextLineWidth,        'Enable','off');
            set(handles.EditLineWidth,        'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        end
        set(handles.EditString, 'Enable','on','BackgroundColor',[1 1 1]);
        set(handles.EditString,'String',handles.Annotation.String);
        set(handles.EditString,'HorizontalAlignment',handles.Annotation.HorAl);
        
    case {'rectangle','ellipse'}
        set(handles.TextHeadWidth,   'Enable','off');
        set(handles.TextHeadLength,  'Enable','off');
        set(handles.TextHeadStyle,   'Enable','off');
        set(handles.EditHeadWidth1,  'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.EditHeadLength1, 'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.SelectHeadStyle1,'Enable','off');
        set(handles.EditHeadWidth2,  'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.EditHeadLength2, 'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.SelectHeadStyle2,'Enable','off');
        set(handles.PushFont,        'Enable','off');
        set(handles.ToggleBox,       'Enable','off');
        set(handles.EditString,      'Enable','off','BackgroundColor',[0.831 0.816 0.784]);

    case {'line'}
        set(handles.TextHeadWidth,   'Enable','off');
        set(handles.TextHeadLength,  'Enable','off');
        set(handles.TextHeadStyle,   'Enable','off');
        set(handles.EditHeadWidth1,  'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.EditHeadLength1, 'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.SelectHeadStyle1,'Enable','off');
        set(handles.EditHeadWidth2,  'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.EditHeadLength2, 'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.SelectHeadStyle2,'Enable','off');
        set(handles.PushFont,        'Enable','off');
        set(handles.ToggleBox,       'Enable','off');
        set(handles.TextBackgroundColor,  'Enable','off');
        set(handles.SelectBackgroundColor,'Enable','off');
        set(handles.EditString,      'Enable','off','BackgroundColor',[0.831 0.816 0.784]);

    case {'arrow'}
        set(handles.EditHeadWidth2,  'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.EditHeadLength2, 'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        set(handles.SelectHeadStyle2,'Enable','off');
        set(handles.PushFont,        'Enable','off');
        set(handles.ToggleBox,       'Enable','off');
        set(handles.TextBackgroundColor,  'Enable','off');
        set(handles.SelectBackgroundColor,'Enable','off');
        set(handles.EditString,      'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
        
    case {'doublearrow'}
        set(handles.PushFont,        'Enable','off');
        set(handles.ToggleBox,       'Enable','off');
        set(handles.TextBackgroundColor,  'Enable','off');
        set(handles.SelectBackgroundColor,'Enable','off');
        set(handles.EditString,      'Enable','off','BackgroundColor',[0.831 0.816 0.784]);

end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EditAnnotationOptions wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EditAnnotationOptions_OutputFcn(hObject, eventdata, handles) 
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

h.Figure(i).Annotation(j).Position(1)=str2num(get(handles.EditX1,'String'));
h.Figure(i).Annotation(j).Position(2)=str2num(get(handles.EditY1,'String'));
h.Figure(i).Annotation(j).Position(3)=str2num(get(handles.EditX2,'String'));
h.Figure(i).Annotation(j).Position(4)=str2num(get(handles.EditY2,'String'));
h.Figure(i).Annotation(j).Head1Width=str2num(get(handles.EditHeadWidth1,'String'));
h.Figure(i).Annotation(j).Head2Width=str2num(get(handles.EditHeadWidth2,'String'));
h.Figure(i).Annotation(j).Head1Length=str2num(get(handles.EditHeadLength1,'String'));
h.Figure(i).Annotation(j).Head2Length=str2num(get(handles.EditHeadLength2,'String'));
h.Figure(i).Annotation(j).LineWidth=str2num(get(handles.EditLineWidth,'String'));
h.Figure(i).Annotation(j).Head1Style=handles.HeadStyles{get(handles.SelectHeadStyle1,'Value')};
h.Figure(i).Annotation(j).Head2Style=handles.HeadStyles{get(handles.SelectHeadStyle2,'Value')};
h.Figure(i).Annotation(j).LineStyle=handles.LineStyles{get(handles.SelectLineStyle,'Value')};
h.Figure(i).Annotation(j).LineColor=handles.LineColors{get(handles.SelectLineColor,'Value')};
h.Figure(i).Annotation(j).BackgroundColor=handles.BackgroundColors{get(handles.SelectBackgroundColor,'Value')};
h.Figure(i).Annotation(j).Box=get(handles.ToggleBox,'Value');
h.Figure(i).Annotation(j).String=get(handles.EditString,'String');

h.Figure(i).Annotation(j).Font=handles.Annotation.Font;
h.Figure(i).Annotation(j).FontSize=handles.Annotation.FontSize;
h.Figure(i).Annotation(j).FontAngle=handles.Annotation.FontAngle;
h.Figure(i).Annotation(j).FontWeight=handles.Annotation.FontWeight;
h.Figure(i).Annotation(j).FontColor=handles.Annotation.FontColor;
h.Figure(i).Annotation(j).HorAl=handles.Annotation.HorAl;

handles.output=h;

guidata(hObject, handles);

uiresume;



% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;

% --- Executes on button press in PushFont.
function PushFont_Callback(hObject, eventdata, handles)
% hObject    handle to PushFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.Annotation.Font;
Font.Size=handles.Annotation.FontSize;
Font.Weight=handles.Annotation.FontWeight;
Font.Angle=handles.Annotation.FontAngle;
Font.Color=handles.Annotation.FontColor;
Font.HorizontalAlignment=handles.Annotation.HorAl;
Font.VerticalAlignment='baseline';
Font.EditAlignment=1;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.Annotation.Font=Font.Type;
handles.Annotation.FontSize=Font.Size;
handles.Annotation.FontAngle=Font.Angle;
handles.Annotation.FontWeight=Font.Weight;
handles.Annotation.FontColor=Font.Color;
handles.Annotation.HorAl=Font.HorizontalAlignment;

guidata(hObject, handles);


function EditX1_Callback(hObject, eventdata, handles)
% hObject    handle to EditX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditX1 as text
%        str2double(get(hObject,'String')) returns contents of EditX1 as a double


% --- Executes during object creation, after setting all properties.
function EditX1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditX2_Callback(hObject, eventdata, handles)
% hObject    handle to EditX2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditX2 as text
%        str2double(get(hObject,'String')) returns contents of EditX2 as a double


% --- Executes during object creation, after setting all properties.
function EditX2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditX2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditY1_Callback(hObject, eventdata, handles)
% hObject    handle to EditY1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditY1 as text
%        str2double(get(hObject,'String')) returns contents of EditY1 as a double


% --- Executes during object creation, after setting all properties.
function EditY1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditY1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditY2_Callback(hObject, eventdata, handles)
% hObject    handle to EditY2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditY2 as text
%        str2double(get(hObject,'String')) returns contents of EditY2 as a double


% --- Executes during object creation, after setting all properties.
function EditY2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditY2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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


% --- Executes on selection change in SelectBackgroundColor.
function SelectBackgroundColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectBackgroundColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectBackgroundColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectBackgroundColor


% --- Executes during object creation, after setting all properties.
function SelectBackgroundColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectBackgroundColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ToggleBox.
function ToggleBox_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleBox

if get(hObject,'Value')
    set(handles.TextLineColor,        'Enable','on');
    set(handles.SelectLineColor,      'Enable','on');
    set(handles.TextBackgroundColor,  'Enable','on');
    set(handles.SelectBackgroundColor,'Enable','on');
    set(handles.TextLineStyle,        'Enable','on');
    set(handles.SelectLineStyle,      'Enable','on');
    set(handles.TextLineWidth,        'Enable','on');
    set(handles.EditLineWidth,        'Enable','on','BackgroundColor',[1 1 1]);
else
    set(handles.TextLineColor,        'Enable','off');
    set(handles.SelectLineColor,      'Enable','off');
    set(handles.TextBackgroundColor,  'Enable','off');
    set(handles.SelectBackgroundColor,'Enable','off');
    set(handles.TextLineStyle,        'Enable','off');
    set(handles.SelectLineStyle,      'Enable','off');
    set(handles.TextLineWidth,        'Enable','off');
    set(handles.EditLineWidth,        'Enable','off','BackgroundColor',[0.831 0.816 0.784]);
end

guidata(hObject, handles);


function EditHeadWidth1_Callback(hObject, eventdata, handles)
% hObject    handle to EditHeadWidth1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditHeadWidth1 as text
%        str2double(get(hObject,'String')) returns contents of EditHeadWidth1 as a double


% --- Executes during object creation, after setting all properties.
function EditHeadWidth1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditHeadWidth1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditHeadWidth2_Callback(hObject, eventdata, handles)
% hObject    handle to EditHeadWidth2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditHeadWidth2 as text
%        str2double(get(hObject,'String')) returns contents of EditHeadWidth2 as a double


% --- Executes during object creation, after setting all properties.
function EditHeadWidth2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditHeadWidth2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditHeadLength1_Callback(hObject, eventdata, handles)
% hObject    handle to EditHeadLength1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditHeadLength1 as text
%        str2double(get(hObject,'String')) returns contents of EditHeadLength1 as a double


% --- Executes during object creation, after setting all properties.
function EditHeadLength1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditHeadLength1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditHeadLength2_Callback(hObject, eventdata, handles)
% hObject    handle to EditHeadLength2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditHeadLength2 as text
%        str2double(get(hObject,'String')) returns contents of EditHeadLength2 as a double


% --- Executes during object creation, after setting all properties.
function EditHeadLength2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditHeadLength2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectHeadStyle1.
function SelectHeadStyle1_Callback(hObject, eventdata, handles)
% hObject    handle to SelectHeadStyle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectHeadStyle1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectHeadStyle1


% --- Executes during object creation, after setting all properties.
function SelectHeadStyle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectHeadStyle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectHeadStyle2.
function SelectHeadStyle2_Callback(hObject, eventdata, handles)
% hObject    handle to SelectHeadStyle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectHeadStyle2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectHeadStyle2


% --- Executes during object creation, after setting all properties.
function SelectHeadStyle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectHeadStyle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end





function EditString_Callback(hObject, eventdata, handles)
% hObject    handle to EditString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditString as text
%        str2double(get(hObject,'String')) returns contents of EditString as a double


% --- Executes during object creation, after setting all properties.
function EditString_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


