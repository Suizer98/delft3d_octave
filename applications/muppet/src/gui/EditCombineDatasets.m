function varargout = EditCombineDatasets(varargin)
% EDITCOMBINEDATASETS M-file for EditCombineDatasets.fig
%      EDITCOMBINEDATASETS, by itself, creates a new EDITCOMBINEDATASETS or raises the existing
%      singleton*.
%
%      H = EDITCOMBINEDATASETS returns the handle to a new EDITCOMBINEDATASETS or the handle to
%      the existing singleton*.
%
%      EDITCOMBINEDATASETS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EDITCOMBINEDATASETS.M with the given input arguments.
%
%      EDITCOMBINEDATASETS('Property','Value',...) creates a new EDITCOMBINEDATASETS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EditCombineDatasets_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EditCombineDatasets_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Copyright 2002-2003 The MathWorks, Inc.
 
% Edit the above text to modify the response to help EditCombineDatasets
 
% Last Modified by GUIDE v2.5 11-Mar-2006 00:08:03
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EditCombineDatasets_OpeningFcn, ...
                   'gui_OutputFcn',  @EditCombineDatasets_OutputFcn, ...
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
 
 
% --- Executes just before EditCombineDatasets is made visible.
function EditCombineDatasets_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EditCombineDatasets (see VARARGIN)
 
% Choose default command line output for EditCombineDatasets
handles.output = hObject;
 
handles.DataProperties=varargin{2};
handles.NrAvailableDatasets=varargin{4};
handles.CombinedDatasetProperties=varargin{6};
handles.NrCombinedDatasets=varargin{8};
 
PutInCentre(hObject);
 
for i=1:handles.NrAvailableDatasets;
    handles.AvailableDatasetNames{i}=handles.DataProperties(i).Name;
end
set(handles.ListDatasetsA,'String',handles.AvailableDatasetNames);
 
set(handles.EditMultiplyA,'String','1.0');
set(handles.EditMultiplyB,'String','1.0');
set(handles.EditUniformValue,'String','0.0');
 
handles.Operations={'Add','Subtract','Multiply','Divide','Max','Min','isnan(A<B)','isnan(A>B)'};
str={'A + B','A - B','A * B','A / B','max(A,B)','min(A,B)','isnan(A<B)','isnan(A>B)'};
set(handles.SelectOperation,'String',str);
 
set(handles.ToggleUniformValue,'Value',0);
set(handles.ToggleDatasetB,'Value',1);
 
str=[handles.DataProperties(1).Name ' - 2'];
set(handles.EditDatasetName,'String',str);
 
handles=FindMatchingDatasets(handles);
 
