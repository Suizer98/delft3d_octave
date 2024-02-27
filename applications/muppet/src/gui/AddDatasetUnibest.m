function varargout = AddDatasetUnibest(varargin)
% ADDDATASETUNIBEST M-file for AddDatasetUnibest.fig
%      ADDDATASETUNIBEST, by itself, creates a new ADDDATASETUNIBEST or raises the existing
%      singleton*.
%
%      H = ADDDATASETUNIBEST returns the handle to a new ADDDATASETUNIBEST or the handle to
%      the existing singleton*.
%
%      ADDDATASETUNIBEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETUNIBEST.M with the given input arguments.
%
%      ADDDATASETUNIBEST('Property','Value',...) creates a new ADDDATASETUNIBEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetUnibest_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetUnibest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help AddDatasetUnibest

% Last Modified by GUIDE v2.5 29-Dec-2006 17:24:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetUnibest_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetUnibest_OutputFcn, ...
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


% --- Executes just before AddDatasetUnibest is made visible.
function AddDatasetUnibest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetUnibest (see VARARGIN)

% Choose default command line output for AddDatasetUnibest
handles.output = hObject;

handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};

handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;

PutInCentre(hObject);
 
handles.FileInfo=qpfopen([handles.PathName handles.FileName]);
handles.DataProps=handles.FileInfo.Quant.LongName;
handles.NTimes=handles.FileInfo.NTimes;
handles.MMax=size(handles.FileInfo.X,2);
handles.Times=qpread(handles.FileInfo,handles.DataProps{1},'times');

if handles.Times(1)<100000
    handles.Times=handles.Times+730486;
end

if handles.Times(1)<100000
    Seconds=handles.Times*86400;
    NDays=floor(Seconds/86400);
    NHours=floor((Seconds-NDays*86400)/3600);
    NMinutes=floor((Seconds-NDays*86400-NHours*3600)/60);
    NSeconds=floor(Seconds-NDays*86400-NHours*3600-NMinutes*60);
    for i=1:handles.NTimes
        handles.DateStrings{i}=['day ' num2str(NDays(i)) ' '  datestr( (NHours(i)*3600 + NMinutes(i)*60 + NSeconds(i))/86400,13)];
    end
else
    for i=1:handles.NTimes
        handles.DateStrings{i}=datestr(handles.Times(i),0);
    end
end

set(handles.ListAvailableTimes,'String',handles.DateStrings);

set(handles.SelectParameter,'String',handles.DataProps);

handles.M1=0;
handles.M2=0;
handles.MStep=1;

handles.T1=1;
handles.T2=1;
handles.TStep=1;

set(handles.ToggleAllM,'Value',1);
set(handles.ToggleAllTimeSteps,'Value',0);

set(handles.EditTimeStep,'String','1');
set(handles.EditM,'String','1');

set(handles.TextMMax,'String',num2str(handles.MMax));
set(handles.TextTimes,'String',num2str(handles.NTimes));

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AddDatasetUnibest wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetUnibest_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.second_output;
 
close(handles.figure1)

% --- Executes on selection change in SelectParameter.
function SelectParameter_Callback(hObject, eventdata, handles)
% hObject    handle to SelectParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectParameter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectParameter

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectParameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTimeStep_Callback(hObject, eventdata, handles)
% hObject    handle to EditTimeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTimeStep as text
%        str2double(get(hObject,'String')) returns contents of EditTimeStep as a double

[handles.T1,handles.T2,handles.TStep]=ReadFirstStepLast(get(handles.EditTimeStep,'String'));

if handles.T1==handles.T2
    set(handles.ListAvailableTimes,'Value',handles.T1);
end
handles=RefreshDatasetName(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTimeStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTimeStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in ToggleAllTimeSteps.
function ToggleAllTimeSteps_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAllTimeSteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAllTimeSteps

if get(hObject,'Value')==0
    [handles.T1,handles.T2,handles.TStep]=ReadFirstStepLast(get(handles.EditTimeStep,'String'));
else
    handles.T1=0;
    handles.T2=0;
    handles.TStep=1;
end

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);


% --- Executes on button press in ToggleAllM.
function ToggleAllM_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAllM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAllM

if get(hObject,'Value')==0
    [handles.M1,handles.M2,handles.MStep]=ReadFirstStepLast(get(handles.EditM,'String'));
else
    handles.M1=0;
    handles.M2=0;
    handles.MStep=1;
end

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);

function EditM_Callback(hObject, eventdata, handles)
% hObject    handle to EditM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditM as text
%        str2double(get(hObject,'String')) returns contents of EditM as a double

