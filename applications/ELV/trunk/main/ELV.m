%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17215 $
%$Date: 2021-04-29 13:40:02 +0800 (Thu, 29 Apr 2021) $
%$Author: chavarri $
%$Id: ELV.m 17215 2021-04-29 05:40:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/ELV.m $
%
%ELV is the main function of the model
%
%ELV(path_file_input,fid_log)
%
%INPUT:
%   -path_file_input = path to the file input.mat; [char]; 
%	-fid_log = log file identifier
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160415
%   -V. First Initial Condition and then Boundary Condition in case you
%   want equilibrium BC.
%
%160614
%   -V. Output pmm for adjusting CFL condition
%
%160429
%   -L. Introduce funtion conditions_construction
%
%160803
%	-L merged Vv3, Lv3
%
%161010
%   -L&V. Nourishment crap
%
%170126
%   -L. Repetitive nourishments
%
%170317
%   -V. Mean loop time
%
%170324
%   -V. Friction correction
%
%170720
%   -V & Pepijn. starting to mess up addng branches
%
%181104
%   -V. Add possibility of CFL based time step
%
%181125
%   -V. Uniformity beteween two ways of time step
%
%200403
%   -V. Deposition of immobile fractions.
%
%210315
%   -V. Added interpolation at edges.

function ELV(path_file_input,fid_log)

%% 
%% INITIALIZATION
%% 

%% INPUT READING

fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'Start of input reading');
load(path_file_input,'input'); 

%% INPUT CHECK

fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'Start of input checking');
input=check_input(input,path_file_input,fid_log); 

%% 
%% PREPROCESSING
%% 

%% PREALLOCATE OTHER VARIABLES AND COUNTERS

% nourcount=1; %nourishment counter
ktl=1; %start time_loop counter
tic_display=tic; %tic to control display in screen
tic_totaltime=tic; %tic to track total simulation time
time_l=input(1,1).mdv.t0; %time of the time step which is being computed
kt=1; %time steps counter
[u_bra,h_bra,etab_bra,Mak_bra,La_bra,msk_bra,Ls_bra,Cf_bra,Cf_b_bra,qbk_bra,thetak_bra,pmm_bra,ell_idx_bra,Gammak_bra,Ek_bra,Dk_bra,psi_bra,u_edg_bra,h_edg_bra,qbk_edg_bra,Cf_b_edg_bra,Mak_edg_bra,La_edg_bra,celerities,celerities_edg,pmm_edg_bra,bc,time_loop]=preallocate_dependent_vars(input,fid_log);
vpk=NaN; %this is necessary in case you have CFL-based time step and morphodynamics do not start in the first time step. Maybe I should move it inside preallocating. 

%% INITIAL AND BOUNDARY CONDITION CONSTRUCTION

fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'Start of initial and boundary condition construction');
for kb=1:input(1,1).mdv.nb
    [u_bra{kb,1},h_bra{kb,1},etab_bra{kb,1},Mak_bra{kb,1},La_bra{kb,1},msk_bra{kb,1},Ls_bra{kb,1},Cf_bra{kb,1},Gammak_bra{kb,1},bc(kb,1)]=condition_construction(input(kb,1),fid_log);
end

%% WRITE t0

fprintf(fid_log,'%s %s\n',datestr(datetime('now')),'Start of t0 conditions saving');
write_results(input(1,1),fid_log,1)
t_nsr=input.mdv.Flmap_dt; %time of next save results [s];
kts=2; %saving time counter (in 1 there is the initial condition)

%% 
%% TIME LOOP
%% 

while time_l<=input(1,1).mdv.Tstop

tic_looptime=tic; %tic to track time spent in loop

%% FLOW UPDATE
[u_bra,h_bra,bc]=flow_update(u_bra,h_bra,etab_bra,Cf_bra,bc,input,fid_log,kt,time_l); 

