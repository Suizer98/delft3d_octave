@ echo off
set exedir=d:\PROGRAMS\MATLAB\R2015b\bin\matlab.exe rem path to matlab executable

rem RUN substitute in run('~') the scrip to execute. This is matlab code!
%exedir% -nodisplay -nosplash -nodesktop -r "run('d:\victorchavarri\SURFdrive\projects\00_codes\ELV\source\main_V_160420.m')"

rem to avoid closing command line
rem pause
