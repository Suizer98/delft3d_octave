%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: copy_folder_structure.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/cartesius/matlab/copy_folder_structure.m $
%
%Copies the folder structure in the p-drive to SURF

%% E.G

% fpath_dir='p:\11206813-007-kpp2021_rmm-3d';
% temporary_folder_win='p:\11206813-007-kpp2021_rmm-3d\C_Work\00_temporal';
% surf_userid='chavarr';
% surf_computer='snellius.surf.nl';
% cartesius_project_folder_lin='/projects/0/einf1711/';

function copy_folder_structure(surf_userid,cartesius_project_folder_lin,temporary_folder_win,surf_computer,fpath_dir)

%% paths

path_h6=fullfile(temporary_folder_win,'commands_copy_folder_structure_1.sh');

fname_ca='commands_copy_folder_structure_2.sh';
path_ca=fullfile(temporary_folder_win,fname_ca);
path_ca_lin=strcat(cartesius_project_folder_lin,fname_ca); %we need to copy the file at the top because nothing exist before the Big Bang

fid_h6=fopen(path_h6,'w');
fid_ca=fopen(path_ca,'w');

%%

[d1,~,~]=dirwalk(fpath_dir);

nd=numel(d1);
for kd=1:nd
    
    if contains(d1{kd,1},'.svn')
        continue
    end
    
    fprintf(fid_ca,'mkdir %s \n',cartesify(cartesius_project_folder_lin,d1{kd,1}));
end

%%

%delete copy file
fprintf(fid_ca,'rm -f %s \n',path_ca_lin);

%%

fprintf(fid_h6,'scp %s %s@%s:%s \n',linuxify(path_ca),surf_userid,surf_computer,path_ca_lin);
fprintf(fid_h6,'ssh %s@%s ''%s'' \n',surf_userid,surf_computer,path_ca_lin);

fclose(fid_ca);
fclose(fid_h6);

%% DISPLAY

messageOut(NaN,sprintf('file with commands for H6: %s',path_h6));
messageOut(NaN,sprintf('file with commands for Cartesius: %s',path_ca));

fprintf('In H6: \n\n')
fprintf('%s \n',linuxify(path_h6));

end %function