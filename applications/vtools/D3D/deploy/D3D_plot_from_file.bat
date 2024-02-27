@echo off

rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem %%%                 VTOOLS                 %%%
rem %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rem % 
rem %Victor Chavarrias (victor.chavarrias@deltares.nl)
rem %
rem %$Revision: 17201 $
rem %$Date: 2021-04-17 01:15:25 +0800 (Sat, 17 Apr 2021) $
rem %$Author: chavarri $
rem %$Id: D3D_plot_from_file.bat 17201 2021-04-16 17:15:25Z chavarri $
rem %$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/deploy/D3D_plot_from_file.bat $
rem %
rem %Runs the plotting routine reading the input from a matlab script
rem %
rem %INPUT:
rem %   -path_input: path to the matlab script (char)

rem INPUT

set path_input_fig="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\210409_webinar_1D\main_1D_plot_from_file.m"

rem CALL

@echo on

D3D_plot_from_file %path_input_fig%

@echo off
pause