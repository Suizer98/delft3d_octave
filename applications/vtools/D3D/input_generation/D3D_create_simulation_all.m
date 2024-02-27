%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_create_simulation_all.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_create_simulation_all.m $
%

function D3D_create_simulation_all(flg,input_m,fdir_sim_runs,fcn_adapt)

%% save input matrix

mkdir_check(fdir_sim_runs);
fpath_input=fullfile(fdir_sim_runs,'readme.mat');
save(fpath_input,'input_m');
D3D_write_readme(input_m,'fpath_out',fullfile(fdir_sim_runs,'readme.txt'));

%% run files

[fid_lin,fid_win]=D3D_create_run_batch('open',fdir_sim_runs);

%% loop on simulations

nsim=numel(input_m.sim);
for ksim=1:nsim
    
    if input_m.sim(ksim).dorun==0; continue; end
    
    %% adapt input
    
    simdef=fcn_adapt(input_m.sim(ksim));
    simdef=D3D_rework(simdef); %defaults

    %% create files
    
    if ~flg.only_run_script

        sta=mkdir_check(simdef.D3D.dire_sim);
        if sta==2
            fprintf('Simulation already exists %s \n',simdef.D3D.dire_sim)
            if flg.overwrite==1
                fprintf('Deleting folder %s \n',simdef.D3D.dire_sim)
                erase_directory(simdef.D3D.dire_sim,1)
            else
                fprintf('Skipping folder %s \n',simdef.D3D.dire_sim)
                continue
            end
        end

        %% files

        %grid
        [dirloc]=fileparts(simdef.file.grd);
        mkdir_check(dirloc);
        if exist(simdef.file.grd,'file')~=2
            D3D_grid(simdef)
        end
        copyfile_check(simdef.file.grd,simdef.D3D.dire_sim); %copy to run location

        %morphological boundary conditions
    %     [dirloc]=fileparts(simdef.file.bcm);
    %     mkdir_check(dirloc)
    %     if exist(simdef.file.bcm,'file')~=2
    %         D3D_bcm(simdef)
    %     end

        %hydrodynamic boundary conditions 
        [dirloc]=fileparts(simdef.file.bc_wL);
        mkdir_check(dirloc);
        if exist(simdef.file.bc_wL,'file')~=2
            D3D_bct(simdef)
        end

        %initial bathymetry
        [dirloc]=fileparts(simdef.file.dep);
        mkdir_check(dirloc);
        if exist(simdef.file.dep,'file')~=2
            D3D_dep(simdef)
        end

        %initial bed grain size distribution
    %     D3D_mini(simdef)

        %initial flow conditions
        if simdef.D3D.structure==1
            D3D_fini(simdef)
        else 
            simdef.file.dep=simdef.file.etaw;
            [dirloc]=fileparts(simdef.file.dep);
            mkdir_check(dirloc);
            if exist(simdef.file.dep,'file')~=2
                simdef.ini.etab=simdef.ini.etab+simdef.ini.h; %changed here to missuse the creation of dep file for water level
                simdef.ini.noise_amp=-simdef.ini.noise_amp;
                simdef.ini.etab_noise=simdef.ini.etaw_noise;
                D3D_dep(simdef)
            end
    %         if simdef.ini.u~=0 || simdef.ini.v~=0
                D3D_fini_u(simdef)
    %         end
        end

        %boundary definition    
        [dirloc]=fileparts(simdef.file.extn);
        mkdir_check(dirloc);
        mkdir_check(simdef.file.fdir_pli);
        if exist(simdef.file.extn,'file')~=2
            D3D_bnd(simdef)
        end

        %morphology parameters
        [dirloc]=fileparts(simdef.file.mor);
        mkdir_check(dirloc);
        if exist(simdef.file.mor,'file')~=2
            D3D_mor(simdef,'check_existing',false)
        end

        %sediment parameters
        [dirloc]=fileparts(simdef.file.sed);
        mkdir_check(dirloc);
        if exist(simdef.file.sed,'file')~=2
            D3D_sed(simdef,'check_existing',false)
        end

        %sediment transport parameters
        if simdef.D3D.structure==1
            [dirloc]=fileparts(simdef.file.tra);
            mkdir_check(dirloc);
            if exist(simdef.file.tra,'file')~=2
                D3D_tra(simdef,'check_existing',false)
            end
        end

        %mdf/mdu        
        D3D_md(simdef,'check_existing',false)

        %runid
        if simdef.D3D.structure==1
            D3D_runid(simdef)
        end

        %observation points
        if simdef.mdf.Flhis_dt>0
            D3D_obs(simdef) 
        end

        %simdef
        fpath_simdef=fullfile(simdef.D3D.dire_sim,'simdef.mat');
        save(fpath_simdef,'simdef')
        
    end 
    
    %% run script

    [strsoft_lin,strsoft_win]=D3D_bat(simdef,input_m.sim(ksim).fpath_software);    
    D3D_create_run_batch('add',fdir_sim_runs,fid_lin,fid_win,simdef.runid.name,strsoft_lin,strsoft_win);
    
    %% erase run in p and move new
%     fpath_c=input_m.sim(ksim).path_sim;
%     fpath_p=strrep(fpath_c,fdir_project,fdir_project_p);
%     fpath_p_old=strrep(fpath_p,'02_runs','02_runs\00_old');
% %     copyfile_check(fpath_p,fpath_p_old);
%     erase_directory(fpath_p);
%     copyfile_check(fpath_c,fpath_p);
    
end

D3D_create_run_batch('close',fdir_sim_runs,fid_lin,fid_win);

end %function