%This script adds (or creates) boundary conditions in the right format 
%for using the conversion tool
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%210215
%

%% PREAMBLE

fclose all;
clear
clc

%% ADD OET

%add the OET in the way you usually do. You can use this:
path_oet='c:\Users\chavarri\checkouts\openearthtools_matlab'; %input

path_add_fcn=fullfile(path_oet,'\applications\vtools\general\'); 
addpath(path_add_fcn)
addOET('path_oet_c',fullfile(path_oet,'oetsettings.m'))

%% INPUT

path_mat='c:\Users\chavarri\temporal\210212_jaarsom_toolbox\02_data\01_mat\rvw_v2018.mat'; %path to the existing mat-file. Empty if nonexisten. 
path_dat='C:\Users\chavarri\temporal\210212_jaarsom_toolbox\02_data\02_sob\'; %path to the folder with the files to add

add_bc_2_mat(path_mat,path_dat);
