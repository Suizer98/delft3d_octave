%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18012 $
%$Date: 2022-05-02 22:48:37 +0800 (Mon, 02 May 2022) $
%$Author: chavarri $
%$Id: D3D_main_plot.m 18012 2022-05-02 14:48:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/D3D_main_plot.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn)

%% INPUT

path_input='c:\Users\chavarri\temporal\220429_ice\03_scripts\input_D3D_fig_ice.m'; 

%% CALL

run(path_input)
out_read=D3D_plot(simdef,in_read,def);

