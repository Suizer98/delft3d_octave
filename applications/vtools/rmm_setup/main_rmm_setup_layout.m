%This script updates the boundary conditions of the SOBEK 3 RMM model
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%200601
%

%% PREAMBLE

fclose all;
clear
clc

%% ADD OET

%add the OET in the way you usually do. You can use this:
path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn)

%% INPUT

simdef.paths.bcmat='c:\Users\chavarri\temporal\210212_jaarsom_toolbox\02_data\01_mat\rvw_v2018_mod.mat'; %path to the matlab file containing the new boundary conditions (from RWS)
simdef.paths.loclabels='input_labels_layout.m'; %path to the m-file containing the conversion names between data and SOBEK 3

simdef.paths.dimr_in='c:\Users\chavarri\temporal\210212_jaarsom_toolbox\03_simulations\in\dimr.xml'; %path to the dimr file defining the SOBEK 3 model 
simdef.paths.s3_out='C:\Users\chavarri\temporal\210212_jaarsom_toolbox\03_simulations\out\'; %path to the folder where to save the new SOBEK 3 model (it is created if it does not exist)

simdef.paths.sre_in='c:\Users\chavarri\temporal\200531_bc_rmm\models\16'; 
simdef.paths.sre_out='c:\Users\chavarri\temporal\200531_bc_rmm\models_out\16';

simdef.start_time=datetime(2018,01,07,01,59,00); %year,momth,day,hour,minute,second
simdef.stop_time=datetime(2018,02,03,15,24,00); %year,month,day,hour,minute,second

%% CALC

update_boundary_conditions_rmm_s3(simdef)
update_boundary_conditions_rmm_sre(simdef)

