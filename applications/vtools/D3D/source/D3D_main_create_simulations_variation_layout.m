%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17345 $
%$Date: 2021-06-11 17:16:16 +0800 (Fri, 11 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_main_create_simulations_variation_layout.m 17345 2021-06-11 09:16:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/D3D_main_create_simulations_variation_layout.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

%change to your path to vtools/general in OET. You can use the one in the p-drive. 
path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\'; 
% path_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn) %drive to take the repo from: 1=c; 2=p

%% INPUT

    %% paths
path_folder_sims='p:\11206793-kpp-vow\014\03_simulations\03_idealized_1d\02_runs\';
path_input_folder='p:\11206793-kpp-vow\014\03_simulations\03_idealized_1d\01_input\';
path_input_folder_refmdf='../../01_input';

    %% sims
path_ref=fullfile(path_folder_sims,sprintf('r%03d',19));
input_m=input_variation_01_runs_01(path_input_folder,path_input_folder_refmdf,path_folder_sims);

    %% run file
call_script='run_cases';
run_script_lin='run.sh'; 
run_script_win='run_69132.bat'; 

D3D_create_variation_simulations(path_ref,input_m,'run_script_lin',run_script_lin,'run_script_win',run_script_win,'call_script',call_script)
