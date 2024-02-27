%run in the folder where the script is

%% PREAMBLE

restoredefaultpath
fclose all;
clear all; %#ok we have to clear all because of the paths to the scripts
close all;
clc;

% dbstop if error
% dbclear all

%% INPUT 
%Folders are not automatically created!

% runid_number={'001','002','003','004','005','006','007','008','009','010','011','012','013'};
runid_number={'007','008','009','010'};
% runid_number={'009','010'};
paths_runs_1='c:\Users\victorchavarri\temporal\ELV\test\'; %containing the folder with this test (..\)
do_profile=0; %0=NO; 1=YES
    
%%  %%  %%
  %%  %%       DO NOT TOUCH FROM HERE ON
%%  %%  %%    

%% PATH DEFINITION

source_path = pwd; 
paths_main = fullfile(source_path, '..\main');
paths_auxiliary = fullfile(source_path, '..\auxiliary');
paths_postprocessing = fullfile(source_path, '..\postprocessing');
paths_test = fullfile(source_path, '..\test');

%% CREATE MAIN FOLDER

runid_serie=sprintf('%11.5f',now);
mkdir(paths_runs_1,runid_serie);
paths_runs=fullfile(paths_runs_1,runid_serie);

%% CREATE LOG

paths_log=fullfile(paths_runs,'log_test.txt');
fid_log=fopen(paths_log,'w');
fprintf(fid_log,'-------------- \n ELV TEST BANK \n-------------- \n');
fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'Start of test');

%% LOOP ON SIMULATIONS

nr=numel(runid_number);
equal_bol_t=NaN(nr,1);
try
for kr=1:nr

%% CREATE RUN FOLDER

mkdir(paths_runs,runid_number{kr});
paths_run_folder=fullfile(paths_runs,runid_number{kr});

%% ADD PATHS

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

%% CREATE INPUT

%paths
paths_input_script=fullfile(paths_test,'reference',runid_number{kr},'input_ELV.m'); %path to the reference input script
paths_output_mat_ref=fullfile(paths_test,'reference',runid_number{kr},'output.mat'); %path to the reference output mat
paths_ref_folder=fullfile(paths_test,'reference',runid_number{kr}); %path to the reference directory
paths_input_mat=fullfile(paths_run_folder,'input.mat'); %path to the new input mat
paths_output_mat=fullfile(paths_run_folder,'output.mat'); %path to the new output mat

%input creation
clear input
run(paths_input_script); %create input from reference values
input.mdv.path_file_output=paths_output_mat; %update path to the output file 
input.run=strcat(runid_serie,'_',runid_number{kr}); %simulation name [char]; e.g. 'L\_05'
save(paths_input_mat,'input') %save input
    %copy all other files in the folder
dire_ref=dir(paths_ref_folder);
nfd=numel(dire_ref);
for kf=3:nfd
    [~,tmp_name,tmp_ext]=fileparts(dire_ref(kf).name);
    if strcmp(tmp_ext,'.mat') && ~strcmp(tmp_name,'input') && ~strcmp(tmp_name,'output') 
        tmp_ref=fullfile(paths_ref_folder,dire_ref(kf).name);
        tmp_new=fullfile(paths_run_folder,dire_ref(kf).name);
        copyfile(tmp_ref,tmp_new);
    end
end

%% RUN

switch do_profile
    case 1
        paths_profile=fullfile(paths_run_folder,'profile');
        mkdir(paths_profile)
        profile on
        run_ELV_debug(paths_input_mat);
        profile off
        profsave(profile('info'),paths_profile)
        profile viewer
    otherwise
        run_ELV_debug(paths_input_mat);
end

%% POST
    %% patch
% input_fig_input;
% fig_patch(paths_run,fig_input)
    %% level
% input_fig_input;
% fig_level(paths_run,fig_input)

%% COMPARE

% var={'u','h','etab','Mak','La','msk','Ls','qbk','Cf','ell_idx'}; %variables name to output (do not use input.output_var if time_loop is stored) 
var={'u','h','etab','Mak','La','msk','Ls','qbk'}; %variables name to output (do not use input.output_var if time_loop is stored) 
[equal_bol_t(kr),equal_bol,dif_idx,dif_res,dif_max,diff_time,diff_time_rel]=compare_results(paths_output_mat,paths_output_mat_ref,var);

if equal_bol_t(kr)
    fprintf(fid_log,'ATTENTION!!! problem in Simulation %s \n',runid_number{kr});
    for kv=1:numel(var)
        fprintf(fid_log,'Maximum absolute difference in %s equal to %e \n',var{1,kv},dif_max(kv,1));
    end
else
    fprintf(fid_log,'Simulation %s is unchanged \n',runid_number{kr});
    fprintf(fid_log,'The new simulation was %f s faster than the reference one (%f %%) \n',-diff_time,-diff_time_rel*100);
end
fprintf(fid_log,'%s %s %s\n',datestr(datetime('now')),'End of simulation ',runid_number{kr});

end %kr 

fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of test');
fclose(fid_log);

%display in screen
% 0 is good, 1 means somethign has changed
if any(equal_bol_t) %if there is a problem in at least one
    for kr=1:nr
        if equal_bol_t(kr)
            fprintf('ATTENTION!!! problem in Simulation %s \n',runid_number{kr});
        else
            fprintf('Simulation %s is unchanged \n',runid_number{kr});
        end        
    end
else %there is no problem in any simulation
    fprintf('GOOD! ELV thanks you for not messing up! \n')
end

catch error_obj
    
errorprint(error_obj,fid_log)
fclose(fid_log);
    
end



