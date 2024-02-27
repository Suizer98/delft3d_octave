function varargout = AddDatasetCurvedVectors(varargin)
% ADDDATASETCURVEDVECTORS M-file for AddDatasetCurvedVectors.fig
%      ADDDATASETCURVEDVECTORS, by itself, creates a new ADDDATASETCURVEDVECTORS or raises the existing
%      singleton*.
%
%      H = ADDDATASETCURVEDVECTORS returns the handle to a new ADDDATASETCURVEDVECTORS or the handle to
%      the existing singleton*.
%
%      ADDDATASETCURVEDVECTORS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETCURVEDVECTORS.M with the given input arguments.
%
%      ADDDATASETCURVEDVECTORS('Property','Value',...) creates a new ADDDATASETCURVEDVECTORS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetCurvedVectors_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetCurvedVectors_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetCurvedVectors
 
% Last Modified by GUIDE v2.5 09-Mar-2006 18:37:05
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetCurvedVectors_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetCurvedVectors_OutputFcn, ...
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
 
 
% --- Executes just before AddDatasetCurvedVectors is made visible.
function AddDatasetCurvedVectors_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetCurvedVectors (see VARARGIN)
 
% Choose default command line output for AddDatasetCurvedVectors
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};
 
PutInCentre(hObject);
 
FileInfo=TEKAL('open',[handles.PathName handles.FileName]);
 
nrblocks=size(FileInfo.Field,2);
 
clear str
for i=1:nrblocks
    str{i}=['Block ' num2str(i)];
end
set(handles.SelectBlock,'String',str);
 
handles.Block=1;
 
handles=RefreshDatasetName(handles);

 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetCurvedVectors wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetCurvedVectors_OutputFcn(hObject, eventdata, handles)
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
 
    handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;

    nr=handles.NrAvailableDatasets;

    handles.DataProperties(nr).Name=get(handles.EditDatasetName,'String');

    handles.DataProperties(nr).FileType='CurvedVectors';

    handles.DataProperties(nr).Parameter='unknown';

    handles.DataProperties(nr).DateTime=0;

    handles.DataProperties(nr).Block=get(handles.SelectBlock,'Value');

    handles.DataProperties(nr).Column=0;

    handles.DataProperties(nr).PathName=handles.PathName;
    handles.DataProperties(nr).FileName=handles.FileName;
    handles.DataProperties(nr).CombinedDataset=0;

    handles.DataProperties=ImportCurvedVectors(handles.DataProperties,nr);

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
 
 
function handles=RefreshDatasetName(handles);
 
j=get(handles.SelectBlock,'Value');
 
set(handles.EditDatasetName,'String',['Vectors - Block ' num2str(j)]);
 