function varargout = AddDatasetD3D(varargin)
% ADDDATASETD3D M-file for AddDatasetD3D.fig
%      ADDDATASETD3D, by itself, creates a new ADDDATASETD3D or raises the existing
%      singleton*.
%
%      H = ADDDATASETD3D returns the handle to a new ADDDATASETD3D or the handle to
%      the existing singleton*.
%
%      ADDDATASETD3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETD3D.M with the given input arguments.
%
%      ADDDATASETD3D('Property','Value',...) creates a new ADDDATASETD3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetD3D_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetD3D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help AddDatasetD3D

% Last Modified by GUIDE v2.5 22-Aug-2007 19:06:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetD3D_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetD3D_OutputFcn, ...
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


% --- Executes just before AddDatasetD3D is made visible.
function AddDatasetD3D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetD3D (see VARARGIN)

% Choose default command line output for AddDatasetD3D
handles.output = hObject;

handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};

handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;

PutInCentre(hObject);
 
handles.FileInfo=qpfopen([handles.PathName handles.FileName]);
handles.LGAFile='';
switch handles.FileName(end-2:end),
    case{'map'}
        filterspec={'*.lga', '*.lga'};
        [filename, pathname, filterindex] = uigetfile(filterspec);
        handles.LGAFile=[pathname filename];
        handles.FileInfo=qpfopen([handles.PathName handles.FileName],handles.LGAFile);
        handles.FileInfo.SubType='Delft3D-waq-map';
    case{'ada'}
        filterspec={'*.lga', '*.lga'};
        [filename, pathname, filterindex] = uigetfile(filterspec);
        handles.LGAFile=[pathname filename];
        handles.FileInfo=qpfopen([handles.PathName handles.FileName],handles.LGAFile);
    case{'his'}
        handles.FileInfo.SubType='Delft3D-waq-history';
end

handles.DataProps=qpread(handles.FileInfo);
[handles.DataFields,dummy1,dummy2]=qpread(handles.FileInfo);

handles.Parameter=handles.DataProps(1).Name;
handles.ParameterNumber=1;
handles.Size=qpread(handles.FileInfo,handles.Parameter,'size');
handles.Dims=handles.DataProps(1).DimFlag;
handles.SubField=handles.DataProps(1).SubFld;
handles.NVal=handles.DataProps(1).NVal;

switch handles.FileInfo.SubType,
    case{'Delft3D-trim','Delft3D-com','Delft3D-hwgxy','Delft3D-waq-map'}
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
        handles.T1=0;
        handles.T2=0;
        handles.TStep=1;
        set(handles.EditM,'String','1');
        set(handles.EditN,'String','1');
        set(handles.EditK,'String','1');
        set(handles.EditTimeStep,'String',handles.T);
        handles.Station='';
    case{'Delft3D-trih','Delft3D-waq-history'}
        handles.AllM=0;
        handles.AllN=0;
        handles.AllK=0;
        handles.AllT=1;
        handles.T1=0;
        handles.T2=0;
        handles.TStep=1;
        handles.AllT=1;
        handles.AllT=1;
        handles.Stations=qpread(handles.FileInfo,handles.DataProps(1).Name,'Stations');
        handles.Station=handles.Stations{1};
        set(handles.SelectStation,'String',handles.Stations);
        handles.K1=0;
        handles.K2=0;
        handles.T=1;
        set(handles.EditK,'String','1');
        set(handles.EditTimeStep,'String',handles.T);
end

switch handles.FileInfo.SubType,
    case{'Delft3D-trim'}
        ConstGroup='map-const';
    case{'Delft3D-trih'}
        ConstGroup='his-const';
end

switch handles.FileInfo.SubType,
    case{'Delft3D-trim','Delft3D-trih'}
        % Check to see if sediments are available
        ised=vs_find(handles.FileInfo,'LSED');
        if isempty(ised)
            handles.LSed=0;
        else
            handles.LSed=vs_get(handles.FileInfo,ConstGroup,'LSED','quiet');
        end
        if handles.LSed>0
            [Sediments,Succes]=vs_get(handles.FileInfo,ConstGroup,'NAMSED','quiet');
            if Succes==0
                [Sediments,Succes]=vs_get(handles.FileInfo,ConstGroup,'NAMCON','quiet');
                for i=1:size(handles.LSed)
                    handles.Sediments{i}=Sediments(i+(size(Sediments,1)-handles.LSed),:);
                end
            else
                for i=1:size(Sediments,1)
                    handles.Sediments{i}=Sediments(i,:);
                end
            end
            if i>1
                handles.Sediments{i+1}='sum over all fractions';
            end
        end
    otherwise
        handles.LSed=0;
