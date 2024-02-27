function simona2dflowfm (varargin)

%simona2dflowfm: converts simona siminp file into a Unstruc input file
%                first the siminp file is converted into a D3D input file (mdf-file)
%                secondly the mdf file is converted into an mdu file and belonging attribute files
%                finally the mdf file is removed
%
%                simona2dflowfm(filewaq,filemdu)
%                   filwaq: filepath to SIMONA siminp.-file (import)
%                   filmdu: filepath to D-FLOW FM .mdu-file (export)

Gen_inf    = {'This tool converts a SIMONA siminp file into a D-Flow FM mdu file'                                  ;
              'with belonging attribute files'                                                                     ;
              ' '                                                                                                  ;
              'Credits go to Wim van Baalen for his conversion of boundary conditions'                             ;
              ' '                                                                                                  ;
              'This tool does a basic first conversion but please check carefully'                                 ;
              '(USE AT OWN RISK)'                                                                                  ;
              ' '                                                                                                  ;
              'First, the SIMINP file is converted to a temporary Delft3D-Flow mdf file'                           ;
              'Secondly, the mdf file is converted into an D-Flow FM mdu file  '                                   ;
              'Finally, the  temporary mdf file is removed'                                                        ;
              'If you want to keep the mdf file, use SIMONA2MDF and D3D2DFLOWFM seperately'                        ;
              ' '                                                                                                  ;
              'If you encounter problems, do not hesitate to contact me'                                           ;                                                                                   ;
              'Theo.vanderkaaij@deltares.nl'                                                                      };

%% set path if necessary

if ~isdeployed && any(which('setproperty'))
   addpath(genpath('..\..\..\..\..\matlab'));
end

%% Check if nesthd_path is set

if isempty (getenv_np('nesthd_path'))
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes ("Release Notes.chm")'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

%% Get filenames (either specify here or get from the argument list); Split into name and path

if isempty(varargin)
    filwaq = '..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp';
    filmdu = 'test.mdu';
else
    filwaq = varargin{1};
    filmdu = varargin{2};
end

[path_mdu,name_mdu,~            ] = fileparts([filmdu]);
name_mdu = [path_mdu filesep name_mdu];

% Temporary directory for mdf file and belonging attribute files

path_mdf = [path_mdu filesep 'TMP'];
if ~isdir(path_mdf); mkdir(path_mdf);end
name_mdf = [path_mdf filesep 'tmp.mdf'];

%% Display the general information

logo = imread([getenv_np('nesthd_path') filesep 'bin' filesep 'dflowfm.jpg']);
logo2= [getenv_np('nesthd_path') filesep 'bin' filesep 'deltares.gif'];
simona2mdf_message(Gen_inf,'Logo',logo,'Logo2',logo2,'n_sec',10,'Window','SIMONA2DFLOWFM Message','Close',true);

%% Convert the Simona siminp file to a temporary mdf file

simona2mdf (filwaq,name_mdf,'DispGen',false);

%% Convert the Delft3D-Flow mdf file to an unstruc mdu file

d3d2dflowfm (name_mdf,name_mdu,'DispGen',false);

%% Finally, delete the temporary directory

fclose all;
rmdir(path_mdf,'s');
