%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17215 $
%$Date: 2021-04-29 13:40:02 +0800 (Thu, 29 Apr 2021) $
%$Author: chavarri $
%$Id: oh_ELV_please_run.m 17215 2021-04-29 05:40:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/source/oh_ELV_please_run.m $
%

function oh_ELV_please_run(ELV)

%% RENAME

if isfield(ELV,'OET')==0
    ELV.OET=1;
end

OET=ELV.OET;
paths_source=ELV.paths_source;
paths_runs=ELV.paths_runs;
input_filename=ELV.input_filename;
runid_serie=ELV.runid_serie;
runid_number=ELV.runid_number;
erase_previous=ELV.erase_previous;
do_profile=ELV.do_profile;
do_postprocessing=ELV.do_postprocessing;
debug_mode=ELV.debug_mode;

%% DEBUG

if debug_mode==1
    dbstop if error
else
    dbclear all
end

%% PATH DEFINITIONS

% path_source = pwd; 
paths_main              = fullfile(paths_source,'..',filesep,'main');
paths_auxiliary         = fullfile(paths_source,'..',filesep,'auxiliary');
paths_postprocessing    = fullfile(paths_source,'..',filesep,'postprocessing');
if contains(input_filename,{':','/','\'}) %crude way of determining if full path. For backward compatibility
    paths_input_script=input_filename;
else
    paths_input_script= fullfile(paths_source,input_filename);
end
paths_run_folder        = fullfile(paths_runs,runid_serie,runid_number);
paths_input_mat         = fullfile(paths_run_folder,'input.mat');

%% ERASE EVERYTHING IN THE FOLDER

if erase_previous
    time_d=5; %#ok seconds delay
    warning('off','backtrace');
    for kt=time_d:-1:0
        warning('You are going to erase the simulation %s%s in %d seconds',runid_serie,runid_number,kt);
        pause(1)
    end
    warning('on','backtrace');
    fclose all;
    dire_in=paths_run_folder;
    dire=dir(dire_in);
    for kf=3:numel(dire)
        if ispc
            if exist(fullfile(dire_in,dire(kf).name),'dir')==7
                dos(sprintf('RD /S /Q %s',fullfile(dire_in,dire(kf).name)));
            elseif exist(fullfile(dire_in,dire(kf).name),'file')
                dos(sprintf('DEL %s',fullfile(dire_in,dire(kf).name)));
            end
        elseif ismac
            error('Are you seriously using a Mac? Come on... You will have to manually erase the folder and set erase_previous to 0')
        else
            error('You will have to manually erase the folder and set erase_previous to 0')
        end
    end
end

%% CREATE FOLDER RUN

if exist(paths_run_folder,'dir')==7

else
    mkdir(paths_run_folder)
end

%% ADD PATHS

if OET    
    path_add_fcn=fullfile(paths_source,'../','../','../','vtools','general'); 
    addpath(path_add_fcn);
    addOET(path_add_fcn) 
else
    %it is self-contained. This is for the compiled option, which does not exist yet.
    
end

%paths to add if they are not already added
paths2add{1,1}=paths_main;
paths2add{2,1}=paths_run_folder;       
paths2add{3,1}=paths_auxiliary;
paths2add{4,1}=paths_postprocessing;

paths_inmatlab=regexp(path,pathsep,'split');
for kp=1:numel(paths2add)
    if ispc  % Windows is not case-sensitive
      onPath=any(strcmpi(paths2add{kp,1},paths_inmatlab));
    else
      onPath=any(strcmp(paths2add{kp,1},paths_inmatlab));
    end
    if onPath==0
        addpath(paths2add{kp,1});
    end
end

%check that OET functions are available. They are zipped in <auxiliary>
if exist('v2struct.m','file')~=2
    error('OET functions are not in path. Add them.')
end

% v2struct(ELV);

%% CREATE INPUT

run(paths_input_script);
input.run=strcat(runid_serie,runid_number); %simulation name [char]; e.g. 'L\_05'

%check before saving
if exist(paths_input_mat,'file')
    error('It seems you are trying to overwrite results. It already exist a file input.mat in the target folder')
else
    save(paths_input_mat,'input')
end

%% RUN 

if debug_mode==1
    run_ELV_debug(paths_input_mat);
else
    switch do_profile
        case 1
            paths_profile=fullfile(paths_run_folder,'profile');
            mkdir(paths_profile)
            profile on
            run_ELV(paths_input_mat);
            profile off
            profsave(profile('info'),paths_profile)
            profile viewer
        otherwise
            run_ELV(paths_input_mat);
    end
end

%% POST
if do_postprocessing
    %% patch
input_fig_input; %#ok
fig_patch(paths_run_folder,fig_input)
    %% level
input_fig_input;
fig_level(paths_run_folder,fig_input)
end