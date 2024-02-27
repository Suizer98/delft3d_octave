%input_single_ELV is a script that creates the input variable input.mat to run a single
%simulation

%HISTORY:
%160223
%   -V. Created for the first time.


%% 
%% MASTER DEFINITION VARIABLES
%% 

input.mdv.flowtype=1; %flow assumption: 0=NO update 1=steady; 2=quasi-steady; 3=unsteady (explicit); 4=unsteady (implicit); [-]; [1x1 double]; e.g. [1]
input.mdv.steady_solver=4; %steady solver: 1=energy-Euler; 2=energy-RK4; 3=depth-Euler; 4=depth-RK4; [1x1 double]; default=1
input.mdv.fluxtype=0; %flux type (only if flowtype=3): 0=upwind; 1=Lax-Wendroff; 2=Beam-Warming; 3=Fromm; 4=minmod; 5=van Leer; 6=superbee; 7=MC; [-]; [1x1 double]; e.g. [1]
input.mdv.frictiontype=1; %friction type: 1=constant; 2=related to grain size; 3=related to flow depth; [1x1 double]; e.g. [1]
input.mdv.Tstop=3600*24*1*1; %simulation time [s]; [1x1 double]; e.g. [3600]
input.mdv.dt=3600*0.0001; %time step [s]; [1x1 double]; e.g. [2]
input.mdv.Flmap_dt=3600*0.1; %printing map-file interval time [s]; [1x1 double]; e.g. [60]  
% input.mdv.disp_t_nt=100; %number of time steps to average the time needed to finish the simulatin [-]; [1x1 double]; e.g. [100]  
input.mdv.disp_time=1; %time in between displays in screen [s]; [1x1 double]; e.g. [1]  
input.mdv.Cf=0.003924; %friction coefficient [-]; [1x1 double]; e.g. [0.008]
input.mdv.rhow=1000; %water density [kg/m^3]; [1x1 double]; e.g. [1000]
input.mdv.g=9.81; %gravity constant [m/s^2]; [1x1 double]; e.g. [9.81]
input.mdv.nu=1e-6; %kinematic viscosity of water [m^2/s]; [1x1 double]; e.g. [1e-6]
input.mdv.output_var={'u','h','etab','Mak','La','msk','Ls','qbk','Cf','ell_idx','time_loop'}; %map variables name to output; 
input.mdv.chk.mass=1; %mass check [-]; [1x1 double]; e.g. [1]
input.mdv.chk.dM_lim=1e-5; %mass error limit [m^2, -!!]; [1x1 double]; e.g. [1e-8]
input.mdv.chk.flow=1; %Froude and CFL check [-]; [1x1 double]; e.g. [1]
input.mdv.chk.Fr_lim=0.8; %Fr limit [-]; [1x1 double]; e.g. [0.8]
input.mdv.chk.cfl_lim=0.8; %CFL limit [-]; [1x1 double]; e.g. [0.95]
input.mdv.chk.F_lim=0.01; %maximum error in volume fractions [-]; [1x1 double]; e.g. [0.01]
input.mdv.chk.nan=1; %check for NaN in variables 0=NO; 1=YES;
input.mdv.chk.ell=0; %display check for ellipticity 0=NO; 1=YES;
input.mdv.chk.pmm=0; %display check for pmm 0=NO; 1=YES;
input.mdv.dd=1e-8; %diferential

input.mdv.biftol=1E-16;

input.mdv.savemethod=2; %1=directly in one file; 2=first in individual files
input.mdv.t0=1; %time step to start (for restarting simulations)

% input.mdv.path_folder_main='c:\Users\victorchavarri\temporal\ELV\A\001\'; %full path to the main folder run [string]; default is the same as the input.mat
% input.mdv.path_folder_results='c:\Users\victorchavarri\temporal\ELV\A\001\'; %full path to the folder where you want to store the output.mat and other files that you may create; default is the same as the input.mat
% input.mdv.path_file_output='c:\Users\victorchavarri\temporal\ELV\A\001\output.mat'; %full path to the file output.mat (you can use this to change the name of the output file); default is the same as the input.mat and it is called output.mat

%%
%% FRICTION
%%

input.frc.wall_corr=0; %flume wall correction: 0=NO; 1=Johnson (1942); 2=Nikuradse; 3=imposed bed friction coefficient
input.frc.Cfb=0.008; %nondimensional bed friction coeddicient 
input.frc.ripple_corr=0; %ripple correction: 0=NO; 1=YES
input.frc.H=0.01; %bed form height [m]
input.frc.L=0.1; %bed form length [m]
input.frc.nk=2; %ks=nk*max(dx) (Nikuradse roughness length) [-]

%% 
%% GRID
%% 