end


set(handles.SelectParameter,'String',handles.DataFields);

handles.Component='vector';
handles.StrComp1={'vector','magnitude','angle (radians)','angle (degrees)','x-component','y-component','m-component','n-component'};
handles.StrComp2={'magnitude','angle (radians)','angle (degrees)','x-component','y-component','m-component','n-component'};
set(handles.SelectComponent,'String',handles.StrComp1);

handles.XCoordinate='pathdistance';
handles.StrXCor1={'path distance','reverse path distance','x coordinate','y coordinate'};
handles.StrXCor2={'pathdistance','revpathdistance','x','y'};
set(handles.SelectXCoordinate,'String',handles.StrXCor1);

handles.Times=[];

handles.ShowTimes=0;
switch handles.FileInfo.SubType,
    case{'Delft3D-trim','Delft3D-com'}
        handles.Times=qpread(handles.FileInfo,'water level','times');
        handles.TimeStrings=datestr(handles.Times,0);
        handles.ShowTimes=1;
    case{'Delft3D-waq-map'}
        for i=1:size(handles.DataProps,1)
            if handles.DataProps(i).DimFlag(1)>0
                handles.Times=qpread(handles.FileInfo,handles.DataProps(i).Name,'times');
                break
            end
        end 
        handles.TimeStrings=datestr(handles.Times,0);
        handles.ShowTimes=1;
    case{'Delft3D-hwgxy'}
        handles.Times=qpread(handles.FileInfo,'hsig wave height','times');
        handles.TimeStrings=datestr(handles.Times,0);
        handles.ShowTimes=1;
end

set(handles.ToggleShowTimes,'Value',handles.ShowTimes);

nstep=1;
for i=1:size(handles.DataProps,1)
    if strcmp(handles.DataProps(i).Name,'-------')==0
        Sz=qpread(handles.FileInfo,handles.DataProps(i).Name,'size');
    else
        Sz(1)=0;
    end
    if Sz(1)>1
       nstep=Sz(1);
       break
    end
end

set(handles.TextTimes,'String',num2str(nstep));

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AddDatasetD3D wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetD3D_OutputFcn(hObject, eventdata, handles) 
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
    handles.Size=qpread(handles.FileInfo,handles.Parameter,'size');
    handles.Dims=handles.DataProps(i).DimFlag;
    handles.SubField=handles.DataProps(i).SubFld;
    handles.NVal=handles.DataProps(i).NVal;
    handles.Times=qpread(handles.FileInfo,handles.Parameter,'times');
    handles.TimeStrings=datestr(handles.Times,0);

    if handles.NVal>1
        handles.Component='vector';
    end

    if strcmp(handles.FileInfo.SubType,'Delft3D-waq-map')==0
        handles.Stations=qpread(handles.FileInfo,handles.Parameter,'Stations');
        if size(handles.Stations,1)>0
            j=strmatch(handles.Station,handles.Stations);
            set(handles.SelectStation,'String',handles.Stations);
            if size(j,1)==0
                handles.Station=handles.Stations{1};
                set(handles.SelectStation,'Value',1);
            end
        end
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

[handles.T1,handles.T2,handles.TStep]=ReadFirstStepLast(get(handles.EditTimeStep,'String'));

if handles.T1==handles.T2
    handles.T=str2num(get(hObject,'String'));
    set(handles.ListAvailableTimes,'Value',handles.T);
else
    handles.T=handles.T1;
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

handles.AllT=get(hObject,'Value');

