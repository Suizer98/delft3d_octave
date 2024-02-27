%input_single_ELV is a script that creates the input variable input.mat to run a single
%simulation

%HISTORY:
%160223
%   -V. Created for the first time.


%% 
%% MASTER DEFINITION VARIABLES
%% 

input.mdv.flowtype=1; %flow assumption: 0=NO update 1=steady; 2=quasi-steady; 3=unsteady (explicit); 4=unsteady (implicit); [-]; 6=steady with floodplains [1x1 double]; e.g. [1]
input.mdv.steady_solver=1; %(if input.mdv.flowtype=1); steady solver: 1=energy-Euler; 2=energy-RK4; 3=depth-Euler; 4=depth-RK4; [1x1 double]; default=1
% input.mdv.fluxtype=1; %flux type (only if flowtype=3): 0=upwind; 1=Lax-Wendroff; 2=Beam-Warming; 3=Fromm; 4=minmod; 5=van Leer; 6=superbee; 7=MC; 8=Koren [-]; [1x1 double]; e.g. [1]
% input.mdv.ade_solver=1; %solver for advection diffusion equation (for particle activity): [1x1 double]; e.g. [2]
    %1=theta-method in time, CS for advection, CS for diffusion;
    %2=theta-method in time, BS for advection, CS for diffusion;
% input.mdv.theta=0.5; %theta in theta-method for particle activity equation; 0=FTCS; 0.5=Crank-Nicolson; 1=BTCS
input.mdv.Tstop=3600*10; %simulation time [s]; [1x1 double]; e.g. [3600]
input.mdv.dt_type=1; %type of time step method [-]: 1=fixed time step; 2=fixed CFL number; [1x1 double]; e.g. [1]  
input.mdv.dt=5.00; %time step [s]; [1x1 double]; e.g. [2] When using input.mdv.dt_type=2 this is the first time step.
% input.mdv.cfl=0.9; %CFL number to compute time step [-]; [1x1 double]; e.g. [0.9] 
% input.mdv.bc_interp_type=1; %type of interpolation of the boundary conditions: 1=interpolate at the beginning and create bc structure; 2=interpolate at each time step [-]; [1x1 double]; e.g. [1] 
input.mdv.Flmap_dt=600; %printing map-file interval time [s]; [1x1 double]; e.g. [60]  
% input.mdv.disp_t_nt=100; %number of time steps to average the time needed to finish the simulatin [-]; [1x1 double]; e.g. [100]  
% input.mdv.disp_time=1; %time in between displays in screen [s]; [1x1 double]; e.g. [1]  
input.mdv.rhow=1000; %water density [kg/m^3]; [1x1 double]; e.g. [1000]
input.mdv.g=9.81; %gravity constant [m/s^2]; [1x1 double]; e.g. [9.81]
input.mdv.nu=1e-6; %kinematic viscosity of water [m^2/s]; [1x1 double]; e.g. [1e-6]
input.mdv.output_var={'u','h','etab','Mak','La','msk','Ls','qbk','Cf','Gammak','ell_idx','time_loop'}; %map variables name to output; 
input.mdv.chk.mass=0; %mass check [-]; [1x1 double]; e.g. [1]
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
input.mdv.dd=1e-8; %diferential

input.mdv.savemethod=2; %1=directly in one file; 2=first in individual files
% input.mdv.t0=0; %starting time of the simulation [s]; [1x1 double]; e.g. [3600] !there was a change in the definition of this variable. It was time step and now it is absolute time.

% input.mdv.email.send=0; %0=NO; 1=YES
% input.mdv.email.sender_mailAddress='v.chavarriasborras@tudelft.nl'; %use only TUD email
% input.mdv.email.recipient_mailAddress='chavarrias.v@gmail.com';
% input.mdv.email.userName='victorchavarri';
% input.mdv.email.password_coded=[5682;5651;6481;5854;5879;6359;5527;5800;5556;5643;6238;6046;6191;5956;5224;5645;5717;6007;5683;6225;6411;6114;6494;5796;6563;5683;5255;5217;5367;6060];

