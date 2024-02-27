%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17593 $
%$Date: 2021-11-16 17:28:04 +0800 (Tue, 16 Nov 2021) $
%$Author: chavarri $
%$Id: D3D_create_variation_simulations.m 17593 2021-11-16 09:28:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_create_variation_simulations.m $
%
%creates a set of simulations based on a reference one 
%and the variations set in a structure
%
%INPUT
%   -path_ref: path to the reference simulations
%   -input_m: input structure with variations in the mdf/mdu-file. The fieldnames must be the keywords to be modified
%
%PAIR INPUT
%   -run_script_lin: name of the sh-file present in each simulation folder to be executed. Default run_script_lin='run.sh'
%   -run_script_win: name of the bat-file present in each simulation folder to be executed. Default run_script_win='run.bat'
%   -call_script: name of the bat- and sh-file created at the level of the simulations folder that calls each of the bst- and sh-file in the individual simulations folder. Default call_script='run_cases'
%
%E.G.:
%   see <../source/D3D_main_create_simulations_variation_layout.m>

function D3D_create_variation_simulations(path_ref,input_m,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'run_script_lin','run.sh');
addOptional(parin,'run_script_win','run.bat');
addOptional(parin,'call_script','run_cases');

parse(parin,varargin{:});

run_script_lin=parin.Results.run_script_lin;
run_script_win=parin.Results.run_script_win;
call_script=parin.Results.call_script;

%% CALC

nsim=numel(input_m.sim);
if isfield(input_m.sim,'dorun')==0
    for ksim=1:nsim
        input_m.sim(ksim).dorun=true;
    end
end

[path_folder_sims,~,~]=fileparts(input_m.sim(1).path_sim);

%ref
[path_file,mdf,~]=D3D_read_sim_folder(path_ref);

%run file
fout_name_lin=sprintf('%s.sh',call_script);
fout_lin=fullfile(path_folder_sims,fout_name_lin);
fout_c_lin=fullfile(pwd,fout_name_lin);
fid_lin=fopen(fout_c_lin,'w');

fout_name_win=sprintf('%s.bat',call_script);
fout_win=fullfile(path_folder_sims,fout_name_win);
fout_c_win=fullfile(pwd,fout_name_win);
fid_win=fopen(fout_c_win,'w');


for ksim=1:nsim
    
    if input_m.sim(ksim).dorun==0
        continue
    end
    
    sim_id=input_m.sim(ksim).sim_id;
    path_sim_loc=input_m.sim(ksim).path_sim;
%     path_mdf_loc=fullfile(path_sim_loc,sprintf('%s.mdf',runid));
    
    if exist(path_sim_loc,'dir')==7
        fclose(fid_win);
        fclose(fid_lin);
        error('Directory already exist: %s',path_sim_loc)
    end
    mkdir(path_sim_loc)
    
    mdf_loc=mdf;
    mdf_loc=D3D_modify_input_structure(mdf_loc,input_m.mdf(ksim));
    
    %special case of grid change->copy to simulation folder
    if isfield(input_m.mdf,'NetFile')
        [~,fname_grd,fext_grd]=fileparts(input_m.mdf(ksim).NetFile);
        fnameext_grd=sprintf('%s%s',fname_grd,fext_grd);
        fpath_grd=fullfile(path_sim_loc,fnameext_grd);
        sts=copyfile_check(input_m.mdf(ksim).NetFile,fpath_grd);
        if ~sts
            fclose(fid_win);
            fclose(fid_lin);
            error('I cannot find the grid to be copied: %s',input_m.mdf(ksim).NetFile)
        end
        mdf_loc.geometry.NetFile=fnameext_grd;
    end
    
    %copy files
    D3D_write_sim_folder(path_sim_loc,path_file,mdf_loc);
    
    %lin
    fprintf(fid_lin,'cd ./%s \n',sim_id);  
    fprintf(fid_lin,'dos2unix %s \n',run_script_lin);
    fprintf(fid_lin,'./%s \n',run_script_lin);
    fprintf(fid_lin,'cd ../ \n');
    
    %win
    fprintf(fid_win,'cd %s \n',sim_id);  
    fprintf(fid_win,'start "w1" %s \n',run_script_win);
    fprintf(fid_win,'cd ../ \n');
    
    %disp
    messageOut(NaN,sprintf('Simulation created: %4.1f %%',ksim/nsim*100))
end

fclose(fid_lin);
copyfile(fout_c_lin,fout_lin);

fclose(fid_win);
copyfile(fout_c_win,fout_win);
