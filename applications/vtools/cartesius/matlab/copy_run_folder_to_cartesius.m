%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18289 $
%$Date: 2022-08-10 17:08:13 +0800 (Wed, 10 Aug 2022) $
%$Author: chavarri $
%$Id: copy_run_folder_to_cartesius.m 18289 2022-08-10 09:08:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/cartesius/matlab/copy_run_folder_to_cartesius.m $
%
%Creates the paths for transferring and running a simulation in Cartesius

function path_h6=copy_run_folder_to_cartesius(surf_userid,folder2send_win,cartesius_project_folder_lin,temporary_folder_win,runscript,surf_computer,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fname_app','');

parse(parin,varargin{:});

fname_app=parin.Results.fname_app;

%%

isrun=1;
if isempty(runscript)
    isrun=0;
end

%% recursive call

if iscell(folder2send_win)
    path_h6_call=fullfile(temporary_folder_win,'commands_copy_run_all.sh');
    fid_h6_call=fopen(path_h6_call,'w');
    
    nd=numel(folder2send_win);
    for kd=1:nd
        path_h6=copy_run_folder_to_cartesius(surf_userid,folder2send_win{kd},cartesius_project_folder_lin,temporary_folder_win,runscript,surf_computer,'fname_app',sprintf('_%02d',kd));
        fprintf(fid_h6_call,'%s \n',linuxify(path_h6));
    end
    fclose(fid_h6_call);
    
    %disp
    fprintf('---------- \n\n')
    fprintf('In H6: \n\n')
    fprintf('%s \n',linuxify(path_h6_call));
    
    return
end

%% paths

path_h6=fullfile(temporary_folder_win,sprintf('commands_copy_run_1%s.sh',fname_app));
path_ca=fullfile(temporary_folder_win,sprintf('commands_copy_run_2%s.sh',fname_app));

fid_h6=fopen(path_h6,'w');
fid_ca=fopen(path_ca,'w');

%% compress and place in output folder of p

if strcmp(folder2send_win(end),'\')
    folder2send_win(end)='';
end
folder2send_win=deblank(folder2send_win);
pathsplit=regexp(folder2send_win,'\','split');
comp_name=sprintf('%s.tar.gz',pathsplit{1,end});
comp_path_win=fullfile(temporary_folder_win,comp_name);

comp_path_lin=linuxify(comp_path_win);
% temporary_folder_lin=linuxify(folder2send_win);

npath=numel(pathsplit);
folder2sendup_win='p:\';
for kpath=2:npath-1
    folder2sendup_win=strcat(folder2sendup_win,pathsplit{1,kpath},'\');
end
folder2sendup_lin=linuxify(folder2sendup_win);

folder_run=pathsplit{end};
cmd_cd=sprintf('cd %s',folder2sendup_lin);
cmd_comp=sprintf('tar -zcvf %s %s',comp_path_lin,folder_run);

%% send file

path_dest_cart='';
for kpath=2:npath-1
    path_dest_cart=strcat(path_dest_cart,pathsplit{1,kpath},'/');
end
path_dest_cart=strcat(cartesius_project_folder_lin,path_dest_cart);
cmd_send=sprintf('rsync -av --bwlimit=5000 %s %s@%s:%s',comp_path_lin,surf_userid,surf_computer,path_dest_cart);

%% send file with commands to cartesius

cmd_send_commands_ca=sprintf('scp %s %s@%s:%s \n',linuxify(path_ca),surf_userid,surf_computer,cartesify(cartesius_project_folder_lin,path_ca));

%% uncompress file

cmd_cd_C_sim=sprintf('cd %s',path_dest_cart); 
path_file_cartesius=strcat(path_dest_cart,comp_name);
cmd_uncomp=sprintf('tar -zxvf %s',path_file_cartesius);
cmd_del_tar=sprintf('rm %s',comp_name); %delete tar

%% create output folder

%Using singularity for some reason the folder needs to be created by hand
if isrun
    simdef.D3D.dire_sim=folder2send_win;
    simdef=D3D_simpath(simdef);
    [~,fdir_out,~]=fileparts(simdef.file.output);
    cmd_mkdir=sprintf('mkdir %s',fdir_out);
end

%% run simulation

path_dest_cart_run=strcat(path_dest_cart,folder_run);
cmd_cd_cart_run=sprintf('cd %s',path_dest_cart_run);
cmd_dos2unix=sprintf('dos2unix %s',runscript);
cmd_submit=sprintf('sbatch %s',runscript);

%% DISPLAY

% clc
% fprintf('In H6: \n\n')
% fprintf('%s \n',cmd_cd)
% fprintf('%s \n',cmd_comp)
% fprintf('%s \n',cmd_send)
% fprintf('\n-----------\n\n')
% fprintf('In Cartesius: \n\n')
% fprintf('Start if necessary: \n')
% fprintf('ssh %s@cartesius.surfsara.nl \n\n',surf_userid)
% fprintf('%s \n',cmd_cd_C_sim)
% fprintf('%s \n',cmd_uncomp)
% fprintf('%s \n',cmd_del_tar)
% fprintf('%s \n',cmd_cd_cart_run)
% fprintf('%s \n',cmd_dos2unix)
% fprintf('%s \n',cmd_submit)
% fprintf('\n')

%% FILE and COMMAND

% clc
% fprintf('In H6: \n\n')
fprintf(fid_h6,'%s \n',cmd_cd);
fprintf(fid_h6,'%s \n',cmd_comp);
fprintf(fid_h6,'%s \n',cmd_send);
fprintf(fid_h6,'%s \n',cmd_send_commands_ca);
% fprintf('\n-----------\n\n');
% fprintf('In Cartesius: \n\n');
% fprintf('Start if necessary: \n');
% fprintf(fid_h6,'ssh %s@cartesius.surfsara.nl \n',surf_userid);
fprintf(fid_h6,'ssh %s@%s ''%s'' \n',surf_userid,surf_computer,cartesify(cartesius_project_folder_lin,path_ca));

fprintf(fid_ca,'%s \n',cmd_cd_C_sim);
fprintf(fid_ca,'%s \n',cmd_uncomp);
fprintf(fid_ca,'%s \n',cmd_del_tar);
if isrun
fprintf(fid_ca,'%s \n',cmd_cd_cart_run);
fprintf(fid_ca,'%s \n',cmd_mkdir);
fprintf(fid_ca,'%s \n',cmd_dos2unix);
fprintf(fid_ca,'%s \n',cmd_submit);
end
% fprintf('\n')

fclose(fid_h6);
fclose(fid_ca);

messageOut(NaN,sprintf('file with commands for H6: %s',path_h6));
messageOut(NaN,sprintf('file with commands for Cartesius: %s',path_ca));

fprintf('In H6: \n\n')
fprintf('%s \n',linuxify(path_h6));
% fprintf('\n-----------\n\n');
% fprintf('In Cartesius: \n\n');
% fprintf('%s \n',cartesify(path_ca));

end %function