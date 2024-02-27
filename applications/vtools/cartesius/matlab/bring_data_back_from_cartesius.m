%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18344 $
%$Date: 2022-08-31 22:59:35 +0800 (Wed, 31 Aug 2022) $
%$Author: chavarri $
%$Id: bring_data_back_from_cartesius.m 18344 2022-08-31 14:59:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/cartesius/matlab/bring_data_back_from_cartesius.m $
%
%Get paths for bringing data from Cartesius to the p-drive
%
%E.G.
%
% surf_userid='pr1n0147';
% output_folder_win='p:\11206813-007-kpp2021_rmm-3d\C_Work\01_RMM_simulations\computations\r006\DFM_OUTPUT_RMM_dflowfm\';
% cartesius_project_folder_lin='/projects/0/hisigem/';
% path_commands='p:\11206813-007-kpp2021_rmm-3d\C_Work\00_temporal\';
%
%OPTION 1
%partition files in the folder
% fname_move='RMM_dflowfm_0000_fou.nc';
% npartitions=120;
% 
% bring_data_back_from_Cartesius(1,surf_userid,output_folder_win,cartesius_project_folder_lin,path_commands,fname_move,npartitions)
% 
%OPTION 2
%all files in the folder (see Note 1)
%
% bring_data_back_from_Cartesius(2,surf_userid,output_folder_win,cartesius_project_folder_lin,path_commands)
%
%OPTION 3
%list of single files
% path_bring_back={... %path in Windows where to place the same file in Cartesius
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_020/figures/crossection/cs_vert_a_020_20111205.png'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_020/figures/crossection/a_020_crosssection_error.txt'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_021/figures/crossection/cs_vert_a_021_20111205.png'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_021/figures/crossection/a_021_crosssection_error.txt'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_026/figures/crossection/cs_vert_a_026_20111205.png'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_026/figures/crossection/a_026_crosssection_error.txt'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_029/figures/crossection/cs_vert_a_029_20111205.png'...
% 'p:/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_029/figures/crossection/a_029_crosssection_error.txt'...
% };
%
% bring_data_back_from_Cartesius(3,surf_userid,output_folder_win,cartesius_project_folder_lin,path_commands,path_bring_back)
%
%NOTES
%
%1: When transferring all the data, the full path in SURF is, e.g.:
%   </gpfs/work4/0/hisigem/11208075-002-ijsselmeer/06_simulations/02_runs/r005/DFM_OUTPUT_ijsselmeer_3D/ijsselmeer_3D_0000_20180605_000000_rst.tar.gz>
%however, the visible path must be used to get the data back. E.g.:
%   </projects/0/hisigem/11208075-002-ijsselmeer/06_simulations/02_runs/r005/DFM_OUTPUT_ijsselmeer_3D/ijsselmeer_3D_0000_20180605_000000_rst.tar.gz>
%the pair input <surf_path_hidden> and <surf_path_seen> are used to replace the sring. 

function bring_data_back_from_cartesius(type_back,surf_userid,output_folder_win,cartesius_project_folder_lin,path_commands,varargin)

%% PARSE

flg.opt=type_back;
switch flg.opt
    case 1 %create paths for given number of partitions
        fname_move=varargin{1};
        npartitions=varargin{2};
        idx_varargin=3;
    case 2 %bring all data from folder
        idx_varargin=1;
    case 3
        path_bring_back=varargin{1}; %path in Windows where to place the same file in Cartesius
        idx_varargin=2;
end

