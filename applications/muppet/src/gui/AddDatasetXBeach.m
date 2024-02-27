function varargout = AddDatasetXBeach(varargin)
% ADDDATASETXBEACH M-file for AddDatasetXBeach.fig
%      ADDDATASETXBEACH, by itself, creates a new ADDDATASETXBEACH or raises the existing
%      singleton*.
%
%      H = ADDDATASETXBEACH returns the handle to a new ADDDATASETXBEACH or the handle to
%      the existing singleton*.
%
%      ADDDATASETXBEACH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETXBEACH.M with the given input arguments.
%
%      ADDDATASETXBEACH('Property','Value',...) creates a new ADDDATASETXBEACH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetXBeach_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetXBeach_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help AddDatasetXBeach

% Last Modified by GUIDE v2.5 22-Aug-2007 19:31:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetXBeach_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetXBeach_OutputFcn, ...
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


% --- Executes just before AddDatasetXBeach is made visible.
function AddDatasetXBeach_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetXBeach (see VARARGIN)

% Choose default command line output for AddDatasetXBeach
handles.output = hObject;

handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};

handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;

PutInCentre(hObject);

handles.DataProps=getXBDataProps;

%XBdims=XBgetdimensions(handles.PathName);
XBdims=getdimensions(handles.PathName);

nx=XBdims.nx;
ny=XBdims.ny;
nt=XBdims.nt;

handles.ngd=XBdims.ngd;       
handles.nd=XBdims.nd;        
handles.ntp=XBdims.ntp;
handles.ntc=XBdims.ntc;
handles.ntm=XBdims.ntm;  

handles.tsglobal=XBdims.tsglobal;
handles.tspoints=XBdims.tspoints;
handles.tscross=XBdims.tscross;
handles.tsmean=XBdims.tsmean;

refdat=20000101;
reftim=0;
TRef=MatTime(refdat,reftim);

handles.tsglobal=TRef+handles.tsglobal/86400;
handles.tsmean=TRef+handles.tsmean/86400;

handles.Size(1)=nt;
handles.Size(2)=0;
handles.Size(3)=nx;
handles.Size(4)=ny;
handles.Size(5)=0;

handles.Dims=[1 0 1 1 0];

set(handles.SelectSubField,'Enable','off');
set(handles.TextSubField,'Enable','off');
set(handles.SelectStation,'Enable','off');
set(handles.TextStation,'Enable','off');

handles.AllM=1;
handles.AllN=1;
handles.AllK=0;
handles.AllT=0;
handles.M1=0;
handles.N1=0;
handles.K1=0;
handles.M2=0;
handles.N2=0;
handles.K2=0;
handles.T=1;
set(handles.EditM,'String','1');
set(handles.EditN,'String','1');
set(handles.EditK,'String','');
set(handles.EditTimeStep,'String',handles.T);
handles.Station='';

handles.ShowTimes=1;

handles.Parameter=handles.DataProps(1).Name;
handles.NVal=handles.DataProps(1).NVal;
handles.DataType=handles.DataProps(1).Type;

switch lower(handles.DataProps(1).Type)
    case{'global'}
        handles.Times=handles.tsglobal;
    case{'mean'}
        handles.Times=handles.tsmean;
    case{'max'}
    case{'min'}
    case{'var'}
end

handles.TimeStrings=datestr(handles.Times,0);
set(handles.TextTimes,'String',num2str(size(handles.Times,1)));

for i=1:length(handles.DataProps)
    str{i}=handles.DataProps(i).Name;
end
set(handles.SelectParameter,'String',str);

handles.StrComp1={'magnitude','vector','m coordinate','n coordinate'};
handles.StrComp2={'magnitude','vector','mcoordinate','ncoordinate'};

handles.XCoordinate='pathdistance';
handles.StrXCor1={'path distance','reverse path distance','x coordinate','y coordinate'};
handles.StrXCor2={'pathdistance','revpathdistance','x','y'};
set(handles.SelectXCoordinate,'String',handles.StrXCor1);

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AddDatasetXBeach wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetXBeach_OutputFcn(hObject, eventdata, handles)
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

i=get(hObject,'Value');
str=get(hObject,'String');
if strcmp(str{i},'-------')
    set(hObject,'Value',handles.ParameterNumber);
