%Main calling script to run ELV.

%% PREAMBLE

fclose all;
clear;
close all;
clc;
restoredefaultpath

%% INPUT 

ELV.paths_source='C:\Users\chavarri\checkouts\openearthtools_matlab\applications\ELV\trunk\source\';
ELV.input_filename='c:\Users\chavarri\temporal\ELV\01_input\input_ELV_Q024.m';
ELV.paths_runs='C:\Users\chavarri\temporal\ELV\';

% ELV.paths_source='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\ELV\trunk\source\';
% ELV.input_filename='p:\dflowfm\projects\2020_d-morphology\modellen\01_newscheme\01_input\input_ELV_Q024.m';
% ELV.paths_runs='p:\dflowfm\projects\2020_d-morphology\modellen\01_newscheme\02_simulations'; 

ELV.OET=1;
ELV.runid_serie='Q';
ELV.runid_number='024';
ELV.erase_previous=1; %it is dangerous, use with care and attention
ELV.do_profile=0; %0=NO; 1=YES
ELV.do_postprocessing=0; %0=NO; 1=YES
ELV.debug_mode=0; %0=NO; 1=YES

%% DEBUG COMMANDS

% dbstop in d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\main\particle_activity_update.m if (any(any(isnan(Gammak)==1)) && kt~=1)

%% Please run!

addpath(ELV.paths_source)
oh_ELV_please_run(ELV)