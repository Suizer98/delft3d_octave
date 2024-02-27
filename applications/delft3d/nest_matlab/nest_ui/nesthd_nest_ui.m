function varargout = nesthd_nest_ui(varargin)
% NESTHD_NEST_UI M-file for nesthd_nest_ui.fig
%      NESTHD_NEST_UI, by itself, creates a new NESTHD_NEST_UI or raises the existing
%      singleton*.
%
%      H = NESTHD_NEST_UI returns the handle to a new NESTHD_NEST_UI or the
%      handle to the existing singleton*.
%
%      NESTHD_NEST_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NESTHD_NEST_UI.M with the given input arguments.
%
%      NESTHD_NEST_UI('Property','Value',...) creates a new NESTHD_NEST_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nesthd_nest_ui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nesthd_nest_ui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nesthd_nest_ui

% Last Modified by GUIDE v2.5 29-Feb-2020 17:50:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nesthd_nest_ui_OpeningFcn, ...
                   'gui_OutputFcn',  @nesthd_nest_ui_OutputFcn, ...
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


% --- Executes just before nesthd_nest_ui is made visible.
function nesthd_nest_ui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to bg
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nesthd_nest_ui (see VARARGIN)

handles = nesthd_ini_ui(handles);

PutInCentre(handles.nest_ui);
simona2mdf_legalornot(handles.nest_ui,[getenv_np('nesthd_path') filesep 'bin' filesep 'deltares.gif']);

set (handles.bg,'Visible'   ,'On');

set_nesthd1(handles,'off');
set_nesthd2(handles,'off');

set (handles.nest_ui,'Visible','on');

handles.add_inf.t_start = NaN;
handles.add_inf.t_stop  = NaN;

% Update handles structure
guidata(hObject, handles);

% Choose default command line output for nesthd_nest_ui


% UIWAIT makes nesthd_nest_ui wait for user response (see UIRESUME)
% uiwait(handles.nesthd_nest_ui);


% --- Outputs from this function are returned to the command line.
function varargout = nesthd_nest_ui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to bg
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function bg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'Visible','off');
nesthd_dir = getenv_np ('nesthd_path');
handles.add_files         = [nesthd_dir filesep 'bin'];

axes(hObject);
fig = imread ([handles.add_files filesep 'nest_1.jpg']);
handles.bg = image(fig);
set(hObject,'DataAspectRatio',[1 1.25 1]);
set(hObject,'YTick'          ,[]        );

% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.

% --- Executes on button press in run_nesthd1.
function run_nesthd1_Callback(hObject, eventdata, handles)
% hObject    handle to run_nesthd1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nesthd_nesthd1(handles.files_hd1);

% --- Executes on button press in run_nesthd2.
function run_nesthd2_Callback(hObject, eventdata, handles)
% hObject    handle to run_nesthd2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nesthd_nesthd2 (handles.files_hd2,handles.add_inf);

% --------------------------------------------------------------------
function Nesthd1_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Nesthd1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.bg,'Visible','off');
set(get(handles.bg,'parent'),'Visible','off');

handles.files_hd1         = {'' '' '' '' '' ''};

set_nesthd1(handles,'on');
set_nesthd2(handles,'off');

guidata (hObject,handles);

% --------------------------------------------------------------------
function Nesthd2_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Nesthd2_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.files_hd2         = {'' '' '' '' ''};

handles.bcc_onoff          = 'off';
handles.run_nesthd2_onoff  = 'off';

set(handles.bg,'Visible','off');
set(get(handles.bg,'parent'),'Visible','off');
set_nesthd1(handles,'off');
set_nesthd2(handles,'on');
add_inf_off (handles);

guidata(hObject,handles);

% --------------------------------------------------------------------
function open_session_Callback(hObject, eventdata, handles)
% hObject    handle to open_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = nesthd_read_ini(handles);

if isfield(handles,'active')

   set(handles.bg,'Visible','off');
   set(get(handles.bg,'parent'),'Visible','off');

   if strcmpi(handles.active,'Nesthd1')
      handles = nesthd_check_nesthd1(handles);
      set_nesthd2(handles,'off');
      set_nesthd1(handles,'on' );
   else
      handles = nesthd_check_nesthd2(handles);
      set_nesthd1(handles,'off');
      set_nesthd2(handles,'on' );
      update_additional(handles);
   end
