%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17115 $
%$Date: 2021-03-16 06:06:55 +0800 (Tue, 16 Mar 2021) $
%$Author: chavarri $
%$Id: check_mdv.m 17115 2021-03-15 22:06:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/check_mdv.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%input_out=check_input(input,path_file_input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -input = variable containing the input [struct] e.g. input
%
%HISTORY:
%170720
%   -V & Pepijn. Created for the first time.
%
%200925
%   -V. deblank save variables

function input_out=check_mdv(input,path_file_input,fid_log)

%% type of time steping method
if isfield(input.mdv,'dt_type')==0
    input.mdv.dt_type=1; %default is fixed time step
end

switch input.mdv.dt_type
    case 1 %fixed time step
        if isfield(input.mdv,'dt')==0
            error('Specify time step')
        end     
        if isfield(input.mdv,'cfl')==1
            warningprint(fid_log,'You are setting a max CFL for computing time step but the method is fixed time step')
        end     
    case 2 %fixed CFL
        if isfield(input.mdv,'cfl')==0
            error('Specify CFL')
        end     
        if input.mdv.cfl>1
            warningprint(fid_log,'Your CFL to march in time is larger than 1. I do not think that this will work dude...')
        end
        if (isfield(input.mor,'Tstart')==0 || input.mor.Tstart>0) && (isfield(input.mdv,'flowtype')==0 || any(input.mdv.flowtype==[0,1])) && isfield(input.mdv,'dt')==0
            error('You are not specifying a time step because you want CFL based time step, but you want to start morphodynamic changes aget Tstart and use steady flow. Hence, I have no manner to compute the celerities after we start morpho changes, so I need a dt')
        else
            if isfield(input.mdv,'dt')==0
                warningprint(fid_log,'You are not setting the first time step. I will use 1e-6.')
                input.mdv.dt=1e-6;
            end 
        end
  
        if (isfield(input.mor,'ellcheck')==0 || input.mor.ellcheck==0) && input.mor.particle_activity==0 
            input.mor.ellcheck=1;
            warningprint(fid_log,'You are not checking for ill-posedness, but it is necessesary to do so if you want to update the time step based on your CFL condition.')
        end   
        
    otherwise
        error('You want to use the magic time step method. Not yet implemented, sorry')
end

%% number of elements and vectors
switch input.mdv.dt_type
    case 1
        input.mdv.nt=round(input.mdv.Tstop/input.mdv.dt); %number time steps [-] 
    case 2
        input.mdv.nt=NaN; %we do not know in advance. Better NaN in case we need it for something later. 
end
input.mdv.nx=round(input.grd.L/input.grd.dx); %number of grid points in space [-] 
input.mdv.nf=numel(input.sed.dk); %number of sediment size fraction [-]
input.mdv.nef=input.mdv.nf-1; %number of effective sediment size fraction [-]

if input.mdv.nf~=1
    input.mdv.nsl=round(input.mor.total_ThUnLyr/input.mor.ThUnLyr); %number of vertical layers for substrate discretisation [-] 
    if input.mdv.nsl==1
        warningprint(fid_log,'When there is only one substrate layer it may be problematic, I suggest you make it at least 2')
    end
else
    input.mdv.nef=1;
    input.mdv.nsl=1;
    input.mor.ThUnLyr=NaN;
    input.mor.La=NaN; %active layer thickness [m]; [1x1 double]; e.g. [0.1]
    input.ini.Fak=NaN; %effective fractions at the active layer [-]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2;0.3]
    input.ini.fsk=NaN; %effective fractions at the substrate [-]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2;0.3]
end

% switch input.mdv.dt_type
%     case 1
%         input.mdv.time=0:input.mdv.dt:input.mdv.nt*input.mdv.dt; %time vector [s]
%         input.mdv.time_results=0:input.mdv.Flmap_dt:input.mdv.nt*input.mdv.dt; %saving time vector [s]
%         input.mdv.nT=numel(input.mdv.time_results); %number of results [-]
%     case 2
%         input.mdv.time=NaN; %time vector [s]
%         input.mdv.time_results=NaN; %saving time vector [s]
%         input.mdv.nT=NaN; %number of results [-]
% end
input.mdv.xedg=0:input.grd.dx:input.mdv.nx*input.grd.dx; %cell edges vector x coordinate vector [m]
input.mdv.xcen=input.grd.dx/2:input.grd.dx:input.mdv.nx*input.grd.dx-input.grd.dx/2; %cell centers vector x coordinate vector [m]