RefreshOptions(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes EditCombineDatasets wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = EditCombineDatasets_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.second_output;
varargout{3} = handles.third_output;
varargout{4} = handles.fourth_output;
 
close(handles.figure1)
 
 
% --- Executes on selection change in ListDatasetsA.
function ListDatasetsA_Callback(hObject, eventdata, handles)
% hObject    handle to ListDatasetsA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns ListDatasetsA contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListDatasetsA
 
handles=FindMatchingDatasets(handles);
 
i=get(hObject,'Value');
str=[handles.DataProperties(i).Name ' - 2'];
set(handles.EditDatasetName,'String',str);
 
guidata(hObject, handles);
 
% --- Executes during object creation, after setting all properties.
function ListDatasetsA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListDatasetsA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in ListDatasetsB.
function ListDatasetsB_Callback(hObject, eventdata, handles)
% hObject    handle to ListDatasetsB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns ListDatasetsB contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListDatasetsB
 
% --- Executes during object creation, after setting all properties.
function ListDatasetsB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListDatasetsB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditMultiplyA_Callback(hObject, eventdata, handles)
% hObject    handle to EditMultiplyA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditMultiplyA as text
%        str2double(get(hObject,'String')) returns contents of EditMultiplyA as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditMultiplyA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMultiplyA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
 
function EditMultiplyB_Callback(hObject, eventdata, handles)
% hObject    handle to EditMultiplyB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditMultiplyB as text
%        str2double(get(hObject,'String')) returns contents of EditMultiplyB as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditMultiplyB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMultiplyB (see GCBO)
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
 
 
% --- Executes on selection change in SelectOperation.
function SelectOperation_Callback(hObject, eventdata, handles)
% hObject    handle to SelectOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectOperation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectOperation
 
 
% --- Executes during object creation, after setting all properties.
function SelectOperation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on button press in PushAdd.
function PushAdd_Callback(hObject, eventdata, handles)
% hObject    handle to PushAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
name=get(handles.EditDatasetName,'String');
 
if NewDatasetName(handles.DataProperties,handles.NrAvailableDatasets,name)
 
    handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;
    nr=handles.NrAvailableDatasets;
 
    k1=get(handles.ListDatasetsA,'Value');
    k2=get(handles.ListDatasetsB,'Value');
    stra=get(handles.ListDatasetsA,'String');
    strb=get(handles.ListDatasetsB,'String');
 
    str=get(handles.EditDatasetName,'String');
 
    handles.NrCombinedDatasets=handles.NrCombinedDatasets+1;
    n=handles.NrCombinedDatasets;
    handles.CombinedDatasetProperties(n).Name=get(handles.EditDatasetName,'String');
    handles.CombinedDatasetProperties(n).UniformValue=str2num(get(handles.EditUniformValue,'String'));
    handles.CombinedDatasetProperties(n).DatasetA.Name=stra{k1};
    handles.CombinedDatasetProperties(n).DatasetB.Name=strb{k2};
    handles.CombinedDatasetProperties(n).DatasetA.Multiply=str2num(get(handles.EditMultiplyA,'String'));
    handles.CombinedDatasetProperties(n).DatasetB.Multiply=str2num(get(handles.EditMultiplyB,'String'));
    handles.CombinedDatasetProperties(n).Operation=handles.Operations{get(handles.SelectOperation,'Value')};
    handles.CombinedDatasetProperties(n).UnifOpt=get(handles.ToggleUniformValue,'Value');

    handles.DataProperties=mp_combineDataset(handles.DataProperties,handles.CombinedDatasetProperties,nr,n);
 
    for i=1:handles.NrAvailableDatasets;
        handles.AvailableDatasetNames{i}=handles.DataProperties(i).Name;
    end
    set(handles.ListDatasetsA,'String',handles.AvailableDatasetNames);
 
    handles=FindMatchingDatasets(handles);
 
    guidata(hObject, handles);
 
else
    txt='Dataset name already exists!';
    mp_giveWarning('WarningText',txt);
end
 
% --- Executes on button press in PushCancel.
function PushCancel_Callback(hObject, eventdata, handles)
% hObject    handle to PushCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;
handles.third_output=handles.CombinedDatasetProperties;
handles.fourth_output=handles.NrCombinedDatasets;
 
guidata(hObject, handles);
 
uiresume;
 
% --- Executes on button press in ToggleUniformValue.
function ToggleUniformValue_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleUniformValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleUniformValue
 
i=get(hObject,'Value');
 
if i==1
    set(handles.ToggleDatasetB,'Value',0);
else
    set(hObject,'Value',1);
end
RefreshOptions(handles);
 
guidata(hObject, handles);
 
 
% --- Executes on button press in ToggleDatasetB.
function ToggleDatasetB_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleDatasetB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hint: get(hObject,'Value') returns toggle state of ToggleDatasetB
 
i=get(hObject,'Value');
 
if i==1
    set(handles.ToggleUniformValue,'Value',0);
else
    set(hObject,'Value',1);
end
RefreshOptions(handles);
 
guidata(hObject, handles);
 
 
function EditUniformValue_Callback(hObject, eventdata, handles)
% hObject    handle to EditUniformValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of EditUniformValue as text
%        str2double(get(hObject,'String')) returns contents of EditUniformValue as a double
 
 
% --- Executes during object creation, after setting all properties.
function EditUniformValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditUniformValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
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
handles.third_output=handles.CombinedDatasetProperties;
handles.fourth_output=handles.NrCombinedDatasets;
 
guidata(hObject, handles);
 
uiresume;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
function handles=RefreshOptions(handles);
 
i=get(handles.ToggleUniformValue,'Value');
 
if i==1
    set(handles.EditUniformValue,     'Enable','on', 'BackGroundColor',[1.0 1.0 1.0]);
    set(handles.TextUniformValue,     'Enable','on');
    set(handles.TextDatasetB,         'Enable','off');
    set(handles.ListDatasetsB,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.TextMultiplyB,        'Enable','off');
    set(handles.EditMultiplyB,        'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
else
    set(handles.EditUniformValue,     'Enable','off', 'BackGroundColor',[0.831 0.816 0.784]);
    set(handles.TextUniformValue,     'Enable','off');
    set(handles.TextDatasetB,         'Enable','on');
    set(handles.ListDatasetsB,        'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
    set(handles.TextMultiplyB,        'Enable','on');
    set(handles.EditMultiplyB,        'Enable','on','BackGroundColor',[1.0 1.0 1.0]);
 
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
function handles=FindMatchingDatasets(handles);
 
i=get(handles.ListDatasetsA,'Value');
 
xdimA=size(handles.DataProperties(i).x);
% ydimA=size(handles.DatasetProperties(i).y);
% zdimA=size(handles.DatasetProperties(i).z);
% udimA=size(handles.DatasetProperties(i).u);
% vdimA=size(handles.DatasetProperties(i).v);
 
handles.NrMatching=0;
 
for k=1:handles.NrAvailableDatasets
 
    if strcmp(handles.DataProperties(i).Type,handles.DataProperties(k).Type)
 
        xdimB=size(handles.DataProperties(k).x);
        if xdimA==xdimB
            handles.NrMatching=handles.NrMatching+1;
            handles.MatchingDatasetNumbers(handles.NrMatching)=k;
%            handles.MatchingDatasets(handles.NrMatching).Name=handles.DataProperties(k).Name;
            handles.MatchingDatasetNames{handles.NrMatching}=handles.DataProperties(k).Name;
        end
    end
end
 
if handles.NrMatching>0
    set(handles.ListDatasetsB,'String',handles.MatchingDatasetNames);
    set(handles.ListDatasetsB,'Value',1);
end
 