end

guidata(hObject,handles);

% --------------------------------------------------------------------
function save_session_Callback(hObject, eventdata, handles)
% hObject    handle to save_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --------------------------------------------------------------------

handles = nesthd_write_ini(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function simona2mdf_Callback(hObject, eventdata, handles)
% hObject    handle to simona2mdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
% First get the name of the simona input file
%

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uigetfile({'siminp*'},'Select WAQUA/TRIWAQ input file');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   file_simona     = [pin fin];

   %
   % Get the name of the output mdf file
   %

   cd(handles.filedir);
   [fin,pin] = uiputfile({'*.mdf'},'Give name of mdf file');
   cd (handles.progdir);
   if fin ~= 0
       handles.filedir = pin;
       file_mdf = [pin fin];

       %
       % Convert
       %

       simona2mdf(file_simona,file_mdf);
   end
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function Simona2dflowfm_Callback(hObject, eventdata, handles)
% hObject    handle to Simona2dflowfm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% First get the name of the simona input file
%

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uigetfile({'siminp*'},'Select WAQUA/TRIWAQ input file');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   file_simona     = [pin fin];

   %
   % Get the name of the output mdu file
   %

   cd(handles.filedir);
   [fin,pin] = uiputfile({'*.mdu'},'Give name of dflowfm input file');
   cd (handles.progdir);
   if fin ~= 0
       handles.filedir = pin;
       file_mdu = [pin fin];

       %
       % Convert
       %

       simona2dflowfm(file_simona,file_mdu);
   end
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function d3d2dflowfm_Callback(hObject, eventdata, handles)
% hObject    handle to d3d2dflowfm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% First get the name of the d3d    input file
%

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uigetfile({'*.mdf'},'Select d3d input file');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   file_mdf        = [pin fin];

   %
   % Get the name of the output mdu file
   %

   cd(handles.filedir);
   [fin,pin] = uiputfile({'*.mdu'},'Give name of dflowfm input file');
   cd (handles.progdir);
   if fin ~= 0
       handles.filedir = pin;
       file_mdu = [pin fin];

       %
       % Convert
       %

       d3d2dflowfm(file_mdf,file_mdu);
   end
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function manual_d3d_Callback(hObject, eventdata, handles)
% hObject    handle to manual_d3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

d3d_home = getenv('D3D_Home');
if strcmp(d3d_home(end),filesep)
    file_man = [d3d_home 'manuals' filesep 'Delft3D-Flow_User_Manual.pdf'];
else
    file_man = [d3d_home filesep 'manuals' filesep 'Delft3D-Flow_User_Manual.pdf'];
end

if exist(file_man,'file')
   open(file_man);
else
   errordlg({'User manual not found';' ';'Either the D3D_Home environment variable is not set, or,';'Manuals are not installed'},'Nesthd Error');
end

% --------------------------------------------------------------------
function Manual_wh_Callback(hObject, eventdata, handles)
% hObject    handle to Manual_wh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

systemroot = getenv('systemroot');
if exist([systemroot filesep 'hh.exe'],'file')
    nesthd_path = getenv_np ('nesthd_path');
    command = [systemroot filesep 'hh.exe ' nesthd_path filesep 'nestHD.chm'];
    system (command);
end


% --------------------------------------------------------------------
function release_notes_Callback(hObject, eventdata, handles)
% hObject    handle to release_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

systemroot = getenv('systemroot');
if exist([systemroot filesep 'hh.exe'],'file')
    nesthd_path = getenv_np ('nesthd_path');
    command = [systemroot filesep 'hh.exe ' nesthd_path filesep 'Release Notes.chm'];
    system (command);
end


% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.nest_ui);


