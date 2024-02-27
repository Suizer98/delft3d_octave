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
%$Id: bring_output_single_2_ws.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bring_output_single_2_ws.m $
%
%this scrip gets the variables from the first result file to the workspace. It needs to be a script and not a function because we want the variables to get into the workspace of the function where is called and we do not know the output a priori.


%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%181108
%   -V. Created for the first time.
%

%get the results of the first time step and call output creation 
kT=1;
path_file_output_sng=fullfile(path_folder_TMP_output,sprintf('%06d.mat',kT)); %path to the separate file with results
load(path_file_output_sng); %load the partial results
%convert non-bra into bra (e.g. u -> u_bra)
for ko=1:input.mdv.no
    aux_varname=input.mdv.output_var{1,ko}; %variable name to update in output.mat
    aux_varname_bra=input.mdv.output_var_bra{1,ko}; %variable name to update in output.mat
    switch aux_varname 
        case {'time_loop','celerities','time_l'} %history variable

        otherwise %map variable
%             aux_varname_bra=strcat(aux_varname,'_bra'); %variable name to update in output.mat
            feval(@()evalin('caller',sprintf('%s{1,1}=%s;',aux_varname_bra,aux_varname)))
    end
end