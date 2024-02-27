function varargout = GenerateLayout(varargin)
% GENERATELAYOUT M-file for GenerateLayout.fig
%      GENERATELAYOUT, by itself, creates a new GENERATELAYOUT or raises the existing
%      singleton*.
%
%      H = GENERATELAYOUT returns the handle to a new GENERATELAYOUT or the handle to
%      the existing singleton*.
%
%      GENERATELAYOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENERATELAYOUT.M with the given input arguments.
%
%      GENERATELAYOUT('Property','Value',...) creates a new GENERATELAYOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GenerateLayout_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GenerateLayout_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help GenerateLayout

% Last Modified by GUIDE v2.5 19-Aug-2007 03:58:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GenerateLayout_OpeningFcn, ...
                   'gui_OutputFcn',  @GenerateLayout_OutputFcn, ...
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


% --- Executes just before GenerateLayout is made visible.
function GenerateLayout_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GenerateLayout (see VARARGIN)

% Choose default command line output for GenerateLayout
handles.output = hObject;

handles.GenerateLayoutPositions=varargin{2};

handles.output=[-1 -1 -1 -1];
handles.second_output=handles.GenerateLayoutPositions;

PutInCentre(hObject);

set(handles.EditNX,'String',num2str(handles.GenerateLayoutPositions(1)));
set(handles.EditNY,'String',num2str(handles.GenerateLayoutPositions(5)));
set(handles.EditSizeX,'String',num2str(handles.GenerateLayoutPositions(2)));
set(handles.EditSizeY,'String',num2str(handles.GenerateLayoutPositions(6)));
set(handles.EditSpacingX,'String',num2str(handles.GenerateLayoutPositions(3)));
set(handles.EditSpacingY,'String',num2str(handles.GenerateLayoutPositions(7)));
set(handles.EditOriginX,'String',num2str(handles.GenerateLayoutPositions(4)));
set(handles.EditOriginY,'String',num2str(handles.GenerateLayoutPositions(8)));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GenerateLayout wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GenerateLayout_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.second_output;

close(handles.figure1)


function EditNX_Callback(hObject, eventdata, handles)
% hObject    handle to EditNX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditNX as text
%        str2double(get(hObject,'String')) returns contents of EditNX as a double


% --- Executes during object creation, after setting all properties.
function EditNX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditNY_Callback(hObject, eventdata, handles)
% hObject    handle to EditNY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditNY as text
%        str2double(get(hObject,'String')) returns contents of EditNY as a double


% --- Executes during object creation, after setting all properties.
function EditNY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditNY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditSizeX_Callback(hObject, eventdata, handles)
% hObject    handle to EditSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSizeX as text
%        str2double(get(hObject,'String')) returns contents of EditSizeX as a double


% --- Executes during object creation, after setting all properties.
function EditSizeX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditSizeY_Callback(hObject, eventdata, handles)
% hObject    handle to EditSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSizeY as text
%        str2double(get(hObject,'String')) returns contents of EditSizeY as a double


% --- Executes during object creation, after setting all properties.
function EditSizeY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditSpacingX_Callback(hObject, eventdata, handles)
% hObject    handle to EditSpacingX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSpacingX as text
%        str2double(get(hObject,'String')) returns contents of EditSpacingX as a double


% --- Executes during object creation, after setting all properties.
function EditSpacingX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSpacingX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditSpacingY_Callback(hObject, eventdata, handles)
% hObject    handle to EditSpacingY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSpacingY as text
%        str2double(get(hObject,'String')) returns contents of EditSpacingY as a double


% --- Executes during object creation, after setting all properties.
function EditSpacingY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSpacingY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditOriginX_Callback(hObject, eventdata, handles)
% hObject    handle to EditOriginX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditOriginX as text
%        str2double(get(hObject,'String')) returns contents of EditOriginX as a double


% --- Executes during object creation, after setting all properties.
function EditOriginX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditOriginX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditOriginY_Callback(hObject, eventdata, handles)
% hObject    handle to EditOriginY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditOriginY as text
%        str2double(get(hObject,'String')) returns contents of EditOriginY as a double


% --- Executes during object creation, after setting all properties.
function EditOriginY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditOriginY (see GCBO)
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

nx=str2num(get(handles.EditNX,'String'));
ny=str2num(get(handles.EditNY,'String'));
szx=str2num(get(handles.EditSizeX,'String'));
szy=str2num(get(handles.EditSizeY,'String'));
spx=str2num(get(handles.EditSpacingX,'String'));
spy=str2num(get(handles.EditSpacingY,'String'));
orx=str2num(get(handles.EditOriginX,'String'));
ory=str2num(get(handles.EditOriginY,'String'));

n=0;
for j=1:ny
    for i=1:nx
        n=n+1;
        pos(n,1)=orx+(i-1)*(szx+spx);
        pos(n,2)=ory+(ny-j)*(szy+spy);
        pos(n,3)=szx;
        pos(n,4)=szy;
    end
end

handles.GenerateLayoutPositions=[nx szx spx orx ny szy spy ory];

handles.output=pos;
handles.second_output=handles.GenerateLayoutPositions;

guidata(hObject, handles);
 
uiresume;

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
 
uiresume;