% --- Executes on button press in get_hd1_grid_big.
function get_hd1_grid_big_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd1_grid_big (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uigetfile({'*.grd;*rgf*;*mdf*;*map.nc;*.nc'},'Select grid file overall model');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd1{1} = nesthd_get_gridname([pin fin]);

   set (handles.name_hd1_grd_big,'String',nesthd_strippath(handles.files_hd1{1}),'FontSize',14,'Enable','on','HorizontalAlignment','left');
   handles = nesthd_check_nesthd1(handles);
   set_nesthd1(handles,'on' );
end

guidata(hObject, handles);

% --- Executes on button press in get_hd1_grid_small.
function get_hd1_grid_small_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd1_grid_small (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uigetfile({'*.grd;*rgf*;*mdf*;siminp*;*map.nc;*net.nc'},'Select grid file nested model');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd1{2} = nesthd_get_gridname([pin fin]);
   filename = nesthd_get_bndname ([pin fin]);
   if ~isempty(filename)
       handles.files_hd1{3} = filename;
   end
   set (handles.name_hd1_grd_small,'String',nesthd_strippath(handles.files_hd1{2}),'FontSize',14,'Enable','on','HorizontalAlignment','left');
   set (handles.name_hd1_bnd,'String',nesthd_strippath(handles.files_hd1{3}),'FontSize',14,'Enable','on','HorizontalAlignment','left');
   handles = nesthd_check_nesthd1(handles);
   set_nesthd1(handles,'on' );
end

guidata(hObject, handles);

% --- Executes on button press in get_hd1_enclosure.
function get_hd1_enclosure_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd1_enclosure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
selection = '';
modelType = EHY_getModelType(handles.files_hd1{2});
switch modelType
    case {'d3d' 'simona'}
        selection = {'*.enc;comgrid*'};
    case 'dfm'
        selection = '';
end
[fin,pin] = uigetfile(selection,'Select enclosure file detailled model');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd1{6} = [pin fin];

   set (handles.name_hd1_enclosure,'String',nesthd_strippath(handles.files_hd1{6}),'FontSize',14,'HorizontalAlignment','left');
   set_nesthd1(handles,'on' );
end

guidata(hObject, handles);


% --- Executes on button press in get_hd1_bnd.
function get_hd1_bnd_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd1_bnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
selection = {'*.bnd;*.mdf;siminp*;*.mdu;*.pli;*.ext'};
if ~isempty(handles.files_hd1{2});
     modelType = EHY_getModelType(handles.files_hd1{2});
     switch modelType
         case {'d3d' 'simona'}
             selection = {'*.bnd;*.mdf;siminp*'};
         case 'dfm'
             selection = {'*.mdu;*.pli;*.ext'};
     end
end
[fin,pin] = uigetfile(selection,'Select Boundary definition nested model');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   filename = nesthd_get_gridname([pin fin]);
   if ~isempty(filename);
       handles.files_hd1{2} = filename;
   end
   handles.files_hd1{3} = nesthd_get_bndname ([pin fin]);
   set (handles.name_hd1_grd_small,'String',nesthd_strippath(handles.files_hd1{2}),'FontSize',14,'Enable','on','HorizontalAlignment','left');
   set (handles.name_hd1_bnd,'String',nesthd_strippath(handles.files_hd1{3}),'FontSize',14,'Enable','on','HorizontalAlignment','left');
   handles = nesthd_check_nesthd1(handles);
   set_nesthd1(handles,'on' );
end

guidata(hObject, handles);


% --- Executes on button press in get_hd1_obs.
function get_hd1_obs_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd1_obs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
selection = {'*.obs;points*;*.xyn'};
if ~isempty (handles.files_hd1{1});
    modelType = EHY_getModelType(handles.files_hd1{1});
    switch modelType
        case {'d3d' 'simona'}
             selection = {'*.obs;points*'};
        case 'dfm'
             selection = {'*.xyn'};
    end
end
[fin,pin] = uiputfile(selection,'Specify name of the file with the nesting stations');

%% uiputfile by default puts  ".obs" to the file name. I do not want that for SIMONA files. Remove the extennsion if a name starts with points
if length(fin) > 5 && strcmpi(fin(1:6),'points')
    [~,fin,~] = fileparts(fin);
end

cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd1{4} = [pin fin];
   set (handles.name_hd1_obs,'String',fin,'FontSize',14,'Enable','on','HorizontalAlignment','left');
   handles = nesthd_check_nesthd1(handles);
   set_nesthd1(handles,'on' );
end

guidata(hObject, handles);


% --- Executes on button press in get_hd1_adm.
function get_hd1_adm_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd1_adm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uiputfile('*.adm','Specify name of the nesting administration file');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd1{5} = [pin fin];
   set (handles.name_hd1_adm,'String',fin,'FontSize',14,'Enable','on','HorizontalAlignment','left');
   handles = nesthd_check_nesthd1(handles);
   set_nesthd1(handles,'on' );
end

guidata(hObject, handles);

% --- Executes on button press in get_hd2_bnd.
function get_hd2_bnd_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd2_bnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.files_hd2{1})
    handles.files_hd2         = {'' '' '' '' ''};
    set (handles.name_hd2_bnd      ,'String',handles.files_hd2{1});
    set (handles.name_hd2_adm      ,'String',handles.files_hd2{2});
    set (handles.name_hd2_trih     ,'String',handles.files_hd2{3});
    set (handles.name_hd2_bct      ,'String',handles.files_hd2{4});
    set (handles.name_hd2_bcc      ,'String',handles.files_hd2{5});
    handles.bcc_onoff          = 'off';
    handles.run_nesthd2_onoff  = 'off';
    set_nesthd1(handles,'off');
    set_nesthd2(handles,'on');
    add_inf_off (handles);
end

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uigetfile({'*.bnd; *.mdf; siminp*; *.pli; *.ext; *.mdu'},'Select boundary definition nested model');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd2{1} = nesthd_get_bndname ([pin fin]);
   set (handles.name_hd2_bnd,'String',nesthd_strippath(handles.files_hd2{1}),'FontSize',14,'Enable','on','HorizontalAlignment','left');
end

if ~isempty(handles.files_hd2{3}) && ~isempty(handles.files_hd2{1})
    add_inf_off(handles);
    [handles] = nesthd_set_add_inf(handles);
    if isempty(handles.bnd)
        handles.name_hd2{1} = '';
        set (handles.name_hd2_bnd,'String',nesthd_strippath(handles.files_hd2{1}),'FontSize',14,'Enable','on','HorizontalAlignment','left');
    else
        update_additional(handles);
    end
end

[handles] = nesthd_check_nesthd2(handles);
set_nesthd2(handles,'on');

guidata(hObject, handles);


% --- Executes on button press in get_hd2_adm.
function get_hd2_adm_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd2_adm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uigetfile('*.adm','Select nesting administration file');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd2{2} = [pin fin];
   set (handles.name_hd2_adm,'String',fin,'FontSize',14,'Enable','on','HorizontalAlignment','left');
   [handles] = nesthd_check_nesthd2(handles);
   set_nesthd2(handles,'on');
end

guidata(hObject, handles);


% --- Executes on button press in get_hd2_trih.
function get_hd2_trih_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd2_trih (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uigetfile({'trih*.dat; SDS*; *.nc', 'History result files (trih*, SDS*, *.nc)'},'Select result history file overall model simulation');
cd (handles.progdir);

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd2{3} = [pin fin];
   set (handles.name_hd2_trih,'String',fin,'FontSize',14,'Enable','on','HorizontalAlignment','left');
   handles.nfs_inf = nesthd_geninf([pin fin]);
   handles.add_inf.t_start = handles.nfs_inf.times(1  );
   handles.add_inf.t_stop  = handles.nfs_inf.times(end);
end

if ~isempty(handles.files_hd2{3}) && ~isempty(handles.files_hd2{1})
    add_inf_off(handles);
    [handles] = nesthd_set_add_inf(handles);
    if isempty(handles.bnd)
        handles.files_hd2{1} = '';
        set (handles.name_hd2_bnd,'String',nesthd_strippath(handles.files_hd2{1}),'FontSize',14,'Enable','on','HorizontalAlignment','left');
    else
        update_additional(handles);
    end
end

[handles] = nesthd_check_nesthd2(handles);
set_nesthd2(handles,'on');

guidata(hObject, handles);

% --- Executes on button press in get_hd2_bct.
function get_hd2_bct_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd2_bct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uiputfile('*.bct; timeser*; *.tim; *.bc','Specify file name hydrodynamic boundary conditions');
cd (handles.progdir);

if length(fin) >= 7
    if strcmpi(fin(1:7),'timeser')
    [~,fin,~] = fileparts(fin);
    end
end

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd2{4} = [pin fin];
   set (handles.name_hd2_bct,'String',fin,'FontSize',14,'Enable','on','HorizontalAlignment','left');
   [handles] = nesthd_check_nesthd2(handles);
   set_nesthd2(handles,'on');
end

guidata(hObject, handles);

% --- Executes on button press in get_hd2_bcc.
function get_hd2_bcc_Callback(hObject, eventdata, handles)
% hObject    handle to get_hd2_bcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty (handles.filedir); cd(handles.filedir); end
[fin,pin] = uiputfile('*.bc; *.bcc; timeser*','Specify file name transport boundary conditions');
cd (handles.progdir);

if length(fin) >= 7
    if strcmpi(fin(1:7),'timeser')
        [~,fin,~] = fileparts(fin);
    end
end

if fin ~= 0
   handles.filedir = pin;
   handles.files_hd2{5} = [pin fin];
   set (handles.name_hd2_bcc,'String',fin,'FontSize',14,'Enable','on','HorizontalAlignment','left');
   [handles] = nesthd_check_nesthd2(handles);
   set_nesthd2(handles,'on');
end

guidata(hObject, handles);

function timeZone_value_Callback(hObject, eventdata, handles)
% hObject    handle to timeZone_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeZone_value as text
%        str2double(get(hObject,'String')) returns contents of timeZone_value as a double

handles.add_inf.timeZone = str2num(get(hObject,'String'));
update_additional(handles);

% Update handles structure
guidata(hObject, handles);

function t_start_value_Callback(hObject, eventdata, handles)
% hObject    handle to t_start_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_start_value as text
%        str2double(get(hObject,'String')) returns contents of t_start_value as a double
org_time = handles.add_inf.t_start;
try
    handles.add_inf.t_start = datenum(get(hObject,'String'),'yyyymmdd  HHMMSS');
catch
    handles.add_inf.t_start = org_time;
end

update_additional(handles);

guidata(hObject, handles);

function t_stop_value_Callback(hObject, eventdata, handles)
% hObject    handle to t_stop_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_stop_value as text
%        str2double(get(hObject,'String')) returns contents of t_stop_value as a double
org_time = handles.add_inf.t_stop;
try
    handles.add_inf.t_stop = datenum(get(hObject,'String'),'yyyymmdd  HHMMSS');
catch
    handles.add_inf.t_stop = org_time;
end

update_additional(handles);

guidata(hObject, handles);

function a0_value_Callback(hObject, eventdata, handles)
% hObject    handle to a0_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a0_value as text
%        str2double(get(hObject,'String')) returns contents of a0_value as a double

handles.add_inf.a0 = str2num(get(hObject,'String'));
update_additional(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in vel_uniform.
function vel_uniform_Callback(hObject, eventdata, handles)
% hObject    handle to vel_uniform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vel_uniform

handles.add_inf.profile = 'uniform';
update_additional(handles);

guidata(hObject, handles);

% --- Executes on button press in vel_logarithmic.
function vel_logarithmic_Callback(hObject, eventdata, handles)
% hObject    handle to vel_logarithmic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vel_logarithmic

handles.add_inf.profile = 'logarithmic';
update_additional(handles);

guidata(hObject, handles);


% --- Executes on button press in vel_3dprofile.
function vel_3dprofile_Callback(hObject, eventdata, handles)
% hObject    handle to vel_3dprofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of vel_3dprofile

handles.add_inf.profile = '3d-profile';
update_additional(handles);

guidata(hObject, handles);

% --- Executes on selection change in list_conc.
function list_conc_Callback(hObject, eventdata, handles)
% hObject    handle to list_conc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list_conc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_conc

handles.l_act = get(hObject,'Value');

update_additional(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function list_conc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_conc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white bg on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bc_yes.
function bc_yes_Callback(hObject, eventdata, handles)
% hObject    handle to bc_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bc_yes

handles.add_inf.genconc(handles.l_act) = true;
update_additional(handles);

handles = nesthd_check_nesthd2(handles);
set_nesthd2(handles,'on');

guidata(hObject, handles);

% --- Executes on button press in bc_no.
function bc_no_Callback(hObject, eventdata, handles)
% hObject    handle to bc_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bc_no

handles.add_inf.genconc(handles.l_act) = false;
update_additional(handles);

handles = nesthd_check_nesthd2(handles);
set_nesthd2(handles,'on');

guidata(hObject, handles);

function add_conc_val_Callback(hObject, eventdata, handles)
% hObject    handle to add_conc_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of add_conc_val as text
%        str2double(get(hObject,'String')) returns contents of add_conc_val as a double

handles.add_inf.add(handles.l_act) = str2double(get(hObject,'String'));
update_additional(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function add_conc_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to add_conc_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function max_conc_val_Callback(hObject, eventdata, handles)
% hObject    handle to max_conc_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_conc_val as text
%        str2double(get(hObject,'String')) returns contents of max_conc_val as a double

handles.add_inf.max(handles.l_act) = str2double(get(hObject,'String'));
update_additional(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function max_conc_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_conc_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function min_conc_val_Callback(hObject, eventdata, handles)
% hObject    handle to min_conc_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_conc_val as text
%        str2double(get(hObject,'String')) returns contents of min_conc_val as a double

handles.add_inf.min(handles.l_act) = str2double(get(hObject,'String'));
update_additional(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function min_conc_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_conc_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function set_nesthd1(handles,onoff)

%
% Set subsystem on or off
%

set (handles.get_hd1_grid_big   ,'Enable', onoff);
set (handles.get_hd1_grid_small ,'Enable', onoff);
set (handles.get_hd1_bnd        ,'Enable', onoff);
set (handles.get_hd1_enclosure  ,'Enable', onoff);
set (handles.get_hd1_obs        ,'Enable', onoff);
set (handles.get_hd1_adm        ,'Enable', onoff);
set (handles.run_nesthd1        ,'Enable' ,handles.run_nesthd1_onoff);
set (handles.files_nesthd1      ,'Visible',onoff);
set (handles.get_hd1_grid_big   ,'Visible',onoff);
set (handles.get_hd1_grid_small ,'Visible',onoff);
set (handles.get_hd1_bnd        ,'Visible',onoff);
set (handles.get_hd1_enclosure  ,'Visible',onoff);
set (handles.get_hd1_obs        ,'Visible',onoff);
set (handles.get_hd1_adm        ,'Visible',onoff);
set (handles.name_hd1_grd_big   ,'Visible',onoff);
set (handles.name_hd1_grd_small ,'Visible',onoff);
set (handles.name_hd1_enclosure ,'Visible',onoff);
set (handles.name_hd1_bnd       ,'Visible',onoff);
set (handles.name_hd1_obs       ,'Visible',onoff);
set (handles.name_hd1_adm       ,'Visible',onoff);
set (handles.run_nesthd1        ,'Visible',onoff);
set (handles.additional         ,'Visible','off');

set (handles.name_hd1_grd_big  ,'String',nesthd_strippath(handles.files_hd1{1}),'FontSize',14,'HorizontalAlignment','left');
set (handles.name_hd1_grd_small,'String',nesthd_strippath(handles.files_hd1{2}),'FontSize',14,'HorizontalAlignment','left');
set (handles.name_hd1_enclosure,'String',nesthd_strippath(handles.files_hd1{6}),'FontSize',14,'HorizontalAlignment','left');
set (handles.name_hd1_bnd      ,'String',nesthd_strippath(handles.files_hd1{3}),'FontSize',14,'HorizontalAlignment','left');
set (handles.name_hd1_obs      ,'String',nesthd_strippath(handles.files_hd1{4}),'FontSize',14,'HorizontalAlignment','left');
set (handles.name_hd1_adm      ,'String',nesthd_strippath(handles.files_hd1{5}),'FontSize',14,'HorizontalAlignment','left');

function set_nesthd2(handles,onoff)

%
% Set subsystem on or off
%

set (handles.get_hd2_bnd        ,'Enable', onoff);
set (handles.get_hd2_adm        ,'Enable', onoff);
set (handles.get_hd2_trih       ,'Enable', onoff);
set (handles.get_hd2_bct        ,'Enable', onoff);
set (handles.get_hd2_bcc        ,'Enable', handles.bcc_onoff);
set (handles.run_nesthd2        ,'Enable' ,handles.run_nesthd2_onoff);
set (handles.files_nesthd2      ,'Visible',onoff);
set (handles.get_hd2_bnd        ,'Visible',onoff);
set (handles.get_hd2_adm        ,'Visible',onoff);
set (handles.get_hd2_trih       ,'Visible',onoff);
set (handles.get_hd2_bct        ,'Visible',onoff);
set (handles.get_hd2_bcc        ,'Visible',onoff);
set (handles.name_hd2_bnd       ,'Visible',onoff);
set (handles.name_hd2_adm       ,'Visible',onoff);
set (handles.name_hd2_trih      ,'Visible',onoff);
set (handles.name_hd2_bct       ,'Visible',onoff);
set (handles.name_hd2_bcc       ,'Visible',onoff);
set (handles.run_nesthd2        ,'Visible',onoff);
set (handles.additional         ,'Visible',onoff);

set (handles.name_hd2_bnd      ,'String',nesthd_strippath(handles.files_hd2{1}),'FontSize',14,'HorizontalAlignment','left');
set (handles.name_hd2_adm      ,'String',nesthd_strippath(handles.files_hd2{2}),'FontSize',14,'HorizontalAlignment','left');
set (handles.name_hd2_trih     ,'String',nesthd_strippath(handles.files_hd2{3}),'FontSize',14,'HorizontalAlignment','left');
set (handles.name_hd2_bct      ,'String',nesthd_strippath(handles.files_hd2{4}),'FontSize',14,'HorizontalAlignment','left');
set (handles.name_hd2_bcc      ,'String',nesthd_strippath(handles.files_hd2{5}),'FontSize',14,'HorizontalAlignment','left');

function add_inf_off(handles)

set (handles.timeZone       ,'Visible','off');
set (handles.timeZone_value ,'Visible','off');

set (handles.t_start        ,'Visible','off');
set (handles.t_start_value  ,'Visible','off');
set (handles.t_stop         ,'Visible','off');
set (handles.t_stop_value   ,'Visible','off');

set (handles.a0             ,'Visible','off');
set (handles.a0_value       ,'Visible','off');

set (handles.vel_profile    ,'Visible','off');
set (handles.vel_uniform    ,'Visible','off');
set (handles.vel_uniform    ,'Visible','off');
set (handles.vel_logarithmic,'Visible','off');
set (handles.vel_3dprofile  ,'Visible','off');

set (handles.text_transport ,'Visible','off');
set (handles.list_conc      ,'Visible','off');
set (handles.gen_bc         ,'Visible','off');
set (handles.bc_yes         ,'Visible','off');
set (handles.bc_no          ,'Visible','off');
set (handles.add_conc       ,'Visible','off');
set (handles.add_conc_val   ,'Visible','off');
set (handles.max_conc       ,'Visible','off');
set (handles.max_conc_val   ,'Visible','off');
set (handles.min_conc       ,'Visible','off');
set (handles.min_conc_val   ,'Visible','off');

function update_additional(handles)

    %
    % Update additional water level information
    %
    if handles.wlev || handles.vel || handles.conc
        set (handles.timeZone      ,'Visible','on','Enable','on');
        set (handles.timeZone_value,'Visible','on','Enable','on','String',num2str(handles.add_inf.timeZone),'HorizontalAlignment','right');
        if ~isnan(handles.add_inf.t_start)
            set (handles.t_start       ,'Visible','on','Enable','on');
            set (handles.t_start_value ,'Visible','on','Enable','on','String',datestr(handles.add_inf.t_start,'yyyymmdd  HHMMSS'),'HorizontalAlignment','right');
        end
        if ~isnan(handles.add_inf.t_stop)
            set (handles.t_stop        ,'Visible','on','Enable','on');
            set (handles.t_stop_value  ,'Visible','on','Enable','on','String',datestr(handles.add_inf.t_stop,'yyyymmdd  HHMMSS'),'HorizontalAlignment','right');
        end
   end

    if handles.wlev
       set (handles.a0,'Visible','on','Enable','on');
       set (handles.a0_value,'Visible','on','Enable','on','String',num2str(handles.add_inf.a0),'HorizontalAlignment','right');
    end

    %
    % Update additional velocity profile information
    %

    if handles.vel || (handles.conc && sum(handles.add_inf.genconc) > 0)
        set (handles.vel_profile,'Visible','on','Enable','on')
        set (handles.vel_uniform,'Visible','on','Enable','on');
        if handles.nfs_inf.kmax > 1
            set (handles.vel_logarithmic,'Enable','on','Visible','on');
            set (handles.vel_3dprofile  ,'Enable','on','Visible','on');
        end
        switch handles.add_inf.profile
            case 'uniform'
                set (handles.vel_uniform    ,'Value',1);
                set (handles.vel_logarithmic,'Value',0);
                set (handles.vel_3dprofile  ,'Value',0);
            case 'logarithmic'
                set (handles.vel_uniform    ,'Value',0);
                set (handles.vel_logarithmic,'Value',1);
                set (handles.vel_3dprofile  ,'Value',0);
            case '3d-profile'
                set (handles.vel_uniform    ,'Value',0);
                set (handles.vel_logarithmic,'Value',0);
                set (handles.vel_3dprofile  ,'Value',1);
        end

    else
        set (handles.vel_profile    ,'Visible','off');
        set (handles.vel_uniform    ,'Visible','off');
        set (handles.vel_logarithmic,'Visible','off');
        set (handles.vel_3dprofile  ,'Visible','off');
    end


    %
    % Update additional transport information
    %

    if handles.conc
        set (handles.text_transport,'Enable','on','Visible','on');
        set (handles.list_conc     ,'Enable','on','Visible','on','String',handles.nfs_inf.namcon,'Value',handles.l_act);
        if handles.add_inf.genconc(handles.l_act)
           set (handles.gen_bc        ,'Enable','on','Visible','on','String',['Generate boundary conditions for ' handles.nfs_inf.namcon{handles.l_act}]);
           set (handles.add_conc      ,'Enable','on','Visible','on','String',['Add to ' handles.nfs_inf.namcon{handles.l_act}]);
           set (handles.add_conc_val  ,'Enable','on','Visible','on','String',num2str(handles.add_inf.add(handles.l_act)),'HorizontalAlignment','right');
           set (handles.min_conc      ,'Enable','on','Visible','on','String',['Minimum value of ' handles.nfs_inf.namcon{handles.l_act}]);
           set (handles.min_conc_val  ,'Enable','on','Visible','on','String',num2str(handles.add_inf.min(handles.l_act)),'HorizontalAlignment','right');
           set (handles.max_conc      ,'Enable','on','Visible','on','String',['Maximum value of ' handles.nfs_inf.namcon{handles.l_act}]);
           set (handles.max_conc_val  ,'Enable','on','Visible','on','String',num2str(handles.add_inf.max(handles.l_act)),'HorizontalAlignment','right');
           set (handles.bc_yes        ,'Enable','on','Visible','on','Value',1);
           set (handles.bc_no         ,'Enable','on','Visible','on','Value',0);
        else
           set (handles.gen_bc        ,'Enable','on' ,'Visible','on','String',['Generate boundary conditions for ' handles.nfs_inf.namcon{handles.l_act}]);
           set (handles.add_conc      ,'Enable','off','Visible','on','String',['Add to ' handles.nfs_inf.namcon{handles.l_act}]);
           set (handles.add_conc_val  ,'Enable','off','Visible','on','String',num2str(handles.add_inf.add(handles.l_act)),'HorizontalAlignment','right');
           set (handles.min_conc      ,'Enable','off','Visible','on','String',['Minimum value of ' handles.nfs_inf.namcon{handles.l_act}]);
           set (handles.min_conc_val  ,'Enable','off','Visible','on','String',num2str(handles.add_inf.min(handles.l_act)),'HorizontalAlignment','right');
           set (handles.max_conc      ,'Enable','off','Visible','on','String',['Maximum value of ' handles.nfs_inf.namcon{handles.l_act}]);
           set (handles.max_conc_val  ,'Enable','off','Visible','on','String',num2str(handles.add_inf.max(handles.l_act)),'HorizontalAlignment','right');
           set (handles.bc_yes        ,'Enable','on' ,'Visible','on','Value',0);
           set (handles.bc_no         ,'Enable','on' ,'Visible','on','Value',1);
        end
    end