else
    handles.Parameter=str{i};
    handles.ParameterNumber=i;
    handles.NVal=handles.DataProps(i).NVal;
    
    switch lower(handles.DataProps(i).Type)
        case{'global'}
            handles.Times=handles.tsglobal;
        case{'mean'}
            handles.Times=handles.tsmean;
        case{'max'}
        case{'min'}
        case{'var'}
    end

    if ~strcmpi(handles.DataProps(i).Type,handles.DataType)
        handles.TimeStrings=datestr(handles.Times,0);
        set(handles.TextTimes,'String',num2str(size(handles.Times,1)));
        handles.T=1;
        handles.DataType=handles.DataProps(i).Type;
    end
   
    handles=RefreshOptions(handles);
    handles=RefreshDatasetName(handles);
end

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

handles.T=str2num(get(hObject,'String'));
set(handles.ListAvailableTimes,'Value',handles.T);

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

handles.AllT=get(hObject,'Value');

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);


% --- Executes on button press in ToggleShowTimes.
function ToggleShowTimes_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleShowTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleShowTimes

handles.ShowTimes=get(hObject,'Value');

handles=RefreshOptions(handles);

guidata(hObject, handles);

% --- Executes on selection change in SelectStation.
function SelectStation_Callback(hObject, eventdata, handles)
% hObject    handle to SelectStation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectStation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectStation

i=get(hObject,'Value');
handles.Station=handles.Stations{i};

handles=RefreshDatasetName(handles);

guidata(hObject, handles);


% --- Executes on button press in ToggleAllM.
function ToggleAllM_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAllM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAllM

handles.AllM=get(hObject,'Value');
if handles.AllM
    handles.M1=0;
    handles.M2=0;
else
    handles.M1=str2double(get(handles.EditM,'String'));
    handles.M2=handles.M1;
end

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);


% --- Executes on button press in ToggleAllN.
function ToggleAllN_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAllN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAllN

handles.AllN=get(hObject,'Value');
if handles.AllN
    handles.N1=0;
    handles.N2=0;
else
    handles.N1=str2double(get(handles.EditN,'String'));
    handles.N2=handles.N1;
end

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);

% --- Executes on button press in ToggleAllK.
function ToggleAllK_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAllK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAllK

handles.AllK=get(hObject,'Value');
if handles.AllK
    handles.K1=0;
    handles.K2=0;
else
    handles.K1=str2double(get(handles.EditK,'String'));
    handles.K2=handles.K1;
end

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SelectStation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectStation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditM_Callback(hObject, eventdata, handles)
% hObject    handle to EditM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditM as text
%        str2double(get(hObject,'String')) returns contents of EditM as a double

handles.M1=str2double(get(hObject,'String'));
handles.M2=handles.M1;

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



function EditN_Callback(hObject, eventdata, handles)
% hObject    handle to EditN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditN as text
%        str2double(get(hObject,'String')) returns contents of EditN as a double

handles.N1=str2double(get(hObject,'String'));
handles.N2=handles.N1;

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditK_Callback(hObject, eventdata, handles)
% hObject    handle to EditK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditK as text
%        str2double(get(hObject,'String')) returns contents of EditK as a double

handles.K1=str2double(get(hObject,'String'));
handles.K2=handles.K1;

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditK (see GCBO)
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

handles.T=get(hObject,'Value');
set(handles.EditTimeStep,'String',num2str(handles.T));

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

% --- Executes on selection change in SelectComponent.
function SelectComponent_Callback(hObject, eventdata, handles)
% hObject    handle to SelectComponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectComponent contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectComponent

i=get(hObject,'Value');
str=get(hObject,'String');
handles.Component=str{i};

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectComponent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectComponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SelectXCoordinate.
function SelectXCoordinate_Callback(hObject, eventdata, handles)
% hObject    handle to SelectXCoordinate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectXCoordinate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectXCoordinate

i=get(hObject,'Value');
handles.XCoordinate=handles.StrXCor2{i};

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SelectXCoordinate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectXCoordinate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in SelectSubField.
function SelectSubField_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSubField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectSubField contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectSubField

