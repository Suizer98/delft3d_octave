function varargout = GUI_Muppet(varargin)
% GUI_MUPPET M-file for GUI_Muppet.fig
%      GUI_MUPPET, by itself, creates a new GUI_MUPPET or raises the existing
%      singleton*.
%
%      H = GUI_MUPPET returns the handle to a new GUI_MUPPET or the handle to
%      the existing singleton*.
%
%      GUI_MUPPET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_MUPPET.M with the given input arguments.
%
%      GUI_MUPPET('Property','Value',...) creates a new GUI_MUPPET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Muppet_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Muppet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Muppet

% Last Modified by GUIDE v2.5 19-Jul-2011 14:03:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Muppet_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Muppet_OutputFcn, ...
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

% --- Executes just before GUI_Muppet is made visible.
function GUI_Muppet_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Muppet (see VARARGIN)

% Choose default command line output for GUI_Muppet
handles.output = hObject;

handles.MuppetVersion=varargin{2};
handles.MuppetPath=varargin{3};
handles.Muppet=hObject;

if isdeployed
    handles.xmlDir=[ctfroot filesep 'xml' filesep];
else
    handles.xmlDir=[fileparts(which('muppet')) filesep 'xml' filesep];
end

set(handles.output,'Tag','MainWindow');

mppath=handles.MuppetPath;

frame=splash([mppath 'settings' filesep 'icons' filesep 'muppets.jpg'],20);

PutInCentre(hObject);

set(gcf,'CloseRequestFcn','set(0,''ShowHiddenHandles'',''on'');delete(get(0,''Children''))');

try
    fh = get(gcf,'JavaFrame'); % Get Java Frame
    fh.setFigureIcon(javax.swing.ImageIcon([mppath 'settings' filesep 'icons' filesep 'deltares.gif']));
end

handles=ReadDefaults(handles);

handles.DefaultColors=ReadDefaultColors(handles.MuppetPath);

handles.DataProperties(1).Dummy=0;
handles.NrAvailableDatasets=0;
handles.CombinedDatasetProperties(1).Dummy=0;
handles.NrCombinedDatasets=0;

handles.DateFormats=ReadTextFile([handles.MuppetPath 'settings' filesep 'defaults' filesep 'dateformats.def']);

dat=datenum(2005,04,28,14,38,25);

for i=1:length(handles.DateFormats)
    str{i}=datestr(dat,handles.DateFormats{i});
end

set(handles.SelectTTickFormat,'String',str);
set(handles.SelectTTickFormat,'Value',1);

set(handles.ToggleAxesEqual,'Enable','off');
set(handles.PushLabelFont,'Enable','off');

clear str;
str={'png','jpeg','tiff','pdf','eps','eps2'};
set(handles.SelectOutputFormat,'String',str);

clear str
str={'ZBuffer','Painters','OpenGL'};
set(handles.SelectRenderer,'String',str);

clear str
str={'50','100','150','200','300','450','600'};
set(handles.SelectResolution,'String',str);

clear str;
str={'linear','logarithmic','normprob'};
set(handles.SelectXAxisScale,'String',str);

clear str;
str={'linear','logarithmic','normprob'};
set(handles.SelectYAxisScale,'String',str);

clear str;
str={'auto','0','1','2','3','4','5','6','no labels'};
set(handles.SelectDecimX,'String',str);
set(handles.SelectDecimY,'String',str);

LayoutName=[mppath 'settings' filesep 'layouts' filesep 'default.mup'];

d=dir([mppath 'settings' filesep 'tunes' filesep '*.wav']);
szd=size(d,1);
if szd==0
    set(handles.PlayTunes,'enable','off','visible','off');
else
    set(handles.PlayTunes,'cdata',MakeIcon([mppath 'settings' filesep 'icons' filesep 'animal2.jpg'],60));
end

if ~exist([mppath 'settings' filesep 'tunes' filesep 'koffietijd' filesep 'koffietijd1_11hz.wav'],'file')
    set(handles.KoffieTijd,'enable','off','visible','off');
else
    set(handles.KoffieTijd,'cdata',MakeIcon([mppath 'settings' filesep 'icons' filesep 'koffie.jpg'],60));
end

handles.ColorMaps=ImportColorMaps(handles.MuppetPath);
cl=1;
for m=1:size(handles.ColorMaps,2)
    colmaps{m}=handles.ColorMaps(m).Name;
    if strcmpi(colmaps{m},handles.DefaultSubplotProperties.ColMap)
        cl=m;
    end
end
set(handles.SelectColorMap,'String',colmaps);
set(handles.SelectColorMap,'Value',cl);

clear str;
handles.Frames=ReadFrames(handles.MuppetPath);
for i=1:size(handles.Frames,2)
    str{i}=handles.Frames(i).Name;
end
set(handles.SelectFrame,'String',str);
set(handles.SelectFrame,'Value',1);

