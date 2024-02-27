%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: input_D3D_AB001.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/input_D3D_AB001.m $
%
%NOTES:
%   -DIFFUSION
%   -Vicouv affects water momentum
%   -Dicouv affects secondary flow
%   -Indirecty, Vicouv affects also secondary flow via the flow field.
%   -Compare the advective part of I to the length of the bend.
%
    

%% grid
simdef.grd.type=            1; %type of domain: 1=rectangular; 2=sine-generated curve; 3=DHL curved flume
simdef.grd.cell_type=       1; %type of cell: 1=quadrangular; 2=triangular
simdef.grd.K=               1; %number of vertical layers for flow [-] [double(1,1)] e.g. [2], 0=2D flow
% simdef.grd.Thick=           [1/3,1/3]*100; %thickness of vertical layers [%] [double(1,K-1)] e.g. [0.5]
    %logarithmic distribution
%     th_1=5; %percentage of the first layer
% simdef.grd.Thick=           [th_1,diff(exp(linspace(log(th_1),log(100),simdef.grd.K)))]; %thickness of vertical layers [%] [double(1,K-1)] e.g. [0.5]
simdef.grd.L=               100; %domain length [m] [10,100]
simdef.grd.B=               1.0; %width [m]; [0.01,0.05,0.1,0.2,1.0,10]
simdef.grd.dx=              1.0; %dx [m]; [0.01,0.05,0.1,0.2,1.0,10]
simdef.grd.dy=              1.0; %dy [m]; [0.01,0.05,0.1,0.2,1.0,10]
    %type 2
% simdef.grd.teta_0=          35/180*pi;  % maximum angle [rad]
% simdef.grd.lambda=          2.2;    % wave length [m] 
% simdef.grd.lambda_num=      4.5; % number of wave lengths [-]
    %type 3
% simdef.grd.L1=              7; %length of the upstream straight part [m]
% simdef.grd.L2=              11;  %length of the downstream straight part [m];
% simdef.grd.R=               12; %radious of curvature of the curved part (R>0 => turn to the left and viceversa) [m]
% simdef.grd.angle=           140; %turning angle of the curved part [grad]

%% master definition file
simdef.mdf.restart=         0; %restart simulation [-] [double(1,1)]: 0=NO; 1=YES. If 1: the trim file to restart has to be called trim-restart.dat and trim-restart.def
simdef.mdf.Tstart=          0; %start simulation time [s] if not input is taken as 0. Double check it makes sense when you restart a simulation.
simdef.mdf.Tstop=           3600; %simulation time [s] 
simdef.mdf.Dt=              30; %time step [s] [dx,dt]=[10,10]; [1,2.5]; [0.2,0.5]; [0.1,0.2]; [0.05,0.1]; [0.01,0.02];
simdef.mdf.FrictType=       0; %friction type [-]: 0=Chezy; 1=Manning; 2=White-Colebrook; 3=idem, WAQUA style; 10=smooth wall (no friction coefficient needed)
simdef.mdf.C=               sqrt(9.81/0.007); %Chezy friction coefficient [m^(1/2)/s] [double(1,1)] e.g. [25.5] if not used (i.e., FrictType=10, set to 1, but not to zero)
simdef.mdf.correct_C=       1; %correct friction for the z0r stuff bug: 0=NO; 1=YES [double(1,1)] e.g. [0]
simdef.mdf.secflow=         0; %flag for computation of secondary flow (1=yes; 0=no) [string] e.g. 'Y'
simdef.mdf.g=               9.81; %acceleration due to gravity [m/s^2] [double(1,1)] e.g. [9.81]
simdef.mdf.Vicouv=          1/6*1*0.41*sqrt(simdef.mdf.g)/simdef.mdf.C*1; %horizontal eddy viscosity [m^2/s] [double(1,1)] e.g. [5]
% simdef.mdf.Vicouv=          1.6907e-04; %horizontal eddy viscosity [m^2/s] [double(1,1)] e.g. [5]
simdef.mdf.Dicouv=          1/6*1*0.41*sqrt(simdef.mdf.g)/simdef.mdf.C*1; %horizontal eddy diffusivity [m^2/s] [double(1,1)] e.g. [5]
simdef.mdf.Vicoww=          1e-6; %vertical eddy viscosity [m^2/s] [double(1,1)] e.g. [1e-6]
simdef.mdf.Dicoww=          1e-6; %vertical eddy diffusivity [m^2/s] [double(1,1)] e.g. [1e-6]
% simdef.mdf.Smagorinsky=     0.15; %Smagorinsky factor in horizontal turbulence [-] [double(1,1)] e.g. [0.15]
simdef.mdf.wall_rough=      0; %account for wall friction: 0=NO; 1=partial slip 
simdef.mdf.wall_ks=         0.000; %(if simdef.mdf.wall_rough==1) wall friction length [m]
% simdef.mdf.filter=          0; %filter the 2dx oscillations due to numerical scheme in FM: 0=NO; 1=YES [-] [double(1,1)] e.g. [0]
    %output
