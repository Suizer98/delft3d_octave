function varargout = saco_select_column(varargin)

% select_column : GUI which displays the columns in a tekal file and let user select a column

% SACO_SELECT_COLUMN M-cancel for saco_select_column.fig
%      SACO_SELECT_COLUMN, by itself, creates a new SACO_SELECT_COLUMN or raises the existing
%      singleton*.
%
%      H = SACO_SELECT_COLUMN returns the handle to a new SACO_SELECT_COLUMN or the handle to
%      the existing singleton*.
%
%      SACO_SELECT_COLUMN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SACO_SELECT_COLUMN.M with the given input arguments.
%
%      SACO_SELECT_COLUMN('Property','Value',...) creates a new SACO_SELECT_COLUMN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before saco_select_column_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to saco_select_column_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help saco_select_column

% Last Modified by GUIDE v2.5 28-Apr-2013 09:19:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @saco_select_column_OpeningFcn, ...
                   'gui_OutputFcn',  @saco_select_column_OutputFcn, ...
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


% --- Executes just before saco_select_column is made visible.
function saco_select_column_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to saco_select_column (see VARARGIN)
%
% General initialisation
%
progdir = varargin{2};
PutInCentre(hObject);
newico     (hObject,[progdir 'fig\salt-icon.png']);

handles.Selection_text = varargin{1};
handles.Colselect       = [];

set (handles.Selection,'String',handles.Selection_text);

% Update handles structure

guidata(hObject, handles);

uiwait(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = saco_select_column_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.Colselect;

delete(hObject);


% --- Executes on selection change in Selection.
function Selection_Callback(hObject, eventdata, handles)
% hObject    handle to Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Selection

handles.Colselect = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Colselect = [];
guidata(hObject, handles);
uiresume;


% --- Executes on button press in Ok.
function Ok_Callback(hObject, eventdata, handles)
% hObject    handle to Ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume


% --- Executes when user attempts to close Saco.
function Saco_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Saco (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

handles.Colselect = [];
guidata(hObject, handles);
uiresume
