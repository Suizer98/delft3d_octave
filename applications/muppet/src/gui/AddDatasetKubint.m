function varargout = AddDatasetKubint(varargin)
% ADDDATASETKUBINT M-file for AddDatasetKubint.fig
%      ADDDATASETKUBINT, by itself, creates a new ADDDATASETKUBINT or raises the existing
%      singleton*.
%
%      H = ADDDATASETKUBINT returns the handle to a new ADDDATASETKUBINT or the handle to
%      the existing singleton*.
%
%      ADDDATASETKUBINT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETKUBINT.M with the given input arguments.
%
%      ADDDATASETKUBINT('Property','Value',...) creates a new ADDDATASETKUBINT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetKubint_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetKubint_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetKubint
 
% Last Modified by GUIDE v2.5 09-Mar-2006 18:37:05
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetKubint_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetKubint_OutputFcn, ...
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
 
 
% --- Executes just before AddDatasetKubint is made visible.
function AddDatasetKubint_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetKubint (see VARARGIN)
 
% Choose default command line output for AddDatasetKubint
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};
 
PutInCentre(hObject);
 
FileInfo=tekal('open',[handles.PathName handles.FileName]);
 
nrcolumns=FileInfo.Field.Size(2);
nrblocks=size(FileInfo.Field,2);
 
for i=1:nrcolumns-2
    str{i}=FileInfo.Field(1).ColLabels{i+2};
    if size(str{i},2)==0
        str{i}=['Column ' num2str(i+2)];
    end
end
set(handles.SelectParameter,'String',str);
 
clear str
for i=1:nrblocks
    str{i}=['Block ' num2str(i)];
end
set(handles.SelectBlock,'String',str);
 
handles.Block=1;
str=get(handles.SelectParameter,'String');
 
handles=RefreshDatasetName(handles);
 
set(handles.TextPolyFile,    'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
 
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetKubint wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetKubint_OutputFcn(hObject, eventdata, handles)
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
 
    a=get(handles.TextPolyFile,'String');
 
    if size(a,2)>0
 
        handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;
 
        nr=handles.NrAvailableDatasets;
 
        handles.DataProperties(nr).Name=get(handles.EditDatasetName,'String');
 
        handles.DataProperties(nr).FileType='Kubint';
 
        i=get(handles.SelectParameter,'Value');
        str=get(handles.SelectParameter,'String');
        handles.DataProperties(nr).Parameter=str{i};
 
        handles.DataProperties(nr).DateTime=0;
 
        handles.DataProperties(nr).Block=get(handles.SelectBlock,'Value');
 
        handles.DataProperties(nr).Column=get(handles.SelectParameter,'Value')+2;
 
        handles.DataProperties(nr).PathName=handles.PathName;
        handles.DataProperties(nr).FileName=handles.FileName;
        handles.DataProperties(nr).CombinedDataset=0;
 
        handles.DataProperties(nr).PolygonFile=handles.PolygonFile;
 
        handles.DataProperties=ImportKubint(handles.DataProperties,nr);
 
        handles.output=handles.DataProperties;
        handles.second_output=handles.NrAvailableDatasets;
 
        uiresume;
 
    else
        txt='First select polygon file!';
        mp_giveWarning('WarningText',txt);
    end
 
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
 
set(handles.EditDatasetName,'String',[str{i} ' - Block ' num2str(j)]);


% --- Executes on button press in PushSelectPolFile.
function PushSelectPolFile_Callback(hObject, eventdata, handles)
% hObject    handle to PushSelectPolFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
filterspec=       {'*.ldb;*.pol','Polygon file (*.xyz,*.pol)'};
[filename, pathname, filterindex] = uigetfile(filterspec);

% if strcmp(pathname,handles.PathName)
%     pathname='';
% end

handles.PolygonFile=[pathname filename];
 
set(handles.TextPolyFile,'String',handles.PolygonFile);
 
guidata(hObject, handles);
 
 
function TextPolyFile_Callback(hObject, eventdata, handles)
% hObject    handle to TextPolyFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of TextPolyFile as text
%        str2double(get(hObject,'String')) returns contents of TextPolyFile as a double
 
 
% --- Executes during object creation, after setting all properties.
function TextPolyFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextPolyFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