handles.CurrentPath=[cd '\'];
handles.FilePath=handles.CurrentPath;
handles.FilterIndex='D3D';

handles.SessionName='';

handles.DataProperties(1).Name='';
handles.CombinedDatasetProperties(1).Name='';

handles.NrAvailableDatasets=0;
handles.NrCombinedDatasets=0;
handles.NrFigures=0;
handles.ActiveAvailableDataset=0;
handles.ActiveSubplot=0;
handles.ActiveFigure=1;

handles.AnimationSettings.frameRate=5;
handles.AnimationSettings.FirstStep=1;
handles.AnimationSettings.Increment=1;
handles.AnimationSettings.LastStep=1;
handles.AnimationSettings.selectBits=24;
handles.AnimationSettings.keepFigures=0;
handles.AnimationSettings.makeKMZ=0;
handles.AnimationSettings.aviFileName='anim.avi';
handles.AnimationSettings.prefix='anim';
handles.AnimationSettings.startTime=[];
handles.AnimationSettings.stopTime=[];
handles.AnimationSettings.timeStep=[];

archstr = computer('arch');
switch lower(archstr)
    case{'w32','win32'}
        % win 32
        handles.AnimationSettings.aviOptions.fccHandler=1684633187;
        handles.AnimationSettings.aviOptions.KeyFrames=0;
        handles.AnimationSettings.aviOptions.Quality=10000;
        handles.AnimationSettings.aviOptions.BytesPerSec=300;
        handles.AnimationSettings.aviOptions.Parameters=[99 111 108 114];
    case{'w64','win64'}
        % win 64 - MSVC1
        handles.AnimationSettings.aviOptions.fccHandler=1668707181;
        handles.AnimationSettings.aviOptions.KeyFrames=15;
        handles.AnimationSettings.aviOptions.Quality=7500;
        handles.AnimationSettings.aviOptions.BytesPerSec=300;
        handles.AnimationSettings.aviOptions.Parameters=[75 0 0 0];
end

handles.AddSubplotAnnotations=0;

% set(handles.PushAdjustAxes,'Enable','off','Visible','off');
% set(handles.PushAddText,'Enable','off','Visible','off');
% set(handles.PushAddArrows,'Enable','off','Visible','off');
% set(handles.ToggleTextBox,'Enable','off','Visible','off');

handles.GenerateLayoutPositions=[3 4 1.2 3.5 4 4.5 1.2 5];

handles.Mode=1;

set(handles.PushProcessDataset,'Enable','off');
set(handles.PushExportDataset,'Enable','off');

% Read Sessionfile
handles=ReadSessionFile(handles,LayoutName);

% Import datasets
handles.DataProperties=mp_importDatasets(handles.DataProperties,handles.NrAvailableDatasets);

handles=RefreshAll(handles);

frame.hide;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_Muppet wait for user response (see UIRESUME)
% uiwait(handles.Mu);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_Muppet_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function ListAvailableDatasets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListAvailableDatasets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% a=handles.AvailableDatasets.Name
% set(hObject,'String',handles.AvailableDatasets.Name);



% --- Executes on selection change in ListAvailableDatasets.
function ListAvailableDatasets_Callback(hObject, eventdata, handles)
% hObject    handle to ListAvailableDatasets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListAvailableDatasets contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListAvailableDatasets

handles.ActiveAvailableDataset=get(hObject,'Value');

handles=RefreshActiveAvailableDatasetText(handles);

guidata(hObject, handles);

% --- Executes on button press in AddDataset.
function AddDataset_Callback(hObject, eventdata, handles)
% hObject    handle to AddDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[handles,NewDataset]=AddDataset(handles);

if NewDataset==1
    handles.ActiveAvailableDataset=handles.NrAvailableDatasets;
    handles=RefreshAvailableDatasets(handles);
    handles=RefreshActiveAvailableDatasetText(handles);
end

guidata(hObject, handles);

% --- Executes on button press in RemoveDataset.
function RemoveDataset_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=DeleteDataset(handles);

guidata(hObject, handles);


% --- Executes on button press in AddToSubplot.
function AddToSubplot_Callback(hObject, eventdata, handles)
% hObject    handle to AddToSubplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=AddToSubplot(handles);

guidata(hObject, handles);


% --- Executes on button press in ShowDatasetProperties.
function ShowDatasetProperties_Callback(hObject, eventdata, handles)
% hObject    handle to ShowDatasetProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ListSubplots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListSubplots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ListSubplots.
function ListSubplots_Callback(hObject, eventdata, handles)
% hObject    handle to ListSubplots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListSubplots contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListSubplots

ifig=handles.ActiveFigure;

handles.ActiveSubplot=get(hObject,'Value');

if handles.ActiveSubplot>0
    handles.ActiveDatasetInSubplot=handles.Figure(ifig).Axis(handles.ActiveSubplot).Nr;
    handles=RefreshAvailableDatasets(handles);
    handles=RefreshSubplots(handles);
    handles=RefreshDatasetsInSubplot(handles);
    handles=RefreshAxes(handles);
    RefreshColorMap(handles);
end

guidata(hObject, handles);


% --- Executes on button press in AddSubplot.
function AddSubplot_Callback(hObject, eventdata, handles)
% hObject    handle to AddSubplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.AddSubplotAnnotations=0;
handles=AddSubplot(handles);

guidata(hObject, handles);

% --- Executes on button press in DeleteSubplot.
function DeleteSubplot_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteSubplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=DeleteSubplot(handles);

guidata(hObject, handles);

% --- Executes on button press in SubplotUp.
function SubplotUp_Callback(hObject, eventdata, handles)
% hObject    handle to SubplotUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ifig=handles.ActiveFigure;

j=handles.ActiveSubplot;
nr=handles.Figure(ifig).NrSubplots;

if nr>1 && j>1
    a=handles.Figure(ifig).Axis(j-1);
    handles.Figure(ifig).Axis(j-1)=handles.Figure(ifig).Axis(j);
    handles.Figure(ifig).Axis(j)=a;
    handles.ActiveSubplot=j-1;
    handles=RefreshSubplots(handles);
    handles=RefreshDatasetsInSubplot(handles);
    handles=RefreshAxes(handles);
end

guidata(hObject, handles);

% --- Executes on button press in SubplotDown.
function SubplotDown_Callback(hObject, eventdata, handles)
% hObject    handle to SubplotDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ifig=handles.ActiveFigure;

j=handles.ActiveSubplot;
nr=handles.Figure(ifig).NrSubplots;

if nr>1 && nr>j
    a=handles.Figure(ifig).Axis(j+1);
    handles.Figure(ifig).Axis(j+1)=handles.Figure(ifig).Axis(j);
    handles.Figure(ifig).Axis(j)=a;
    handles.ActiveSubplot=j+1;
    handles=RefreshSubplots(handles);
    handles=RefreshDatasetsInSubplot(handles);
    handles=RefreshAxes(handles);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ListDatasetsInSubplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListDatasetsInSubplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in ListDatasetsInSubplot.
function ListDatasetsInSubplot_Callback(hObject, eventdata, handles)
% hObject    handle to ListDatasetsInSubplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ListDatasetsInSubplot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ListDatasetsInSubplot

handles.ActiveDatasetInSubplot=get(hObject,'Value');
str=get(hObject,'String');
if handles.ActiveDatasetInSubplot>0
    set(hObject,'ToolTipString',str{handles.ActiveDatasetInSubplot});
else
    set(hObject,'ToolTipString','No Datasets in Subplot');
end

guidata(hObject, handles);

% --- Executes on button press in EditPlotOptions.
function EditPlotOptions_Callback(hObject, eventdata, handles)
% hObject    handle to EditPlotOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=EditPlotOptions(handles);

guidata(hObject, handles);


% --- Executes on button press in DeleteDataset.
function DeleteDataset_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=RemoveDataset(handles);

guidata(hObject, handles);

% --- Executes on button press in DatasetUp.
function DatasetUp_Callback(hObject, eventdata, handles)
% hObject    handle to DatasetUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ifig=handles.ActiveFigure;

if handles.Figure(ifig).NrSubplots>0

    k=handles.ActiveSubplot;
    j=handles.ActiveDatasetInSubplot;
    nr=handles.Figure(ifig).Axis(k).Nr;

    if nr>1 && j>1
        if strcmpi(handles.Figure(ifig).Axis(k).PlotType,'annotations')
            b=handles.Figure(ifig).Annotation(j-1);
            handles.Figure(ifig).Annotation(j-1)=handles.Figure(ifig).Annotation(j);
            handles.Figure(ifig).Annotation(j)=b;
        end
        b=handles.Figure(ifig).Axis(k).Plot(j-1);
        handles.Figure(ifig).Axis(k).Plot(j-1)=handles.Figure(ifig).Axis(k).Plot(j);
        handles.Figure(ifig).Axis(k).Plot(j)=b;
        handles.ActiveDatasetInSubplot=j-1;
        handles=RefreshDatasetsInSubplot(handles);
    end

end

guidata(hObject, handles);

% --- Executes on button press in DatasetDown.
function DatasetDown_Callback(hObject, eventdata, handles)
% hObject    handle to DatasetDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ifig=handles.ActiveFigure;

if handles.Figure(ifig).NrSubplots>0
    
    k=handles.ActiveSubplot;
    j=handles.ActiveDatasetInSubplot;
    nr=handles.Figure(ifig).Axis(k).Nr;

    if nr>1 && nr>j
        if strcmpi(handles.Figure(ifig).Axis(k).PlotType,'annotations')
            b=handles.Figure(ifig).Annotation(j+1);
            handles.Figure(ifig).Annotation(j+1)=handles.Figure(ifig).Annotation(j);
            handles.Figure(ifig).Annotation(j)=b;
        end
        b=handles.Figure(ifig).Axis(k).Plot(j+1);
        handles.Figure(ifig).Axis(k).Plot(j+1)=handles.Figure(ifig).Axis(k).Plot(j);
        handles.Figure(ifig).Axis(k).Plot(j)=b;
        handles.ActiveDatasetInSubplot=j+1;
        handles=RefreshDatasetsInSubplot(handles);
    end

end

guidata(hObject, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ListAvailableDatasets.
function ListAvailableDatasets_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ListAvailableDatasets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuFile_Callback(hObject, eventdata, handles)
% hObject    handle to MenuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function MenuOpen_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname]=uigetfile('*.mup');
handles.SessionName=[pathname filename];

if pathname~=0

    for i=1:handles.NrFigures
        if ishandle(i)
            close(i);
        end
    end

    handles.CurrentPath=pathname;
    handles.FilePath=pathname;
    cd(pathname);

    handles=rmfield(handles,'Figure');
    handles=rmfield(handles,'DataProperties');
    handles=rmfield(handles,'CombinedDatasetProperties');

    handles.DataProperties(1).Name='';

    handles.NrAvailableDatasets=0;
    handles.NrCombinedDatasets=0;
%    handles.NrSubplots=0;
    handles.ActiveAvailableDataset=0;
    handles.ActiveSubplot=0;
    handles.ActiveFigure=1;

    wb = waitbox('Opening session file ...');
    
    try
        % Read Sessionfile
        handles=ReadSessionFile(handles,handles.SessionName);
        % Import datasets
        handles.DataProperties=mp_importDatasets(handles.DataProperties,handles.NrAvailableDatasets);
        % Combine datasets
        [handles.DataProperties,handles.NrAvailableDatasets,handles.CombinedDatasetProperties]=mp_combineDatasets(handles.DataProperties, ...
            handles.NrAvailableDatasets,handles.CombinedDatasetProperties,handles.NrCombinedDatasets);
    catch
        err=lasterror;
        str{1}=['An error occured in function: '  err.stack(1).name];
        str{2}=['Error: '  err.message];
        str{3}=['File: ' err.stack(1).file];
        str{4}=['Line: ' num2str(err.stack(1).line)];
        str{5}=['See muppet.err for more information'];
        strv=strvcat(str{1},str{2},str{3},str{4},str{5});
        uiwait(errordlg(strv,'Error','modal'));
        WriteErrorLog(err);
    end
    
    close(wb);

    handles=RefreshAll(handles);

    guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function EditTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTitle_Callback(hObject, eventdata, handles)
% hObject    handle to EditTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditTitle as text
%        str2double(get(hObject,'String')) returns contents of EditTitle as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Title=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditXLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditXLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditXLabel_Callback(hObject, eventdata, handles)
% hObject    handle to EditXLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditXLabel as text
%        str2double(get(hObject,'String')) returns contents of EditXLabel as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabel=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditYLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditYLabel_Callback(hObject, eventdata, handles)
% hObject    handle to EditYLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditYLabel as text
%        str2double(get(hObject,'String')) returns contents of EditYLabel as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabel=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditXMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditXMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditXMax_Callback(hObject, eventdata, handles)
% hObject    handle to EditXMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditXMax as text
%        str2double(get(hObject,'String')) returns contents of EditXMax as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMax=str2num(get(hObject,'String'));

typ=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotType;
switch lower(typ),
    case {'2d'}
        if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AxesEqual==1
            xmin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMin;
            xmax=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMax;
            ymin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin;
            x1=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(3);
            y1=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(4);

            scale=(xmax-xmin)/(0.01*x1);
            ymax=ymin+scale*0.01*y1;

            handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax=ymax;
            handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Scale=scale;

            set(handles.EditScale,'String',num2str(scale,7));
            set(handles.EditYMax,'String',num2str(ymax,7));
        end
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditXMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditXMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function EditXMin_Callback(hObject, eventdata, handles)
% hObject    handle to EditXMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditXMin as text
%        str2double(get(hObject,'String')) returns contents of EditXMin as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMin=str2num(get(hObject,'String'));

xmin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMin;
typ=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotType;
switch lower(typ),
    case {'2d'}
        if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AxesEqual==1
            scale=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Scale;
            x1=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(3);
            xmax=xmin+scale*x1*0.01;
            handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMax=xmax;
            set(handles.EditXMax,'String',num2str(xmax));
        end
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMinYear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function EditTMinYear_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearMin=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearMin));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMinMonth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMinMonth_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthMin=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthMin));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMinDay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMinDay_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayMin=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayMin));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMinHour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMinHour_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourMin=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourMin));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMinMinute_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMinMinute_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteMin=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteMin));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMinSecond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMinSecond_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondMin=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondMin));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMaxYear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMaxYear_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearMax=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearMax));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMaxMonth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMaxMonth_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthMax=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthMax));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMaxDay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMaxDay_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayMax=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayMax));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMaxHour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMaxHour_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourMax=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourMax));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMaxMinute_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMaxMinute_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteMax=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteMax));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTMaxSecond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTMaxSecond_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondMax=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).SecondMax));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTTickYear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTTickYear_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearTick=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YearTick));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTTickMonth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTTickMonth_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthTick=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MonthTick));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditTTickDay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTTickDay_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayTick=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DayTick));
end
guidata(hObject, handles);


