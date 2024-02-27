%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16714 $
%$Date: 2020-10-29 03:38:23 +0800 (Thu, 29 Oct 2020) $
%$Author: chavarri $
%$Id: D3D_main_minimal_write_morini_from_map.m 16714 2020-10-28 19:38:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/D3D_main_minimal_write_morini_from_map.m $
%

%% PREAMBLE

close all
fclose all;
clear
clc

%% INPUT

flg.write=1; %write files 

%path to map results with original GSD
path_map='c:\Users\chavarri\temporal\09_gsd_preparation\gsd_030\dflowfm\DFM_OUTPUT_rijn-flow-model\rijn-flow-model_map.nc'; %j19

%path to sed-file associated to the original GSD
path_sed='c:\Users\chavarri\temporal\09_gsd_preparation\gsd_000\dflowfm\sed.sed';

%tag of the folder where everything is saved
tag_folder_out='mod';

%% CALC

%get data
mesh1d_node_x=ncread(path_map,'mesh1d_node_x');
mesh1d_node_y=ncread(path_map,'mesh1d_node_y');
mesh1d_lyrfrac=ncread(path_map,'mesh1d_lyrfrac',[1,1,1,1],[Inf,Inf,Inf,1]);
mesh1d_thlyr=ncread(path_map,'mesh1d_thlyr',[1,1,1],[Inf,Inf,1]);
mesh1d_node_branch=ncread(path_map,'mesh1d_node_branch');
% mesh1d_node_offset=ncread(path_map,'mesh1d_node_offset');
network1d_edge_nodes=ncread(path_map,'network1d_edge_nodes');
network1d_branch_id=ncread(path_map,'network1d_branch_id')';
% network1d_node_id=ncread(path_map,'network1d_node_id')';

gsd_original=D3D_read_sed(path_sed);

%rename
cord_original=[mesh1d_node_x,mesh1d_node_y];
frac_original=mesh1d_lyrfrac(:,1:end-1,:);
thk_original=mesh1d_thlyr(1:end-1,:)';

cord_br_mod=cord_original;
fractions_var_mod=frac_original;
thk_mod=thk_original;
fractions_branch=mesh1d_node_branch;
gsd_mod=gsd_original;
mesh1d_node_branch_mod=mesh1d_node_branch;

%path out
path_folder_out=fullfile(pwd,tag_folder_out);
mkdir(path_folder_out);

%% WRITE

if flg.write
    
cord_write=cord_br_mod;
frac_write=fractions_var_mod;
thk_write=thk_mod;

simdef.mor.frac=frac_write; 
simdef.mor.frac_xy=cord_write;
simdef.mor.thk=thk_write;
simdef.mor.folder_out='gsd_ini_mod';

simdef.D3D.dire_sim=path_folder_out;
simdef.D3D.structure=2;

mkdir(fullfile(path_folder_out,simdef.mor.folder_out))

D3D_morini(simdef)
D3D_morini_files(simdef)
fprintf('done writing files \n')

end
