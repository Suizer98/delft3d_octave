function varargout = GiveWarning(varargin)
% GIVEWARNING M-file for GiveWarning.fig
%      GIVEWARNING, by itself, creates a new GIVEWARNING or raises the existing
%      singleton*.
%
%      H = GIVEWARNING returns the handle to a new GIVEWARNING or the handle to
%      the existing singleton*.
%
%      GIVEWARNING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GIVEWARNING.M with the given input arguments.
%
%      GIVEWARNING('Property','Value',...) creates a new GIVEWARNING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GiveWarning_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GiveWarning_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help GiveWarning
 
% Last Modified by GUIDE v2.5 10-Mar-2006 13:47:35
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GiveWarning_OpeningFcn, ...
                   'gui_OutputFcn',  @GiveWarning_OutputFcn, ...
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
 
 
% --- Executes just before GiveWarning is made visible.
function GiveWarning_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GiveWarning (see VARARGIN)
 
% Choose default command line output for GiveWarning

h=getHandles;

handles.output = hObject;
 
handles.Text=varargin{2};

PutInCentre(hObject);

if ~isempty(h)
    StatName=[h.settingsDir '\icons\god2.jpg'];
    c = imread(StatName,'jpeg');
    image(c);
    tick(gca,'x','none');tick(gca,'y','none');
else
    set(gca,'Visible','off');
end

set(handles.text1,'String',handles.Text);
 
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes GiveWarning wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = GiveWarning_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;

close(handles.figure1)
 
% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;