wb = waitbox('Loading time steps ...');pause(0.1);
if size(handles.Times,1)==0
    switch handles.FileInfo.SubType,
        case{'Delft3D-trim','Delft3D-com','Delft3D-trih'}
            handles.Times=qpread(handles.FileInfo,'water level','times');
        case{'Delft3D-waq-map','Delft3D-waq-history'}
            handles.Times=qpread(handles.FileInfo,handles.Parameter,'times');
        case{'Delft3D-hwgxy'}
            handles.Times=qpread(handles.FileInfo,'hsig wave height','times');
    end
    handles.TimeStrings=datestr(handles.Times,0);
end
close(wb);

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

if size(handles.Times,1)==0
    switch handles.FileInfo.SubType,
        case{'Delft3D-trim','Delft3D-com','Delft3D-trih'}
            handles.Times=qpread(handles.FileInfo,'water level','times');
        case{'Delft3D-waq-map','Delft3D-waq-history'}
            handles.Times=qpread(handles.FileInfo,handles.Parameter,'times');
        case{'Delft3D-hwgxy'}
            handles.Times=qpread(handles.FileInfo,'hsig wave height','times');
    end
    handles.TimeStrings=datestr(handles.Times,0);
end

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
    handles.M1=str2num(get(handles.EditM,'String'));
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
    handles.N1=str2num(get(handles.EditN,'String'));
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
    handles.K1=str2num(get(handles.EditK,'String'));
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



function EditN_Callback(hObject, eventdata, handles)
% hObject    handle to EditN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditN as text
%        str2double(get(hObject,'String')) returns contents of EditN as a double

[handles.N1,handles.N2,handles.NStep]=ReadFirstStepLast(get(handles.EditN,'String'));

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

handles.K1=str2num(get(hObject,'String'));
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
 
    switch lower(handles.FileInfo.SubType),
        case{'delft3d-waq-map','delft3d-waq-history'}
            handles.DataProperties(nr).FileType='Delwaq';
        otherwise
            handles.DataProperties(nr).FileType='Delft3D';
    end
    
    handles.DataProperties(nr).PathName=handles.PathName;
    handles.DataProperties(nr).FileName=handles.FileName;

    handles.DataProperties(nr).CombinedDataset=0;

    handles.DataProperties(nr).Parameter=handles.Parameter;

    handles.DataProperties(nr).SubField='none';
    if ischar(handles.SubField)
        if handles.SubField(1)=='s'
            i=get(handles.SelectSubField,'Value');
            str=handles.Sediments;
            handles.DataProperties(nr).SubField=str{i};
        end
    end
    
    handles.DataProperties(nr).LGAFile=handles.LGAFile;
    
    handles.DataProperties(nr).Station=handles.Station;

    handles.DataProperties(nr).Component=handles.Component;
    
    if handles.AllT==1
        handles.DataProperties(nr).DateTime=0;
        handles.DataProperties(nr).Block=0;
        handles.DataProperties(nr).T1=0;
        handles.DataProperties(nr).T2=0;
        handles.DataProperties(nr).TStep=1;
    elseif handles.T2>handles.T1
        handles.DataProperties(nr).DateTime=0;
        handles.DataProperties(nr).Block=0;
        handles.DataProperties(nr).T1=handles.T1;
        handles.DataProperties(nr).T2=handles.T2;
        handles.DataProperties(nr).TStep=handles.TStep;
    else
        handles.DataProperties(nr).DateTime=handles.Times(handles.T);
        handles.DataProperties(nr).Block=get(handles.ListAvailableTimes,'Value');
        handles.DataProperties(nr).T1=0;
        handles.DataProperties(nr).T2=0;
        handles.DataProperties(nr).TStep=1;
    end

    if handles.Size(2)>0
        station=get(handles.SelectStation,'Value');
    else
        station=0;
    end

    if handles.AllM==0
        [M1,M2,MStep]=ReadFirstStepLast(get(handles.EditM,'String'));
        handles.DataProperties(nr).M1=M1;
        handles.DataProperties(nr).M2=M2;
        handles.DataProperties(nr).MStep=MStep;
    else
        handles.DataProperties(nr).M1=0;
        handles.DataProperties(nr).M2=0;
        handles.DataProperties(nr).MStep=1;
    end    
    if handles.AllN==0
        [N1,N2,NStep]=ReadFirstStepLast(get(handles.EditN,'String'));
        handles.DataProperties(nr).N1=N1;
        handles.DataProperties(nr).N2=N2;
        handles.DataProperties(nr).NStep=NStep;
    else
        handles.DataProperties(nr).N1=0;
        handles.DataProperties(nr).N2=0;
        handles.DataProperties(nr).NStep=1;
    end    

    if handles.AllK==1 || handles.Size(5)==0
        handles.DataProperties(nr).K1=0;
        handles.DataProperties(nr).K2=0;
    else
        handles.DataProperties(nr).K1=handles.K1;
        handles.DataProperties(nr).K2=handles.K2;
    end
    
    handles.DataProperties(nr).XCoordinate=handles.XCoordinate;
    
    wb = waitbox('Reading data file ...');pause(0.1);
    handles.DataProperties=ImportD3D(handles.DataProperties,nr);
    close(wb);
    
