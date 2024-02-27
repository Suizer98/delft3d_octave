function varargout = EditFigures(varargin)
% EDITFIGURES M-file for EditFigures.fig
%      EDITFIGURES, by itself, creates a new EDITFIGURES or raises the existing
%      singleton*.
%
%      H = EDITFIGURES returns the handle to a new EDITFIGURES or the handle to
%      the existing singleton*.
%
%      EDITFIGURES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITFIGURES.M with the given input arguments.
%
%      EDITFIGURES('Property','Value',...) creates a new EDITFIGURES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditFigures_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditFigures_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help EditFigures

% Last Modified by GUIDE v2.5 04-Aug-2006 10:26:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditFigures_OpeningFcn, ...
                   'gui_OutputFcn',  @EditFigures_OutputFcn, ...
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


% --- Executes just before EditFigures is made visible.
function EditFigures_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditFigures (see VARARGIN)

% Choose default command line output for EditFigures

h=varargin{2};
handles.output = h;
handles.Figure=h.Figure;
handles.ActiveFigure=h.ActiveFigure;
handles.NrFigures=h.NrFigures;
handles.DefaultFigureProperties=h.DefaultFigureProperties;
handles.DefaultSubplotProperties=h.DefaultSubplotProperties;

PutInCentre(hObject);
 
handles=UpdateFigureList(handles);


% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddSubplot wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = EditFigures_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
 
close(handles.figure1);


% --- Executes on selection change in ListFigures.
function ListFigures_Callback(hObject, eventdata, handles)
% hObject    handle to ListFigures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListFigures contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListFigures

handles.ActiveFigure=get(hObject,'Value');
set(handles.EditFigureName,'String',handles.Figure(handles.ActiveFigure).Name);

if strcmp(get(gcf,'SelectionType'),'open')
    h=guidata(findobj('Name','Muppet'));
    h.Figure=handles.Figure;
    h.NrFigures=handles.NrFigures;
    h.ActiveFigure=handles.ActiveFigure;
    handles.output=h;
    guidata(hObject, handles);
    uiresume;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ListFigures_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListFigures (see GCBO)
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
h.Figure=handles.Figure;
h.NrFigures=handles.NrFigures;
h.ActiveFigure=handles.ActiveFigure;
handles.output=h;
 
guidata(hObject, handles);
 
uiresume;

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;

% --- Executes on button press in PushCopy.
function PushCopy_Callback(hObject, eventdata, handles)
% hObject    handle to PushCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

i=handles.ActiveFigure;
handles.NrFigures=handles.NrFigures+1;
handles.Figure(handles.NrFigures)=handles.Figure(i);
handles.ActiveFigure=handles.NrFigures;
handles.Figure(handles.NrFigures).Name=[handles.Figure(i).Name ' - 2'];
handles=UpdateFigureList(handles);
guidata(hObject, handles);

% --- Executes on button press in PushDelete.
function PushDelete_Callback(hObject, eventdata, handles)
% hObject    handle to PushDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ifig=handles.ActiveFigure;

if handles.NrFigures>1
    
    for i=ifig:handles.NrFigures-1
        handles.Figure(i)=handles.Figure(i+1);
    end        

    handles.Figure=handles.Figure(1:handles.NrFigures-1);
    handles.NrFigures=handles.NrFigures-1;
    handles.ActiveFigure=min(handles.ActiveFigure,handles.NrFigures);
    handles=UpdateFigureList(handles);
    
end

guidata(hObject, handles);

% --- Executes on button press in PushAdd.
function PushAdd_Callback(hObject, eventdata, handles)
% hObject    handle to PushAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname,filter]=uigetfile([handles.MuppetPath 'settings' filesep 'layouts' filesep '*.mup']);
handles.LayoutName=[pathname filename];

if filter==1

    handles.NrFigures=handles.NrFigures+1;
    handles.ActiveFigure=handles.NrFigures;
    
    % Read layout file

    handles=ReadLayout(handles,handles.LayoutName,handles.ActiveFigure);
    
    handles.Figure(handles.ActiveFigure).FileName=[handles.Figure(handles.ActiveFigure).Name '.png'];
    handles.Figure(handles.ActiveFigure).Format='png';
    handles.Figure(handles.ActiveFigure).Resolution=300;
    handles.Figure(handles.ActiveFigure).Renderer='zbuffer';
    
    handles=UpdateFigureList(handles);

end

guidata(hObject, handles);


function EditFigureName_Callback(hObject, eventdata, handles)
% hObject    handle to EditFigureName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFigureName as text
%        str2double(get(hObject,'String')) returns contents of EditFigureName as a double

i=handles.ActiveFigure;
handles.Figure(i).Name=get(hObject,'String');
handles=UpdateFigureList(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditFigureName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFigureName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function handles=UpdateFigureList(handles)

for i=1:handles.NrFigures
    FigureNames{i}=handles.Figure(i).Name;
end

set(handles.ListFigures,'String',FigureNames);
set(handles.ListFigures,'Value',handles.ActiveFigure);
set(handles.EditFigureName,'String',handles.Figure(handles.ActiveFigure).Name);
