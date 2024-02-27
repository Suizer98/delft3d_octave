
%check required toolboxes

%% PREAMBLE

clear

%% INPUT

%no input required

%% CALC

% path_folder_in='d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\main\';
path_folder_in=fullfile(pwd,'..','main');

%directory tree
[path_f1,path_f2,path_f3]=dirwalk(path_folder_in);
n_f1=size(path_f1,1);

%walk directory
kc=1;
for kf1=1:n_f1 
    n_f3=size(path_f3{kf1,1},1);
    if n_f3~=0
        for kf3=1:n_f3
            [~,~,ext]=fileparts(path_f3{kf1,1}{kf3,1});
            if strcmp(ext,'.m')
                path_file_in=fullfile(path_f1{kf1,1},path_f3{kf1,1}{kf3,1});
%                 path_a{1,1}=path_file_in;
%                 tlb=dependencies.toolboxDependencyAnalysis(path_a);
%                 all_f{kc,1}=tlb;
                all_f{kc,1}=path_file_in;
                
                kc=kc+1;
            end
        end
    end
end

%% 

[f_list,p_list]=matlab.codetools.requiredFilesAndProducts(all_f);