% input.mdv.path_folder_main='c:\Users\victorchavarri\temporal\ELV\A\001\'; %full path to the main folder run [string]; default is the same as the input.mat
% input.mdv.path_folder_results='c:\Users\victorchavarri\temporal\ELV\A\001\'; %full path to the folder where you want to store the output.mat and other files that you may create; default is the same as the input.mat
% input.mdv.path_file_output='c:\Users\victorchavarri\temporal\ELV\A\001\output.mat'; %full path to the file output.mat (you can use this to change the name of the output file); default is the same as the input.mat and it is called output.mat

%%
%% FRICTION
%%

input.frc.Cf_type=1; %friction type: 1=constant; 2=related to grain size; 3=related to flow depth; 4=related to active layer [1x1 double]; e.g. [1]
input.frc.Cf=0.01; %friction coefficient [-]; [1x1 double]; e.g. [0.008]
input.frc.wall_corr=0; %flume wall correction: 0=NO; 1=Johnson (1942); 
input.frc.Cfb_model=0; %skin friction model: 0=plane bed (Cf_b=Cf); 2=Nikuradse (1933); 3=imposed bed friction coefficient; 4=related to active layer thickness; 5=Engelund-Hansen (1967); 6=Wright and Parker (2004); 7=Smith and McLean (1977); 8=Haque (1983)
% input.frc.Cfb=0.008; %nondimensional bed friction coefficient 
% input.frc.ripple_corr=0; %type of ripple correction (in case input.frc.Cfb_model=7): 1=constant values; 2=depending on active layer
% input.frc.H=0.01; %bed form height [m]
% input.frc.L=0.1; %bed form length [m]
% input.frc.nk=2; %ks=nk*max(dx) (Nikuradse roughness length) [-]
% input.frc.Cf_param=[0.1981,0.0055]; %[a,b] parameters of Cf=a*La+b; [1x2 double]
% input.frc.Cfb_param=[0.1981,0.0055]; %[a,b] parameters of Cfb=a*La+b; [1x2 double]
% input.frc.H_param=[2,0]; %[a,b] parameters of H=a*La+b; [1x2 double]
% input.frc.L_param=[(1.79-0.99)/(0.061-0.009),1.79-(1.79-0.99)/(0.061-0.009)*0.061]; %[a,b] parameters of L=a*La+b; [1x2 double]

%% 
%% GRID
%% 

input.grd.L=100; %domain length [m]; [1x1 double]; e.g. [100]
input.grd.dx=0.1; %streamwise discretizations [m]; [1x1 double]; e.g. [0.1]
input.grd.B=1; %width [m]; [1x1 double] | [1xnx double]; e.g. [10]

%% 
%% MORPHOLOGY
%% 

