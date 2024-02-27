

%% PREAMBLE

% close all
% clear all %if changes outside matlab
cd('C:\Users\chavarri\checkouts\openearthtools_matlab\applications\ELV\trunk\source\')

%% INPUT

dire_in='C:\Users\chavarri\temporal\ELV\Q\001\';

%% PATHS

addpath('..\auxiliary\')
addpath('..\postprocessing\')
addpath('..\main\')

%% RUN INPUT

run('input_fig_input_Q.m')

%% patch
fig_patch(dire_in,fig_input)    
%% level
fig_level(dire_in,fig_input)    
%% x-cnt
fig_x_cnt(dire_in,fig_input)
%% t-cnt
fig_t_cnt(dire_in,fig_input)
%% x-t-var
fig_xt(dire_in,fig_input)    
%% time_loop
fig_time_loop(dire_in,fig_input)
%% x-cnt (pmm)
fig_x_cnt_pmm(dire_in,fig_input)    
