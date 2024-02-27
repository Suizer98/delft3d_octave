%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17376 $
%$Date: 2021-07-02 22:00:24 +0800 (Fri, 02 Jul 2021) $
%$Author: chavarri $
%$Id: input_variation_01_runs_01_layout.m 17376 2021-07-02 14:00:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/input_variation_01_runs_01_layout.m $
%

function input_m=input_variation_01_runs_01(paths_input_folder,path_input_folder_refmdf,path_runs_folder)

%% input

sim_0=20; %first simulation to be created

input_m=input_variation_01(paths_input_folder,path_input_folder_refmdf);

%% add info

nsim=numel(input_m.sim);
for ksim=1:nsim
    sim_num=sim_0+ksim-1;
    sim_id=sprintf('r%03d',sim_num);
    
    input_m.sim(ksim).sim_num=sim_num;
    input_m.sim(ksim).sim_id=sim_id;
    input_m.sim(ksim).path_sim=fullfile(path_runs_folder,sim_id);
end

end %function