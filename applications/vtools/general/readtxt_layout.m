%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: readtxt_layout.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/readtxt_layout.m $
%

%% PREAMBLE

clear
clc

%% INPUT

paths_etaw='c:\Users\chavarri\temporal\SOBEK\test\001\output\etaw.csv';


%% READ

fid=fopen(paths_etaw,'r');
% fstr='%02d/%02d/%02d %02d:%02d:%02d,%f,%f,%s,%f,%f';
fstr='%s %f %f %s %f %f';
% 00/01/01 00:00:00,9.99950300363246,0,Channel1,9.959,1.80190004919931
%time [-],x,y,branch,chainage,Water level [m AD]
data=textscan(fid,fstr,'headerlines',1,'delimiter',',');
fclose(fid);



