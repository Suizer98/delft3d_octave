function varargout = ListTunes(varargin)
% LISTTUNES M-file for ListTunes.fig
%      LISTTUNES, by itself, creates a new LISTTUNES or raises the existing
%      singleton*.
%
%      H = LISTTUNES returns the handle to a new LISTTUNES or the handle to
%      the existing singleton*.
%
%      LISTTUNES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LISTTUNES.M with the given input arguments.
%
%      LISTTUNES('Property','Value',...) creates a new LISTTUNES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ListTunes_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ListTunes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ListTunes

% Last Modified by GUIDE v2.5 20-May-2007 17:25:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ListTunes_OpeningFcn, ...
                   'gui_OutputFcn',  @ListTunes_OutputFcn, ...
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


% --- Executes just before ListTunes is made visible.
function ListTunes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ListTunes (see VARARGIN)

% Choose default command line output for ListTunes
handles.output = hObject;
 
handles.Tunes=varargin{2};

PutInCentre(hObject);
 
set(handles.ListSongs,'String',handles.Tunes);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ListTunes wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ListTunes_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

close(handles.figure1)
 

% --- Executes on selection change in ListSongs.
function ListSongs_Callback(hObject, eventdata, handles)
% hObject    handle to ListSongs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListSongs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListSongs


% --- Executes during object creation, after setting all properties.
function ListSongs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListSongs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

i=get(handles.ListSongs,'Value');
handles.Tune=handles.Tunes{i};

handles.output=handles.Tune;
 
guidata(hObject, handles);
 
uiresume;

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output='';
 
guidata(hObject, handles);
 
uiresume;

