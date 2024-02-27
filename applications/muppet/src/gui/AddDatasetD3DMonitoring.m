function varargout = AddDatasetD3DMonitoring(varargin)
% ADDDATASETD3DMONITORING M-file for AddDatasetD3DMonitoring.fig
%      ADDDATASETD3DMONITORING, by itself, creates a new ADDDATASETD3DMONITORING or raises the existing
%      singleton*.
%
%      H = ADDDATASETD3DMONITORING returns the handle to a new ADDDATASETD3DMONITORING or the handle to
%      the existing singleton*.
%
%      ADDDATASETD3DMONITORING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETD3DMONITORING.M with the given input arguments.
%
%      ADDDATASETD3DMONITORING('Property','Value',...) creates a new ADDDATASETD3DMONITORING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetD3DMonitoring_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetD3DMonitoring_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetD3DMonitoring
 
% Last Modified by GUIDE v2.5 20-Feb-2008 11:31:35
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetD3DMonitoring_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetD3DMonitoring_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
 
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
 
 
% --- Executes just before AddDatasetD3DMonitoring is made visible.
function AddDatasetD3DMonitoring_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetD3DMonitoring (see VARARGIN)
 
% Choose default command line output for AddDatasetD3DMonitoring
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};

PutInCentre(hObject);
 
filename=[handles.PathName handles.FileName];
 
fil=vs_use(filename,'quiet');
Stations=vs_get(fil,'his-const','XYSTAT','quiet');
CrossSections=vs_get(fil,'his-const','XYTRA','quiet');

if size(Stations,2)==1
    handles.NrStat(1)=0;
else
    handles.NrStat(1)=1;
end
if size(CrossSections,2)==1
    handles.NrStat(2)=0;
else
    handles.NrStat(2)=1;
end    

if handles.NrStat(1)==0 & handles.NrStat(2)==0
    mp_giveWarning('No stations or cross sections in file!');
    handles.output=handles.DataProperties;
    handles.second_output=handles.NrAvailableDatasets;
    guidata(hObject, handles);
    uiresume;
end

if handles.NrStat(1)==0
    set(handles.ToggleWindVelocity,'Value',0,'Enable','off');
else
    set(handles.ToggleWindVelocity,'Value',1);
end
if handles.NrStat(2)==0
    set(handles.TogglePressure,'Value',0,'Enable','off');
end

handles=RefreshDatasetName(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetD3DMonitoring wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetD3DMonitoring_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.second_output;
 
close(handles.figure1)
 
 
% --- Executes on button press in CancelDataset.
function CancelDataset_Callback(hObject, eventdata, handles)
% hObject    handle to CancelDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;
 
guidata(hObject, handles);
 
uiresume;
 
 
% --- Executes on button press in AddDataset.
function AddDataset_Callback(hObject, eventdata, handles)
% hObject    handle to AddDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
name=get(handles.EditDatasetName,'String');
 
if NewDatasetName(handles.DataProperties,handles.NrAvailableDatasets,name)
 
        handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;
 
        nr=handles.NrAvailableDatasets;
 
        handles.DataProperties(nr).Name=get(handles.EditDatasetName,'String');
  
        handles.DataProperties(nr).PathName=handles.PathName;
        handles.DataProperties(nr).FileName=handles.FileName;
        handles.DataProperties(nr).CombinedDataset=0;
 
        if get(handles.ToggleWindVelocity,'Value')==1
            handles.DataProperties(nr).Type='Annotation';
        else
            handles.DataProperties(nr).Type='CrossSections';
            mp_giveWarning('WarningText','This Muppet version has a problem with cross-section coordinates!');
        end
        
        handles.DataProperties(nr).FileType='D3DMonitoring';
 
        handles.DataProperties=ImportD3DMonitoring(handles.DataProperties,nr);
 
        handles.DataProperties(nr).DateTime=0;
        handles.DataProperties(nr).Parameter='Text';
        handles.DataProperties(nr).Block=0;
 
        handles.output=handles.DataProperties;
        handles.second_output=handles.NrAvailableDatasets;
 
        uiresume;
 
else
    txt='Dataset name already exists!';
    mp_giveWarning('WarningText',txt);
end
 
guidata(hObject, handles);
 
function EditDatasetName_Callback(hObject, eventdata, handles)
% hObject    handle to EditDatasetName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditDatasetName as text
%        str2double(get(hObject,'String')) returns contents of EditDatasetName as a double
 
handles.Name=get(hObject,'String');
 
guidata(hObject, handles);
 
 
% --- Executes during object creation, after setting all properties.
function EditDatasetName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditDatasetName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 


% --- Executes on button press in ToggleWindVelocity.
function ToggleWindVelocity_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleWindVelocity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleWindVelocity

set(handles.TogglePressure,'Value',0);
if handles.NrStat(2)==0
    set(hObject,'Value',1);
end    
handles=RefreshDatasetName(handles);

guidata(hObject, handles);

% --- Executes on button press in TogglePressure.
function TogglePressure_Callback(hObject, eventdata, handles)
% hObject    handle to TogglePressure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglePressure

set(handles.ToggleWindVelocity,'Value',0);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);




function handles=RefreshDatasetName(handles);

if get(handles.ToggleWindVelocity,'Value')==1
    str2=' - Stations';
else
    str2=' - Cross Sections';
end
str=[handles.FileName str2];
set(handles.EditDatasetName,'String',str);

