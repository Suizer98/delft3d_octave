function varargout = saco_ui(varargin)
% SACO_UI GUI for salinity conversion program SACO
%      SACO_UI, by itself, creates a new SACO_UI or raises the existing
%      singleton*.
%
%      H = SACO_UI returns the handle to a new SACO_UI or the handle to
%      the existing singleton*.
%
%      SACO_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SACO_UI.M with the given input arguments.
%
%      SACO_UI('Property','Value',...) creates a new SACO_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before saco_ui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to saco_ui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help saco_ui

% Last Modified by GUIDE v2.5 08-Feb-2011 15:45:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @saco_ui_OpeningFcn, ...
                   'gui_OutputFcn',  @saco_ui_OutputFcn, ...
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


% --- Executes just before saco_ui is made visible.
function saco_ui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to saco_ui (see VARARGIN)
%
% General initialisation
%
handles.saco_dir       =   getenv ('saco_path');
handles.wrkdir         =   pwd;

%
% Get default value (skip during file conversion)
%
Info              = inifile('open',[handles.saco_dir filesep 'saco.ini']);
handles.def_value = inifile('get' ,Info,'File','def_value');

PutInCentre(handles.Saco);
newico     (handles.Saco,[handles.saco_dir  'fig' filesep 'salt-icon.png']);

handles.Selection_text = {'Salinity to Density (NaCl; Millero Delft Hydraulics)  ', 'Salinity    ', 'Density         ', 1;
                          'Salinity to Density (NaCl; Franks/ Lo Surdo)          ', 'Salinity    ', 'Density         ', 2;
                          'Salinity to Density (Seawater/Unesco 1981)            ', 'Salinity    ', 'Density         ', 3;
                          'Salinity to Density (Seawater/Eckart)                 ', 'Salinity    ', 'Density         ', 4;
                          'Salinity to Density (NOAA; www.csgnetwork.com/h2odenscalc', 'Salinity    ', 'Density         ', 31;
                          'Salinity to Density (Approximation)                   ', 'Salinity    ', 'Density         ', 5;
                          'Salinity to Chlorinity (NaCl)                         ', 'Salinity    ', 'Chlorinity      ',26;
                          'Salinity to Chlorinity (Seawater)                     ', 'Salinity    ', 'Chlorinity      ',27;
                          'Salinity to Conductivity (NaCl; Labrique/Kohlraush)   ', 'Salinity    ', 'Conductivity    ',14;
                          'Salinity to Conductivity (NaCl94)                     ', 'Salinity    ', 'Conductivity    ',15;
                          'Salinity to Conductivity (NaCl; Hewitt)               ', 'Salinity    ', 'Conductivity    ',16;
                          'Salinity to Conductivity (Seawater; Unesco 1981)      ', 'Salinity    ', 'Conductivity    ',17;
                          'Chlorinity to Density (NaCl; Millero Delft Hydraulics)', 'Chlorinity  ', 'Density         ', 6;
                          'Chlorinity to Density (NaCl; Franks/ Lo Surdo)        ', 'Chlorinity  ', 'Density         ', 7;
                          'Chlorinity to Density (Seawater/Unesco 1981)          ', 'Chlorinity  ', 'Density         ', 8;
                          'Chlorinity to Salinity (NaCl)                         ', 'Chlorinity  ', 'Salinity        ',28;
                          'Chlorinity to Salinity (Seawater/Unesco 1981)         ', 'Chlorinity  ', 'Salinity        ',29;
                          'Chlorinity to Conductivity (NaCl; Labrique/Kohlraush) ', 'Chlorinity  ', 'Conductivity    ',21;
                          'Chlorinity to Conductivity (NaCl94)                   ', 'Chlorinity  ', 'Conductivity    ',22;
                          'Chlorinity to Conductivity (Seawater; Unesco 1981)    ', 'Chlorinity  ', 'Conductivity    ',23;
                          'Conductivity to Salinity (NaCl; Labrique/Kohlraush)   ', 'Conductivity', 'Salinity        ', 9;
                          'Conductivity to Salinity (NaCl94)                     ', 'Conductivity', 'Salinity        ',10;
                          'Conductivity to Salinity (NaCl; Chiu/Head)            ', 'Conductivity', 'Salinity        ',11;
                          'Conductivity to Salinity (NaCl; Hewitt)               ', 'Conductivity', 'Salinity        ',12;
                          'Conductivity to Salinity (Seawater/Unesco 1981)       ', 'Conductivity', 'Salinity        ',13;
                          'Conductivity to Density (NaCl, Labr/Kohlr/Mill/Delft) ', 'Conductivity', 'Density         ',24;
                          'Conductivity to Density (Seawater/Unesco 1981)        ', 'Conductivity', 'Density         ',25;
                          'Conductivity to Chlorinity (NaCl; Labrique/Kohlraush) ', 'Conductivity', 'Chlorinity      ',18;
                          'Conductivity to Chlorinity (NaCl94)                   ', 'Conductivity', 'Chlorinity      ',19;
                          'Conductivity to Chlorinity (Seawater/Unesco 1981)     ', 'Conductivity', 'Chlorinity      ',20;
                          'Conductivity to Cl- (RWS-NDB)                         ', 'Conductivity', 'Cl-concentr.    ',30;
                          'Conductivity to Chlorinity (EVIDES)                   ', 'Conductivity', 'Cl-concentr.    ',32};