i=get(hObject,'Value');
str=get(hObject,'String');
handles.SubField=str{i};

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectSubField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectSubField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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

    handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;
 
    nr=handles.NrAvailableDatasets;
 
    handles.DataProperties(nr).Name=Name;
 
    handles.DataProperties(nr).FileType='XBeach';
    
    handles.DataProperties(nr).PathName=handles.PathName;
    handles.DataProperties(nr).FileName='dims.dat';
    
    handles.DataProperties(nr).CombinedDataset=0;

    handles.DataProperties(nr).Parameter=handles.Parameter;

    handles.DataProperties(nr).SubField='none';
    
    handles.DataProperties(nr).Component=handles.Component;
    
    handles.DataProperties(nr).DateTime=handles.Times(get(handles.ListAvailableTimes,'Value'));
 
    handles.DataProperties(nr).Block=get(handles.ListAvailableTimes,'Value');
    
    if handles.AllT==1
        handles.DataProperties(nr).DateTime=0;
    else
        handles.DataProperties(nr).DateTime=handles.Times(handles.T);
    end

    if handles.AllM==1 || handles.Size(3)==0
        handles.DataProperties(nr).M1=0;
        handles.DataProperties(nr).M2=0;
    else
        handles.DataProperties(nr).M1=handles.M1;
        handles.DataProperties(nr).M2=handles.M2;
    end

    if handles.AllN==1 || handles.Size(4)==0
        handles.DataProperties(nr).N1=0;
        handles.DataProperties(nr).N2=0;
    else
        handles.DataProperties(nr).N1=handles.N1;
        handles.DataProperties(nr).N2=handles.N2;
    end

    if handles.AllK==1 || handles.Size(5)==0
        handles.DataProperties(nr).K1=0;
        handles.DataProperties(nr).K2=0;
    else
        handles.DataProperties(nr).K1=handles.K1;
        handles.DataProperties(nr).K2=handles.K2;
    end

    handles.DataProperties(nr).XCoordinate=handles.XCoordinate;
    
    handles.DataProperties=ImportXBeach(handles.DataProperties,nr);
    
else
    txt='Dataset name already exists!';
    mp_giveWarning('WarningText',txt);
end
 
guidata(hObject, handles);

%%
function handles=RefreshOptions(handles)

% Components
if handles.NVal==2
    set(handles.SelectComponent,'Enable','on');
    set(handles.ComponentText,  'Enable','on');
    set(handles.SelectComponent,'String',handles.StrComp1);
    set(handles.SelectComponent,'Value',strmatch(handles.Component,handles.StrComp1,'exact'));
    if strcmp(handles.Component,'vector')
        if handles.Size(2)>0 || (handles.M1==handles.M2 && handles.N1==handles.N2 && handles.M1~=0 && handles.N1~=0)
            set(handles.SelectComponent,'String',handles.StrComp2);
            handles.Component='magnitude';
            set(handles.SelectComponent,'Value',1);
        end
    end
else
    set(handles.SelectComponent,'Enable','off');
    set(handles.ComponentText,  'Enable','off');
    set(handles.SelectComponent,'String',handles.StrComp2);
    handles.Component='magnitude';
    set(handles.SelectComponent,'Value',1);
end

% Times
if handles.Size(1)==0
    set(handles.ToggleShowTimes,      'Enable','off');
    set(handles.TextTimeStep,         'Enable','off');
    set(handles.ToggleAllTimeSteps,   'Enable','off');
    set(handles.EditTimeStep,         'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.ListAvailableTimes,   'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.ListAvailableTimes,   'String','');
