function varargout = AddDatasetD3DMeteo(varargin)
% ADDDATASETD3DMETEO M-file for AddDatasetD3DMeteo.fig
%      ADDDATASETD3DMETEO, by itself, creates a new ADDDATASETD3DMETEO or raises the existing
%      singleton*.
%
%      H = ADDDATASETD3DMETEO returns the handle to a new ADDDATASETD3DMETEO or the handle to
%      the existing singleton*.
%
%      ADDDATASETD3DMETEO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETD3DMETEO.M with the given input arguments.
%
%      ADDDATASETD3DMETEO('Property','Value',...) creates a new ADDDATASETD3DMETEO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetD3DMeteo_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetD3DMeteo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetD3DMeteo
 
% Last Modified by GUIDE v2.5 26-Jun-2008 16:49:55
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetD3DMeteo_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetD3DMeteo_OutputFcn, ...
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
 
 
% --- Executes just before AddDatasetD3DMeteo is made visible.
function AddDatasetD3DMeteo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetD3DMeteo (see VARARGIN)
 
% Choose default command line output for AddDatasetD3DMeteo
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
fname=varargin{6};
handles.FileName=fname(1:end-4);
handles.NrAvailableDatasets=varargin{8};

handles.RefDate=floor(now);

yyyy=datestr(handles.RefDate,'yyyy');
mm=datestr(handles.RefDate,'mm');
dd=datestr(handles.RefDate,'dd');
str=[yyyy ' ' mm ' ' dd];
set(handles.EditRefDate,'String',str);

PutInCentre(hObject);

set(handles.ToggleWindVelocity,'Enable','off');
set(handles.TogglePressure,'Enable','off');

str={'Pa','mBar'};
set(handles.SelectPressureType,'String',str);

if strcmpi(fname(end),'p')
    set(handles.ToggleWindVelocity,'Value',0);
    set(handles.TogglePressure,'Value',1);
    handles.Parameter='pressure';
else
    set(handles.ToggleWindVelocity,'Value',1);
    set(handles.TogglePressure,'Value',0);
    handles.Parameter='wind velocity';
    set(handles.SelectPressureType,'Visible','off');
end

wb = waitbox('Getting Meteo Times ...');pause(0.1);

handles=GetD3DMeteoTimes(handles);

close(wb);

handles=RefreshTimes(handles);

handles=RefreshDatasetName(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetD3DMeteo wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetD3DMeteo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.second_output;
 
close(handles.figure1)
 
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;
 
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in PushOK.
function PushOK_Callback(hObject, eventdata, handles)
% hObject    handle to PushOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;
 
guidata(hObject, handles);
 
uiresume;

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


function handles=RefreshDatasetName(handles)

if get(handles.ToggleWindVelocity,'Value')==1
    str2=' - Wind Velocity';
else
    str2=' - Air Pressure';
end
ii=get(handles.SelectTime,'Value');
tim=handles.Times(ii);
timstr=datestr(tim,0);
str=[handles.FileName str2 ' ' timstr];
set(handles.EditDatasetName,'String',str);

function EditRefDate_Callback(hObject, eventdata, handles)
% hObject    handle to EditRefDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditRefDate as text
%        str2double(get(hObject,'String')) returns contents of EditRefDate as a double

str=get(hObject,'String');
handles.RefDate=D3DTimeString(str);
handles=RefreshTimes(handles);
handles=RefreshDatasetName(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditRefDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditRefDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectTime.
function SelectTime_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectTime contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectTime

handles=RefreshDatasetName(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function handles=RefreshTimes(handles)

nt=length(handles.Hours);
times=handles.RefDate+handles.Hours/24;
handles.Times=times;
for ii=1:nt
    t{ii}=datestr(times(ii),0);
end
set(handles.SelectTime,'String',t);



% --- Executes on button press in PushAdd.
function PushAdd_Callback(hObject, eventdata, handles)
% hObject    handle to PushAdd (see GCBO)
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
            handles.DataProperties(nr).Parameter='Wind Velocity';
            handles.DataProperties(nr).Type='2DVector';
        else
            handles.DataProperties(nr).Parameter='Pressure';
            handles.DataProperties(nr).Type='2DScalar';
        end
        
        handles.DataProperties(nr).FileType='D3DMeteo';
 
        handles.DataProperties(nr).RefDate=handles.RefDate;
 
        ii=get(handles.SelectTime,'Value');
        handles.DataProperties(nr).DateTime=handles.Times(ii);
        handles.DataProperties(nr).Block=0;

        if strcmpi(handles.DataProperties(nr).Parameter(1),'p')
            str={'Pa','mBar'};
            ii=get(handles.SelectPressureType,'Value');
            handles.DataProperties(nr).PressureType=str{ii};
        end
        
        wb = waitbox('Importing Meteo Data ...');pause(0.1);
        handles.DataProperties=ImportD3DMeteo(handles.DataProperties,nr);
        close(wb);

        handles.output=handles.DataProperties;
        handles.second_output=handles.NrAvailableDatasets;
 
 %       uiresume;
 
else
    txt='Dataset name already exists!';
    mp_giveWarning('WarningText',txt);
end
 
guidata(hObject, handles);
 

%%
function handles=GetD3DMeteoTimes(handles)

par=lower(handles.Parameter(1));

itdate=handles.RefDate;

switch par
    case{'p'}
        fid=fopen([handles.PathName handles.FileName '.amp'],'r');
    case{'w'}
        fid=fopen([handles.PathName handles.FileName '.amu'],'r');
end

if strcmpi(par,'p');
    v0=strread(fgetl(fid),'%q');
end

v0=strread(fgetl(fid),'%q');
ncols=str2double(v0{2});
v0=strread(fgetl(fid),'%q');
nrows=str2double(v0{2});

v0=strread(fgetl(fid),'%q');
v0=strread(fgetl(fid),'%q');
v0=strread(fgetl(fid),'%q');
v0=strread(fgetl(fid),'%q');

for ii=1:1000
    tx0=fgetl(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
        th=str2double(v0{4});
        tf=itdate+th/24;
        handles.Hours(ii)=th;
        dummy=fscanf(fid,'%g',[ncols nrows]);
        tx1=fgetl(fid);
    else
        u=[];
        v=[];
        break;
    end
end

fclose(fid);


% --- Executes on selection change in SelectPressureType.
function SelectPressureType_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPressureType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectPressureType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectPressureType


% --- Executes during object creation, after setting all properties.
function SelectPressureType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectPressureType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