simdef.mdf.Flmap_dt=        60; %printing map-file interval time [s] [double(1,1)] e.g. [60]     
% simdef.mdf.Flhis_dt=        60; %printing his-file interval time [s] [double(1,1)] e.g. [60]     
% simdef.mdf.obs_cord= [0,0;1,0.5]; %coordinates of the observations points [x,y] [m] [double(np,2)] e.g. [0,0;1,0.5]    
% simdef.mdf.obs_name={'s1','s2'} ; %name of the observation stations [-] [cell(np,1)] e.g. {'s1','s2'}
simdef.mdf.Flrst_dt=      3600; %restart file time interval [s] [double(1,1)] e.g. [60]

%% morphology parameters
simdef.mor.morphology=      1; %include morphology or not [-] [double(1,1)]: 0=NO; 1=YES
simdef.mor.BedUpd=          1; %bed level update [-] [double(1,1)]: 0=NO; 1=YES
simdef.mor.CmpUpd=          0; %composition update [-] [double(1,1)]: 0=NO; 1=YES
simdef.mor.ThTrLyr=         0.10; %active layer thickness [m] [double(1,1)]
simdef.mor.ThUnLyr=         5.00; %thickness of each underlayer [m] [double(1,1)]
simdef.mor.total_ThUnLyr=   10; %thickness of the entire bed [m] [double(1,1)]
simdef.mor.IHidExp=         1;  %1: none; 2: Egiazaroff; 3: Ashida & Michiue; 4: Power Law;
simdef.mor.ASKLHE=          0.8; %Power Law hiding factor (in case simdef.mor.hiding=4). ATTENTION! in ECT is defined with a change of sign!
simdef.mor.MorStt=          0; %spin-up time [s] [double(1,1)] e.g. [1800]
simdef.mor.MorFac=          1; %morphological accelerator factor [-] [double(1,1)] e.g. [1]
simdef.mor.ISlope=          3; %bed slope formulation (integer) 1=NO; 2=Bagnold; 3=Koch and Flokstra; 4=Parker and Andrews
simdef.mor.AShld=           1; %A parameter in Kock and Flokstra
simdef.mor.BShld=           0; %B parameter in Kock and Flokstra
simdef.mor.CShld=           0; %C parameter in Kock and Flokstra
simdef.mor.DShld=           0; %D parameter in Kock and Flokstra
simdef.mor.UpwindBedload=   1; %Use upwind bedload (1) or central bedload (0)
    
%ill-posedness
simdef.mor.HiranoCheck=     0; %Flag for well-posedness of Hirano check [-] [double(1,1)]: 0=NO; 1=YES
simdef.mor.HiranoRegularize=0; %Flag for regularizing the active layer model: 0=NO; 1=only at ill-posed locations; 2=everywhere [-] [double(1,1)]
simdef.mor.HiranoDiffusion= 1; %Diffusion coefficient applied to Mak to regularize the active layer model [m^2/s] [double(1,1)]. Default = 1 m^2/s
simdef.mor.RegularizationRadious= 0.5; %Radious of the circumference inside which all nodes are regularized [m] [double(1,1)]. Default = 1 m
simdef.mor.SedTransDerivativesComputation= 1; %Flag for type of computation of derivatives [-] [double(1,1)]: 1=analytical; 2=numerical. Default = 2

%% initial conditions
    %etaw
simdef.ini.etaw_type=       1; %type of initial water level: 1=use flow depth; 2=read from file (only for FM);
simdef.ini.h=               1.0; %initial flow depth (everywhere) [m] [double(1,1)] e.g. [0.22] ATTENTION! if NaN, normal flow depth will be used
% simdef.ini.etaw_file='etaw.xyz';
    %etab
simdef.ini.etab0_type=      1; %type of initial bed elevation: 1=sloping bed; 2=constant bed elevation; 3=xyz 
simdef.ini.s=               7.135575942915392e-04; %(if etab0_type=1) initial slope [-] [double(1,1)] | [double(M,1)] e.g. [3e-3] | linspace(0.001,0.0001,simdef.grd.L/simdef.grd.dx+1)]
simdef.ini.etab=            -simdef.ini.h; %initial downstream bed level [m] [double(1,1)] e.g. [0] ATTENTION! if NaN, the bed level at the downstream end will be at 0; if you want the base level to be at 0, this should be -simdef.ini.h; if you want the bed level to be at 0, this should be 0;
simdef.ini.etab_noise=      0; %flag for initial noise [double(1,1)] 0=NO; 1=random; 2=alternate bars; 3=random including upstream end
simdef.ini.noise_Lb=        0; %bar length [m]
simdef.ini.noise_amp=       0; %bar amplitude [m]
% aux=load('c:\Users\chavarri\temporal\D3D\runs\P\001\figures\etab_0002593800.mat');
% simdef.ini.xyz=aux.data_save;
%simdef.ini.xyz= [1,1,3;1,2,3]; % bed elevation coordinates (:,1)=x; (:,2)=y; (:,3)=etab
% simdef.ini.xyz= [0           ,0           ,simdef.grd.L*simdef.ini.s;...
%                  0           ,simdef.grd.B,simdef.grd.L*simdef.ini.s;...
%                  simdef.grd.L,0           ,0                        ;...
%                  simdef.grd.L,simdef.grd.B,0                         ]; % bed elevation coordinates (:,1)=x; (:,2)=y; (:,3)=etab
    %sec flow
