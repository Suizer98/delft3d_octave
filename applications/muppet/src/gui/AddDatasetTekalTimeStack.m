function varargout = AddDatasetTekalTimeStack(varargin)
% ADDDATASETTEKALTIMESTACK M-file for AddDatasetTekalTimeStack.fig
%      ADDDATASETTEKALTIMESTACK, by itself, creates a new ADDDATASETTEKALTIMESTACK or raises the existing
%      singleton*.
%
%      H = ADDDATASETTEKALTIMESTACK returns the handle to a new ADDDATASETTEKALTIMESTACK or the handle to
%      the existing singleton*.
%
%      ADDDATASETTEKALTIMESTACK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETTEKALTIMESTACK.M with the given input arguments.
%
%      ADDDATASETTEKALTIMESTACK('Property','Value',...) creates a new ADDDATASETTEKALTIMESTACK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetTekalTimeStack_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetTekalTimeStack_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetTekalTimeStack
 
% Last Modified by GUIDE v2.5 24-Sep-2005 21:24:36
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetTekalTimeStack_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetTekalTimeStack_OutputFcn, ...
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
 
 
% --- Executes just before AddDatasetTekalTimeStack is made visible.
function AddDatasetTekalTimeStack_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetTekalTimeStack (see VARARGIN)
 
% Choose default command line output for AddDatasetTekalTimeStack
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};
 
PutInCentre(hObject);
 
FileInfo=tekal('open',[handles.PathName handles.FileName]);
 
nrcolumns=FileInfo.Field(1).Size(2);
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
    str{i}=FileInfo.Field(i).Name;
end
set(handles.SelectBlock,'String',str);
 
handles.M=0;
handles.N=0;
handles.Block=1;
handles.DateTime=0;
str=get(handles.SelectParameter,'String');
 
handles=RefreshDatasetName(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetTekalTimeStack wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetTekalTimeStack_OutputFcn(hObject, eventdata, handles)
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
 
    handles.DataProperties(nr).FileType='TekalTimeStack';
 
    i=get(handles.SelectParameter,'Value');
    str=get(handles.SelectParameter,'String');
    handles.DataProperties(nr).Parameter=str{i};
 
    handles.DataProperties(nr).DateTime=0;
 
    handles.DataProperties(nr).Block=get(handles.SelectBlock,'Value');
 
    handles.DataProperties(nr).Column=get(handles.SelectParameter,'Value')+2;
 
    handles.DataProperties(nr).PathName=handles.PathName;
    handles.DataProperties(nr).FileName=handles.FileName;
    handles.DataProperties(nr).CombinedDataset=0;
 
    %handles.DataProperties(nr).Multiply=handles.Multiply;
 
    handles.DataProperties(nr).Multiply=1.0;
 
    handles.DataProperties=ImportTekalTimeStack(handles.DataProperties,nr);
 
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
