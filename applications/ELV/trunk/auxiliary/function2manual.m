
%% PREAMBLE

clear

%% INPUT


%% CALC

%paths
paths_aux=pwd;
paths_manual=fullfile(paths_aux,'..','manual');
paths_main=fullfile(paths_aux,'..','main');

%open file to write
file_out=fullfile(paths_manual,'functions.tex');
fileID_out=fopen(file_out,'w'); %file identifier of the output file

%directory tree
dir_main=dir(paths_main);
nf=size(dir_main,1);

for kf=3:nf
    [~,~,ext]=fileparts(dir_main(kf).name);
    if strcmp(ext,'.m')
        path_file_in=fullfile(dir_main(kf).folder,dir_main(kf).name);
        [file_old,file_nr]=file_read(path_file_in);
        %search for 'HISTORY'
        kl=1;
        while strcmp(file_old{kl,1}(1:end-2),'%HISTORY:')==0
            kl=kl+1;
        end
        %write
        fname_ori=dir_main(kf).name;
        fname_2prt=strrep(fname_ori,'_','\_');
        fprintf(fileID_out,'\\subsection{%s}\n',fname_2prt);
        for kr=16:kl-1
            str2ori=file_old{kr,1}(2:end);
            str2prt=str2ori;
            str2prt=strrep(str2prt,'_','\_');
            str2prt=strrep(str2prt,'^2','$^2$');
            str2prt=strrep(str2prt,'^3','$^3$');
            str2prt=strrep(str2prt,'[','$[$');
            str2prt=strrep(str2prt,']','$]$');
            fprintf(fileID_out,'%s \\\\ \n',str2prt(1:end-2));
        end
    end
end

fclose(fileID_out);
