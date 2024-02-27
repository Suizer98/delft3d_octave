%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: delete_files.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/file_movement/delete_files.m $
%
%

%% PREAMBLE

clear
clc

%% INPUT

deletefiles=1; %if 0; it will display which ones it will delete

path_main_folder='C:\Users\chavarri\temporal\210122_rmm_salinity_2020\02_data\hagestein\';
% tag2erase={'_map.nc';'_his.nc';'_rst.nc'}; %erase files based on the last part of the file name
tag2erase={'LOBH_OW_Q_NVT_ddl_wq.csv'}; %erase files based on the last part of the file name
folder2erase={'hagestein'}; %folders to erase

% folder2erase={};
% for kfol=1:20
%     folder2erase=cat(2,folder2erase,{sprintf('%03d',kfol)});
% end
% for kfol=21:44
%     folder2erase=cat(2,folder2erase,{sprintf('r_%03d',kfol)});
% end

%% CALC

ntag=numel(tag2erase);
% nfe=numel(folder2erase);

[pathNames,dirNames,fileNames]=dirwalk(path_main_folder);

np=numel(fileNames);

for kp=1:np
    nf=numel(fileNames{kp,1});
    for kf=1:nf
        file_path=fullfile(pathNames{kp,1},fileNames{kp,1}{kf,1});
        if contains(file_path,folder2erase) && contains(file_path,tag2erase)
            disp(file_path)
            if deletefiles==1
                delete(file_path)                
            end
        end
    end %kf
end %kp

fprintf('done \n')