set (handles.Selection,'String',handles.Selection_text(:,1));
set (handles.File      ,'Enable','off');

handles.formula           = 1 ;
handles.Salinity_value    = [];
handles.Temperature_value = [];
handles.Density_value     = [];

% Choose default command line output for saco_ui

handles.output         = hObject;
% Update handles structure

guidata(hObject, handles);

% UIWAIT makes saco_ui wait for user response (see UIRESUME)

% uiwait(handles.Saco);


% --- Outputs from this function are returned to the command line.
function varargout = saco_ui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Selection.
function Selection_Callback(hObject, eventdata, handles)
% hObject    handle to Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Selection

selected_formula = get(hObject,'Value');
strsal_org  = get(handles.Salinity_text,'String');
strsal_new = handles.Selection_text{selected_formula,2};
strden_new = handles.Selection_text{selected_formula,3};
if strsal_new(1:4) == 'Sali'
   sal_unit = '[psu]';
elseif strsal_new(1:4) == 'Dens'
   sal_unit = '[kg/m3]';
elseif strsal_new(1:4) == 'Chlo'
   sal_unit = '[-]';
elseif strsal_new(1:4) == 'Cond'
   sal_unit = '[mS/cm]';
end

if strden_new(1:4) == 'Sali'
   den_unit = '[psu]';
elseif strden_new(1:4) == 'Dens'
   den_unit = '[kg/m3]';
elseif strden_new(1:4) == 'Chlo'
   den_unit = '[-]';
elseif strden_new(1:4) == 'Cond'
   den_unit = '[mS/cm]';
elseif strden_new(1:4) == 'Cl-c'
   den_unit = '[kg/m3]';
end

set (handles.Salinity_text,'String',strsal_new);
set (handles.Density_text ,'String',strden_new);
set (handles.Salinity_unit,'String',sal_unit);
set (handles.Density_unit ,'String',den_unit);

handles.formula = handles.Selection_text{selected_formula,4};

if handles.formula >= 26 && handles.formula <= 29
   set(handles.Temperature_input,'Enable','off');
   set(handles.File,'Enable','on');
else
   set(handles.Temperature_input,'Enable','on');
   if isempty(handles.Temperature_value)
      set(handles.File,'Enable','off');
   end
end

if ~strcmp(strsal_org(1:8),strsal_new(1:8))
    handles.Salinity_value    = [];
    handles.Density_value     = [];
