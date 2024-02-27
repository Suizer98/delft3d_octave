function varargout = AddDatasetUnibestCL(varargin)
% ADDDATASETUNIBESTCL M-file for AddDatasetUnibestCL.fig
%      ADDDATASETUNIBESTCL, by itself, creates a new ADDDATASETUNIBESTCL or raises the existing
%      singleton*.
%
%      H = ADDDATASETUNIBESTCL returns the handle to a new ADDDATASETUNIBESTCL or the handle to
%      the existing singleton*.
%
%      ADDDATASETUNIBESTCL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDDATASETUNIBESTCL.M with the given input arguments.
%
%      ADDDATASETUNIBESTCL('Property','Value',...) creates a new ADDDATASETUNIBESTCL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddDatasetUnibestCL_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddDatasetUnibestCL_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
 
% Edit the above text to modify the response to help AddDatasetUnibestCL
 
% Last Modified by GUIDE v2.5 23-Jul-2007 17:20:26
 
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddDatasetUnibestCL_OpeningFcn, ...
                   'gui_OutputFcn',  @AddDatasetUnibestCL_OutputFcn, ...
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
 
 
% --- Executes just before AddDatasetUnibestCL is made visible.
function AddDatasetUnibestCL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddDatasetUnibestCL (see VARARGIN)
 
% Choose default command line output for AddDatasetUnibestCL
 
handles.output=hObject;
 
handles.DataProperties=varargin{2};
handles.PathName=varargin{4};
handles.FileName=varargin{6};
handles.NrAvailableDatasets=varargin{8};
 
PutInCentre(hObject);
 
handles.Data=unibest_clp_read_prn([handles.PathName handles.FileName]);

handles.NrTimes=length(handles.Data.CEL);
for i=1:handles.NrTimes
    handles.Time(i)=handles.Data.CEL(i).year;
    handles.TimeStrings{i}=num2str(handles.Time(i));
end
set(handles.SelectTime,'String',handles.TimeStrings);
set(handles.SelectTime,'Value',1);

handles.NrCells=length(handles.Data.CEL(1).cel);
handles.Cells=1:handles.NrCells;

for i=1:handles.NrCells
    handles.CellStrings{i}=num2str(i);
end

handles.NrRays=length(handles.Data.RAY(1).ray);
handles.Rays=1:handles.NrRays;

for i=1:handles.NrRays
    handles.RayStrings{i}=num2str(i);
end

set(handles.ToggleCell,'Value',1);
set(handles.ToggleRay,'Value',0);

set(handles.ToggleTimeSeries,'Value',1);
set(handles.ToggleXYSeries,'Value',0);

handles.CellParams{1}='coast line';
handles.CellParams{2}='XCoast';
handles.CellParams{3}='YCoast';
handles.CellParams{4}='y';
handles.CellParams{5}='y-y0';
handles.CellParams{6}='source';
handles.CellParams{7}='alfa';
handles.CellParams{8}='S';

handles.RayParams{1}='coast line';
handles.RayParams{2}='XCoast';
handles.RayParams{3}='YCoast';
handles.RayParams{4}='N';
handles.RayParams{5}='vol';
handles.RayParams{6}='transport';
handles.RayParams{7}='alfa';
handles.RayParams{8}='S';

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);
 
% Update handles structure
guidata(hObject, handles);
 
% UIWAIT makes AddDatasetUnibestCL wait for user response (see UIRESUME)
uiwait(handles.figure1);
 
 
% --- Outputs from this function are returned to the command line.
function varargout = AddDatasetUnibestCL_OutputFcn(hObject, eventdata, handles)
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
function SelectTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
 
 
% --- Executes on selection change in SelectTime.
function SelectTime_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
% Hints: contents = get(hObject,'String') returns SelectTime contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectTime
 
handles=RefreshDatasetName(handles);
 
guidata(hObject, handles);
 
 
% --- Executes on button press in AddDataset.
function AddDataset_Callback(hObject, eventdata, handles)
% hObject    handle to AddDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
name=get(handles.EditDatasetName,'String');
 
i=get(handles.SelectParameter,'Value');
str=get(handles.SelectParameter,'String');
if get(handles.ToggleTimeSeries,'Value')==1 & strcmp(lower(str{i}),'coast line')
    txt='Cannot make time series of coast line!';
    mp_giveWarning('WarningText',txt);