function EditTTickHour_Callback(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit35 as text
%        str2double(get(hObject,'String')) returns contents of edit35 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourTick=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).HourTick));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditTTickHour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditTTickMinute_Callback(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit36 as text
%        str2double(get(hObject,'String')) returns contents of edit36 as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteTick=floor(val);
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).MinuteTick));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditTTickMinute_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes during object creation, after setting all properties.
function EditXTick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditXTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditXTick_Callback(hObject, eventdata, handles)
% hObject    handle to EditXTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditXTick as text
%        str2double(get(hObject,'String')) returns contents of EditXTick as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XTick=str2num(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditXDecimals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditXDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditXDecimals_Callback(hObject, eventdata, handles)
% hObject    handle to EditXDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditXDecimals as text
%        str2double(get(hObject,'String')) returns contents of EditXDecimals as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimX=str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes on button press in ToggleXGrid.
function ToggleXGrid_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleXGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleXGrid

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XGrid=get(hObject,'Value');;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditYMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditYMax_Callback(hObject, eventdata, handles)
% hObject    handle to EditYMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditYMax as text
%        str2double(get(hObject,'String')) returns contents of EditYMax as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax=str2num(get(hObject,'String'));

typ=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotType;
switch lower(typ),
    case {'2d'}
        if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AxesEqual==1

            ymin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin;
            ymax=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax;
            xmin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMin;
            x1=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(3);
            y1=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(4);

            scale=(ymax-ymin)/(0.01*y1);
            xmax=xmin+scale*0.01*x1;

            handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMax=xmax;
            handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Scale=scale;

            set(handles.EditScale,'String',num2str(scale,7));
            set(handles.EditXMax,'String',num2str(xmax,7));
        end
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditYMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditYMin_Callback(hObject, eventdata, handles)
% hObject    handle to EditYMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditYMin as text
%        str2double(get(hObject,'String')) returns contents of EditYMin as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin=str2num(get(hObject,'String'));

ymin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin;

typ=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotType;
switch lower(typ),
    case {'2d'}
        if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AxesEqual==1

            scale=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Scale;
            y1=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(4);
            ymax=ymin+scale*y1*0.01;
            handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax=ymax;

            set(handles.EditYMax,'String',num2str(ymax));
        end
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function EditYTick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditYTick_Callback(hObject, eventdata, handles)
% hObject    handle to EditYTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditYTick as text
%        str2double(get(hObject,'String')) returns contents of EditYTick as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YTick=str2num(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditYDecimals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditYDecimals_Callback(hObject, eventdata, handles)
% hObject    handle to EditYDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditYDecimals as text
%        str2double(get(hObject,'String')) returns contents of EditYDecimals as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimY=str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes on button press in ToggleYGrid.
function ToggleYGrid_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleYGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleYGrid

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YGrid=get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobutton1.
function ToggleMap2D_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1

set(handles.ToggleMap3D,     'Value',0);

i=get(hObject,'Value');
if i==1
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotType='2d';
else
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotType='3d';
end

handles=Convert2D3D(handles);

handles=RefreshAxes(handles);

guidata(hObject, handles);

% --- Executes on button press in radiobutton2.
function ToggleXY_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton3.
function ToggleTimeSeries_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton4.
function ToggleImage_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in EditTitleFont.
function EditTitleFont_Callback(hObject, eventdata, handles)
% hObject    handle to EditTitleFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFont;
Font.Size=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFontSize;
Font.Weight=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFontWeight;
Font.Angle=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFontAngle;
Font.Color=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFontColor;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFont=Font.Type;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFontSize=Font.Size;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFontAngle=Font.Angle;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFontWeight=Font.Weight;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).TitleFontColor=Font.Color;
guidata(hObject, handles);

% --- Executes on button press in EditXLabelFont.
function EditXLabelFont_Callback(hObject, eventdata, handles)
% hObject    handle to EditXLabelFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFont;
Font.Size=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFontSize;
Font.Weight=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFontWeight;
Font.Angle=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFontAngle;
Font.Color=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFontColor;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFont=Font.Type;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFontSize=Font.Size;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFontAngle=Font.Angle;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFontWeight=Font.Weight;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XLabelFontColor=Font.Color;
guidata(hObject, handles);

% --- Executes on button press in EditYLabelFont.
function EditYLabelFont_Callback(hObject, eventdata, handles)
% hObject    handle to EditYLabelFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Font.Type=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFont;
Font.Size=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFontSize;
Font.Weight=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFontWeight;
Font.Angle=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFontAngle;
Font.Color=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFontColor;
Font.HorizontalAlignment='left';
Font.VerticalAlignment='baseline';
Font.EditAlignment=0;
Font=SelectFont('Type',Font,'Colors',handles.DefaultColors);
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFont=Font.Type;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFontSize=Font.Size;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFontAngle=Font.Angle;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFontWeight=Font.Weight;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YLabelFontColor=Font.Color;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditScale_Callback(hObject, eventdata, handles)
% hObject    handle to EditScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditScale as text
%        str2double(get(hObject,'String')) returns contents of EditScale as a double

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Scale=str2num(get(hObject,'String'));
scale=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Scale;
xmin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMin;
ymin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMin;
x1=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(3);
y1=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(4);
xmax=xmin+scale*x1*0.01;
ymax=ymin+scale*y1*0.01;

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XMax=xmax;
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YMax=ymax;

set(handles.EditXMax,'String',num2str(xmax,7));
set(handles.EditYMax,'String',num2str(ymax,7));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditPaperWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPaperWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditPaperWidth_Callback(hObject, eventdata, handles)
% hObject    handle to EditPaperWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPaperWidth as text
%        str2double(get(hObject,'String')) returns contents of EditPaperWidth as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).PaperSize(1)=val;
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).PaperSize(1)));
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditPaperHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditPaperHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function EditPaperHeight_Callback(hObject, eventdata, handles)
% hObject    handle to EditPaperHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditPaperHeight as text
%        str2double(get(hObject,'String')) returns contents of EditPaperHeight as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).PaperSize(2)=val;
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).PaperSize(2)));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SelectOutputFormat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectOutputFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectOutputFormat.
function SelectOutputFormat_Callback(hObject, eventdata, handles)
% hObject    handle to SelectOutputFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectOutputFormat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectOutputFormat

str=get(hObject,'String');
i=get(hObject,'Value');
if ~strcmp(str{i},handles.Figure(handles.ActiveFigure).Format)
    name=handles.Figure(handles.ActiveFigure).FileName(1:end-4);
    switch str{i},
        case {'png'}
            handles.Figure(handles.ActiveFigure).FileName=[name '.png'];
        case {'jpeg'}
            handles.Figure(handles.ActiveFigure).FileName=[name '.jpg'];
        case {'tiff'}
            handles.Figure(handles.ActiveFigure).FileName=[name '.tif'];
        case {'pdf'}
            handles.Figure(handles.ActiveFigure).FileName=[name '.pdf'];
        case {'eps'}
            handles.Figure(handles.ActiveFigure).FileName=[name '.eps'];
        case {'eps2'}
            handles.Figure(handles.ActiveFigure).FileName=[name '.ps2'];
    end
end

handles.Figure(handles.ActiveFigure).Format=str{i};

set(handles.EditOutputFile,'String',handles.Figure(handles.ActiveFigure).FileName);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SelectResolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectResolution.
function SelectResolution_Callback(hObject, eventdata, handles)
% hObject    handle to SelectResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectResolution contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectResolution

str=get(hObject,'String');
handles.Figure(handles.ActiveFigure).Resolution=str2num(str{get(hObject,'Value')});
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SelectRenderer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectRenderer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectRenderer.
function SelectRenderer_Callback(hObject, eventdata, handles)
% hObject    handle to SelectRenderer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectRenderer contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectRenderer

str=get(hObject,'String');
handles.Figure(handles.ActiveFigure).Renderer=str{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes on button press in ExportFigure.
function ExportFigure_Callback(hObject, eventdata, handles)
% hObject    handle to ExportFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%makeColorBar(handles,'colorbar.png',[handles.Figure(1).Axis(1).CMin handles.Figure(1).Axis(1).CStep handles.Figure(1).Axis(1).CMax],handles.Figure(1).Axis(1).Plot(1).ColorMap,handles.Figure(1).Axis(1).ColorBarLabel);

ExportFigure(handles,handles.ActiveFigure,'guiexport');
delete(['curvecpos.*.dat']);
%for i=1:5
%    if exist(['pos' num2str(i) '.dat'],'file')
%        delete(['pos' num2str(i) '.dat']);
%    end
%end

% --- Executes on button press in PushAdjustAxes.
function PushAdjustAxes_Callback(hObject, eventdata, handles)
% hObject    handle to PushAdjustAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=AdjustAxes(handles);
handles=RefreshAxes(handles);

guidata(hObject, handles);


% --- Executes on button press in Preview.
function Preview_Callback(hObject, eventdata, handles)
% hObject    handle to Preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%makeColorBar(handles,'colorbar.png',[handles.Figure(1).Axis(1).CMin handles.Figure(1).Axis(1).CStep handles.Figure(1).Axis(1).CMax],handles.Figure(1).Axis(1).Plot(1).ColorMap,handles.Figure(1).Axis(1).ColorBarLabel);

handles=Preview(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditOutputFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditOutputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditOutputFile_Callback(hObject, eventdata, handles)
% hObject    handle to EditOutputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditOutputFile as text
%        str2double(get(hObject,'String')) returns contents of EditOutputFile as a double

handles.Figure(handles.ActiveFigure).FileName=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditSubplotPositionX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSubplotPositionX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditSubplotPositionX_Callback(hObject, eventdata, handles)
% hObject    handle to EditSubplotPositionX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSubplotPositionX as text
%        str2double(get(hObject,'String')) returns contents of EditSubplotPositionX as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(1)=val;
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(1)));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditSubplotPositionY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSubplotPositionY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditSubplotPositionY_Callback(hObject, eventdata, handles)
% hObject    handle to EditSubplotPositionY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSubplotPositionY as text
%        str2double(get(hObject,'String')) returns contents of EditSubplotPositionY as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(2)=val;
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(2)));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditSubplotSizeX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSubplotSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditSubplotSizeX_Callback(hObject, eventdata, handles)
% hObject    handle to EditSubplotSizeX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSubplotSizeX as text
%        str2double(get(hObject,'String')) returns contents of EditSubplotSizeX as a double

ifig=handles.ActiveFigure;
isub=handles.ActiveSubplot;

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(ifig).Axis(isub).Position(3)=val;
    if strcmp(lower(handles.Figure(ifig).Axis(isub).PlotType),'image')
        n=FindDatasetNr(handles.Figure(ifig).Axis(isub).Plot(1).Name,handles.DataProperties);
        ImageSize=size(handles.DataProperties(n).x');
        ysz=handles.Figure(ifig).Axis(isub).Position(3)*ImageSize(2)/ImageSize(1);
        handles.Figure(ifig).Axis(isub).Position(4)=round(ysz*10)/10;
        set(handles.EditSubplotSizeY,'String',num2str(handles.Figure(ifig).Axis(isub).Position(4)));
    end
else
    set(hObject,'String',num2str(handles.Figure(ifig).Axis(isub).Position(3)));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditSubplotSizeY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSubplotSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditSubplotSizeY_Callback(hObject, eventdata, handles)
% hObject    handle to EditSubplotSizeY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSubplotSizeY as text
%        str2double(get(hObject,'String')) returns contents of EditSubplotSizeY as a double

ifig=handles.ActiveFigure;
isub=handles.ActiveSubplot;

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(ifig).Axis(isub).Position(4)=val;
    if strcmp(lower(handles.Figure(ifig).Axis(isub).PlotType),'image')
        n=FindDatasetNr(handles.Figure(ifig).Axis(isub).Plot(1).Name.Name,handles.DataProperties);
        ImageSize=size(handles.DataProperties(n).x');
        xsz=handles.Figure(ifig).Axis(isub).Position(4)*ImageSize(1)/ImageSize(2);
        handles.Figure(ifig).Axis(isub).Position(3)=round(xsz*10)/10;
        set(handles.EditSubplotSizeX,'String',num2str(handles.Figure(ifig).Axis(isub).Position(3)));
    end
else
    set(hObject,'String',num2str(handles.Figure(ifig).Axis(isub).Position(4)));
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectFrame.
function SelectFrame_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectFrame contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectFrame

str=get(hObject,'String');
handles.Figure(handles.ActiveFigure).Frame=str{get(hObject,'Value')};

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectColorMap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectColorMap.
function SelectColorMap_Callback(hObject, eventdata, handles)
% hObject    handle to SelectColorMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectColorMap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectColorMap

str=get(hObject,'String');
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ColMap=str{get(hObject,'Value')};
RefreshColorMap(handles);

guidata(hObject, handles);

% --- Executes on button press in ToggleColorBar.
function ToggleColorBar_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleColorBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleColorBar

i=get(hObject,'Value');

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotColorBar=i;

if i==1
    set(handles.EditColorBar,'Enable','on');
    % Set colorbar position
    if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ColorBarPosition(3)==0
        x0=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(1)+ ...
            handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(3)-2.0;
        y0=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(2)+1.0;
        x1=0.5;
        y1=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(4)-2.0;
        handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ColorBarPosition=[x0 y0 x1 y1];
    end
else
    set(handles.EditColorBar,'Enable','off');
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SelectTTickFormat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectTTickFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectTTickFormat.
function SelectTTickFormat_Callback(hObject, eventdata, handles)
% hObject    handle to SelectTTickFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectTTickFormat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectTTickFormat

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DateFormatNr=get(hObject,'Value');
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DateFormat=handles.DateFormats{get(hObject,'Value')};

guidata(hObject, handles);


% --- Executes on button press in ToggleTGrid.
function ToggleTGrid_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleTGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleTGrid

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XGrid=get(hObject,'Value');
guidata(hObject, handles);

% --------------------------------------------------------------------
function MenuNew_Callback(hObject, eventdata, handles)
% hObject    handle to MenuNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.SessionName='';

for i=1:handles.NrFigures
    if ishandle(i)
        close(i);
    end
end

LayoutName=[handles.MuppetPath 'settings' filesep 'layouts' filesep 'default.mup'];

handles=rmfield(handles,'Figure');
handles=rmfield(handles,'DataProperties');
handles=rmfield(handles,'CombinedDatasetProperties');

handles.DataProperties(1).Name='';

handles.NrAvailableDatasets=0;
handles.NrCombinedDatasets=0;
%handles.NrSubplots=0;
handles.ActiveAvailableDataset=0;
handles.ActiveDatasetInSubplot=0;
handles.ActiveSubplot=0;
handles.ActiveFigure=1;

handles.AnimationSettings.startTime=[];
handles.AnimationSettings.stopTime=[];
handles.AnimationSettings.timeStep=[];

% Read Sessionfile
handles=ReadSessionFile(handles,LayoutName);

% Import datasets
handles.DataProperties=mp_importDatasets(handles.DataProperties,handles.NrAvailableDatasets);

handles=RefreshAll(handles);

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function MenuSave_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if size(handles.SessionName,2)>0
    SaveSessionFile(handles,handles.SessionName,0);
else
    [filename pathname]=uiputfile('*.mup');
    if pathname~=0
        handles.SessionName=[pathname filename];
        SaveSessionFile(handles,handles.SessionName,0);
    end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function MenuSaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname]=uiputfile('*.mup');
if pathname~=0
    handles.SessionName=[pathname filename];
    handles.CurrentPath=pathname;
    handles.FilePath=pathname;
    cd(handles.CurrentPath);
    SaveSessionFile(handles,handles.SessionName,0);
    guidata(hObject, handles);
end

% --------------------------------------------------------------------
function MenuExit_Callback(hObject, eventdata, handles)
% hObject    handle to MenuExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear all;
close all;

% --------------------------------------------------------------------
function MenuLayout_Callback(hObject, eventdata, handles)
% hObject    handle to MenuLayout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function MenuImportLayout_Callback(hObject, eventdata, handles)
% hObject    handle to MenuImportLayout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname,filter]=uigetfile([handles.MuppetPath 'settings' filesep 'layouts' filesep '*.mup']);
handles.LayoutName=[pathname filename];