input.mor.bedupdate=1; %update bed elevation 0=NO; 1=YES [-]; e.g. 1
input.mor.gsdupdate=1; %update grain size distribution 0=NO; 1=Hirano ;2=eli 1 (max. La); 3=eli 1 (min. La); 4=pmm (a<1,b~=1); 5=pmm (a>1,b~=1); 6=(a<1,b=1); 7=(a>1,b=1); 8=impose a (by means of pmm_alpha_eps); 9=a_m (M_eta=1/b, M_Fak=1/(a*b)); [-]; e.g. 1 
input.mor.scheme=0; %morphodynamic numerical scheme 0=FTBS (old style); 1=FTBS (new style); 2=Boorsbom [1x1 double]; e.g. [0] 
input.mor.fluxtype=8; %same as input.mdv.fluxtype
% input.mor.pmm_alpha_eps=0.01; %fraction added to alpha to avoid equal eigenvalues; [1x1 double]; e.g. [0.05]
input.mor.particle_activity=0; %use particle activity model 0=NO; 1=YES [-]; [1x1 double]; e.g. [0]
input.mor.ellcheck=0; %ellipticity check 0=NO; 1=YES (full model); 2=YES (approximate model) [-]; e.g. 1
input.mor.interfacetype=1; %fractions at the interface 1=Hirano; 2=Hoey and Ferguson [-]; [1x1 double];
% input.mor.fIk_alpha=1; %Hoey and Ferguson parameter (0=100% active layer, 1=100% bed load) [-]; [1x1 double];
input.mor.porosity=0.4; %porosity [-]; [1x1 double]; e.g. [0.4]
input.mor.Latype=1; %active layer assumption: 1=constant thickness; 2=related to grain size; 3=related to flow depth; 4=growing with time [-]; [1x1 double]; e.g. [1]
% input.mor.timeLa=[0;3600*4;input.mdv.Tstop];  %time at which the input is specified [s]; [nix1 double]; e.g. [1800;3600]
input.mor.La=0.01; %active layer thickness [m]; [1x1 double] | [nix1 double]; e.g. [0.1];
input.mor.ThUnLyr=0.05; %thickness of each underlayer [m]; [1x1 double]; e.g. [0.15]
input.mor.total_ThUnLyr=0.20; %thickness of the entire bed [m]; [1x1 double]; e.g. [2]
input.mor.lsk1_fc=1; %factor multiplying the thickness of the first substrate layer [-]; [1x1 double]; e.g. [0.5]
% input.mor.ThUnLyrEnd=10; %thickness of the last underlayer [m]; [1x1 double]; e.g. [10]
input.mor.MorFac=1; %morphological accelerator factor [-]; [1x1 double]; e.g. [10]
input.mor.Tstart=1; %start time of morphology update [s]; [1x1 double]; e.g. [600]
input.mor.Struiksma=0; %apply Struiksma reduction of sediment transport and reduction of the active layer thickness [-]; e.g. 0

%% 
%% SEDIMENT CHARACTERISTICS
%% 

input.sed.dk=[0.002,0.004]; %characteristic grain sizes [m]; [nfx1 double]; e.g. [0.0005;0.003;0.005]
input.sed.rhos=2650; %sediment density [kg/m^3]; [1x1 double]; e.g. [2650]

%% 
%% SEDIMENT TRANSPORT
%% 

