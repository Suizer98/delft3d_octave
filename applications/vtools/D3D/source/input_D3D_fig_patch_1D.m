%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%
%add paths to OET tools:
%   https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab
%   run(oetsettings)

%% PREAMBLE
% clear
% close all

%% INPUT

    %% debug
    
flg.profile=0;

    %% path
%form of input
    %1=several simulations in structured folders; 
    %2=one simulation;
    %3=from script
def.sim_in=2; 
    %1) (for more than one simulation, structured results)
% def.simulations={'051','043','057','061'}; %simulations to run the loop
% def.series={'P','P','P','P'}; %series to analyze
% def.paths_runs='n:\My Documents\runs\D3D\';
    %2) (for 1 simulation)
simdef.D3D.dire_sim='p:\11203223-tki-rivers\02_rijntakken_2020\04_runs\08_morpho_1\mr1_070\dflowfm\';
    %3) (from script)
% def.script='input_plot_FM_3Dflow_validation_u';
% def.script='input_plot_groynes_lab_groyne_field';

    %% variable
simdef.flg.which_p=4; %which kind of plot: 
%MAP
%      LOOP ON TIME
%   1=3D bed elevation and gsd
%   2=2DH
%   3=1D
%   4=patch (vertical section of sediment, 2DV)
%   9=2DV
%  10=cross-sections
%       OTHER
%   5=xtz
%   6=xz for several time

%   7=0D
%   8=2DH cumulative
%HIS
%      LOOP ON TIME
%   a=vertical profile
%      OTHER
%   b=for a given time vector
%
%GRID
%   grid
%
simdef.flg.which_v=26; %which variable: 
%   1=etab
%   2=h
%   3=dm Fak
%   4=dm fIk
%   5=fIk
%   6=I
%   7=elliptic
%	8=Fak
%   9=detrended etab based on etab_0
%   10=depth averaged velocity
%   11=velocity
%   12=water level
%   13=face indices
%   14=active layer thickness
%   15=bed shear stress
%   16=specific water discharge
%   17=cumulative bed elevation
%   18=water discharge 
%   19=bed load transport in streamwise direction (at nodes)
%   20=velocity at the main channel
%   21=discharge at main channel
%   22=cumulative nourished volume of sediment
%   23=suspended transport in streamwise direction
%   24=cumulative bed load transport
%   25=total sediment mass (summation of all substrate layers)
%   26=dg Fak
%   27=total sediment thickness (summation of all substrate layers)
%   28=main channel averaged bed level
%   29=sediment transport magnitude at edges m^2/s
%   30=sediment transport magnitude at edges m^3/s
%   31=morphodynamic width [m]
%   32=Chezy 
%   33=cell area [m^2]
%   34=space step (only 1D)
%   35=cumulative dredged volume of sediment [m^3]
%   36=Froude number [-]

    %% domain
    
