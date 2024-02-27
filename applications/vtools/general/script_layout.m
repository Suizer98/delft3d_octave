%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18049 $
%$Date: 2022-05-13 12:29:15 +0800 (Fri, 13 May 2022) $
%$Author: chavarri $
%$Id: script_layout.m 18049 2022-05-13 04:29:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/script_layout.m $
%
%Description

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

fpath_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
fpath_project='';

% fpath_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';
% fpath_project='';

%% ADD OET

if isunix
    fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
end
addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% PATHS

fpaths=paths_project(fpath_project);

%% INPUT