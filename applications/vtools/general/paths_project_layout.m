%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18069 $
%$Date: 2022-05-21 00:31:37 +0800 (Sat, 21 May 2022) $
%$Author: chavarri $
%$Id: paths_project_layout.m 18069 2022-05-20 16:31:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/paths_project_layout.m $
%
%Creates paths pf the project directory

function fpaths=paths_project(fpath_project)

if isunix
    fpath_project=linuxify(fpath_project);
end

fpaths.fdir_sim=fullfile(fpath_project,'06_simulations');
    fpaths.fdir_sim_in=fullfile(fpaths.fdir_sim,'01_input');
    fpaths.fdir_sim_runs=fullfile(fpaths.fdir_sim,'02_runs');
    
fpaths.fdir_data=fullfile(fpath_project,'05_data');
    

end %function