input.grd.br=[1,2;2,3;2,4]; %node connectivity [-]
input.grd.L=[50;1000;1000]; %domain length [m]; [1x1 double]; e.g. [100]
input.grd.dx=[0.5;0.05;0.05]; %streamwise discretizations [m]; [1x1 double]; e.g. [0.1]
input.grd.B=[315;250;250]; %width [m]; [1x1 double] | [1xnx double]; e.g. [10]

%% 
%% MORPHOLOGY
%% 

input.mor.bedupdate=1; %update bed elevation 0=NO; 1=YES [-]; e.g. 1
input.mor.gsdupdate=1; %update grain size distribution 0=NO; 1=Hirano ;2=eli 1 (max. La); 3=eli 1 (min. La); 4=pmm (a<1,b~=1); 5=pmm (a>1,b~=1); 6=(a<1,b=1); 7=(a>1,b=1) (M_eta=1/b, M_Fak=1/(a*b)) [-]; e.g. 1 
input.mor.ellcheck=0; %ellipticity check 0=NO; 1=YES [-]; e.g. 1
input.mor.interfacetype=1; %fractions at the interface 1=Hirano; 2=Hoey and Ferguson [-]; [1x1 double];
input.mor.fIk_alpha=0; %Hoey and Ferguson parameter (0=100% active layer, 1=100% bed load) [-]; [1x1 double];
input.mor.porosity=0.3; %porosity [-]; [1x1 double]; e.g. [0.4]
input.mor.Latype=1; %active layer assumption: 1=constant thickness; 2=related to grain size; 3=related to flow depth; 4=growing with time [-]; [1x1 double]; e.g. [1]
% input.mor.La_t_growth= 0.0001%growth factor [m/s]; [1x1 double]; e.g. [0.0001]
input.mor.La=1; %active layer thickness [m]; [1x1 double]; e.g. [0.1]
input.mor.ThUnLyr=0.05; %thickness of each underlayer [m]; [1x1 double]; e.g. [0.15]
input.mor.total_ThUnLyr=5; %thickness of the entire bed [m]; [1x1 double]; e.g. [2]
input.mor.ThUnLyrEnd=100; %thickness of the last underlayer [m]; [1x1 double]; e.g. [10]
% input.mor.MorStt=60; %spin-up time [s]; [1x1 double]; e.g. [60]
input.mor.MorFac=1; %morphological accelerator factor [-]; [1x1 double]; e.g. [10]

% bifurcation sediment partitioning
input.mor.nodal = 1; % 1 is based on Wang (1995); 2=Bolla Pittaluga 2003
input.mor.nodparam=[5 5]; % or defined once for all bifurcation or for each seperate
                          % Wang: k value for each grain size [1x(nf) double] | [nbx(nf) double] (in which nb is the number of bifurcations)
                          % Bolla: alpha value and r valye [1x2 double]       | [nbx2 double] (in which nb is the number of bifurcations)
input.mor.Qminlim=10;% Model assumes closed branch when discharge is smaller than input.mor.Qminlim. (default input.mor.Qminlim=0)

%% 
%% SEDIMENT CHARACTERISTICS
%% 

input.sed.dk=[0.001; 0.006]; %characteristic grain sizes [m]; [nfx1 double]; e.g. [0.0005;0.003;0.005]
input.sed.rhos=2650; %sediment density [kg/m^3]; [1x1 double]; e.g. [2650]

%% 
%% SEDIMENT TRANSPORT
%% 