input.tra.cr=1; %sediment transport closure relation 1=Meyer-Peter-Muller; 2=Engelund-Hansen; 3=Ashida-Michiue; 4=Wilcock-Crowe; 5=general power law; 6=Parker; 7=Ribberink [1x1 double]; e.g. [1]
% input.tra.E_cr=1; %closure relation for entrainment function 1=FLvB; 3=AM-type [1x1 double]; e.g. [1]
% input.tra.vp_cr=1; %closure relation for paticle velocity function 1=FLvB [1x1 double]; e.g. [1]
input.tra.param=[5.7,1.5,0.047]; %sediment transport parameters (depending on the closure relation) 1=[8,1.5,0.047] (MPM) [5.7,1.5,0.047] (FLvB); 2=[0.05,5] (EH); 3=[17,0.05] (AM)
% input.tra.E_param=[0.0199,1.5]; %entrainment function paramenters 1=[0.0199,1.5]; 3=[0.0591] (to keep Dk_st with the values by FLvB)
% input.tra.vp_param=[11.5,0.7]; %particle velocity function parameters
input.tra.hid=0; %hiding function= %0=NO function; 1=Egiazaroff; 2=Power-Law; 3=Ashida-Mishihue;
% input.tra.hiding_b=0; %power function of the Power Law function [-] [1x1 double]; e.g. [-0.8]
input.tra.Dm=1; %1=geometric 2^sum(Fak*log2(dk); 2=arithmetic sum(Fak*dk);
% input.tra.kappa=[0.1;0.1]; %diffusivity [m^2/s]; [(nf)x(1) double]; e.g. [0.1;0.1] If exponential rest times: kappa=O(1)*vp*lambda=O(1)*vp*16*dk, where vp is the particle velocity and lambda is the step length. The first equality is shown in Furbish12_3 and the second one in FernandezLuque76.
input.tra.mu=0; %ripple factor flag: 0=NO; 1=constant;
% input.tra.mu_param=0.3169; %ripple factor [-] [1x1 double]; e.g. [0.315]

%% 
%% INITIAL CONDITION
%% 

input.ini.initype=1; %kind of initial condition= %1=normal flow (for a given qbk0); 2=free; 3=from file; 4=normal flow (for a given initial condition) [-] [1x1 double]; e.g. [1]
    %1 => out of the upstrem hydrodynamic and morphodynamic and boundary conditions (Q0, Qbk0), the initial condition (u, h, etab, Mak) is set such that the start is normal flow
    %4 => out of the intial condition (u, h, etab, Mak) the upstream morphodynamic boundary condition (Qbk0) and the downstream hydraulic boundary condition (etaw0) are set such that the start is normal flow
% input.ini.rst_file='d:\victorchavarri\SURFdrive\projects\00_codes\ELV\runs\B\04\output.mat'; %path to the folder
% input.ini.rst_resultstimestep=294; %result time step with the initial condition [-]; [1x1 double]; e.g. [70]; if NaN it will be the last one     
% input.ini.u=0.607591356540161; %flow velocity [m/s]; [1x1 double] | [1xnx double]; e.g. [1]
% input.ini.h=0.329168606246920; %flow depth [m]; [1x1 double] | [1xnx double]; e.g. [1.5]
% input.ini.slopeb=0.001143235648281; %bed slope [-]; [1x1 double] | [1xnx double]; e.g. [1e-3]
% input.ini.etab0=-input.ini.h; %downstream bed elevation [m]; [1x1 double]; e.g. [0]
% input.ini.etab=1:0.1;10; %bed level [-]; [1x1 double] | [1xnx double]; e.g. [1e-3]
% input.ini.Fak=0.140448138654066; %effective fractions at the active layer [-]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3]
input.ini.fsk=0.0; %effective fractions at the substrate [-]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3]
% input.ini.Gammak=[0;0]; %initial particle activity [m]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3]
% input.ini.Gammak=[1.299628674097695e-05;1.963400567023249e-05]; %initial particle activity [m]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3]
% input.ini.subs.patch.x=[6,6.4]; %x coordinate of the upper corners of the patch [m]; [1x2 double]; e.g. [5,7.5]
% input.ini.subs.patch.releta=0.04; %substrate depth of the upper corners of the patch [m]; [1x1 double]; e.g. [0.2,0.2]
% input.ini.subs.patch.fsk=1; %effective fractions in the patch at the substrate [-]; (nf-1)x1 double]; e.g. [0.2,0.3]
input.ini.noise=0; %add noise to the initial condition; 0=NO; 1=sinusoidal to etab; 2=trench added to etab [-] [1x1 double]; e.g. [0]
% input.ini.noise_param=[0.001,10]; %parameters [A,L] to add sinusoidal noise to the initial bed elevation etab=etab+A*sin(2*pi/L)
% input.ini.trench.x=[2,4]; %x coordinates of the trench (beginning and end) [m]; [1x2 double]; e.g. [5,7.5]
% input.ini.trench.dz=-0.04; %trench depth (negative is dredge, positive is dump) [m]; [1x1 double]; e.g. [-0.04]

%% 
%% HYDRODYNAMIC BOUNDARY CONDITIONS
%% 

input.bch.uptype=1; %type of hydrodynamic boundary condition at the upstream end: 1=water discharge; 2=cyclic hydrograph; 12=input from file [-] [1x1 double]; e.g. [1]
% input.bch.path_file_Q=fullfile(source_path,'data','Qw1951.mat'); %path to the mat file containing the time series
input.bch.dotype=1; %type of hydrodynamic boundary condition at the downstream end: 1=water level 2=water depth [-]; 3=normal flow depth [1x1 double]; e.g. [1]
input.bch.timeQ0=[0;input.mdv.Tstop]; %time at which the water discharge is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bch.Q0=[0.2;0.2]; %water discharge at the specified times [m^3/s]; [ntx1 double]; e.g. [1;2]
% input.bch.ch.alpha=[6/12;3/12]; %yearly probability density function of water discharge (for input.bch.uptype=2) [-]; [nmodes-1,1]; e.g. [6/12;3/12]
% input.bch.ch.Q0k=[1.5;5;10]; %discharge per mode [m^3/s] (for input.bch.uptype=2); [nmodes-1,1]; [1.5;5;10]
input.bch.timeetaw0=[0;input.mdv.Tstop]; %time at which the downstream water level is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bch.etaw0=[0;+0.05]; %downstream water level at the specified times [m]; [nix1 double]; e.g. [1;1.5]