% in_read.branch={'channel1','channel2'}; 
% in_read.branch={'Channel1','Channel2'}; 
% in_read.branch={'Channel1'}; 
% in_read.branch={'Channel3','Channel1'}; 
% in_read.branch={'1','2','3','4','5'}; 
% in_read.branch={'Channel_1D_1'}; 
% in_read.branch={'BovenEijsden','Kalkmaas1','Kalkmaas2','Kalkmaas3','Kalkmaas4','Grensmaas1','Grensmaas2','Grensmaas3','Grensmaas4','Grensmaas5','Grensmaas6','Zandmaas01','Zandmaas02','Zandmaas03','Zandmaas04','Zandmaas05','Zandmaas06','Zandmaas07','Zandmaas08','Zandmaas09','Zandmaas10','Zandmaas11','Zandmaas12','Zandmaas13','Zandmaas14','Zandmaas15','Zandmaas16','Zandmaas17','Getijmaas1','Getijmaas2','Getijmaas3','Getijmaas4','BergscheMaas1','BergscheMaas2'}; 
% in_read.branch={'01_SAZ','02_SAZ','03_SAZ','04_SAZ','05_SAZ','06_SAZ','07_SAZ','08_SAZ','09_SAZ','10_SAZ','11_SAZ','01_SAZ','13_SAZ_A','13_SAZ_B_A','13_SAZ_B_B_A','13_SAZ_B_B_B_A','13_SAZ_B_B_B_B','14_SAZ','15_SAZ','16_SAZ_A','16_SAZ_B'}; 
% in_read.branch={'29_A','29_B_A','29_B_B','29_B_C','29_B_D','52_A','52_B','31_A_A','31_A_B','31_A_C','31_B','51_A','BovenLobith','Bovenrijn'};
% in_read.branch={'Nederrijn1','Nederrijn2','Nederrijn3','Nederrijn4','Nederrijn5','Nederrijn6','Lek1','Lek2','Lek4','Lek5','Lek6','Lek7','Lek8'};
in_read.branch={'Waal1','Waal2','Waal3','Waal4','Waal5','Waal6'}; %RT+G Waal;
% in_read.branch={'PanKan1','PanKan2'}; 
% in_read.branch={'IJssel01','IJssel02','IJssel03','IJssel04','IJssel05','IJssel06','IJssel07','IJssel08','IJssel09','IJssel10','IJssel11','IJssel12'}; 
% in_read.branch={'Kattendiep1','Kattendiep2'}; 
% in_read.branch={'Lek1'}; 
% in_read.branch={'Nederrijn1','Nederrijn2'}; 
% in_read.branch={'Waal1'}; 
% in_read.branch={'BovenLobith','Bovenrijn'};

% in_read.station=3; %station number (for history files)
% in_read.station={'Pannerdenschekop'}; %station number (for history files)
% in_read.station={'867.00_BR'}; %station number (for history files)
% in_read.station={'868.00_WA'}; %station number (for history files)
% in_read.station={'868.00_PK'}; %station number (for history files)
% in_read.station={'825_Rhein'}; %station number (for history files)
% in_read.station={'Q-DrielbovDrielben'}; %station number (for history files)
% in_read.station={'LMW Drielboven'}; %station number (for history files)
% in_read.station={'LMW Drielbeneden'}; %station number (for history files)
% in_read.station={'LMW IJsselkop'}; %station number (for history files)
% in_read.station={'LMW Lobith'}; %station number (for history files)
% in_read.station={'obsCross_Pannerdenschekop_PK'};
% in_read.station={'obsCross_Pannerdenschekop'};
% in_read.station={'obsCross_900.00_WA'};
% in_read.station={'868.00_WA'};
% in_read.station={'obsCross_868.00_WA'};

%x,y,f coordinate if NaN, all
% in_read.kf=1:8;
% in_read.kf=14:17;
% in_read.kf=13:16;
% in_read.kf=9:12;
% in_read.pol.x=linspace(0,30000,1000); %polyline with x coordinates to make cross section (FM)
% in_read.pol.y=linspace(50,50,1000); %polyline with y coordinates to make cross section (FM)

% in_read.kcs=[100,1]; %cross-sections to plot [first one, counter]

%D3D4
% in_read.kx=NaN;
% in_read.ky=2;

    %% times to plot
    
    %0=all the time steps; 
    %1='time' is a single time or a vector with the time steps to plot. If NaN it plots the last time step; 
    %2='time' is the spacing between 1 and the last results;
def.rsl_input=1; 
def.rsl_time=1;

    %% print
simdef.flg.print=NaN; %NaN=nothing; 0=pause until click; 0.5=pause 'pauset' time; 1=eps; 2=png
% simdef.flg.pauset=0.1;
simdef.flg.save_name=NaN; %name to save a figure, if NaN it gives automatic name
% simdef.flg.save_name='C:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\200522_vow20\ge'; %name to save a figure, if NaN it gives automatic name

