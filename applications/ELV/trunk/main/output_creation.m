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
%$Id: output_creation.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/output_creation.m $
%
%output_creation is a function that creates the file where the results will be saved and saves the initial condition.
%
%output_creation(input,fid_log)
%
%INPUT:
%   -input = input structure of a single branch
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.

function output_creation(input,~)

%%
%% RENAME
%%

nb=input(1,1).mdv.nb;
no=input(1,1).mdv.no;
nT=input(1,1).mdv.nT;
nx=input(1,1).mdv.nx;
nef=input(1,1).mdv.nef;
if input(1,1).mdv.dt_type==1
    %if CFL based time step we do not save time_loop and we do not have nt
    nt=input(1,1).mdv.nt;
end

%% CALC

%bring ~_bra variables in
for ko=1:no
    %call to the workspace of the function the variables that we want to save
    aux_varname_bra=input(1,1).mdv.output_var_bra{1,ko}; %variable name to update in output.mat
    aux_varname=input(1,1).mdv.output_var{1,ko}; %variable name to update in output.mat
    aux_var_bra=evalin('caller',aux_varname_bra); %variable value in the main function corresponding to the variable name
    switch aux_varname
        case 'time_loop' %time_loop has a different size in ELV.m that in output.mat
            aux_var_4=NaN(nt,1); 
            feval(@()assignin('caller',aux_varname,aux_var_4)) %rename such that the variable name goes with its variable value
            feval(@()evalin('caller',sprintf('%s=%s;',aux_varname_bra,aux_varname)))
        case 'celerities'
            %this is not general enough. In the input I should specify which field of the structure to save and allocate it here.
            aux_var_celerities=struct('ls',NaN(nef,nx,1,nT),'lb',NaN(1,nx,1,nT)); %we are not saving the other celerities. Preallocate if you want them
            feval(@()assignin('caller',aux_varname,aux_var_celerities)) %rename such that the variable name goes with its variable value
            feval(@()evalin('caller',sprintf('%s=%s;',aux_varname_bra,aux_varname)))
        case 'time_l'
            aux_var_4=NaN(nT,1); 
            feval(@()assignin('caller',aux_varname,aux_var_4)) %rename such that the variable name goes with its variable value
            feval(@()evalin('caller',sprintf('%s=%s;',aux_varname_bra,aux_varname)))
        otherwise
            for kb=1:nb
                aux_var_size=size(aux_var_bra{kb,1});
                switch numel(aux_var_size)
                    case 2
                        aux_var_4=NaN(aux_var_size(1),aux_var_size(2),1,nT);  
                    case 3
                        aux_var_4=NaN(aux_var_size(1),aux_var_size(2),aux_var_size(3),nT); 
                end
                feval(@()assignin('caller',aux_varname,aux_var_4)) %rename such that the variable name goes with its variable value
                feval(@()evalin('caller',sprintf('%s{kb,1}=%s;',aux_varname_bra,aux_varname)))
            end %kb
    end %aux_varname    
    
end %ko

%% SAVE

%the variables cannot be saved in a structure if you want to partially load
%them. the file must be save in version 7.3 for partially loading it
path_file_output=input(1,1).mdv.path_file_output;
if nb==1 
    save_var_str=input(1,1).mdv.output_var;         
else
    save_var_str=input(1,1).mdv.output_var_bra; 
end 
save_var_str{no+1}='fieldNames'; %to use v2struct it is necessary to have the string 'fieldNames' in the cell array.
save_var_sctruct=v2struct(save_var_str); %#ok variables into a structure to save it
save(path_file_output,'-struct','save_var_sctruct','-v7.3')