if strcmp(output_folder_win(end),'\')
    output_folder_win(end)='';
end

output_folder_win=small_p(output_folder_win);

%%

parin=inputParser;

addOptional(parin,'surf_comp','snellius.surf.nl');
addOptional(parin,'surf_path_hidden','gpfs/work4');
addOptional(parin,'surf_path_seen','projects');
addOptional(parin,'only_back',false);
addOptional(parin,'queue','normal-e3-c7');

parse(parin,varargin{idx_varargin:end});

surf_comp=parin.Results.surf_comp;
pre_path_surf_hidden=parin.Results.surf_path_hidden;
pre_path_surf_seen=parin.Results.surf_path_seen;
only_back=parin.Results.only_back;
queue=parin.Results.queue;

%% FILES

suf=now_chr;
path_h6=fullfile(path_commands,sprintf('bring_data_back_%s.sh',suf));
fid_h6=fopen(path_h6,'w');
path_ca=fullfile(path_commands,sprintf('tmp_bring_data_back_%s.sh',suf));
fid_ca=fopen(path_ca,'w');

%% CALC

switch flg.opt
    case 1
        %% send file with commands to cartesius

        cmd_send_commands_ca=sprintf('scp %s %s@%s:%s \n',linuxify(path_ca),surf_userid,surf_comp,cartesify(cartesius_project_folder_lin,path_ca));

        %% compress

        switch flg.opt
            case 1
                fname_compress='';
                for kpartitions=1:npartitions
                    fname_compress=[fname_compress,' ',strrep(fname_move,'0000',sprintf('%04d',kpartitions-1))];
                end
                folder2work_win=output_folder_win;
            case 2
                [folder2work_win,folder_last]=folderUp(output_folder_win);
                fname_compress=folder_last;
        end

        folder2work_cartesius=cartesify(cartesius_project_folder_lin,folder2work_win);
        compressed_path_win=fullfile(folder2work_win,strcat(fname_compress,'.tar.gz'));
        compressed_path_cartesius=cartesify(cartesius_project_folder_lin,compressed_path_win);

        cmd_go_cartesius_folder=sprintf('cd %s',folder2work_cartesius);
        cmd_comp=sprintf('tar -zcvf %s %s',compressed_path_cartesius,fname_compress);
        
        %% mkdir
        
        compressed_path_h6=strrep(compressed_path_cartesius,cartesius_project_folder_lin,'/p/');
        [path_dir,~,~]=fileparts(compressed_path_h6);
        cmd_mkdir=sprintf('mkdir %s',linuxify(path_dir));
        
        %% transport

        cmd_transport=sprintf('rsync -av --bwlimit=5000 %s@%s:%s %s',surf_userid,surf_comp,compressed_path_cartesius,compressed_path_h6);

        %% uncompress

        output_folder_h6=linuxify(folder2work_win);
        cmd_cd_C_sim=sprintf('cd %s',output_folder_h6); 
        cmd_uncomp=sprintf('tar -zxvf %s',compressed_path_h6);
        cmd_del_tar=sprintf('rm -rf %s',compressed_path_h6); %delete tar
        
        %% display

        %cartesius commands
        fprintf(fid_ca,'%s \n',cmd_go_cartesius_folder);
        fprintf(fid_ca,'%s \n',cmd_comp);
        
        %h6
        fprintf(fid_h6,'%s \n',cmd_send_commands_ca);
        fprintf(fid_h6,'ssh %s@%s ''%s'' \n',surf_userid,surf_comp,cartesify(cartesius_project_folder_lin,path_ca));
        fprintf(fid_h6,'%s \n',cmd_mkdir);
        fprintf(fid_h6,'%s \n',cmd_transport);
        fprintf(fid_h6,'%s \n',cmd_cd_C_sim);
        fprintf(fid_h6,'%s \n',cmd_uncomp);
        fprintf(fid_h6,'%s \n',cmd_del_tar);

        case 2
            
        %% file in cartesius
        
        fprintf(fid_ca,'#!/bin/bash \n');
        
        %go to results file
        output_folder_ca=cartesify(cartesius_project_folder_lin,output_folder_win);
        fprintf(fid_ca,'cd %s \n',output_folder_ca);
        
        %compress all files
        fprintf(fid_ca,'for i in *; do                                                     \n');
        fprintf(fid_ca,'	extension="${i##*.}"                                           \n');
        fprintf(fid_ca,'	if [ "$extension" = "nc" ] || [ "$extension" = "dia" ]; then   \n');
        fprintf(fid_ca,'		out_var="${i%%.$extension}.tar.gz"                         \n');
		fprintf(fid_ca,'		echo $out_var                                              \n');
		fprintf(fid_ca,'        if [ ! -f $out_var ]                                       \n');
		fprintf(fid_ca,'        then                                                       \n');
		fprintf(fid_ca,'        	echo "File does not exist. Compressing."               \n');
		fprintf(fid_ca,'        	tar -zcvf $out_var $i                                  \n');
		fprintf(fid_ca,'        	fpath=$(realpath $out_var)                             \n');
		fprintf(fid_ca,'        	echo $fpath >> var_names.txt                           \n');
		fprintf(fid_ca,'        else                                                       \n');
		fprintf(fid_ca,'        	echo "File found. Skip compression"                    \n');
		fprintf(fid_ca,'        fi                                                         \n');
        fprintf(fid_ca,'	fi                                                             \n');
        fprintf(fid_ca,'done                                                               \n'); 
                
        %% file in h6
        
        fprintf(fid_h6,'#!/bin/bash \n');
        fprintf(fid_h6,'#$ -q %s \n',queue);
        
        %send file with commands to cartesius
        if ~only_back
        cmd_send_commands_ca=sprintf('scp %s %s@%s:%s \n',linuxify(path_ca),surf_userid,surf_comp,cartesify(cartesius_project_folder_lin,path_ca));
        fprintf(fid_h6,'%s \n',cmd_send_commands_ca);
        fprintf(fid_h6,'ssh %s@%s ''%s'' \n',surf_userid,surf_comp,cartesify(cartesius_project_folder_lin,path_ca));
        end
        
        %create output folder and go there
        output_folder_h6=linuxify(output_folder_win);
        fprintf(fid_h6,'mkdir %s \n',output_folder_h6);
        fprintf(fid_h6,'cd %s \n',output_folder_h6);
        
        %bring back <var_names.txt>
        if ~only_back
        fpath_varnames_win=fullfile(output_folder_win,'var_names.txt');
        fpath_varnames_h6=linuxify(fpath_varnames_win);
        fpath_varnames_ca=cartesify(cartesius_project_folder_lin,fpath_varnames_win);
        cmd_transport_varnames=sprintf('rsync -av --bwlimit=5000 %s@%s:%s %s',surf_userid,surf_comp,fpath_varnames_ca,fpath_varnames_h6);
        fprintf(fid_h6,'%s \n',cmd_transport_varnames);
        end
        
        %read (loop)
        fprintf(fid_h6,'file="var_names.txt" \n');
        fprintf(fid_h6,'dos2unix $file \n');
        fprintf(fid_h6,'while IFS= read -r line \n');
        fprintf(fid_h6,'do \n');
            %filename with extension
%         fprintf(fid_h6,'filename=$(basename -- "$line") \n');
            %for some reason, the filename is in <lustre5> directory, but we need to read from <projects>
        fprintf(fid_h6,'full_string=$line \n');
        fprintf(fid_h6,'search_string="%s" \n',pre_path_surf_hidden);
        fprintf(fid_h6,'replace_string="%s" \n',pre_path_surf_seen);
        fprintf(fid_h6,'linep=${full_string/$search_string/$replace_string} \n');

        fprintf(fid_h6,'full_string=$linep \n');
        fprintf(fid_h6,'search_string="%s" \n',cartesius_project_folder_lin);
        fprintf(fid_h6,'replace_string="/p/" \n');
        fprintf(fid_h6,'linep2=${full_string/$search_string/$replace_string} \n');
        fprintf(fid_h6,'timstr=$(date) \n');
        
%         fprintf(fid_h6,'printf "%%s start transferring %%s here %%s \\n" $timstr $linep $linep2 >> log.txt \n'); %the behaviour of $(date) changed?
        fprintf(fid_h6,'printf "%%s %%s %%s %%s %%s %%s start transferring %%s here %%s \\n" $timstr $linep $linep2 >> log.txt \n');
        
            %transport each file
        fprintf(fid_h6,'rsync -av --bwlimit=5000 %s@%s:$linep $linep2 \n',surf_userid,surf_comp);
            %uncompress
%             printf "start uncompressing %s.\n" $filename >> log.txt
        fprintf(fid_h6,'tar -zxvf $linep2 \n');
            %delete tar
        fprintf(fid_h6,'rm -rf $linep2 \n'); 
            %display for debug    
%         fprintf(fid_h6,'	printf ''%%s\\n'' "$line" \n'); %one % taken, one \n taken
%         fprintf(fid_h6,'	printf ''%%s\\n'' "$filename" \n'); %one % taken, one \n taken
        fprintf(fid_h6,'done <"$file" \n');
        
        
        case 3
            %% transport
            nf=numel(path_bring_back);
            cmd_mkdir=cell(nf,1);
            cmd_transport=cell(nf,1);
            kf=1;
            [path_dir,~,~]=fileparts(path_bring_back{kf});
            path_dir=small_p(path_dir);
            cmd_mkdir{kf}=sprintf('mkdir %s',linuxify(path_dir));
            cmd_cd=sprintf('cd %s',linuxify(path_dir));
            for kf=1:nf
                path_bring_back{kf}=small_p(path_bring_back{kf});
                [path_dir,~,~]=fileparts(path_bring_back{kf});
                cmd_mkdir{kf}=sprintf('mkdir %s',linuxify(path_dir));
                cmd_transport{kf,1}=sprintf('rsync -av --bwlimit=5000 %s@snellius.surf.nl:%s %s &>log.txt',surf_userid,cartesify(cartesius_project_folder_lin,path_bring_back{kf}),linuxify(path_bring_back{kf}));
            end %kf
            
            %% display
            fprintf(fid_h6,'#!/bin/bash \n');
            fprintf(fid_h6,'#$ -q normal-e3-c7 \n');
            fprintf(fid_h6,'%s \n',cmd_mkdir{1,1});
            fprintf(fid_h6,'%s \n',cmd_cd);
            for kf=1:nf
                fprintf(fid_h6,'%s \n',cmd_mkdir{kf,1});
                fprintf(fid_h6,'%s \n',cmd_transport{kf,1});
            end %kf

    otherwise
        error ('this option does not exist')
end %flg.opt

%% close 

fclose(fid_h6);
fclose(fid_ca);

%% disp

% fprintf('Run file for compressing data in Cartesius: %s \n',path_ca);
% fprintf('Run file for bringing data back to H6: %s \n',path_h6);
fprintf('For an unknown reason, sometimes it crashes because \n rsync is not found. Simply submit again. \n')
fprintf('qsub %s \n',linuxify(path_h6))

end %function

%%
%% FUNCTIONS
%%

function path_dir=small_p(path_dir)

path_dir=strrep(path_dir,'P:','p:');

end %function