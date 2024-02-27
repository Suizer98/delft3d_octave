Instructions for running and postprocessing results in Cartesius
----------------------------------------------------------------

For questions you can contact Victor Chavarrias (victor.chavarrias@deltares.nl), as I have written this file. Menno Genseberger (Menno.Genseberger@deltares.nl) manages the project in SURFsara and the contact there is Maxim Moge (maxime.moge@surf.nl).

%%
%% GETTING ACCESS TO CARTESIUS
%%

For getting access to cartesius, write an email to Maxim Moge with the following information:
- first name
- last name
- phone number
- email address
- nationality
- title
- organization
- project role
- public key to allow connection without a certificate

For knowing your public key, you can make a copy of the contents at H6 of file </u/[your-user-name]/.ssh/id_rsa.pub>

You will receive a username from SURF such as: pr1n0147@cartesius.surfsara.nl. In the rest of the readme file, this is referred to as <username>@cartesius.surfsara.nl. 

%%
%% CARTESIUS MANAGEMENT
%%

It is good practice to keep the same file structure in the p-drive as in Cartesius. This facilitates transferring files and keeping things in order. If you do this, the only difference in path names between the two drives is the first folder(s). E.g.:
H6:
                 /p/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_022/run_3.sh
Cartesius:
/projects/0/hisigem/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_022/run_3.sh

%% accessing cartesius

- Open an H6 terminal
- Type: ssh <username>@cartesius.surfsara.nl

%% copying a single small file to cartesius

- Open an H6 terminal
- Type: scp <filepath_in_h6> <username>@cartesius.surfsara.nl:<filepath_in_cartesius>

e.g. scp /p/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_022/run_3.sh pr1n0147@cartesius.surfsara.nl:/projects/0/hisigem/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_022/run_3.sh

%% copying a large file to cartesius

- Open an H6 terminal
- Type: rsync -av --bwlimit=5000 <filepath_in_h6> <username>@cartesius.surfsara.nl:<filepath_in_cartesius>

e.g.

rsync -av --bwlimit=5000 /p/11205258-016-kpp2020rmm-3d/C_Work/00_temporal/rmm_plot.tar.gz pr1n0147@cartesius.surfsara.nl:/projects/0/hisigem/11205258-016-kpp2020rmm-3d/E_Software_Scripts/ 

%% copying a file from Cartesius

- Open an H6 terminal
- Type: rsync -av --bwlimit=5000 <username>@cartesius.surfsara.nl:<filepath_in_cartesius> <filepath_in_h6> 

e.g.

rsync -av --bwlimit=5000 pr1n0147@cartesius.surfsara.nl:/projects/0/hisigem/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_026/DFM_OUTPUT_RMM_dflowfm/RMM_dflowfm_0000_his.nc /p/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_026/DFM_OUTPUT_RMM_dflowfm/RMM_dflowfm_0000_his.nc

%%
%% RUNNING AN FM SIMULATION IN CARTESIUS
%%

- Copy simulation files to Cartesius. In the simulation folder, place the running script. An example is given in this folder (<./shell/run.sh>). 
- Access Cartesius 
- Go to the simulatin folder
- Type: dos2unix run.sh
- Type: sbatch run.sh

You will see the <jobid> of the run, such as: 8916523
A log file is created with name: slurm-<jobid>.out

%% check status and cancel run

For checking the status of all your simulations type: 
squeue -u <username>
e.g.
squeue -u pr1n0147

For checking the status of one simulation type: 
scontrol show job <jobid>
e.g.
scontrol show job 8916523

For checking the log file use 'tail', as it may become huge:
tail -n <number_of_lines> <path_to_log_file>
e.g.
tail -n 10000 /projects/0/hisigem/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_030/slurm-9079971.out

For cancelling a run type:
scancel <jobid>
e.g.
scancel 8916523

%%
%% MATLABIZATION OF RUNNING A SIMULATION
%%

Use script <./matlab/main_copy2cartesius.m> to create the commands for running a simulation. Then you simply have to copy paste into an H6 and Cartesius terminal. 

Use script <./matlab/main_bring_data_back.m> to create the commands for bringing data back to the p-drive from Cartesius. Then you simply have to copy paste into an H6 and Cartesius terminal. 

Use shell-file <./shell/run_matlab.sh> to run matlab in Cartesius for postprocessing results. The OpenEarthTools are here:
/projects/0/hisigem/11205258-016-kpp2020rmm-3d/E_Software_Scripts/repositories/openearthtools_matlab/

In case this still exists when you are reading this file, you can use it or update it rather than transferring everything again. 