%% MORPHOLOGY UPDATE
if time_l>=input(1,1).mor.Tstart
    
    %% LOOP ON BRANCHES FOR SEDIMENT TRANSPORT
    for kb=1:input(1,1).mdv.nb
        
        %% FRICTION CORRECTION
        [Cf_b_bra{kb,1}]=friction_correction(u_bra{kb,1},h_bra{kb,1},Cf_bra{kb,1},Mak_bra{kb,1},La_bra{kb,1},input(kb,1),fid_log,kt);
        
        %% SEDIMENT TRANSPORT
       %[qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq]
        [qbk,~  ,thetak,~     ,~    ,~   ,~  ,~     ,Ek,~    ,Ek_g,Dk,~    ,Dk_g,vpk,~     ,Gammak_eq]=sediment_transport(...
            input(kb,1).aux.flg,input(kb,1).aux.cnt,h_bra{kb,1}',(u_bra{kb,1}(1,:).*h_bra{kb,1})',Cf_b_bra{kb,1},La_bra{kb,1}',Mak_bra{kb,1}',input(kb,1).sed.dk,input(kb,1).tra.param,input(kb,1).aux.flg.hiding_parameter,1,input.tra.E_param,input.tra.vp_param,Gammak_bra{kb,1}',fid_log,kt);
        qbk_bra{kb,1}=qbk';
        thetak_bra{kb,1}=thetak';
        Ek_bra{kb,1}=Ek';
        Ek_g=Ek_g';
        Dk_bra{kb,1}=Dk';
        Dk_g=Dk_g';
        vpk=vpk';
        Gammak_eq=Gammak_eq';
        
        %% INTERPOLATE
        [u_edg_bra{kb,1},h_edg_bra{kb,1},Cf_b_edg_bra{kb,1},La_edg_bra{kb,1},Mak_edg_bra{kb,1},qbk_edg_bra{kb,1},celerities_edg(kb,1),pmm_edg_bra{kb,1}]=interpolate_at_edges(input(kb,1),u_bra{kb,1},h_bra{kb,1},Cf_b_bra{kb,1},La_bra{kb,1},Mak_bra{kb,1},celerities(kb,1),pmm_bra{kb,1},fid_log);

        %% STRUIKSMA REDUCTION
        [qbk_bra{kb,1},psi_bra{kb,1}]=struiksma_reduction(qbk_bra{kb,1},La_bra{kb,1},Ls_bra{kb,1},Mak_bra{kb,1},msk_bra{kb,1},input(kb,1),fid_log);

        %% PARTICLE ACTIVITY
        Gammak_bra{kb,1}=particle_activity_update(Gammak_bra{kb,1},u_bra{kb,1},h_bra{kb,1},etab_bra{kb,1},Mak_bra{kb,1},La_bra{kb,1},Cf_bra{kb,1},Cf_b_bra{kb,1},vpk,Ek_g,Dk_g,Gammak_eq,bc(kb,1),input(kb,1),fid_log,kt,time_l);

    end

    %% NODAL POINT RELATION
    if input(1,1).mdv.nb~=1
        bc=nodal_point_distribution(u_bra,h_bra,etab_bra,qbk_bra,thetak_bra,Cf_bra,bc,input,fid_log,kt);
    end

    %% LOOP ON BRANCHES FOR MORPHOLOGY UPDATE
    for kb=1:input(1,1).mdv.nb
        %% BED LEVEL UPDATE
        etab_old=etab_bra{kb,1}; %for Hirano
        pmm_bra{kb,1}=ones(2,input.mdv.nx); %update without preconditioning
        etab_bra{kb,1}=bed_level_update(etab_bra{kb,1},qbk_bra{kb,1},Dk_bra{kb,1},Ek_bra{kb,1},bc(kb,1),input(kb,1),fid_log,kt,time_l,pmm_bra{kb,1},celerities(kb,1),u_bra{kb,1},u_edg_bra{kb,1},qbk_edg_bra{kb,1},pmm_edg_bra{kb,1},celerities_edg(kb,1));

        %% ACTIVE LAYER THICKNESS UPDATE
        La_old=La_bra{kb,1}; %for Hirano
        La_bra{kb,1}=active_layer_thickness_update(h_bra{kb,1},Mak_bra{kb,1},La_bra{kb,1},etab_bra{kb,1},etab_old,psi_bra{kb,1},bc(kb,1),input(kb,1),fid_log,kt,time_l);

        %% GRAIN SIZE DISTRIBUTION UPDATE

        %save for the check
        Mak_old=Mak_bra{kb,1}; 
        msk_old=msk_bra{kb,1};
        Ls_old=Ls_bra{kb,1};
        [Mak_bra{kb,1},msk_bra{kb,1},Ls_bra{kb,1},La_bra{kb,1},etab_bra{kb,1},ell_idx_bra{kb,1},celerities(kb,1),pmm_bra{kb,1}]=grain_size_distribution_update(...
            Mak_bra{kb,1},msk_bra{kb,1},Ls_bra{kb,1},La_old,La_bra{kb,1},etab_old,etab_bra{kb,1},qbk_bra{kb,1},Dk_bra{kb,1},Ek_bra{kb,1},bc(kb,1),u_bra{kb,1},h_bra{kb,1},Cf_b_bra{kb,1},input(kb,1),fid_log,kt,time_l);

        %% FRICTION UPDATE
        Cf_bra{kb,1}=friction(h_bra{kb,1},Mak_bra{kb,1},Cf_bra{kb,1},La_bra{kb,1},input(kb,1),fid_log,kt);
        
        %% CHECK SIMULATION
        check_simulation(u_bra{kb,1},u_edg_bra{kb,1},h_bra{kb,1},h_edg_bra{kb,1},Mak_bra{kb,1},Mak_old,msk_bra{kb,1},msk_old,La_bra{kb,1},La_old,Ls_bra{kb,1},Ls_old,etab_bra{kb,1},etab_old,qbk_bra{kb,1},qbk_edg_bra{kb,1},bc(kb,1),ell_idx_bra{kb,1},celerities(kb,1),pmm_bra{kb,1},vpk,input(kb,1),fid_log,kt,time_l);

    end %kb
end %if time_l>input.mor.Tstart

%% RESULTS WRITING

if time_l>=t_nsr %due to round off error it may be possible that last results is not savec...
    display_tloop(time_loop,input(1,1),fid_log,kt,kts,time_l,tic_totaltime)
    write_results(input(1,1),fid_log,kts)
    kts=kts+1; %time save counter
    t_nsr=floor(time_l/input.mdv.Flmap_dt)*input.mdv.Flmap_dt+input.mdv.Flmap_dt; %next time at which we have to save results
end

%% NOURISHMENT

%ATTENTION! This parts needs to be updated accounting for the possibility of using a CFL based time step.

%nourishment needs to be after saving results for having consistent flow and morphology
% for kb=1:input(1,1).mdv.nb
%     if kt*input(kb,1).mdv.dt == input(kb,1).nour.t(nourcount)
%         [Mak_bra{kb,1},msk_bra{kb,1},Ls_bra{kb,1},La_bra{kb,1},etab_bra{kb,1}]=add_nourishment(Mak_bra{kb,1},msk_bra{kb,1},Ls_bra{kb,1},La_bra{kb,1},etab_bra{kb,1},h_bra{kb,1},input(kb,1),fid_log,kt);
%         nourcount = nourcount + 1;
%     end
% end
    
%% TIME STEP

switch input(1,1).mdv.dt_type
    case 1
        time_l=time_l+input(1,1).mdv.dt;
    case 2
        [input,time_l]=time_step(u_bra{kb,1},h_bra{kb,1},celerities,pmm_bra{kb,1},vpk,input(1,1),fid_log,kt,time_l); %here there will be a problem with more than one branch. This function needs to be modified to change input.mdv.dt in all branches according to the max CFL of all the branches
end
kt=kt+1; %update time step counter

%% DISPLAY

time_loop(ktl)=toc(tic_looptime);
ktl=ktl+1; %update time_loop counter
if toc(tic_display)>input(1,1).mdv.disp_time
    display_tloop(time_loop,input(1,1),NaN,kt,kts-1,time_l,tic_totaltime) %using NaN on fid_log we print on scrint
    tic_display=tic; %reset display tic
    ktl=1; %reset time_loop counter
end

end %time loop

%% PUT OUTPUT FILES TOGETHER

input=get_nT(input,fid_log); 
output_creation(input,fid_log)
join_results(input,fid_log);
erase_directory(input(1,1).mdv.path_folder_TMP_output,fid_log)