else
    set(handles.ToggleShowTimes,      'Enable','on');
    set(handles.TextTimeStep,         'Enable','on');
    set(handles.ToggleAllTimeSteps,   'Enable','on');
    set(handles.EditTimeStep,         'Enable','on', 'BackGroundColor',[1 1 1]);
    if handles.AllT==0
        set(handles.EditTimeStep,         'Enable','on', 'BackGroundColor',[1 1 1]);
    else
        set(handles.EditTimeStep,         'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    end
    if handles.ShowTimes && handles.AllT==0
        set(handles.ListAvailableTimes,   'Enable','on', 'BackGroundColor',[1 1 1]);
    else
        set(handles.ListAvailableTimes,   'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    end
    if handles.ShowTimes
        set(handles.ListAvailableTimes,   'String',handles.TimeStrings);
        set(handles.ListAvailableTimes,   'Value', handles.T);
    else
        set(handles.ListAvailableTimes,'String','');
    end
end
set(handles.ToggleAllTimeSteps,'Value',handles.AllT);

% M and N
if handles.Size(2)>0
    set(handles.TextStation,'Enable','on')
    set(handles.SelectStation,'Enable','on')
    set(handles.TextM,'Enable','off');
    set(handles.TextMMax,'Enable','off');
    set(handles.TextMMax,'String','-');
    set(handles.EditM,'Enable','off');
    set(handles.EditM,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.ToggleAllM,'Enable','off');
    set(handles.TextN,'Enable','off');
    set(handles.TextNMax,'Enable','off');
    set(handles.TextNMax,'String','-');
    set(handles.EditN,'Enable','off');
    set(handles.EditN,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.ToggleAllN,'Enable','off');
    set(handles.TextXCoordinate,'enable','off');
    set(handles.SelectXCoordinate,'enable','off');
else
    set(handles.TextStation,'Enable','off')
    set(handles.SelectStation,'Enable','off')
    set(handles.TextM,'Enable','on');
    set(handles.TextMMax,'Enable','on');
    set(handles.TextMMax,'String',num2str(handles.Size(3)));
    if handles.AllM==1
        set(handles.EditM,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    else
        set(handles.EditM,'Enable','on','BackGroundColor',[1.000 1.000 1.000]);
    end
    set(handles.TextN,'Enable','on');
    set(handles.TextNMax,'Enable','on');
    set(handles.TextNMax,'String',num2str(handles.Size(4)));
    if handles.AllN==1
        set(handles.EditN,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    else
        set(handles.EditN,'Enable','on','BackGroundColor',[1.000 1.000 1.000]);
    end
    if handles.M1>0 && handles.M1==handles.M2 && handles.N1>0 && handles.N1==handles.N2 
        set(handles.TextXCoordinate,'enable','off');
        set(handles.SelectXCoordinate,'enable','off');
    elseif (handles.M1>0 && handles.M1==handles.M2) || (handles.N1>0 && handles.N1==handles.N2)
        set(handles.TextXCoordinate,'enable','on');
        set(handles.SelectXCoordinate,'enable','on');
    else
        set(handles.TextXCoordinate,'enable','off');
        set(handles.SelectXCoordinate,'enable','off');
    end
end    
set(handles.ToggleAllM,'Value',handles.AllM);
set(handles.ToggleAllN,'Value',handles.AllN);

% Layers
if handles.Dims(5)==0
    set(handles.TextK,'Enable','off');
    set(handles.TextKMax,'Enable','off');
    set(handles.TextKMax,'String','-');
    set(handles.EditK,'Enable','off');
    set(handles.EditK,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.ToggleAllK,'Enable','off');
else
    set(handles.TextK,'Enable','on');
    set(handles.TextKMax,'Enable','on');
    set(handles.TextKMax,'String',num2str(handles.Size(5)));
    if handles.AllK==1
        handles.K1=0;
        handles.K2=0;
        set(handles.EditK,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    else
        handles.K1=str2double(get(handles.EditK,'String'));
        handles.K2=handles.K1;
        set(handles.EditK,'Enable','on','BackGroundColor',[1.000 1.000 1.000]);
    end
    set(handles.ToggleAllK,'Enable','on');
end    
set(handles.ToggleAllK,'Value',handles.AllK);

%%
function handles=RefreshDatasetName(handles)

ParStr=handles.Parameter;

if handles.NVal>1
    i=get(handles.SelectComponent,'Value');
    str=get(handles.SelectComponent,'String');
    CompStr=[ ' - ' str{i}];
else
    CompStr='';
end

if handles.AllT || handles.Size(1)==0
    DatStr='';
else
    DatStr=[ ' - ' handles.TimeStrings(handles.T,:)];
end

if handles.Size(2)>0
    i=get(handles.SelectStation,'Value');
    StatStr=[ ' - ' handles.Station];
else
    StatStr='';
end

if handles.AllM || handles.Size(3)==0
    MStr='';
else
    MStr=[ ' - M=' num2str(handles.M1)];
end

if handles.AllN || handles.Size(4)==0
    NStr='';
else
    NStr=[ ' - N=' num2str(handles.N1)];
end

if handles.AllK || handles.Dims(5)==0
    KStr='';
else
    KStr=[ ' - K=' num2str(handles.K1)];
end

handles.Name=[ParStr CompStr StatStr DatStr MStr NStr KStr];
 
set(handles.EditDatasetName,'String',handles.Name);




