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
%$Id: run_ELV.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/run_ELV.m $
%
%run_ELV is a function that creates the folders for the output, calls the main function and then the postprocessing functions
%
%run_ELV(path_file_input)
%
%INPUT:
%   -path_file_input = path to the file input.mat; [char];
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%170123
%   -L. Added a seperate highway to compute equilibrium;

function run_ELV(path_file_input)

try 
%% 
%% INITIALIZATION
%% 

%% LOG FILE CREATION

fid_log=log_file_creation(path_file_input);
ELV_version(fid_log)

%% FOLDERS CREATION

folders_creation(path_file_input,fid_log);

%%
%% MAIN FUNCTION
%%

ELV(path_file_input,fid_log)

%log file
fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of ELV');
sendemail_from_path(path_file_input,'SIMULATION FINISHED',sprintf('nice!'),fid_log) %send email

%%
%% POSTPROCESSING
%%

%% LOG FILE

fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of the postprocessing');
fclose(fid_log);

catch error_obj
    
    errorprint(error_obj,fid_log)
    join_results_iferror(path_file_input,fid_log)
    sendemail_from_path(path_file_input,'ERROR in ELV run',sprintf('!! ERROR !! %s in file: %s, at line %d \n',error_obj.message,error_obj.stack(1).file,error_obj.stack(1).line),fid_log) %send email
    fclose(fid_log);
    profile off
%     error('I am afraid to say that the simulation has crashed...') %throw error to main
    
end
    