end

if ~isempty(handles.Salinity_value) && (handles.formula >= 26 && handles.formula <= 29)
   handles.Density_value = saco_convert(handles.Salinity_value,handles.formula);
elseif ~isempty(handles.Salinity_value) && ~isempty (handles.Temperature_value)
   handles.Density_value = saco_convert(handles.Salinity_value,handles.formula,handles.Temperature_value);
end

set (handles.Salinity_input     ,'String',num2str(handles.Salinity_value   ,'%9.3f'));
set (handles.Temperature_input  ,'String',num2str(handles.Temperature_value,'%9.3f'));
set (handles.Density_output     ,'String',num2str(handles.Density_value    ,'%9.3f'));

handles.selected_formula = selected_formula;

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in File.
function File_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cd (handles.wrkdir);
[fin,pin]= uigetfile({'*.tek';'*.dat'},'Select data file to open ...');
cd (handles.saco_dir);


if pin~=0
   handles.wrkdir  = pin;
   Info            = tekal('open', [pin fin]);
   [Colinfo]       = saco_get_Colinfo(Info.Field.Comments,Info.Field.Size(2));
   Selected_column = saco_select_column(Colinfo(:,1),handles.saco_dir);
   if ~isempty(Selected_column)
      Selected_column                   = Colinfo{Selected_column,2};
      val_o                             = Info.Field.Data(:,Selected_column);
      val_o(val_o == handles.def_value) = NaN;

      for irow = 1: Info.Field.Size(1)
          val_n(1,irow)       = saco_convert(val_o(irow),handles.formula,handles.Temperature_value);
      end
      
      val_n(isnan(val_n)) = handles.def_value;

      cd (handles.wrkdir);
      [fout,pout]= uiputfile({'*.tek';'*.dat'},'Select data file to write ...');
      cd (handles.saco_dir);

      if pout ~= 0
         handles.wrkdir = pout;
         addcomments{1} = sprintf ('* Column %2i: %s',size(Colinfo,1)+1 ,handles.Selection_text{handles.selected_formula,3});
         saco_write_tekal([pin fin],[pout fout],val_n,addcomments);
      end
   end
end

guidata(hObject, handles);

function Salinity_input_Callback(hObject, eventdata, handles)
% hObject    handle to Salinity_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Salinity_input as text
%        str2double(get(hObject,'String')) returns contents of Salinity_input as a double

handles.Salinity_value = str2double(get(hObject,'String'));

if ~isempty(handles.Salinity_value) && ~isempty(handles.Temperature_value)
   [handles.Density_value] = saco_convert(handles.Salinity_value,handles.formula,handles.Temperature_value);
   set (handles.Density_output,'String',num2str(handles.Density_value,'%9.3f'))
end

if ~isempty(handles.Salinity_value) && handles.formula >= 26 && handles.formula <= 29
   [handles.Density_value] = saco_convert(handles.Salinity_value,handles.formula,handles.Temperature_value);
   set (handles.Density_output,'String',num2str(handles.Density_value,'%9.3f'))
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Salinity_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Salinity_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Temperature_input_Callback(hObject, eventdata, handles)
% hObject    handle to Temperature_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Temperature_input as text
%        str2double(get(hObject,'String')) returns contents of Temperature_input as a double


handles.Temperature_value = str2double(get(hObject,'String'));
if isempty (handles.Temperature_value)
    set (handles.File,'Enable','off');
else
    set (handles.File,'Enable','on');
end

if ~isempty(handles.Salinity_value) && ~isempty(handles.Temperature_value)
   [handles.Density_value] = saco_convert(handles.Salinity_value,handles.formula,handles.Temperature_value);
   set (handles.Density_output,'String',num2str(handles.Density_value,'%9.3f'))
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Temperature_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Temperature_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Density_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Density_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
command = ['hh.exe ' [handles.saco_dir 'manual\saco.chm']];
system (command);