if filter==1

    if isfield(handles,'fig')
        if ishandle(handles.fig)
            close(handles.fig);
        end
    end

    handles.Figure(handles.ActiveFigure)=[];
    % Read layout file
    handles=ReadLayout(handles,handles.LayoutName,handles.ActiveFigure);
    handles.Figure(handles.ActiveFigure).FileName='figure1.png';
    
    handles=RefreshAll(handles);
    
    handles.Figure(handles.ActiveFigure).NrAnnotations=0;

    handles.ActiveSubplot=1;
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function MenuExportLayout_Callback(hObject, eventdata, handles)
% hObject    handle to MenuExportLayout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname]=uiputfile([handles.MuppetPath 'settings' filesep 'layouts' filesep '*.mup']);
if pathname~=0
    LayoutName=[pathname filename];
    SaveSessionFile(handles,LayoutName,1);
    guidata(hObject, handles);
end

% --- Executes on button press in PushCombineDatasets.
function PushCombineDatasets_Callback(hObject, eventdata, handles)
% hObject    handle to PushCombineDatasets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.NrAvailableDatasets>0
    [handles.DataProperties,handles.NrAvailableDatasets,handles.CombinedDatasetProperties,handles.NrCombinedDatasets]= ...
        EditCombineDatasets('DataProperties',handles.DataProperties,'Nr',handles.NrAvailableDatasets,'CombinedDatasetProperties', ...
        handles.CombinedDatasetProperties,'NrCombined',handles.NrCombinedDatasets);
    handles.ActiveAvailableDataset=handles.NrAvailableDatasets;
    handles=RefreshAvailableDatasets(handles);
    handles=RefreshActiveAvailableDatasetText(handles);
end

guidata(hObject, handles);

% --- Executes on button press in ToggleAxesEqual.
function ToggleAxesEqual_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAxesEqual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAxesEqual

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AxesEqual=get(hObject,'Value');
handles=RefreshAxes(handles);

guidata(hObject, handles);

% --- Executes on button press in PushEditFrameText.
function PushEditFrameText_Callback(hObject, eventdata, handles)
% hObject    handle to PushEditFrameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=EditFrameText(handles,1);

guidata(hObject, handles);


% --- Executes on button press in ToggleLegend.
function ToggleLegend_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleLegend

i=get(hObject,'Value');

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotLegend=i;

if i==1
    set(handles.EditLegend,'Enable','on');
else
    set(handles.EditLegend,'Enable','off');
end

guidata(hObject, handles);

% --- Executes on button press in ToggleScaleBar.
function ToggleScaleBar_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleScaleBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleScaleBar

i=get(hObject,'Value');

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotScaleBar=i;

if i==1
    set(handles.EditScaleBar,'Enable','on');
    if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ScaleBar(3)==0
        x0=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(1)+1.5;
        y0=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(2)+1.5;
        x1=round(0.04*handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Scale);
        handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ScaleBar=[x0 y0 x1];
        handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ScaleBarText=[num2str(x1) ' m'];
    end
else
    set(handles.EditScaleBar,'Enable','off');
end

guidata(hObject, handles);

% --- Executes on button press in ToggleNorthArrow.
function ToggleNorthArrow_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleNorthArrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleNorthArrow

i=get(hObject,'Value');

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotNorthArrow=i;

if i==1
    set(handles.EditNorthArrow,'Enable','on');
    if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).NorthArrow(3)==0
        x0=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(1)+1.5;
        y0=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(2)+ ...
            handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(4)-1.5;
        x1=1.0;
        y1=90;
        handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).NorthArrow=[x0 y0 x1 y1];
    end
else
    set(handles.EditNorthArrow,'Enable','off');
end

guidata(hObject, handles);


% --- Executes on button press in EditLegend.
function EditLegend_Callback(hObject, eventdata, handles)
% hObject    handle to EditLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=EditLegend('handles',handles);
guidata(hObject, handles);

% --- Executes on button press in EditColorBar.
function EditColorBar_Callback(hObject, eventdata, handles)
% hObject    handle to EditColorBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=EditColorBar('handles',handles);
guidata(hObject, handles);

% --- Executes on button press in EditScaleBar.
function EditScaleBar_Callback(hObject, eventdata, handles)
% hObject    handle to EditScaleBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=EditScaleBar('handles',handles);
guidata(hObject, handles);

% --- Executes on button press in EditNorthArrow.
function EditNorthArrow_Callback(hObject, eventdata, handles)
% hObject    handle to EditNorthArrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=EditNorthArrow('handles',handles);
guidata(hObject, handles);

function EditCMin_Callback(hObject, eventdata, handles)
% hObject    handle to EditCMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditCMin as text
%        str2double(get(hObject,'String')) returns contents of EditCMin as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin=val;
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin));
end

cdif=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax-handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin;
cmin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin;
cmax=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax;
cstep=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CStep;

if cmax<=cmin | cstep>cdif | cstep<0.01*cdif
    set(handles.EditCMin,'BackgroundColor',[1 0 0]);
    set(handles.EditCMax,'BackgroundColor',[1 0 0]);
    set(handles.EditCStep,'BackgroundColor',[1 0 0]);
else
    set(handles.EditCMin,'BackgroundColor',[1 1 1]);
    set(handles.EditCMax,'BackgroundColor',[1 1 1]);
    set(handles.EditCStep,'BackgroundColor',[1 1 1]);
    RefreshColorMap(handles);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditCMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditCStep_Callback(hObject, eventdata, handles)
% hObject    handle to EditCStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditCStep as text
%        str2double(get(hObject,'String')) returns contents of EditCStep as a double

[val,ok]=str2num(get(hObject,'String'));

if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CStep=val;
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CStep));
end

cdif=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax-handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin;
cmin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin;
cmax=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax;
cstep=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CStep;

if cmax<=cmin | cstep>cdif | cstep<0.01*cdif
    set(handles.EditCMin,'BackgroundColor',[1 0 0]);
    set(handles.EditCMax,'BackgroundColor',[1 0 0]);
    set(handles.EditCStep,'BackgroundColor',[1 0 0]);
else
    set(handles.EditCMin,'BackgroundColor',[1 1 1]);
    set(handles.EditCMax,'BackgroundColor',[1 1 1]);
    set(handles.EditCStep,'BackgroundColor',[1 1 1]);
    RefreshColorMap(handles);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditCStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function EditCMax_Callback(hObject, eventdata, handles)
% hObject    handle to EditCMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditCMax as text
%        str2double(get(hObject,'String')) returns contents of EditCMax as a double

[val,ok]=str2num(get(hObject,'String'));
if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax=val;
else
    set(hObject,'String',num2str(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax));
end

cdif=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax-handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin;
cmin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin;
cmax=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax;
cstep=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CStep;

if cmax<=cmin | cstep>cdif | cstep<0.01*cdif
    set(handles.EditCMin,'BackgroundColor',[1 0 0]);
    set(handles.EditCMax,'BackgroundColor',[1 0 0]);
    set(handles.EditCStep,'BackgroundColor',[1 0 0]);