%% 
%% MORPHODYNAMIC BOUNDARY CONDITIONS
%% 

input.bcm.type=1; %type of morphodynamic boundary condition:  [-] [1x1 double] e.g. [1]
	%1=sediment discharge; 
	%2=periodic; 
	%3=cyclic hydrograph; 
	%4=fixed bed
	%13=Normal Flow Load Distribution (with Qw(t) we compute Qs(t) for normal flow ATT! more info is needed (input.bcm.NFLtype)); 
% input.bcm.NFLtype=3; %only if input.bcm.type=13 : 1=specify slope and GSD of the bed; 2=specify the total sediment load and the GSD of the bed; 3=specify sediment load
% input.bcm.NFLparam=[0.56;0.11]*1e9/2650/31536000; %if input.bcm.NFLtype=1: [slope,Fak (for all k)] e.g. [1e-4;0.1;0.9]; if input.bcm.NFLtype=2: [Qb,Fak (for all k)] e.g. [1e-5;0.1;0.9]; if input.bcm.NFLtype=3: [Qbk] e.g. [0.56;0.11]*1e9/2650/31536000
input.bcm.timeQbk0=[0;input.mdv.Tstop]; %time at which the input is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bcm.Qbk0=[0.5,0.5;0.5,0.5]*1e-5; %volume of sediment transported excluding pores per unit time, and per size fraction at the specified times [m^3/s]; [ntxnf double]; e.g. [2e-4,4-4;3e-4,5e-4]
% input.bcm.pa_u=3; %particle activity upstream boundary condition type: 
	%1=Dirichlet (Gammak at x=0 specified). You can also specify Qbk if the diffusion coefficient is equal to 0.
	%2=Neumann   (dGammak/dx at x=0 specified). It is not yet implemented.
	%3=Robin     (Qbk at x=0 specified). If the diffusion coefficient is equal to 0 use Dirichlet to impose Qbk0.
% input.bcm.timeGammak0=[0;input.mdv.Tstop]; %time at which the input is specified [s]; [nix1 double]; e.g. [1800;3600]
% input.bcm.Gammak0=[1.299628674097695e-05,1.963400567023249e-05;1.299628674097695e-05,1.963400567023249e-05]; %particle activity at x=0 at the specified times [m^3]; [(nt)x(nf)]; e.g. [0,0;0,0] if NaN it sets saturation value for all time
% input.bcm.pa_d=3; %particle activity downstream boundary condition type: 
	%0=NO		  when there is no diffusion (input.tra.kappa=0) you cannot set a downstream boundary condition. 
	%1=Dirichlet (Gammak at x=L specified). You can also specify Qbk if the diffusion coefficient is equal to 0. If you do not specify GammakL nor QbkL it is assumed saturation value. 
	%2=Neumann   (dGammak/dx at x=L specified)
    %3=Robin     (Qbk at x=L specified)
% input.bcm.timeGammakL=[0;input.mdv.Tstop]; %time at which the input is specified [s]; [nix1 double]; e.g. [1800;3600]
% input.bcm.GammakL=NaN; %particle activity at x=L at the specified times [m]; [(nt)x(nf)]; e.g. [0,0;0,0] if NaN it sets saturation value for all time
% input.bcm.timeQbkL=[0;input.mdv.Tstop]; %time at which the input is specified [s]; [nix1 double]; e.g. [1800;3600]
% input.bcm.QbkL=[0.5,0.5;0.5,0.5]*1e-5; %volume of sediment transported excluding pores per unit time, and per size fraction at the specified times [m^3/s]; [ntxnf double]; e.g. [2e-4,4-4;3e-4,5e-4]. If NaN it sets the value for small gradient (from closure relation)
% input.bcm.GammakL=[1.299628674097695e-05,1.963400567023249e-05;1.299628674097695e-05,1.963400567023249e-05]; %particle activity at x=0 at the specified times [m]; [(nt)x(nf)]; e.g. [0,0;0,0] if NaN it sets saturation value for all time