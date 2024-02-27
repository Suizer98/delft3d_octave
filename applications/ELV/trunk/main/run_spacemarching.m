%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: run_spacemarching.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/run_spacemarching.m $
%
%run_ELV is a function that creates the folders for the output, calls the main function and then the postprocessing functions
%
%run_spacemarching(path_file_input)
%
%INPUT:
%   -path_file_input = path to the file input.mat; [char];
%
%OUTPUT:
%   -
%
%HISTORY:
%170130
%   -L. First created;

function run_spacemarching(path_file_input)
version='1';

%% 
%% INITIALIZATION
%% 

%% LOG FILE CREATION

fid_log=log_file_creation_sp(path_file_input);
fprintf(fid_log,'run_spacemarching version: %s\n',version); %stamp run_ELV version in log

%%
%% MAIN FUNCTION
%%

ELV_sp(path_file_input,fid_log)


%log file
fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of space marching algorithm');

%%
%% POSTPROCESSING
%%



%% LOG FILE

fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of the postprocessing');
fclose(fid_log);

