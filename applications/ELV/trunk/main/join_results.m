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
%$Id: join_results.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/join_results.m $
%
%join_results does this and that
%
%join_results(input,fid_log)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%170207
%   -V. Created for the first time.

function join_results(input,fid_log)

%%
%% RENAME
%%

nb=input(1,1).mdv.nb;
no=input(1,1).mdv.no;

Flmap_dt=input(1,1).mdv.Flmap_dt;
dt=input(1,1).mdv.dt;

savemethod=input(1,1).mdv.savemethod;

output_var=input(1,1).mdv.output_var;
output_var_bra=input(1,1).mdv.output_var_bra;

path_folder_TMP_output=input(1,1).mdv.path_folder_TMP_output;
path_file_output=input(1,1).mdv.path_file_output;


%%
%% SAVE
%%

if savemethod==2
    if isnan(fid_log)
        fprintf('%s %s\n',datestr(datetime('now')),'Start of putting all result files together');
    else
        fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'Start of putting all result files together');
    end

%load the empty results
% if exist(path_file_output,'file')==0 %if CFL based dt there is no output created at the start
%     %get the results of the first time step and call output creation 
%     bring_output_single_2_ws
%     input=get_nT(input,fid_log);    
%     output_creation(input,fid_log)
% end

output_m=load(path_file_output);

%check how many files are in the temporary output folder (do not use nT in
%case the simulation has crashed)
dir_TMP_output=dir(path_folder_TMP_output);
nF=numel(dir_TMP_output)-2; %number of files in directory (. and ..)
% nTt=nF+1; %number of saving results times. 't' because it may has crashed so it is 'temporary' :) we add 1 because file 000001 does not exist.
nTt=nF; %number of saving results times. 't' because it may has crashed so it is 'temporary' :) we add 1 because file 000001 does not exist.

%load the separate resutls files and copy to the variable with all the results
for kT=1:nTt %loop on separate files with results (kT is counter for results time file)
    path_file_output_sng=fullfile(path_folder_TMP_output,sprintf('%06d.mat',kT)); %path to the separate file with results
    output_par=load(path_file_output_sng); %load the partial results
    for ko=1:no %loop on varaibles to save
        aux_varname=output_var{1,ko}; %variable name to update in output.mat
        switch aux_varname 
            case 'time_loop' %history variable
%                 output_m.(aux_varname)((kT-2)*floor(Flmap_dt/dt)+1:(kT-1)*floor(Flmap_dt/dt))=output_par.(aux_varname);
%                 output_m.(aux_varname)((kT-1)*floor(Flmap_dt/dt)+1:(kT)*floor(Flmap_dt/dt))=output_par.(aux_varname);
                %if it is not an exact multilple the number of results may vary... This is a bit crappy
                s_o=size(((kT-1)*floor(Flmap_dt/dt)+1:(kT)*floor(Flmap_dt/dt)),1);
                s_s=size(output_par.(aux_varname),1);
                min_s=min(s_o,s_s);
                aux_v=output_par.(aux_varname);
                aux_s=aux_v(1:min_s);  
                output_m.(aux_varname)((kT-1)*floor(Flmap_dt/dt)+1:(kT)*floor(Flmap_dt/dt))=aux_s;
            case 'celerities'
                %the name of this variables does not have '_bra', so it does not need to be changed
                output_m.(aux_varname).ls(:,:,:,kT)=output_par.(aux_varname).ls;
                output_m.(aux_varname).lb(:,:,:,kT)=output_par.(aux_varname).lb;
            case 'time_l'
                output_m.(aux_varname)(kT)=output_par.(aux_varname);
            otherwise %map variable
                if nb==1
                    nel=size(output_m.(aux_varname)); %size of the variable in the .mat file
                    output_m.(aux_varname)(1:nel(1),1:nel(2),1:nel(3),kT)=output_par.(aux_varname)(1:nel(1),1:nel(2),1:nel(3));
                else
                    aux_varname_bra=output_var_bra{1,ko}; %variable name to update in output.mat
                    for kb=1:nb
                        nel=size(output_m.(aux_varname_bra){kb,1}); %size of the variable in the .mat file
                        output_m.(aux_varname_bra){kb,1}(1:nel(1),1:nel(2),1:nel(3),kT)=output_par.(aux_varname_bra){kb,1}(1:nel(1),1:nel(2),1:nel(3));
                    end
                end
        end
    end
end
        

if nb==1 %modify the variable with all the results
    output_mat=matfile(path_file_output,'writable',true); %matfile io object creation
    for ko=1:no
        aux_varname=output_var{1,ko}; %variable name to update in output.mat
        output_mat.(aux_varname)=output_m.(aux_varname); %add the value of the current time
    end
else %overwrite (cannot index into '~_bra' because MatFile objects only support '()' indexing)
    save(path_file_output,'-struct','output_m','-v7.3')
end

%% display

if isnan(fid_log)
    fprintf('%s %s\n',datestr(datetime('now')),'End of putting all result files together');
else
    fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'End of putting all result files together');
end

end
