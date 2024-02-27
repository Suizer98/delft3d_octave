%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18035 $
%$Date: 2022-05-10 22:01:00 +0800 (Tue, 10 May 2022) $
%$Author: chavarri $
%$Id: D3D_main_minimal_1D_plot.m 18035 2022-05-10 14:01:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/D3D_main_minimal_1D_plot.m $
%
%1D minimal plot

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

% fpath_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
% fpath_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';
fpath_add_fcn='p:\studenten-riv\05_OpenEarthTools\01_matlab\applications\vtools\general\';

%% ADD OET

if isunix
    fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
end
addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% INPUT

in_read.branch={'Channel_1D_1'}; %branch
in_read.kt=inf; %output time index
simdef.D3D.dire_sim='p:\studenten-riv\03_Work\220324_Josephien_Lingbeek\01_runs\r043\dflowfm\';
simdef.flg.which_v=2; %see list: open input_D3D_fig_layout

%% do not change

simdef.flg.which_p=3; %plot type 

%% CALL

simdef=D3D_simpath(simdef);
out_read=D3D_read(simdef,in_read);

%% PLOT

figure
plot(out_read.SZ,out_read.z)
ylabel(out_read.zlabel)
xlabel('streamwise coordinate [m]')
title(sprintf('time = %f s',out_read.time_r))

