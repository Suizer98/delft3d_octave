function varargout = AddDatasetTekalMap(varargin)
% ADDDATASETTEKALMAP M-file for AddDatasetTekalMap.fig
%      ADDDATASETTEKALMAP, by itself, creates a new ADDDATASETTEKALMAP or raises the existing
%      singleton*.
%
%      H = ADDDATASETTEKALMAP returns the handle to a new ADDDATASETTEKALMAP or the handle to
%      the existing singleton*.
%
%      ADDDATASETTEKALMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETTEKALMAP.M with the given input arguments.
%
%      ADDDATASETTEKALMAP('Property','Value',...) creates a new ADDDATASETTEKALMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetTekalMap_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetTekalMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetTekalMap
 
% Last Modified by GUIDE v2.5 18-Apr-2007 17:20:07
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetTekalMap_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetTekalMap_OutputFcn, ...
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
 
 
% --- Executes just before AddDatasetTekalMap is made visible.
function AddDatasetTekalMap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetTekalMap (see VARARGIN)
 
% Choose default command line output for AddDatasetTekalMap
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};
 
PutInCentre(hObject);
 
FileInfo=tekal('open',[handles.PathName handles.FileName]);

mmax=FileInfo.Field(1).Size(4);
nmax=FileInfo.Field(1).Size(3);
nrcolumns=FileInfo.Field(1).Size(2);
nrblocks=size(FileInfo.Field,2);

for i=1:nrcolumns
    str{i}=['Column ' num2str(i)];
end
set(handles.SelectX,'String',str);
clear str;

for i=1:nrcolumns
    str{i}=['Column ' num2str(i)];
end
set(handles.SelectY,'String',str);
clear str;

for i=1:nrcolumns-2
    str{i}=FileInfo.Field(1).ColLabels{i+2};
    if size(str{i},2)==0
        str{i}=['Column ' num2str(i+2)];
    end
end
set(handles.SelectParameter,'String',str);
clear str

for i=1:nrblocks
    str{i}=FileInfo.Field(i).Name;
end
set(handles.SelectBlock,'String',str);
clear str

handles.M=0;
handles.N=0;
handles.Block=1;
handles.DateTime=0;
handles.AllM=1;
handles.AllN=1;

set(handles.TextMMax,'String',num2str(mmax));
set(handles.TextNMax,'String',num2str(nmax));
set(handles.ToggleAllM,'Value',handles.AllM);
set(handles.ToggleAllN,'Value',handles.AllN);
set(handles.EditM,'String','1');
set(handles.EditN,'String','1');

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

set(handles.SelectX,'Value',1);
set(handles.SelectY,'Value',2);
set(handles.SelectParameter,'Value',1);

clear FileInfo;

% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetTekalMap wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetTekalMap_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.second_output;
 
close(handles.figure1)
 
% --- Executes during object creation, after setting all properties.
function SelectParameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
% --- Executes on selection change in SelectParameter.
function SelectParameter_Callback(hObject, eventdata, handles)
% hObject    handle to SelectParameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectParameter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectParameter
 
handles=RefreshDatasetName(handles);
 
guidata(hObject, handles);
 
 
% --- Executes on button press in OKDataset.
function OKDataset_Callback(hObject, eventdata, handles)
% hObject    handle to OKDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
 
handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;
 
guidata(hObject, handles);
 
uiresume;
 
 
% --- Executes on button press in CancelDataset.
function CancelDataset_Callback(hObject, eventdata, handles)
% hObject    handle to CancelDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;
 
guidata(hObject, handles);
 
uiresume;
 
% --- Executes during object creation, after setting all properties.
function SelectBlock_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in SelectBlock.
function SelectBlock_Callback(hObject, eventdata, handles)
% hObject    handle to SelectBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectBlock contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectBlock
 
handles.Block=get(hObject,'Value');
handles=RefreshDatasetName(handles);
guidata(hObject, handles);
 
 
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
 
    handles.DataProperties(nr).FileType='TekalMap';
 
    i=get(handles.SelectParameter,'Value');
    str=get(handles.SelectParameter,'String');
    handles.DataProperties(nr).Parameter=str{i};
 
    handles.DataProperties(nr).DateTime=0;
 
    handles.DataProperties(nr).Block=get(handles.SelectBlock,'Value');

    handles.DataProperties(nr).ColumnX=get(handles.SelectX,'Value');
    handles.DataProperties(nr).ColumnY=get(handles.SelectY,'Value');
    
    handles.DataProperties(nr).Column=get(handles.SelectParameter,'Value')+2;
 
    handles.DataProperties(nr).PathName=handles.PathName;
    handles.DataProperties(nr).FileName=handles.FileName;
    handles.DataProperties(nr).CombinedDataset=0;
    
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
    
    handles.DataProperties(nr).MultiplyX=1.0;
    handles.DataProperties(nr).AddX=0.0;
        
    handles.DataProperties=ImportTekalMap(handles.DataProperties,nr);
 
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
 
 
function handles=RefreshDatasetName(handles);
 
i=get(handles.SelectParameter,'Value');
str=get(handles.SelectParameter,'String');
 
j=get(handles.SelectBlock,'Value');
strbl=get(handles.SelectBlock,'String');
 
set(handles.EditDatasetName,'String',[str{i} ' - ' strbl{j}]);


% --- Executes on selection change in SelectY.
function SelectY_Callback(hObject, eventdata, handles)
% hObject    handle to SelectY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectY


% --- Executes during object creation, after setting all properties.
function SelectY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectX.
function SelectX_Callback(hObject, eventdata, handles)
% hObject    handle to SelectX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectX contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectX


% --- Executes during object creation, after setting all properties.
function SelectX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function EditM_Callback(hObject, eventdata, handles)
% hObject    handle to EditM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditM as text
%        str2double(get(hObject,'String')) returns contents of EditM as a double


% --- Executes during object creation, after setting all properties.
function EditM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditN_Callback(hObject, eventdata, handles)
% hObject    handle to EditN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditN as text
%        str2double(get(hObject,'String')) returns contents of EditN as a double


% --- Executes during object creation, after setting all properties.
function EditN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
% handles=RefreshDatasetName(handles);

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
% handles=RefreshDatasetName(handles);

guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles=RefreshOptions(handles);

if handles.AllM==1
    set(handles.EditM,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
else
    set(handles.EditM,'Enable','on','BackGroundColor',[1.000 1.000 1.000]);
end
if handles.AllN==1
    set(handles.EditN,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
else
    set(handles.EditN,'Enable','on','BackGroundColor',[1.000 1.000 1.000]);
end


