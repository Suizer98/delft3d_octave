function simon2mdf (varargin)

%simona2mdf: converts simona siminp file into a D3D-Flow master definition file (first basic version)

Gen_inf    = {'This tool converts a SIMONA siminp file into a Delft3D-Flow mdf file'                               ;
              'with belonging attribute files'                                                                     ;
              ' '                                                                                                  ;
              'Not everything is supported:'                                                                       ;
              '- Transport other than Salinity (temp. and tracers) not supported yet'                              ;
              '- Restarting is not supported yet'                                                                  ;
              '- Space varying wind is not supported yet'                                                          ;
              ' '                                                                                                  ;
              'This tool does a basic first conversion but please check carefully'                                 ;
              '(USE AT OWN RISK)'                                                                                  ;
              ' '                                                                                                  ;
              'If you encounter problems, please do not hesitate to contact me'                                    ;                                                                                   ;
              'Theo.vanderkaaij@deltares.nl'                                                                      };

%% set path if necessary

if ~isdeployed || ~any(which('setproperty'))
   oetsettings('quiet');
end

%% Display general information

OPT.DispGen     = true;
OPT.nesthd_path = getenv_np('nesthd_path');
OPT = setproperty(OPT,varargin{3:end});

%% Check if nesthd_path is set

if isempty (OPT.nesthd_path)
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes ("Release Notes.chm")'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

%% Get filenames (either specify here or get from the argument list); Split into name and path

if isempty(varargin)
    filwaq = '..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp';
    filmdf = 'test.mdf';
else
    filwaq = varargin{1};
    filmdf = varargin{2};
end

[path_waq,name_waq,extension_waq] = fileparts([filwaq]);
[path_mdf,name_mdf,~            ] = fileparts([filmdf]);
if ~isempty(path_mdf)
    if ~isdir(path_mdf) mkdir(path_mdf); end
    name_mdf = [path_mdf filesep name_mdf];
end

%% Display the general information

logo  = imread([OPT.nesthd_path filesep 'bin' filesep 'simona_logo.jpg']);
logo2 = [OPT.nesthd_path filesep 'bin' filesep 'deltares.gif'];

if OPT.DispGen
    simona2mdf_message(Gen_inf                                  ,'Logo',logo,'Logo2',logo2,'n_sec',5);
end

%% Start with creating empty template (add the simonapath to it to allow for
%  copying of the grid file)

DATA = delft3d_io_mdf('new',[OPT.nesthd_path filesep 'bin' filesep 'template_gui.mdf']);
mdf  = DATA.keywords;
if ~isempty(path_waq)
    mdf.pathsimona = path_waq;
else
    mdf.pathsimona = '.';
end
if ~isempty(path_mdf)
    mdf.pathd3d    = path_mdf;
else
    mdf.pathd3d    = '.';
end

%% Read the entire siminp and parse everything into 1 structure

S = readsiminp(path_waq,[name_waq extension_waq]);
S = all_in_one(S);


%% parse the siminp information

simona2mdf_message('Parsing AREA information'               ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_area     (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing BATHYMETRY information'         ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_bathy    (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing DRYPOINT information'           ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_dryp     (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing THINDAM information'            ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_thd      (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing WEIR information'               ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_weirs    (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing TIMES information'              ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_times    (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing PROCES information'             ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_processes(S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing PHYSICAL information'           ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_physical (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing NUMERICAL information'          ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_numerical(S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing BOUNDARY information'           ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_bnd      (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing DISCHARGE POINTS information'   ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_dis      (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing WIND information'               ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_wind     (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing INITIAL CONDITION information'  ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_initial  (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing RESTART information'            ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_restart  (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing FRICTION information'           ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_friction (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing VISCOSITY information'          ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_viscosity(S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing OBSERVATION STATION information','Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_obs      (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing CROSS-SECTION information'      ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_crs      (S,mdf,name_mdf, 'nesthd_path', OPT.nesthd_path);

simona2mdf_message('Parsing OUTPUT information'             ,'Logo',logo,'Logo2',logo2, 'nesthd_path', OPT.nesthd_path);
mdf = simona2mdf_output   (S,mdf, 'nesthd_path', OPT.nesthd_path);

%% Finally,  write the mdf file and close everything

mdf = rmfield(mdf,'pathd3d'   );
mdf = rmfield(mdf,'pathsimona');
delft3d_io_mdf('write',filmdf,mdf,'stamp',false);

simona2mdf_message('','Close',true);