input.tra.cr=2; %sediment transport closure relation= %1=Meyer-Peter-Muller; 2=Engelund-Hansen; 3=Ashida-Michiue; 4=Wilcock-Crowe; [1x1 double]; e.g. [1]
input.tra.param=[0.05, 5]; %sediment transport parameters (depending on the closure relation)
input.tra.hid=0; %hiding function= %0=NO function; 1=Egiazaroff; 2=Power-Law; 3=Ashida-Mishihue;
input.tra.hiding_b=0; %power function of the Power Law function 
input.tra.Dm=1; %1=geometric 2^sum(Fak*log2(dk); 2=arithmetic sum(Fak*dk);
input.tra.Ls=0; % take an adaptation length into account in the comp of transport capacity [1x1 logical];
input.tra.a_Ls=9000; % parameter a in Yalin 1972 for the adaptation length [1x1 double];

%% 
%% INITIAL CONDITION
%% 
input.ini.initype=2; %kind of initial condition= %1=normal flow (for a given qbk0); 2=free; 3=from file; 4=normal flow (for a given initial condition) [-] [1x1 double]; e.g. [1]
    %1 => out of the upstrem hydrodynamic and morphodynamic and boundary conditions (Q0, Qbk0), the initial condition (u, h, etab, Mak) is set such that the start is normal flow
    %4 => out of the intial condition (u, h, etab, Mak) the upstream morphodynamic boundary condition (Qbk0) and the downstream hydraulic boundary condition (etaw0) are set such that the start is normal flow
input.ini.initype_bra=1; 
    %requires input.ini.initype to be 2=free
    %1 => water discharge Q [m^3/s] per branch and bed slope, assuming normal flow
% input.ini.rst_file='d:\victorchavarri\SURFdrive\projects\00_codes\ELV\runs\B\04\output.mat'; %path to the folder
% input.ini.rst_resultstimestep=294; %result time step with the initial condition [-]; [1x1 double]; e.g. [70]; if NaN it will be the last one     
input.ini.u=999; %flow velocity [m/s]; [1x1 double] | [1xnx double]; e.g. [1]
input.ini.h=0.30; %flow depth [m]; [1x1 double] | [1xnx double]; e.g. [1.5]
input.ini.slopeb=[3.18E-5;5E-5;NaN]; %bed slope [-]; 
    %if 1 branch       [1x1 double] | [1xnx double]; e.g. [1e-3]
    %if more branches  [(nb)x1 double]
input.ini.Q_frac=[NaN;0.2;NaN]; %water discharge partitioning at the bifurcations (only to compute initial condition, the actual value may change) [m^3/s]; [(nb)x1 double]
input.ini.etab0=0; %downstream bed elevation [m]; [1x1 double]; e.g. [0]
% input.ini.etab=1:0.1;10; %bed level [-]; [1x1 double] | [1xnx double]; e.g. [1e-3]
input.ini.Fak=[0.5;0.5;0.5]; %effective fractions at the active layer [-]; 
    %if 1 branch       [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3] 
    %if more branches  [(nb)x(nf-1) double]
input.ini.fsk=[0.5;0.5;0.5]; %effective fractions at the substrate [-]; [(nf-1)x1 double] | [(nf-1)xnx double]; e.g. [0.2,0.3]
% input.ini.subs.patch.x=[6,6.4]; %x coordinate of the upper corners of the patch [m]; [1x2 double]; e.g. [5,7.5]
% input.ini.subs.patch.releta=0.04; %substrate depth of the upper corners of the patch [m]; [1x1 double]; e.g. [0.2,0.2]
% input.ini.subs.patch.fsk=1; %effective fractions in the patch at the substrate [-]; (nf-1)x1 double]; e.g. [0.2,0.3]

%% 
%% HYDRODYNAMIC BOUNDARY CONDITIONS
%% 

input.bch.uptype=1; %type of hydrodynamic boundary condition at the upstream end: 1=water discharge; 2=cyclic hydrograph [-] [1x1 double]; e.g. [1]
input.bch.dotype=1; %type of hydrodynamic boundary condition at the downstream end: 1=water level 2=water depth [-]; [1x1 double]; e.g. [1]
input.bch.timeQ0=[0;input.mdv.Tstop]; %time at which the water discharge is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bch.Q0=[4000;4000]; %water discharge at the specified times [m^3/s]; 
    %if 1 branch       [(ni)x(1) double] | e.g. [0.2;0.3] 
    %if more branches  [(nt)x(n_upstream_nodes) double]
% input.bch.ch.alpha=[6/12;3/12]; %yearly probability density function of water discharge (for input.bch.uptype=2) [-]; [nmodes-1,1]; e.g. [6/12;3/12]
% input.bch.ch.Q0k=[1.5;5;10]; %discharge per mode [m^3/s] (for input.bch.uptype=2); [nmodes-1,1]; [1.5;5;10]
input.bch.timeetaw0=[0;input.mdv.Tstop]; %time at which the downstream water level is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bch.etaw0=[0,0; 0,0]; %downstream water level at the specified times [m]; [(nt)x(n_downstream_nodes) double]; e.g. [1;1.5]

%% 
%% MORPHODYNAMIC BOUNDARY CONDITIONS
%% 

input.bcm.type=1; %type of morphodynamic boundary condition: 1=sediment discharge [-]; 2=periodic; 3=cyclic hydrograph [1x1 double]; e.g. [1]
input.bcm.timeQbk0=[0;input.mdv.Tstop]; %time at which the input is specified [s]; [nix1 double]; e.g. [1800;3600]
input.bcm.Qbk0(:,:,1)=[0.007502656, 0.001250443;0.007502656, 0.001250443]; %volume of sediment transported excluding pores per unit time, and per size fraction at the specified times [m^3/s]; [(ni)x(nf)x(n_upstream_nodes) double]; e.g. [2e-4,4-4;3e-4,5e-4]
%input.bcm.Qbk0=[0.5,0.5;0.5,0.5]*1e-5; %volume of sediment transported excluding pores per unit time, and per size fraction at the specified times [m^3/s]; [ntxnf double]; e.g. [2e-4,4-4;3e-4,5e-4]
% input.bch.ch.alpha=[6/12;3/12]; %yearly probability density function of water discharge (for input.bcm.uptype=3) [-]; [nmodes-1,1]; e.g. [6/12;3/12]
% input.bch.ch.Qbk0i=[1.5;5;10]; %discharge per mode (for input.bcm.uptype=3) [m^3/s]; [nmodes-1,1]; [1.5;5;10]*1e-5