% simdef.flg.fig_visible=1; %see plot: 0=NO; 1=YES (if unspecified, it only appears if it is not printed)

% simdef.flg.elliptic=0; %plot elliptic results: 0=NO; 1=YES (from ect); 2=YES (from D3D)

% simdef.flg.plot_unitx=1/1000; %conversion from m
% simdef.flg.plot_unitx=1; %conversion from m
% simdef.flg.plot_unity=1; %conversion from m
% simdef.flg.plot_unity=1/1000; %conversion from m
% simdef.flg.plot_unitz=1; %conversion from m
% simdef.flg.plot_unitt=1; %conversion from s
% simdef.flg.plot_unitt=1/3600; %conversion from s
% simdef.flg.plot_unitt=1/3600/24; %conversion from s
% simdef.flg.plot_unitt=1/3600/24/365; %conversion from s

%plot limits (comment to make it automatic)
% simdef.flg.lims.x=[1.85e2,1.97e2]; %x limit in [m * plot_unitx]
% simdef.flg.lims.y=[4.29e2,4.325e2]; %y limit in [m * plot_unit_y]
% simdef.flg.lims.z=[-1,1]; %z limit in [m] (for 1D it is the limit of the vertical axis)
% simdef.flg.lims.f=[-1,1]; %variable limits [default units]
% simdef.flg.view=[56.5545   80.7235];
% simdef.flg.prnt_size=[0,0,10,6]; %slide=[0,0,25.4,19.05]; 

% simdef.flg.marg.mt=0.2; %top margin [cm]
% simdef.flg.marg.mb=0.2; %bottom margin [cm]
% simdef.flg.marg.mr=0.5; %right margin [cm]
% simdef.flg.marg.ml=1.5; %left margin [cm]
% simdef.flg.marg.sh=0.0; %horizontal spacing [cm]
% simdef.flg.marg.sv=0.0; %vertical spacing [cm]

% simdef.flg.equal_axis=1; %equal axis

% simdef.flg.prop.fs=10; %font size [points]
% simdef.flg.prop.edgecolor='none'; %edge color in surf plot

% simdef.flg.cbar.displacement=[0.0,0.0,0,0.00]; 
% simdef.flg.ncmap=100; %number of colors to discretize the colormap

% simdef.flg.addtitle=0; %add title to the plot

%0 and 999 to NaN
% simdef.flg.zerosarenan=1; %convert 0 in coordinate to NaN
% simdef.flg.nine3sarenan=1; %convert 999 in variable to NaN
% simdef.flg.zerosinvarsarenan=1; %convert 999 in variable to NaN

% simdef.flg.language='nl'; %language: 'en'=english; 'nl'=nederlands

% simdef.flg.interp_u=1;

%save data
simdef.flg.save_data=0; %0=NO, 1=xyz

%figure with face indices
% simdef.flg.fig_faceindices=0; %0=NO, 1=YES

%not necessary
% simdef.D3D_home=NaN;

% simdef.flg.mean_type=2; %1=log2; 2=mean

%tiles
% simdef.flg.add_tiles=1; %add map tiles to background
% simdef.flg.tiles_path='c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\200528_VOW\data\tiles.mat';

%domain figure
% simdef.flg.plot_branches=0;
% simdef.flg.plot_nodes=0;

%plot style
simdef.flg.which_s=4; %which plot style: 
%   1=surf
%   2=contourf
%   3=scatter
%   4=patch
%   5=text

%% conversion to river kilometers
% in_read.path_rkm="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\river_kilometers\rijntakken\irm\rkm_rijntakken_rhein.csv";
% in_read.rkm_curved="c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\river_kilometers\rijntakken\irm\rijn-flow-model_map_curved.nc";
% in_read.rkm_TolMinDist=300; %tolerance for accepting an rkm point

%% prevent error if empty

in_read.dummy=NaN;