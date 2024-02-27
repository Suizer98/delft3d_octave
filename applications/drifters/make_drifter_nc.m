clear all;close all;clc;
%% Write drifter netcdf file
mid = 'rip_23_09';
mdir = 'g:\PhDData\Survey\MegaPEX\Drifters\';

gt31 = process_drifterlog(mid,mdir);

drifters2nc(mid,gt31);