% input.mdv.Tstop_round=nt*input.mdv.dt; %real computational time [s]
% input.mdv.L_round=nx*input.mdv.dx;%real domain length [m]

%% solver

if isfield(input.mdv,'flowtype')==0
    input.mdv.flowtype=1;
    input.mdv.steady_solver=1;
    warningprint(fid_log,'Solver not specified, using steady energy-Euler')
end

if input.mdv.flowtype==1 && isfield(input.mdv,'steady_solver')==0
    input.mdv.steady_solver=1;
    warningprint(fid_log,'Steady solver not specified, using energy-Euler')
end

if isfield(input.mdv,'UpwFac')==0
    input.mdv.UpwFac=1;
end

if input.mdv.UpwFac~=1
    warningprint(fid_log,'You are using a non-upwind scheme for Exner and Hirano. For a positive charactersitc celerity this is unstable, you better know what you are doing...')
end

if isfield(input.mdv,'ade_solver')==0
    input.mdv.ade_solver=2;
end

%% version

if verLessThan('matlab','9.1')
   error('You are using a Matlab version older than R2016b. Some functions will not work. If you do not want to upgrade, change the name of the functions in the ''main'' folder that have a ''~_2016b'' (remove the tag, thus overwriting the newer functions)')  
end

%% email
if isfield(input.mdv,'email')==0 %if it does not exist
    input.mdv.email.send=0; %0=NO; 1=YES
end
if input.mdv.email.send==1
    if isnumeric(input.mdv.email.password_coded)==0
        error('encode your password in input.mdv.email.password_coded')
    end
end

%% save method
if isfield(input.mdv,'savemethod')==0 %if it does not exist
    input.mdv.savemethod=2; %1=directly in one file; 2=first in individual files
end

%% starting time step
if isfield(input.mdv,'t0')==0 %if it does not exist
    input.mdv.t0=0; %time to start
end

if input.mdv.t0==1
    warningprint(fid_log,'You want to start the simulation at t0=1s. This may be correct but most probably you have not adapted an old script. This variable used to be time step but now it is absolute time.')
end
%% display time 
if isfield(input.mdv,'disp_time')==0 %if it does not exist
    input.mdv.disp_time=1;
end
if isunix==1
    warningprint(fid_log,'It seems you are using a Unix machine, are you using the cluster? If the answer is "yes I do" the you should set the parameter input.mdv.disp_time equal to input.mdv.Tstop+1 so that there is no screen display')
end

%% check
if isfield(input.mdv,'chk')==0 
    input.mdv.chk.mass=1; %mass check [-]; [1x1 double]; e.g. [1]
    input.mdv.chk.dM_lim=1e-5; %mass error limit [m^2, -!!]; [1x1 double]; e.g. [1e-8]
    input.mdv.chk.flow=1; %Froude and CFL check [-]; [1x1 double]; e.g. [1]
    input.mdv.chk.Fr_lim=0.8; %Fr limit [-]; [1x1 double]; e.g. [0.8]
    input.mdv.chk.cfl_lim=0.95; %CFL limit [-]; [1x1 double]; e.g. [0.95]
    input.mdv.chk.Pe_lim=2; %Peclet limit [-]; [1x1 double]; e.g. [2]
    input.mdv.chk.F_lim=0.01; %maximum error in volume fractions [-]; [1x1 double]; e.g. [0.01]
    input.mdv.chk.nan=1; %check for NaN in variables 0=NO; 1=YES;
    input.mdv.chk.ell=0; %display check for ellipticity 0=NO; 1=YES;
    input.mdv.chk.pmm=0; %display check for pmm 0=NO; 1=YES;
    input.mdv.chk.disp_Mak_update=0; %display filter of Mak update 0=NO; 1=YES;
