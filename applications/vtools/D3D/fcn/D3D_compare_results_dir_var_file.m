%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18118 $
%$Date: 2022-06-08 18:01:17 +0800 (Wed, 08 Jun 2022) $
%$Author: chavarri $
%$Id: D3D_compare_results_dir_var_file.m 18118 2022-06-08 10:01:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_compare_results_dir_var_file.m $
%
%Gets as output the path to each file type

function D3D_compare_results_dir_var_file(fdir_res,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fname','var_names.txt')
addOptional(parin,'surf_comp','snellius.surf.nl');
addOptional(parin,'surf_path_hidden','gpfs/work4');
addOptional(parin,'surf_path_seen','projects');
addOptional(parin,'surf_userid','');
addOptional(parin,'cartesius_project_folder_lin','/projects/0/hisigem/');
addOptional(parin,'path_commands','');
addOptional(parin,'queue','normal-e3-c7');

parse(parin,varargin{:})

surf_comp=parin.Results.surf_comp;
pre_path_surf_hidden=parin.Results.surf_path_hidden;
pre_path_surf_seen=parin.Results.surf_path_seen;
fname_var=parin.Results.fname;
surf_userid=parin.Results.surf_userid;
cartesius_project_folder_lin=parin.Results.cartesius_project_folder_lin;
path_commands=parin.Results.path_commands;
queue=parin.Results.queue;

%% CALC
% fdir_res='P:\11208075-002-ijsselmeer\06_simulations\02_runs\r005\DFM_OUTPUT_ijsselmeer_3D\';
% fname_var='var_names.txt';

%% intended files in folder

fpath_var=fullfile(fdir_res,fname_var);
fid=fopen(fpath_var,'r');
fname_int={};
fpath_int={};
while ~feof(fid)
    lin=fgetl(fid);
    fpath_int=cat(1,fpath_int,{lin});
    tok=regexp(lin,'/','split');
%     /gpfs/work4/0/hisigem/11208075-002-ijsselmeer/06_simulations/02_runs/r006/DFM_OUTPUT_ijsselmeer_3D/ijsselmeer_3D_0000_20180605_000000_rst.tar.gz
    fname_comp=deblank(tok{end});
    fname_uncomp=strrep(fname_comp,'.tar.gz','');
    if any(strcmp(fname_uncomp(end-2:end),{'rst','map','his'}))
        fext='.nc';
    else
        fext='.dia';
    end
    fname_ext=sprintf('%s%s',fname_uncomp,fext);
    fname_int=cat(1,fname_int,fname_ext);
    
end
fclose(fid);

%% actual files in folder

dire=dir(fdir_res);
fname_act={dire.name}';

%% compare

bol_pre=ismember(fname_int,fname_act);
if all(bol_pre)
    messageOut(NaN,'All files are in results folder');
    return
end

fpath_re=fpath_int(~bol_pre);
nfn=numel(fpath_re);
messageOut(NaN,sprintf('You are missing %02d files',nfn));

%% write new file

%save old var file
fname_old_save=strrep(fname_var,'.txt',sprintf('_%s.txt',now_chr));
fpath_old_save=fullfile(fdir_res,fname_old_save);
copyfile_check(fpath_var,fpath_old_save);

fid_n=fopen(fpath_var,'w');
for kfn=1:nfn
%     /gpfs/work4/0/hisigem/11208075-002-ijsselmeer/06_simulations/02_runs/r006/DFM_OUTPUT_ijsselmeer_3D/ijsselmeer_3D_0000_20180605_000000_rst.tar.gz
    fprintf(fid_n,'%s \n',fpath_re{kfn});
end %kfn
fclose(fid_n);
messageOut(NaN,sprintf('new file for getting data back created: %s',fpath_var));

%% create file for submitting

if ~isempty(surf_userid)
    if isempty(path_commands)
        error('set <path_commands> to path with temporal data')
    end
    bring_data_back_from_cartesius(2,surf_userid,fdir_res,cartesius_project_folder_lin,path_commands,'surf_comp',surf_comp,'surf_path_hidden',pre_path_surf_hidden,'surf_path_seen',pre_path_surf_seen,'only_back',true,'queue',queue)
end

end %function