simdef.ini.I0=              0; %secondary flow intensity [m/s]

%morphodynamic
    %active layer
simdef.ini.actlay_frac_type=1; %type of active layer fractions: 1=constant; 2=patch [-] [double(1,1)]
simdef.ini.actlay_frac=     [1]; %effective (total-1) number of fractions at the active layer [-] [double(nf-1)]
% simdef.ini.actlay_patch_x=[5.5,6.5]; %x coordinates of the beginning and end of the patch [m] [double(1,2)]
% simdef.ini.actlay_patch_y=[2.5,3.0]; %y coordinates of the beginning and end of the patch [m] [double(1,2)]
% simdef.ini.actlay_patch_frac=[0]; %effective (total-1) number of fractions at the active layer in the patch [-] [double(nf-1)]
    %substrate
simdef.ini.subs_type=       1; %type of substrate: 1=constant; 2=patch [-] [double(1,1)]
simdef.ini.subs_frac=       [1]; %efective (total-1) number of fractions at the substrate [-] [double(nf-1)]
% simdef.ini.subs_patch_x=    [1,10]; %x coordinate of the upper corners of the patch [m] [double(1,2)]
% simdef.ini.subs_patch_releta=0.01; %substrate depth of the upper corners of the patch [m] [double(1,1)]
% simdef.ini.subs_patch_frac= [0.2]; %effective (total-1) number of fractions at the patch substrate (below the bed surface) [-] [double(nf-1)]

%% morphological boundary conditions
simdef.mor.IBedCond=        5; %flag for upstream boundary bed boundary condition: 
                               %1=bed level fixed; 
                               %2=bed level as a function of time
                               %3=bed level change as a function of time  ATTENTION! in FM it is 7, but you can set here 3. 
                               %5=bedload transport rate
simdef.mor.CondPerNode=     0; %boundary condition set in each cell (versus set for the whole section): 0=N0; 1=YES
simdef.mor.ICmpCond=        0; %flag for upstream boundary gsd boundary condition: 0=free; 1=gsd fixed
simdef.bcm.time=            [0;simdef.mdf.Tstop]; %time at which the fractions are specified [s] [double(nt,1)]
simdef.bcm.transport=       [1.1176637e-04;1.1176637e-04]; %(if IBedCond=5)transport = transport excluding pores of each fraction at each time [m^2/s] [double(nt,nf)]
% simdef.bcm.deta_dt=         -0.00/3600*ones(2,1); %(if IBedCond=3); rate of change of the bed elevation (negative mens degradation) [m/s] [double(nt,1)]
% simdef.bcm.eta=             [-0.1,-0.2]; %(if IBedCond=2); bed elevation as a function of time [m] [double(nt,1)]

%% hydrodynamic boundary conditions
simdef.bct.Q=               1*simdef.grd.B; %Q [m3/s] (value before width is the value per unit width)
simdef.bct.time=            [0,simdef.mdf.Tstop]; %time at which the water levels are specified [s] [double(nt,1)]
simdef.bct.etaw=            [0.000;0.000]; %water levels at the specified times [m] [double(nt,1)]

%% sediment data
simdef.sed.dk=              [0.001]; %characteristic grain sizes [m] [double(nf,1)] 

%% sediment transport formulation
simdef.tra.IFORM=           1; %sediment transport flag [-] [integer(1,1)] 2=MPM; 4=MPM-based; 14=AM
simdef.tra.sedTrans=        [1]; %sediment transport parameters (as in ECT) EH
% simdef.tra.sedTrans=        [17,0.05]; %sediment transport parameters (as in ECT) AM
% simdef.tra.sedTrans=        [8,1.5,0.047]; %sediment transport parameters (as in ECT) MPM

%%
%% advanced input
%%

simdef.mdf.Dpsopt='MEAN'; %bed level interpolation at water level points [string]: DP=position of depth points shifted to water level points; MIN=minimum of the surrounding points; MEAN=mean of the surrounding points; MAX=max of the surrouding points; 
simdef.mdf.Dpuopt='MOR'; %bed level interpolation at velocity    points [string]: MIN=minimum of the surrounding point; MEAN=mean of the surrounding points; UPW=upwind 
 