end

if isfield(input.mdv.chk,'mass')==0 
    input.mdv.chk.mass=1; %mass check [-]; [1x1 double]; e.g. [1]
    input.mdv.chk.dM_lim=1e-5; %mass error limit [m^2, -!!]; [1x1 double]; e.g. [1e-8]
else
    if isfield(input.mdv.chk,'dM_lim')==0 
        warningprint(fid_log,'You want to check if you lose mass but you are not specifying a limit (input.mdv.chk.dM_lim), I am using the default value of 1e-5')
        input.mdv.chk.dM_lim=1e-5; %mass error limit [m^2, -!!]; [1x1 double]; e.g. [1e-8]
    end
end

if isfield(input.mdv.chk,'flow')==0 
    input.mdv.chk.flow=1; %Froude and CFL check [-]; [1x1 double]; e.g. [1]
    input.mdv.chk.Fr_lim=0.8; %Fr limit [-]; [1x1 double]; e.g. [0.8]
    input.mdv.chk.cfl_lim=0.95; %CFL limit [-]; [1x1 double]; e.g. [0.95]
else
    if isfield(input.mdv.chk,'Fr_lim')==0 
        warningprint(fid_log,'You want to check the Froude number but you are not specifying a limit (input.mdv.chk.Fr_lim), I am using the default value 0.80')
        input.mdv.chk.Fr_lim=0.8; %Fr limit [-]; [1x1 double]; e.g. [0.8]
    end
    if isfield(input.mdv.chk,'cfl_lim')==0 
        warningprint(fid_log,'You want to check the CFL number but you are not specifying a limit (input.mdv.chk.cfl_lim), I am using the default value of 0.95')
        input.mdv.chk.cfl_lim=0.95; %CFL limit [-]; [1x1 double]; e.g. [0.95]
    end
end

if isfield(input.mdv.chk,'F_lim')==0 
    input.mdv.chk.F_lim=0.01; %maximum error in volume fractions [-]; [1x1 double]; e.g. [0.01]
end    
    
if isfield(input.mdv.chk,'nan')==0 
    input.mdv.chk.nan=1; %check for NaN in variables 0=NO; 1=YES;
end 

if isfield(input.mdv.chk,'ell')==0 
    input.mdv.chk.ell=0; %display check for ellipticity 0=NO; 1=YES;
end 

if isfield(input.mdv.chk,'pmm')==0 
    input.mdv.chk.pmm=0; 
end 

if isfield(input.mdv.chk,'Pe_lim')==0 
    input.mdv.chk.Pe_lim=2; %Peclet limit [-]; [1x1 double]; e.g. [2]
end 

if isfield(input.mdv.chk,'disp_Mak_update')==0 
    input.mdv.chk.disp_Mak_update=0; %display filter of Mak update 0=NO; 1=YES;
end 

%% CONSTANTS

if isfield(input.mdv,'g')==0 
    input.mdv.g=9.81;
end
if isfield(input.mdv,'nu')==0 
    input.mdv.nu=1e-6;
end
if isfield(input.mdv,'rhow')==0 
    input.mdv.rhow=1000;
end
if isfield(input.sed,'rhos')==0 
    input.sed.rhos=2650;
end

if isfield(input.mdv,'dd')==0 
    input.mdv.dd=1e-8; %diferential
end

%% PATHS

if isfield(input.mdv,'path_folder_main')==0 %if it does not exist the path to the main file
    [path_folder_main,~,~]=fileparts(path_file_input); %get path to main folder
    input.mdv.path_folder_main=path_folder_main;
end

if isfield(input.mdv,'path_folder_results')==0 %if it does not exist the path to the results folder
    input.mdv.path_folder_results=input.mdv.path_folder_main; %path to result folder 
end

if isfield(input.mdv,'path_file_output')==0 %if it does not exist the path to the output file
    input.mdv.path_file_output=fullfile(input.mdv.path_folder_main,'output.mat'); %path to the output file
end