else
    set(handles.EditCMin,'BackgroundColor',[1 1 1]);
    set(handles.EditCMax,'BackgroundColor',[1 1 1]);
    set(handles.EditCStep,'BackgroundColor',[1 1 1]);
    RefreshColorMap(handles);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EditCMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditCMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in PushApplyToAll.
function PushApplyToAll_Callback(hObject, eventdata, handles)
% hObject    handle to PushApplyToAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=ApplyToAllAxes(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in Push3DOptions.
function Push3DOptions_Callback(hObject, eventdata, handles)
% hObject    handle to Push3DOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=Options3D('handles',handles);
guidata(hObject, handles);

% --- Executes on button press in ToggleMap3D.
function ToggleMap3D_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleMap3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleMap3D

set(handles.ToggleMap2D,     'Value',0);

i=get(hObject,'Value');
if i==1
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotType='3d';
else
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotType='2d';
end

handles=Convert2D3D(handles);

handles=RefreshAxes(handles);

guidata(hObject, handles);



% --- Executes on selection change in SelectXAxisScale.
function SelectXAxisScale_Callback(hObject, eventdata, handles)
% hObject    handle to SelectXAxisScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectXAxisScale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectXAxisScale

i=get(hObject,'Value');
str=get(hObject,'String');
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).XScale=str{i};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectXAxisScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectXAxisScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectYAxisScale.
function SelectYAxisScale_Callback(hObject, eventdata, handles)
% hObject    handle to SelectYAxisScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectYAxisScale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectYAxisScale

i=get(hObject,'Value');
str=get(hObject,'String');
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).YScale=str{i};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectYAxisScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectYAxisScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes on button press in PushLabelFont.
function PushLabelFont_Callback(hObject, eventdata, handles)
% hObject    handle to PushLabelFont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=EditAxisLabels('handles',handles);
guidata(hObject, handles);

% --- Executes on button press in TogglePortrait.
function TogglePortrait_Callback(hObject, eventdata, handles)
% hObject    handle to TogglePortrait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TogglePortrait

i=handles.ActiveFigure;
if handles.Figure(i).Orientation=='p'
    set(hObject,'Value',1);
else
    set(handles.ToggleLandscape,'Value',0);
    handles.Figure(i).Orientation='p';
    xtmp=handles.Figure(i).PaperSize(2);
    handles.Figure(i).PaperSize(2)=handles.Figure(i).PaperSize(1);
    handles.Figure(i).PaperSize(1)=xtmp;
    set(handles.EditPaperWidth,'String',num2str(handles.Figure(i).PaperSize(1)));
    set(handles.EditPaperHeight,'String',num2str(handles.Figure(i).PaperSize(2)));
    for j=1:handles.Figure(i).NrSubplots
        pos=handles.Figure(i).Axis(j).Position;
        handles.Figure(i).Axis(j).Position(1)=handles.Figure(i).PaperSize(1)-pos(2)-pos(4);
        handles.Figure(i).Axis(j).Position(2)=pos(1);
        handles.Figure(i).Axis(j).Position(3)=pos(4);
        handles.Figure(i).Axis(j).Position(4)=pos(3);
    end
    handles=RefreshAxes(handles);
end
guidata(hObject, handles);

% --- Executes on button press in ToggleLandscape.
function ToggleLandscape_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleLandscape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleLandscape

i=handles.ActiveFigure;
if handles.Figure(i).Orientation=='l'
    set(hObject,'Value',1);
else
    set(handles.TogglePortrait,'Value',0);
    handles.Figure(i).Orientation='l';
    xtmp=handles.Figure(i).PaperSize(2);
    handles.Figure(i).PaperSize(2)=handles.Figure(i).PaperSize(1);
    handles.Figure(i).PaperSize(1)=xtmp;
    set(handles.EditPaperWidth,'String',num2str(handles.Figure(i).PaperSize(1)));
    set(handles.EditPaperHeight,'String',num2str(handles.Figure(i).PaperSize(2)));
    for j=1:handles.Figure(i).NrSubplots
        pos=handles.Figure(i).Axis(j).Position;
        handles.Figure(i).Axis(j).Position(1)=pos(2);
        handles.Figure(i).Axis(j).Position(2)=handles.Figure(i).PaperSize(2)-pos(3)-pos(1);
        handles.Figure(i).Axis(j).Position(3)=pos(4);
        handles.Figure(i).Axis(j).Position(4)=pos(3);
    end
    handles=RefreshAxes(handles);
end
guidata(hObject, handles);



% --- Executes on button press in ToggleRightAxis.
function ToggleRightAxis_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleRightAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleRightAxis

i=get(hObject,'Value');

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).RightAxis=i;

guidata(hObject, handles);

% --- Executes on button press in EditRightAxis.
function EditRightAxis_Callback(hObject, eventdata, handles)
% hObject    handle to EditRightAxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=EditRightAxis('handles',handles);
guidata(hObject, handles);

% --- Executes on button press in ToggleAddDate.
function ToggleAddDate_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAddDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAddDate

i=get(hObject,'Value');

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AddDate=i;

guidata(hObject, handles);



% --- Executes on button press in PushAddText.
function PushAddText_Callback(hObject, eventdata, handles)
% hObject    handle to PushAddText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.FigureProperties(handles.ActiveFigure)=EditAddText('FigureProperties',handles.FigureProperties(handles.ActiveFigure), ...
%     'Colors',handles.DefaultColors);

% guidata(hObject, handles);


% --- Executes on button press in ToggleVectorLegend.
function ToggleVectorLegend_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleVectorLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleVectorLegend

i=get(hObject,'Value');

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).PlotVectorLegend=i;

if i==1
    set(handles.EditVectorLegend,'Enable','on');
    if handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).VectorLegendPosition(1)==0
        x0=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(1)+1.0;
        y0=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Position(2)+1.0;
        handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).VectorLegendPosition=[x0 y0];
    end
else
    set(handles.EditVectorLegend,'Enable','off');
end

guidata(hObject, handles);

% --- Executes on button press in EditVectorLegend.
function EditVectorLegend_Callback(hObject, eventdata, handles)
% hObject    handle to EditVectorLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=EditVectorLegend('handles',handles);
guidata(hObject, handles);

% --- Executes on button press in ToggleCustomContours.
function ToggleCustomContours_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleCustomContours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleCustomContours

i=get(hObject,'Value');
if i==1
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ContourType='custom';
else
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ContourType='limits';
end

handles=RefreshAxes(handles);

guidata(hObject, handles);

% --- Executes on button press in PushEditCustomContours.
function PushEditCustomContours_Callback(hObject, eventdata, handles)
% hObject    handle to PushEditCustomContours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cmin=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMin;
cmax=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CMax;
cstep=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).CStep;
oricont=handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Contours;
if size(oricont,2)==1
    oricont=cmin:cstep:cmax;
end

contours=EditCustomContours('oricont',oricont,'cmin',cmin,'cmax',cmax,'cstep',cstep);

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).Contours=contours;

guidata(hObject, handles);



% --- Executes on button press in ToggleAdjustAxes.
function ToggleAdjustAxes_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleAdjustAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleAdjustAxes

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).AdjustAxes=get(hObject,'Value');

guidata(hObject, handles);


% --- Executes on selection change in SelectFigure.
function SelectFigure_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectFigure contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectFigure

inum=get(hObject,'Value');

if inum<=handles.NrFigures
    handles.ActiveFigure=inum;
else
    handles=EditFigures('handles',handles);
