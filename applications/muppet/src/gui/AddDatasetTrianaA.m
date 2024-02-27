function varargout = AddDatasetTrianaA(varargin)
% ADDDATASETTRIANAA M-file for AddDatasetTrianaA.fig
%      ADDDATASETTRIANAA, by itself, creates a new ADDDATASETTRIANAA or raises the existing
%      singleton*.
%
%      H = ADDDATASETTRIANAA returns the handle to a new ADDDATASETTRIANAA or the handle to
%      the existing singleton*.
%
%      ADDDATASETTRIANAA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETTRIANAA.M with the given input arguments.
%
%      ADDDATASETTRIANAA('Property','Value',...) creates a new ADDDATASETTRIANAA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetTrianaA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetTrianaA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetTrianaA
 
% Last Modified by GUIDE v2.5 11-Dec-2006 14:38:08
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetTrianaA_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetTrianaA_OutputFcn, ...
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
 
 
% --- Executes just before AddDatasetTrianaA is made visible.
function AddDatasetTrianaA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetTrianaA (see VARARGIN)
 
% Choose default command line output for AddDatasetTrianaA
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};

PutInCentre(hObject);
 
fid=fopen([handles.PathName,handles.FileName]);
 
nostat=0;
for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        v0=strread(tx0,'%q');
        if size(v0,1)>2
            if strcmp(v0{3},'component')
                loc='';
                for k=5:size(v0,1)
                    loc=strcat([loc ' ' v0{k}]);
                end
                loc=loc(2:end);
                nostat=nostat+1;
                handles.ComponentNames{nostat}=loc;
            end
        end
    end
end

set(handles.SelectComponent,'String',handles.ComponentNames);

handles.Parameters={'Hc','Gc','Ho','Go','Hc-Ho','Gc-Go','Hc/Ho','VD'};
set(handles.SelectParameter,'String',handles.Parameters);

set(handles.EditTrianaBFile,    'Enable','off','BackGroundColor',[0.831 0.816 0.784]);

handles=RefreshDatasetName(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetTrianaA wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetTrianaA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.second_output;
 
close(handles.figure1)
 
% --- Executes during object creation, after setting all properties.
function SelectComponent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectComponent (see GCBO)
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
 
 
% --- Executes on button press in AddDataset.
function AddDataset_Callback(hObject, eventdata, handles)
% hObject    handle to AddDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
name=get(handles.EditDatasetName,'String');
 
if NewDatasetName(handles.DataProperties,handles.NrAvailableDatasets,name)

    a=get(handles.EditTrianaBFile,'String');
 
    if size(a,2)>0
        
        handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;

        nr=handles.NrAvailableDatasets;

        handles.DataProperties(nr).Name=get(handles.EditDatasetName,'String');

        handles.DataProperties(nr).FileType='TrianaA';

        i=get(handles.SelectComponent,'Value');
        str=get(handles.SelectComponent,'String');
        handles.DataProperties(nr).Component=str{i};

        i=get(handles.SelectParameter,'Value');
        str=get(handles.SelectParameter,'String');
        handles.DataProperties(nr).Parameter=str{i};
        handles.DataProperties(nr).Column=i+4;

        handles.DataProperties(nr).DateTime=0;

        handles.DataProperties(nr).PathName=handles.PathName;
        handles.DataProperties(nr).FileName=handles.FileName;
        handles.DataProperties(nr).CombinedDataset=0;

        handles.DataProperties(nr).TrianaBFile=handles.TrianaBFile;

        handles.DataProperties=ImportTrianaA(handles.DataProperties,nr);

    else

        txt='First select Triana B file!';
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
 
i=get(handles.SelectComponent,'Value');
str=get(handles.SelectComponent,'String');
 
j=get(handles.SelectParameter,'Value');
strbl=get(handles.SelectParameter,'String');
 
set(handles.EditDatasetName,'String',[str{i} ' - ' strbl{j}]);


% --- Executes on button press in SelectTrianaBFile.
function SelectTrianaBFile_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTrianaBFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filterspec=       {'*.tab','Triana B file (*.tab)'};
[filename, pathname, filterindex] = uigetfile(filterspec);

handles.TrianaBFile=[pathname filename];
 
set(handles.EditTrianaBFile,'String',handles.TrianaBFile);
 
guidata(hObject, handles);


function EditTrianaBFile_Callback(hObject, eventdata, handles)
% hObject    handle to EditTrianaBFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTrianaBFile as text
%        str2double(get(hObject,'String')) returns contents of EditTrianaBFile as a double


% --- Executes during object creation, after setting all properties.
function EditTrianaBFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTrianaBFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