%attention! this two folders are hardcoded in folders_creation because that function is called before check_input. Do not change (or do it with care :D )
%this should be changed by changint the function order
input.mdv.path_folder_TMP_output=fullfile(input.mdv.path_folder_main,'TMP_output'); %path to the temporal results output
input.mdv.path_folder_figures=fullfile(input.mdv.path_folder_main,'figures'); %path to the figures files

%% DISPLAY TIME

if isfield(input.mdv,'disp_t_nt')==0
    input.mdv.disp_t_nt=floor(input.mdv.Flmap_dt/input.mdv.dt);   
end
if mod(input.mdv.disp_t_nt,1)~=0
    warningprint(fid_log,'The value you input in input.mdv.disp_t_nt is not an integer. I have rounded it.')
    input.mdv.disp_t_nt=round(input.mdv.disp_t_nt);
end
if input.mdv.disp_t_nt>floor(input.mdv.Flmap_dt/input.mdv.dt)
    warningprint(fid_log,'The value you ask to average the time needed in each loop is larger than the saving time, I do not like you to waste computational time. I set it to the maximum. Check input.mdv.disp_t_nt')
    input.mdv.disp_t_nt=floor(input.mdv.Flmap_dt/input.mdv.dt);
end
if input.mdv.disp_t_nt>1e5
    warningprint(fid_log,'The value for averaging the output time is huge. This is probably because you have automatic time steping. Consider setting it manually or increasing the first time step. I am setting it to 1000')
    input.mdv.disp_t_nt=1000;
end

%% SAVE VARIABLES

if isfield(input.mdv,'output_var')==0
    warningprint(fid_log,'You are not saving any results! add input.mdv.output_var')
    input.mdv.output_var={};
end

input.mdv.output_var={input.mdv.output_var{:},'time_l'}; %#ok %You always have to save this one.
input.mdv.output_var=cellfun(@deblank,input.mdv.output_var,'UniformOutput',0); %deblank for preventing that a space is added in the variable name to save.
input.mdv.no=numel(input.mdv.output_var); %number of output variables [-]

%test that time_loop is not saved if we use CFL based time step
if input.mdv.dt_type==2
    isthere=strcmp(input.mdv.output_var,'time_loop');
    if any(isthere)
        warningprint(fid_log,'You want to save time_loop and compute time_step based on CFL. This is not possible at this moment. I am not saving time_loop.')
    end
    v_all=1:1:input.mdv.no;
    v_get=v_all(~isthere);
    input.mdv.output_var=input.mdv.output_var(1,v_get);
    input.mdv.no=numel(input.mdv.output_var); %number of output variables [-]
end

%create branches saving string
input.mdv.output_var_bra=cell(1,input.mdv.no);
for ko=1:input.mdv.no
    switch input.mdv.output_var{ko}
        case {'time_loop','celerities','time_l'}
            input.mdv.output_var_bra{1,ko}=input.mdv.output_var{ko};
        otherwise
            input.mdv.output_var_bra{1,ko}=strcat(input.mdv.output_var{ko},'_bra');
    end
end
    
%% TYPE OF INTERPOLATION OF THE BOUNDARY CONDITION

if isfield(input.mdv,'bc_interp_type')==0
    switch input.mdv.dt_type
        case 1
            input.mdv.bc_interp_type=1; %default is to interpolate at the beggining
        case 2
            input.mdv.bc_interp_type=2; %default is to interpolate at each time step
    end
end

if input.mdv.bc_interp_type==1 && input.mdv.dt_type==2
    error(fid_log,'You want to compute the time step based on CFL and interpolate the boundary conditions at the beginning. This is not possible!')
    input.mdv.bc_interp_type=2;
end

if input.mdv.bc_interp_type==1
    input.mdv.time=0:input.mdv.dt:input.mdv.nt*input.mdv.dt; %time vector [s] needed to interpolate the boundary conditions
end

%% edges interpolation

if isfield(input.mdv,'interp_edges')==0
input.mdv.interp_edges=0; %do not conduct interpolation at edges
end

%% OUTPUT 

input_out=input;