else
    if NewDatasetName(handles.DataProperties,handles.NrAvailableDatasets,name)

        handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;

        nr=handles.NrAvailableDatasets;

        handles.DataProperties(nr).Name=get(handles.EditDatasetName,'String');

        handles.DataProperties(nr).FileType='UnibestCL';

        i=get(handles.SelectParameter,'Value');
        str=get(handles.SelectParameter,'String');
        handles.DataProperties(nr).Parameter=str{i};

        handles.DataProperties(nr).DateTime=0;

        if get(handles.ToggleTimeSeries,'Value')==1
            handles.DataProperties(nr).Date=0;
            i=get(handles.SelectCellRay,'Value');
            if get(handles.ToggleCell,'Value')==1
                handles.DataProperties(nr).Location=['Cell ' handles.CellStrings{i}];
            else
                handles.DataProperties(nr).Location=['Ray ' handles.RayStrings{i}];
            end
        else
            i=get(handles.SelectTime,'Value');
            handles.DataProperties(nr).Date=handles.Time(i);
            if get(handles.ToggleCell,'Value')==1
                handles.DataProperties(nr).Location='AllCells';
            else
                handles.DataProperties(nr).Location='AllRays';
            end
        end

        handles.DataProperties(nr).Block=0;

        handles.DataProperties(nr).MultiplyX=1.0;
        handles.DataProperties(nr).AddX=0.0;

        handles.DataProperties(nr).PathName=handles.PathName;
        handles.DataProperties(nr).FileName=handles.FileName;
        handles.DataProperties(nr).CombinedDataset=0;

        wb = waitbox('Reading data file ...');pause(0.1);
        handles.DataProperties=ImportUnibestCL(handles.DataProperties,nr);
        close(wb);

    else
        txt='Dataset name already exists!';
        mp_giveWarning('WarningText',txt);
    end
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
 
 
% --- Executes on selection change in SelectCellRay.
function SelectCellRay_Callback(hObject, eventdata, handles)
% hObject    handle to SelectCellRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectCellRay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectCellRay

handles=RefreshDatasetName(handles);
 
guidata(hObject, handles);
 

% --- Executes during object creation, after setting all properties.
function SelectCellRay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectCellRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in ToggleCell.
function ToggleCell_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleCell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleCell

if get(handles.ToggleRay,'Value')==1;
    set(handles.ToggleCell,'Value',1);
    set(handles.ToggleRay,'Value',0);
end

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);

% --- Executes on button press in ToggleRay.
function ToggleRay_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleRay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleRay

if get(handles.ToggleCell,'Value')==1;
    set(handles.ToggleCell,'Value',0);
    set(handles.ToggleRay,'Value',1);
end

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);


% --- Executes on button press in ToggleTimeSeries.
function ToggleTimeSeries_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleTimeSeries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleTimeSeries

if get(handles.ToggleXYSeries,'Value')==1;
    set(handles.ToggleXYSeries,'Value',0);
    set(handles.ToggleTimeSeries,'Value',1);
end

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);

% --- Executes on button press in ToggleXYSeries.
function ToggleXYSeries_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleXYSeries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleXYSeries

if get(handles.ToggleTimeSeries,'Value')==1;
    set(handles.ToggleTimeSeries,'Value',0);
    set(handles.ToggleXYSeries,'Value',1);
end

handles=RefreshOptions(handles);
handles=RefreshDatasetName(handles);

guidata(hObject, handles);


function handles=RefreshOptions(handles);


if get(handles.ToggleCell,'Value')==1
    set(handles.TextCellOrRay,'String','Cell');
    set(handles.ToggleRay,'Value',0);
    set(handles.SelectCellRay,'String',handles.CellStrings);
%    if get(handles.ToggleTimeSeries,'Value')==1
        set(handles.SelectParameter,'String',handles.CellParams);
%    else
%        set(handles.SelectParameter,'String',handles.CellParams{2:end});
%    end
else
    set(handles.TextCellOrRay,'String','Ray');
    set(handles.ToggleCell,'Value',0);
    set(handles.SelectCellRay,'String',handles.RayStrings);
    set(handles.SelectParameter,'String',handles.RayParams);
end

if get(handles.ToggleTimeSeries,'Value')==1
    set(handles.ToggleXYSeries,'Value',0);
    set(handles.SelectCellRay,'Enable','on','BackGroundColor',[1.000 1.000 1.000]);
    set(handles.SelectTime,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
else
    set(handles.ToggleTimeSeries,'Value',0);
    set(handles.SelectCellRay,'Enable','off','BackGroundColor',[0.831 0.816 0.784]);
    set(handles.SelectTime,'Enable','on','BackGroundColor',[1.000 1.000 1.000]);
end


function handles=RefreshDatasetName(handles);

i=get(handles.SelectParameter,'Value');
str=get(handles.SelectParameter,'String');
str1=str{i};

if get(handles.ToggleTimeSeries,'Value')==1
    if get(handles.ToggleCell,'Value')==1
        str2=['Cell ' num2str(get(handles.SelectCellRay,'Value'))];
    else
        str2=['Ray ' num2str(get(handles.SelectCellRay,'Value'))];
    end
else
    j=get(handles.SelectTime,'Value');
    strbl=get(handles.SelectTime,'String');
    if get(handles.ToggleCell,'Value')==1
        str2=['AllCells - ' num2str(strbl{j})];
    else
        str2=['AllRays - ' num2str(strbl{j})];
    end
end

set(handles.EditDatasetName,'String',[str1 ' - ' str2]);