else
    txt='Dataset name already exists!';
    mp_giveWarning('WarningText',txt);
end
 
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles=RefreshOptions(handles)

% Subfields
if ischar(handles.SubField)
    if handles.SubField(1)=='s'
        set(handles.SelectSubField,'String',handles.Sediments);
        set(handles.SelectSubField,'Enable','on');
        set(handles.TextSubField,'Enable','on');
    else
        set(handles.SelectSubField,'String',' ');
        set(handles.SelectSubField,'Enable','off');
        set(handles.TextSubField,'Enable','off');
        set(handles.SelectSubField,'Value',1);
    end
else
    set(handles.SelectSubField,'String',' ');
    set(handles.SelectSubField,'Enable','off');
    set(handles.TextSubField,'Enable','off');
    set(handles.SelectSubField,'Value',1);
end   

% Components
if handles.NVal>1
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
elseif handles.Size(1)==1
    set(handles.ToggleShowTimes,      'Enable','off');
    set(handles.TextTimeStep,         'Enable','off');
    set(handles.ToggleAllTimeSteps,   'Enable','off');
    set(handles.EditTimeStep,         'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.ListAvailableTimes,   'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.ListAvailableTimes,'Value',1);
    if handles.ShowTimes
        set(handles.ListAvailableTimes,'String',handles.TimeStrings(1,:));
    else
        set(handles.ListAvailableTimes,'String','');
    end
    handles.T=1;
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
if handles.Dims(5)==0 || handles.Size(5)<=1
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
        handles.K1=str2num(get(handles.EditK,'String'));
        handles.K2=handles.K1;
        set(handles.EditK,'Enable','on','BackGroundColor',[1.000 1.000 1.000]);
    end
    set(handles.ToggleAllK,'Enable','on');
end    
set(handles.ToggleAllK,'Value',handles.AllK);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

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
elseif handles.T2>handles.T1
    if handles.TStep~=1
        DatStr=[ ' - T=' num2str(handles.T1) ':' num2str(handles.TStep) ':' num2str(handles.T2)];
    else
        DatStr=[ ' - T=' num2str(handles.T1) ':' num2str(handles.T2)];
    end
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

if handles.AllN || handles.Size(4)==0
    NStr='';
else
    if handles.N2>handles.N1
        if handles.NStep~=1
            NStr=[ ' - N=' num2str(handles.N1) ':' num2str(handles.NStep) ':' num2str(handles.N2)];
        else
            NStr=[ ' - N=' num2str(handles.N1) ':' num2str(handles.N2)];
        end
    else
        NStr=[ ' - N=' num2str(handles.N1)];
    end
end

if handles.AllK || handles.Size(5)<=1
    KStr='';
else
    KStr=[ ' - K=' num2str(handles.K1)];
end

if strcmp(handles.FileInfo.SubType,'Delft3D-trim') || strcmp(handles.FileInfo.SubType,'Delft3D-trih')
    fname=handles.FileInfo.DatExt;
    switch handles.FileInfo.SubType,
        case{'Delft3D-trim'}
            ii=strfind(fname,'trim');
            RunidStr=[' - ' fname(ii+5:end-4)];
        case{'Delft3D-trih'}
            ii=strfind(fname,'trih');
            RunidStr=[' - ' fname(ii+5:end-4)];
    end
else
    RunidStr='';
end

handles.Name=[ParStr CompStr StatStr DatStr MStr NStr KStr RunidStr];
 
set(handles.EditDatasetName,'String',handles.Name);




