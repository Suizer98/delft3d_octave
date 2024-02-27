function varargout = AddDatasetD3DGrid(varargin)
% ADDDATASETD3DGRID M-file for AddDatasetD3DGrid.fig
%      ADDDATASETD3DGRID, by itself, creates a new ADDDATASETD3DGRID or raises the existing
%      singleton*.
%
%      H = ADDDATASETD3DGRID returns the handle to a new ADDDATASETD3DGRID or the handle to
%      the existing singleton*.
%
%      ADDDATASETD3DGRID('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETD3DGRID.M with the given input arguments.
%
%      ADDDATASETD3DGRID('Property','Value',...) creates a new ADDDATASETD3DGRID or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetD3DGrid_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetD3DGrid_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetD3DGrid
 
% Last Modified by GUIDE v2.5 09-Mar-2006 13:27:56
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetD3DGrid_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetD3DGrid_OutputFcn, ...
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
 
 
% --- Executes just before AddDatasetD3DGrid is made visible.
function AddDatasetD3DGrid_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetD3DGrid (see VARARGIN)
 
% Choose default command line output for AddDatasetD3DGrid
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};

PutInCentre(hObject);
 
set(handles.EditDatasetName,'String',handles.FileName);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetD3DGrid wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetD3DGrid_OutputFcn(hObject, eventdata, handles)
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
 
 
        handles.DataProperties(nr).PathName=handles.PathName;
        handles.DataProperties(nr).FileName=handles.FileName;
        handles.DataProperties(nr).CombinedDataset=0;
 
        handles.DataProperties(nr).FileType='D3DGrid';
        handles.DataProperties(nr).Type='Grid';
        handles.DataProperties(nr).TC='c';
 
        wb = waitbox('Reading data file ...');pause(0.1);
        [x,y,enc]=wlgrid('read',[handles.PathName handles.FileName]);
        close(wb);

        handles.DataProperties(nr).x=x;
        handles.DataProperties(nr).y=y;
        handles.DataProperties(nr).z=0;
 
        handles.DataProperties(nr).DateTime=0;
        handles.DataProperties(nr).Parameter='Grid';
        handles.DataProperties(nr).Block=0;
 
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
 
 