[handles.M1,handles.M2,handles.MStep]=ReadFirstStepLast(get(handles.EditM,'String'));

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function EditDatasetName_Callback(hObject, eventdata, handles)
% hObject    handle to EditDatasetName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditDatasetName as text
%        str2double(get(hObject,'String')) returns contents of EditDatasetName as a double


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

% --- Executes on selection change in ListAvailableTimes.
function ListAvailableTimes_Callback(hObject, eventdata, handles)
% hObject    handle to ListAvailableTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListAvailableTimes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListAvailableTimes

handles.T1=get(hObject,'Value');
handles.T2=handles.T1;
handles.TStep==1;

set(handles.EditTimeStep,'String',num2str(handles.T1));

handles=RefreshDatasetName(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ListAvailableTimes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListAvailableTimes (see GCBO)
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

handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;
 
guidata(hObject, handles);
 
uiresume;

% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;

% --- Executes on button press in PushAdd.
function PushAdd_Callback(hObject, eventdata, handles)
% hObject    handle to PushAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Name=get(handles.EditDatasetName,'String');

if NewDatasetName(handles.DataProperties,handles.NrAvailableDatasets,Name)

    if ((handles.T2>handles.T1 | handles.T1==0) & (handles.M2>handles.M1 | handles.M1==0)) | ((handles.T2==handles.T1 & handles.T1>0) & (handles.M2==handles.M1 & handles.M1>0))

        txt='These dimensions are not possible!';
        mp_giveWarning('WarningText',txt);

    else

        handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;

        nr=handles.NrAvailableDatasets;

        handles.DataProperties(nr).Name=Name;

        handles.DataProperties(nr).FileType=handles.FileInfo.FileType;

        handles.DataProperties(nr).PathName=handles.PathName;
        handles.DataProperties(nr).FileName=handles.FileName;

        if handles.T1>0 & handles.T1==handles.T2
            if handles.Times(handles.T1)>100000
                handles.DataProperties(nr).DateTime=handles.Times(handles.T1);
            else
                handles.DataProperties(nr).DateTime=0;
            end
        else
            handles.DataProperties(nr).DateTime=0;
        end

        handles.DataProperties(nr).CombinedDataset=0;

        handles.DataProperties(nr).Parameter=handles.DataProps{get(handles.SelectParameter,'Value')};

        handles.DataProperties(nr).T1=handles.T1;
        handles.DataProperties(nr).T2=handles.T2;
        handles.DataProperties(nr).TStep=handles.TStep;

        handles.DataProperties(nr).M1=handles.M1;
        handles.DataProperties(nr).M2=handles.M2;
        handles.DataProperties(nr).MStep=handles.MStep;

        handles.DataProperties=ImportUnibest(handles.DataProperties,nr);

    end
else
    txt='Dataset name already exists!';
    mp_giveWarning('WarningText',txt);
end

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles=RefreshOptions(handles);

if get(handles.ToggleAllTimeSteps,'Value')==1
    set(handles.ListAvailableTimes,   'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.EditTimeStep,         'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
else
    set(handles.ListAvailableTimes,   'Enable','on', 'BackGroundColor',[1 1 1]);
    set(handles.EditTimeStep,         'Enable','on', 'BackGroundColor',[1 1 1]);
end

if get(handles.ToggleAllM,'Value')==1
    set(handles.EditM,         'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
else
    set(handles.ListAvailableTimes,   'Enable','on', 'BackGroundColor',[1 1 1]);
    set(handles.EditM,         'Enable','on', 'BackGroundColor',[1 1 1]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

function handles=RefreshDatasetName(handles);

ParStr=handles.DataProps{get(handles.SelectParameter,'Value')};

if get(handles.ToggleAllTimeSteps,'Value')==1
    DatStr='';
else
    if handles.T2>handles.T1
        if handles.TStep~=1
            DatStr=[ ' - T=' num2str(handles.T1) ':' num2str(handles.TStep) ':' num2str(handles.T2) ];
        else
            DatStr=[ ' - T=' num2str(handles.T1) ':' num2str(handles.T2) ];
        end
    else
        DatStr=[ ' - ' handles.DateStrings{handles.T1} ];
    end
end

if get(handles.ToggleAllM,'Value')==1
    MStr='';
else
    if handles.M2>handles.M1
        if handles.MStep~=1
            MStr=[ ' - M=' num2str(handles.M1) ':' num2str(handles.MStep) ':' num2str(handles.M2)];
        else
            MStr=[ ' - M=' num2str(handles.M1) ':' num2str(handles.M2)];
        end
    else
        MStr=[ ' - M=' num2str(handles.M1)];
    end
end

handles.Name=[ParStr DatStr MStr];
 
set(handles.EditDatasetName,'String',handles.Name);


