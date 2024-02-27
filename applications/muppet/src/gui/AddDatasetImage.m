function varargout = AddDatasetImage(varargin)
% ADDDATASETIMAGE M-file for AddDatasetImage.fig
%      ADDDATASETIMAGE, by itself, creates a new ADDDATASETIMAGE or raises the existing
%      singleton*.
%
%      H = ADDDATASETIMAGE returns the handle to a new ADDDATASETIMAGE or the handle to
%      the existing singleton*.
%
%      ADDDATASETIMAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETIMAGE.M with the given input arguments.
%
%      ADDDATASETIMAGE('Property','Value',...) creates a new ADDDATASETIMAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetImage_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetImage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetImage
 
% Last Modified by GUIDE v2.5 13-Apr-2006 11:33:32
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetImage_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetImage_OutputFcn, ...
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
 
 
% --- Executes just before AddDatasetImage is made visible.
function AddDatasetImage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetImage (see VARARGIN)
 
% Choose default command line output for AddDatasetImage
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};
 
PutInCentre(hObject);
 
set(handles.EditDatasetName,'String',[handles.FileName]);
 
set(handles.TextGeoReferenceFile,    'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetImage wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetImage_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.second_output;
 
close(handles.figure1)
 
 
% --- Executes on button press in CancelDataset.
function CancelDataset_Callback(hObject, eventdata, handles)
% hObject    handle to CancelDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
handles.output=handles.DataProperties;
handles.second_output=handles.NrAvailableDatasets;
 
guidata(hObject, handles);
 
uiresume;
 
 
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
 
    handles.DataProperties(nr).Parameter='unknown';
 
    handles.DataProperties(nr).DateTime=0;
 
    handles.DataProperties(nr).Block=1;
 
    handles.DataProperties(nr).Column=1;
 
    handles.DataProperties(nr).PathName=handles.PathName;
    handles.DataProperties(nr).FileName=handles.FileName;
    handles.DataProperties(nr).CombinedDataset=0;

    set(gcf,'Pointer','watch');pause(0.1);
    handles.DataProperties(nr).FileType='Image';
    set(gcf,'Pointer','arrow');
 
    if size(get(handles.TextGeoReferenceFile,'String'),2)>0
        handles.DataProperties(nr).GeoReferenceFile=handles.GeoReferenceFile;
    else
        handles.DataProperties(nr).GeoReferenceFile='';
    end
 
    wb = waitbox('Reading image file ...');pause(0.1);
    handles.DataProperties=ImportImage(handles.DataProperties,nr);
    close(wb);
    
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
 
 
% --- Executes on button press in PushGeoReferenceFile.
function PushGeoReferenceFile_Callback(hObject, eventdata, handles)
% hObject    handle to PushGeoReferenceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
filterspec=       {'*.jgw','JPG GeoReference (*.jgw)'};
[filename, pathname, filterindex] = uigetfile(filterspec);
 
handles.GeoReferenceFile=[pathname filename];
 
set(handles.TextGeoReferenceFile,'String',handles.GeoReferenceFile);
 
guidata(hObject, handles);
 
 
function TextGeoReferenceFile_Callback(hObject, eventdata, handles)
% hObject    handle to TextGeoReferenceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: get(hObject,'String') returns contents of TextGeoReferenceFile as text
%        str2double(get(hObject,'String')) returns contents of TextGeoReferenceFile as a double
 
 
% --- Executes during object creation, after setting all properties.
function TextGeoReferenceFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextGeoReferenceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