end
handles=RefreshAll(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in MakeAnimation.
function MakeAnimation_Callback(hObject, eventdata, handles)
% hObject    handle to MakeAnimation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check to see if there are time dependent datasets
icontinue=0;
for i=1:length(handles.DataProperties)
    if strcmpi(handles.DataProperties(i).TC,'t')
        icontinue=1;
    end
end
if ~icontinue
    return
end

if isempty(handles.AnimationSettings.startTime)
    % Try to determine start and stop times
    tmin=floor(now)+1000000;
    tmax=floor(now)-1000000;
    dt=1;
    for i=1:length(handles.DataProperties)
        if strcmpi(handles.DataProperties(i).TC,'t')
            tmin=min(tmin,handles.DataProperties(i).AvailableTimes(1));
            tmax=max(tmax,handles.DataProperties(i).AvailableTimes(end));
            dt1=0;
            if length(handles.DataProperties(i).AvailableTimes)>1
                dt1=86400*(handles.DataProperties(i).AvailableTimes(2)-handles.DataProperties(i).AvailableTimes(1));
            end
            dt=max(dt1,dt);
        end
    end
    handles.AnimationSettings.startTime=tmin;
    handles.AnimationSettings.stopTime=tmax;
    handles.AnimationSettings.timeStep=dt;
end

ifig=handles.ActiveFigure;
res=handles.Figure(ifig).Resolution;
n1=handles.Figure(ifig).PaperSize(1)/2.5;
n2=handles.Figure(ifig).PaperSize(2)/2.5;

nopix=res*res*n1*n2;

if ~isempty(handles.AnimationSettings.aviFileName)
    fid=fopen(handles.AnimationSettings.aviFileName,'w');
    if fid~=-1
        fclose(fid);
    end
else
    fid=0;
end

if nopix>2500000
    txt='Reduce Output Resolution';
    mp_giveWarning('WarningText',txt);
elseif fid==-1
    txt=strvcat(['The file ' handles.AnimationSettings.aviFileName ' cannot be opened'],'Remove write protection');
    mp_giveWarning('WarningText',txt);
else
    mp_makeAnimation(handles,ifig);
end

% --- Executes on button press in PushAnimationSettings.
function PushAnimationSettings_Callback(hObject, eventdata, handles)
% hObject    handle to PushAnimationSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.NrAvailableDatasets>0
    
    % check to see if there are time dependent datasets
    icontinue=0;
    for i=1:length(handles.DataProperties)
        if strcmpi(handles.DataProperties(i).TC,'t')
            icontinue=1;
        end
    end
    if ~icontinue
        return
    end

    if isempty(handles.AnimationSettings.startTime)
        % Try to determine start and stop times
        tmin=floor(now)+1000000;
        tmax=floor(now)-1000000;
        dt=1;
        for i=1:length(handles.DataProperties)
            if strcmpi(handles.DataProperties(i).TC,'t')
                tmin=min(tmin,handles.DataProperties(i).AvailableTimes(1));
                tmax=max(tmax,handles.DataProperties(i).AvailableTimes(end));
                dt1=0;
                if length(handles.DataProperties(i).AvailableTimes)>1
                    dt1=86400*(handles.DataProperties(i).AvailableTimes(2)-handles.DataProperties(i).AvailableTimes(1));
                end
                dt=max(dt1,dt);
            end
        end
        handles.AnimationSettings.startTime=tmin;
        handles.AnimationSettings.stopTime=tmax;
        handles.AnimationSettings.timeStep=dt;
    end
    
    %handles.AnimationSettings=EditAnimationSettings2('Settings',handles.AnimationSettings);
    
    xmlfile='animationsettings.xml';
    
    [handles.AnimationSettings,ok]=gui_newWindow(handles.AnimationSettings,'xmldir',handles.xmlDir,'xmlfile',xmlfile);
    
    guidata(hObject, handles);
    
end

% --- Executes on button press in ToggleTextBox.
function ToggleTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleTextBox


% --- Executes on button press in ToggleDrawBox.
function ToggleDrawBox_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleDrawBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleDrawBox

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DrawBox=get(hObject,'Value');

guidata(hObject, handles);




function EditZMin_Callback(hObject, eventdata, handles)
% hObject    handle to EditZMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditZMin as text
%        str2double(get(hObject,'String')) returns contents of EditZMin as a double


% --- Executes during object creation, after setting all properties.
function EditZMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditZMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditZMax_Callback(hObject, eventdata, handles)
% hObject    handle to EditZMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditZMax as text
%        str2double(get(hObject,'String')) returns contents of EditZMax as a double


% --- Executes during object creation, after setting all properties.
function EditZMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditZMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditZTick_Callback(hObject, eventdata, handles)
% hObject    handle to EditZTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditZTick as text
%        str2double(get(hObject,'String')) returns contents of EditZTick as a double


% --- Executes during object creation, after setting all properties.
function EditZTick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditZTick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditZDecimals_Callback(hObject, eventdata, handles)
% hObject    handle to EditZDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditZDecimals as text
%        str2double(get(hObject,'String')) returns contents of EditZDecimals as a double


% --- Executes during object creation, after setting all properties.
function EditZDecimals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditZDecimals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KoffieTijd.
function KoffieTijd_Callback(hObject, eventdata, handles)
% hObject    handle to KoffieTijd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

y=wavread([handles.MuppetPath 'settings' filesep 'tunes' filesep 'koffietijd' filesep 'koffietijd1_11hz.wav']);
wavplay(y,'async');


% --- Executes on button press in PlayTunes.
function PlayTunes_Callback(hObject, eventdata, handles)
% hObject    handle to PlayTunes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cmenu = uicontextmenu;

d=dir([handles.MuppetPath 'settings' filesep 'tunes' filesep '*.wav']);
d2=dir([handles.MuppetPath 'settings' filesep 'tunes' filesep '*.mp3']);
szd=size(d,1);
szd2=size(d2,1);
for i=1:szd2
    d(szd+i)=d2(i);
end
szd=size(d,1);

if isfield(handles,'PlayTune')
    a=get(handles.PlayTune,'Running');
    if strcmp(a,'on')
        stop(handles.PlayTune);
        clear handles.PlayTune;
    else
        rand('state',sum(100*clock));
        rn=rand;
        ii=ceil(rn*szd);
        fname=[handles.MuppetPath 'settings' filesep 'tunes' filesep d(ii).name];
        if fname(end-2:end)=='wav'
           [y,fs]=wavread(fname);
        elseif fname(end-2:end)=='mp3'
           [y,fs]=mp3read(fname);
        end
        handles.PlayTune = audioplayer(y,fs);
        play(handles.PlayTune);
    end
else
    rand('state',sum(100*clock));
    rn=rand;
    ii=ceil(rn*szd);
    fname=[handles.MuppetPath 'settings' filesep 'tunes' filesep d(ii).name];
    if fname(end-2:end)=='wav'
        [y,fs]=wavread(fname);
    elseif fname(end-2:end)=='mp3'
        [y,fs]=mp3read(fname);
    end
    handles.PlayTune = audioplayer(y,fs);
    play(handles.PlayTune);
end

guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PlayTunes.
function PlayTunes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PlayTunes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

d=dir([handles.MuppetPath 'settings' filesep 'tunes' filesep '*.wav']);
d2=dir([handles.MuppetPath 'settings' filesep 'tunes' filesep '*.mp3']);
szd=size(d,1);
szd2=size(d2,1);
for i=1:szd2
    d(szd+i)=d2(i);
end
szd=size(d,1);

for i=1:szd;
    Tunes{i}=d(i).name;
end

fname=ListTunes('Tunes',Tunes);
szf=size(fname);
if szf(1)>0
    fname=[handles.MuppetPath 'settings' filesep 'tunes' filesep fname];
    if isfield(handles,'PlayTune')
        a=get(handles.PlayTune,'Running');
        if strcmp(a,'on')
            stop(handles.PlayTune);
            clear handles.PlayTune;
            if fname(end-2:end)=='wav'
                [y,fs]=wavread(fname);
            elseif fname(end-2:end)=='mp3'
                [y,fs]=mp3read(fname);
            end
            handles.PlayTune = audioplayer(y,fs);
            play(handles.PlayTune);
        else
            if fname(end-2:end)=='wav'
                [y,fs]=wavread(fname);
            elseif fname(end-2:end)=='mp3'
                [y,fs]=mp3read(fname);
            end
            handles.PlayTune = audioplayer(y,fs);
            play(handles.PlayTune);
        end
    else
        if fname(end-2:end)=='wav'
            [y,fs]=wavread(fname);
        elseif fname(end-2:end)=='mp3'
            [y,fs]=mp3read(fname);
        end
        handles.PlayTune = audioplayer(y,fs);
        play(handles.PlayTune);
    end
end
guidata(hObject, handles);



% --------------------------------------------------------------------
function MenuHelpDeltaresOnline_Callback(hObject, eventdata, handles)
% hObject    handle to MenuHelpDeltaresOnline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web http://www.deltares.nl/en -browser

% --------------------------------------------------------------------
function MenuHelpAboutMuppet_Callback(hObject, eventdata, handles)
% hObject    handle to MenuHelpAboutMuppet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

AboutMuppet('Text',handles.MuppetVersion);

% --------------------------------------------------------------------
function MenuHelp_Callback(hObject, eventdata, handles)
% hObject    handle to MenuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function Mu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called






% --- Executes on selection change in SelectDecimX.
function SelectDecimX_Callback(hObject, eventdata, handles)
% hObject    handle to SelectDecimX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectDecimX contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectDecimX

i=get(hObject,'Value');
if i==1
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimX=-1;
elseif i<9
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimX=get(hObject,'Value')-2;
else
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimX=-999;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectDecimX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectDecimX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectDecimY.
function SelectDecimY_Callback(hObject, eventdata, handles)
% hObject    handle to SelectDecimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectDecimY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectDecimY

i=get(hObject,'Value');
if i==1
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimY=-1;
elseif i<9
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimY=get(hObject,'Value')-2;
else
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).DecimY=-999;
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SelectDecimY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectDecimY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in PushAddArrows.
function PushAddArrows_Callback(hObject, eventdata, handles)
% hObject    handle to PushAddArrows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot)=EditAddArrows('SubplotProperties', ...
%     handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot),'Colors',handles.DefaultColors);
% guidata(hObject, handles);

if ~isfield(handles,'EPSG')
    wb = waitbox('Reading coordinate conversion libraries ...');
    curdir=[handles.MuppetPath 'settings' filesep 'SuperTrans'];
    handles.EPSG=load([curdir filesep 'data' filesep 'EPSG.mat']);
    close(wb);
end

handles=mp_getCoordinateSystems(handles);

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.CoordinateData,handles.EPSG, ...
    'default',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.name, ...
    'defaulttype',handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.type, ...
    'type','both'); 

if ok
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.name=cs;
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.type=type;
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.nr=nr;
end

guidata(hObject, handles);


% --- Executes on selection change in SelectFigureColor.
function SelectFigureColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectFigureColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectFigureColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectFigureColor

i=get(hObject,'Value');
str=get(hObject,'String');
handles.Figure(handles.ActiveFigure).BackgroundColor=str{i};

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectFigureColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectFigureColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in SelectSubplotColor.
function SelectSubplotColor_Callback(hObject, eventdata, handles)
% hObject    handle to SelectSubplotColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SelectSubplotColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectSubplotColor

i=get(hObject,'Value');
str=get(hObject,'String');
handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).BackgroundColor=str{i};

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SelectSubplotColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectSubplotColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function MenuColors_Callback(hObject, eventdata, handles)
% hObject    handle to MenuColors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuEditColorMaps_Callback(hObject, eventdata, handles)
% hObject    handle to MenuEditColorMaps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

icl=get(handles.SelectColorMap,'Value');
clmap=handles.ColorMaps(icl).Name;

clm.Name=clmap;
clm.Space='RGB';
clm.Index=handles.ColorMaps(icl).Val(:,1);
clm.Colors=handles.ColorMaps(icl).Val(:,2:4)/255;
clm.AlternatingColors=0;
CMStructOut=md_colormap(clm);

handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ColMap=CMStructOut.Name;

handles.ColorMaps=ImportColorMaps(handles.MuppetPath);

cl=get(handles.SelectColorMap,'Value');
for m=1:size(handles.ColorMaps,2)
    colmaps{m}=handles.ColorMaps(m).Name;
    if strcmpi(colmaps{m},lower(handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).ColMap))
        cl=m;
    end
end
set(handles.SelectColorMap,'String',colmaps);
set(handles.SelectColorMap,'Value',cl);

clear clm;

guidata(hObject, handles);

% --------------------------------------------------------------------
function MenuEditDefaultColors_Callback(hObject, eventdata, handles)
% hObject    handle to MenuEditDefaultColors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.DefaultColors=EditDefaultColors('Colors',handles.DefaultColors);
handles=RefreshAll(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function MenuGenerateLayout_Callback(hObject, eventdata, handles)
% hObject    handle to GenerateLayout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ifig=handles.ActiveFigure;

[pos,handles.GenerateLayoutPositions]=GenerateLayout('pos',handles.GenerateLayoutPositions);

if pos(1,1)>0

    if handles.Figure(ifig).NrSubplots>0
        button = questdlg('Delete existing subplots?','','Cancel','No','Yes','Yes');
    end

    if ~strcmp(button,'Cancel')

        if strcmp(button,'Yes')
            for i=1:handles.Figure(ifig).NrSubplots
                handles.ActiveSubplot=1;
                handles.ActiveDatasetInSubplot=handles.Figure(ifig).Axis(handles.ActiveSubplot).Nr;
                handles=DeleteSubplot(handles);
            end
        end

        if handles.Figure(ifig).NrAnnotations>0
            i0=handles.Figure(ifig).NrSubplots-1;
            ii=handles.Figure(ifig).NrSubplots+size(pos,1);
            handles.Figure(ifig).Axis(ii)=handles.Figure(ifig).Axis(handles.Figure(ifig).NrSubplots);
        else
            i0=handles.Figure(ifig).NrSubplots;
        end

        for k=1:size(pos,1)
            i=i0+k;
            handles.Figure(ifig).Axis(i).Name=['Subplot ' num2str(i)];
            handles.Figure(ifig).Axis(i).Position=pos(k,:);
            handles.Figure(ifig).Axis(i).PlotType='unknown';
            handles.Figure(ifig).Axis=matchstruct(handles.DefaultSubplotProperties,handles.Figure(ifig).Axis,i);
            handles.Figure(ifig).Axis(i).Nr=0;
        end
        handles.ActiveSubplot=1;
        handles.ActiveDatasetInSubplot=1;
        handles.Figure(ifig).NrSubplots=handles.Figure(ifig).NrSubplots+size(pos,1);
        handles=RefreshAll(handles);

    end
    
end

guidata(hObject, handles);



% --------------------------------------------------------------------
function MenuPlotMode_Callback(hObject, eventdata, handles)
% hObject    handle to MenuPlotMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Mode=1;
set(handles.MenuMode,'Label','Plot Mode');
handles=RefreshAll(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function MenuDataProcessingMode_Callback(hObject, eventdata, handles)
% hObject    handle to MenuDataProcessingMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Mode=2;
set(handles.MenuMode,'Label','Data Processing Mode');
handles=RefreshAll(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function MenuMode_Callback(hObject, eventdata, handles)
% hObject    handle to MenuMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function MenuDummy_Callback(hObject, eventdata, handles)
% hObject    handle to MenuDummy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function MenuOptions_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuSaveFreeText_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSaveFreeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename pathname]=uiputfile('*.ann');
if pathname~=0
    FName=[pathname filename];
    SaveFreeText(handles,FName);
end

% --------------------------------------------------------------------
function MenuLdbTool_Callback(hObject, eventdata, handles)
% hObject    handle to MenuLdbTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuVirtualEarth_Callback(hObject, eventdata, handles)
% hObject    handle to MenuVirtualEarth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuCoordinateConversion_Callback(hObject, eventdata, handles)
% hObject    handle to MenuCoordinateConversion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'EPSG')
    wb = waitbox('Reading coordinate conversion libraries ...');
    curdir = fileparts(which('SuperTrans'));
    fname = fullfile(curdir,'..','data','EPSG.mat');
    if exist(fname,'file')==2
        handles.EPSG = load(fname);
    end
    fname = fullfile(curdir,'..','data','EPSG_ud.mat');
    if exist(fname,'file')==2
        sud=load(fname);
        fnames1=fieldnames(handles.EPSG);
        for i=1:length(fnames1)
            fnames2=fieldnames(handles.EPSG.(fnames1{i}));
            switch fnames1{i}
                case{'user_defined_data'}
                otherwise
                    for j=1:length(fnames2)
                        if ~isempty(sud.(fnames1{i}).(fnames2{j}))
                            nori=length(handles.EPSG.(fnames1{i}).(fnames2{j}));
                            nnew=length(sud.(fnames1{i}).(fnames2{j}));
                            for k=1:nnew
                                if iscell(handles.EPSG.(fnames1{i}).(fnames2{j}))
                                    handles.EPSG.(fnames1{i}).(fnames2{j}){nori+k}=sud.(fnames1{i}).(fnames2{j}){k};
                                else
                                    handles.EPSG.(fnames1{i}).(fnames2{j})(nori+k)=sud.(fnames1{i}).(fnames2{j})(k);
                                end
                            end
                        end
                    end
            end
        end
    end
    close(wb);
end

if exist(curdir,'dir')==7
    SuperTrans(handles.EPSG);
else
    errordlg('SuperTrans toolbox is not installed.','SuperTrans is not found','modal');
end

guidata(hObject, handles);

% --- Executes on button press in PushExportDataset.
function PushExportDataset_Callback(hObject, eventdata, handles)
% hObject    handle to PushExportDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PushProcessDataset.
function PushProcessDataset_Callback(hObject, eventdata, handles)
% hObject    handle to PushProcessDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function MenuHelpMuppetHelp_Callback(hObject, eventdata, handles)
% hObject    handle to MenuHelpMuppetHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web(['file:///' handles.MuppetPath 'settings/help/index.html'],'-browser');



% --- Executes on button press in toggleGeographic.
function toggleGeographic_Callback(hObject, eventdata, handles)
% hObject    handle to toggleGeographic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleGeographic
if get(hObject,'Value')
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.name='WGS 84';
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.type='geographic';
else
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.name='unknown';
    handles.Figure(handles.ActiveFigure).Axis(handles.ActiveSubplot).coordinateSystem.type='projected';
end
guidata(hObject, handles);

