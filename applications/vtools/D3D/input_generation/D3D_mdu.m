%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17936 $
%$Date: 2022-04-05 19:43:17 +0800 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_mdu.m 17936 2022-04-05 11:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mdu.m $
%
%mdu creation

%INPUT:
%   -
%
%OUTPUT:
%   -a .mdf file compatible with D3D is created in folder_out
%

function D3D_mdu(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

% dire_sim=simdef.D3D.dire_sim;

% runid_serie=simdef.runid.serie;
% runid_number=simdef.runid.number;

% restart=simdef.mdf.restart;
Tstart=simdef.mdf.Tstart;
% Tunit=simdef.mdf.Tunit;
% Tfact=simdef.mdf.Tfact;
Tstop=simdef.mdf.Tstop;
Dt=simdef.mdf.Dt;   
C=simdef.mdf.C;
Flmap_dt=simdef.mdf.Flmap_dt;
g=simdef.mdf.g;
secflow=simdef.mdf.secflow;

Vicouv=simdef.mdf.Vicouv;
Dicouv=simdef.mdf.Dicouv;
Vicoww=simdef.mdf.Vicoww;
Dicoww=simdef.mdf.Dicoww;

Smagorinsky=simdef.mdf.Smagorinsky;

wall_rough=simdef.mdf.wall_rough;
wall_ks=simdef.mdf.wall_ks;

FrictType=simdef.mdf.FrictType;

obs_filename=simdef.mdf.obs_filename;

etab=simdef.ini.etab;

h=simdef.ini.h;

Flhis_dt=simdef.mdf.Flhis_dt;
Flrst_dt=simdef.mdf.Flrst_dt;

K=simdef.grd.K;

morphology=simdef.mor.morphology;

filter=simdef.mdf.filter;

% file_name=simdef.runid.name;
file_name=simdef.file.mdf;

%% FILE

kl=1;
data{kl,1}=sprintf('# Generated: %s',datestr(datetime('now'))); kl=kl+1;
data{kl,1}=        '# by Victor Chavarrias'; kl=kl+1;
data{kl,1}=        ''; kl=kl+1;
%%
data{kl,1}=        '[model]'; kl=kl+1;
data{kl,1}=        'Program           = D-Flow FM       '; kl=kl+1;
data{kl,1}=        'Version           = 1.2.38.63285M   '; kl=kl+1;
data{kl,1}=        'MDUFormatVersion  = 1.02            '; kl=kl+1;
data{kl,1}=        'GuiVersion        = 1.5.2.42543     '; kl=kl+1;
data{kl,1}=        'AutoStart         = 0               '; kl=kl+1;
data{kl,1}=        ''; kl=kl+1;
%% GEOMETRY
data{kl,1}=        '[geometry]'; kl=kl+1;
data{kl,1}=sprintf('NetFile           = %s',simdef.mdf.grd); kl=kl+1;
% if simdef.mor.morphology || simdef.grd.cell_type
% data{kl,1}=sprintf('BathymetryFile    = %s',simdef.mdf.dep); kl=kl+1;
% else
% data{kl,1}=        'BathymetryFile    =         ' ; kl=kl+1;
% end
data{kl,1}=        'DryPointsFile     =         '; kl=kl+1;
data{kl,1}=        'GridEnclosureFile =         '; kl=kl+1;
if simdef.ini.etaw_type==2
% data{kl,1}=sprintf('WaterLevIniFile   = %s      ',simdef.ini.etaw_file); kl=kl+1;
% data{kl,1}=sprintf('WaterLevIniFile   = %s      ',simdef.mdf.etaw_file); kl=kl+1;
else
data{kl,1}=        'WaterLevIniFile   =         '; kl=kl+1;
end
data{kl,1}=        'LandBoundaryFile  =         '; kl=kl+1;
data{kl,1}=        'ThinDamFile       =         '; kl=kl+1;
data{kl,1}=        'FixedWeirFile     =         '; kl=kl+1;
data{kl,1}=        'PillarFile        =         '; kl=kl+1;
data{kl,1}=        'StructureFile     =         '; kl=kl+1;
data{kl,1}=        'VertplizFile      =         '; kl=kl+1;
data{kl,1}=        'ProflocFile       =         '; kl=kl+1;
data{kl,1}=        'ProfdefFile       =         '; kl=kl+1;
data{kl,1}=        'ProfdefxyzFile    =         '; kl=kl+1;
data{kl,1}=        'Uniformwidth1D    = 2       '; kl=kl+1;
data{kl,1}=        'ManholeFile       =         '; kl=kl+1;
if simdef.ini.etaw_type==1
data{kl,1}=sprintf('WaterLevIni       = %0.7E',etab+h); kl=kl+1;
else
data{kl,1}=        'WaterLevIni       = 0    '; kl=kl+1;
end
% if simdef.ini.etab0_type==2
% data{kl,1}=sprintf('Bedlevuni         = %0.7E',etab); kl=kl+1;
% else
data{kl,1}=        'Bedlevuni         = -5      '; kl=kl+1;
% end
data{kl,1}=        'Bedslope          = 0       '; kl=kl+1;
% if simdef.mor.morphology || simdef.grd.cell_type
data{kl,1}=        'BedlevType        = 1       '; kl=kl+1;
% else
% data{kl,1}=        'BedlevType        = 3       '; kl=kl+1;
% end
data{kl,1}=        'Blmeanbelow       = -999    '; kl=kl+1;
data{kl,1}=        'Blminabove        = -999    '; kl=kl+1;
data{kl,1}=        'PartitionFile     =         '; kl=kl+1;
data{kl,1}=        'Anglat            =  0        '; kl=kl+1;
data{kl,1}=        'Grdang            =  0        '; kl=kl+1;
data{kl,1}=        'Conveyance2D      = -1        '; kl=kl+1;
data{kl,1}=        'Nonlin2D          = 0         '; kl=kl+1;
data{kl,1}=        'Sillheightmin     = 0         '; kl=kl+1;
data{kl,1}=        'Makeorthocenters  = 0         '; kl=kl+1;
data{kl,1}=        'Dcenterinside     = 1         '; kl=kl+1;
data{kl,1}=        'Bamin             = 1E-06     '; kl=kl+1;
data{kl,1}=        'OpenBoundaryTolerance= 3      '; kl=kl+1;
data{kl,1}=        'RenumberFlowNodes = 1         '; kl=kl+1;
data{kl,1}=sprintf('Kmx               = %d',K)     ; kl=kl+1;
data{kl,1}=        'Layertype         = 1         '; kl=kl+1;
data{kl,1}=        'Numtopsig         = 0         '; kl=kl+1;
data{kl,1}=        'SigmaGrowthFactor = 1         '; kl=kl+1;

% Kmx                               = 28                  # Maximum number of vertical layers
% Layertype                         = 2                   # Vertical layer type (1: all sigma, 2: all z, 3: use VertplizFile)
% Numtopsig                         = 0                   # Number of sigma layers in top of z-layer model
% SigmaGrowthFactor                 = 1.                  # Layer thickness growth factor from bed up
% StretchType                       = 1                   # Type of layer stretching, 0 = uniform, 1 = user defined, 2 = fixed level double exponential
% StretchCoef                       = 6.392 5.9247 5.4884 5.0842 4.7097 4.3629 4.0416 3.7439 3.4682 3.2128 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762 2.9762# Layers thickness percentage
% ZlayBot                           = -42.                # level of bottom layer in z-layers
% ZlayTop                           = 0.                  # level of top layer in z-layers

data{kl,1}=        ''; kl=kl+1;
%% NUMERICS
data{kl,1}=        '[numerics]'; kl=kl+1;
data{kl,1}=sprintf('CFLMax            = %f         ',simdef.mdf.CFLMax); kl=kl+1;
data{kl,1}=        'AdvecType         = 33         '; kl=kl+1;
data{kl,1}=        'TimeStepType      = 2          '; kl=kl+1;
data{kl,1}=        'Limtyphu          = 0          '; kl=kl+1;
data{kl,1}=        'Limtypmom         = 4          '; kl=kl+1;
data{kl,1}=        'Limtypsa          = 4          '; kl=kl+1;
data{kl,1}=        'TransportMethod   = 1          '; kl=kl+1;
data{kl,1}=        'Vertadvtypmom     = 6          '; kl=kl+1; %vertical advection for u1: 0: No, 3: Upwind implicit, 4: Central implicit, 5: QUICKEST implicit., 6: centerbased upwind expl
data{kl,1}=        'Vertadvtypsal     = 6          '; kl=kl+1;
data{kl,1}=        'Icgsolver         = 4          '; kl=kl+1;
data{kl,1}=        'Maxdegree         = 6          '; kl=kl+1;
data{kl,1}=        'FixedWeirScheme   = 6          '; kl=kl+1;
data{kl,1}=        'FixedWeirContraction= 1        '; kl=kl+1;
data{kl,1}=        'FixedWeirfrictscheme= 1        '; kl=kl+1;
data{kl,1}=        'Fixedweirtopwidth = 3          '; kl=kl+1;
data{kl,1}=        'Fixedweirtopfrictcoef= -999    '; kl=kl+1;
data{kl,1}=        'Fixedweirtalud    = 4          '; kl=kl+1;
data{kl,1}=sprintf('Izbndpos          = %d         ',simdef.mdf.izbndpos); kl=kl+1;
data{kl,1}=        'Tlfsmo            = 0          '; kl=kl+1;
data{kl,1}=        'Logprofatubndin   = 1          '; kl=kl+1; % ubnds inflow: 0=uniform U1, 1 = log U1, 2 = user3D
data{kl,1}=        'Logprofkepsbndin  = 0          '; kl=kl+1; % inflow: 0=0 keps, 1 = log keps inflow, 2 = log keps in and outflow
data{kl,1}=        'Slopedrop2D       = 0          '; kl=kl+1;
data{kl,1}=        'Chkadvd           = 0.1        '; kl=kl+1;
data{kl,1}=sprintf('Teta0             = %f         ',simdef.mdf.theta); kl=kl+1;
data{kl,1}=        'Qhrelax           = 0.01       '; kl=kl+1;
data{kl,1}=        'Jbasqbnddownwindhs= 0          '; kl=kl+1;
data{kl,1}=        'cstbnd            = 0          '; kl=kl+1;
data{kl,1}=        'Maxitverticalforestersal= 0    '; kl=kl+1;
data{kl,1}=        'Maxitverticalforestertem= 0    '; kl=kl+1;
data{kl,1}=        'Jaorgsethu        = 1          '; kl=kl+1;
data{kl,1}=        'Turbulencemodel   = 3          '; kl=kl+1;
data{kl,1}=        'Turbulenceadvection= 3         '; kl=kl+1;
data{kl,1}=        'AntiCreep         = 0          '; kl=kl+1;
data{kl,1}=        'Maxwaterleveldiff = 0          '; kl=kl+1;
data{kl,1}=        'Maxvelocitydiff   = 0          '; kl=kl+1;
data{kl,1}=        'Epshu             = 0.0001     '; kl=kl+1;
data{kl,1}=        'SobekDFM_umin     = 0          '; kl=kl+1;
data{kl,1}=sprintf('TransportAutoTimestepdiff = %d         ',simdef.mdf.TransportAutoTimestepdiff); kl=kl+1;
data{kl,1}=sprintf('filter            = %d         ',filter); kl=kl+1;
data{kl,1}=sprintf('MinTimestepBreak  = %d         ',0); kl=kl+1;
data{kl,1}=        ''; kl=kl+1;

%%
data{kl,1}=        '[physics]                        '; kl=kl+1;
data{kl,1}=sprintf('UnifFrictCoef     = %0.7E',C); kl=kl+1;
data{kl,1}=sprintf('UnifFrictType     = %d',FrictType); kl=kl+1;
data{kl,1}=        'UnifFrictCoef1D   = 0.023        '; kl=kl+1;
data{kl,1}=        'UnifFrictCoefLin  = 0            '; kl=kl+1;
data{kl,1}=        'Umodlin           = 0            '; kl=kl+1;
data{kl,1}=sprintf('Vicouv            = %0.7E',Vicouv); kl=kl+1;
data{kl,1}=sprintf('Dicouv            = %0.7E',Dicouv); kl=kl+1;
data{kl,1}=sprintf('Vicoww            = %0.7E',Vicoww); kl=kl+1;
data{kl,1}=sprintf('Dicoww            = %0.7E',Dicoww); kl=kl+1;
data{kl,1}=        'Vicwminb          = 0            '; kl=kl+1;
data{kl,1}=sprintf('Smagorinsky       = %0.7E',Smagorinsky); kl=kl+1; %Add Smagorinsky horizontal turbulence : vicu = vicu + ( (Smagorinsky*dx)**2)*S, e.g. 0.1
data{kl,1}=        'Elder             = 0            '; kl=kl+1; %Add Elder contribution                : vicu = vicu + Elder*kappa*ustar*H/6),   e.g. 1.0
data{kl,1}=sprintf('Irov              = %d',wall_rough); kl=kl+1;
data{kl,1}=sprintf('wall_ks           = %0.7E',wall_ks); kl=kl+1; %Nikuradse roughness for side walls, wall_z0=wall_ks/30
data{kl,1}=        'Rhomean           = 1000         '; kl=kl+1;
data{kl,1}=        'Idensform         = 2            '; kl=kl+1;
data{kl,1}=sprintf('Ag                = %0.7E',g)     ; kl=kl+1;
data{kl,1}=        'TidalForcing      = 0            '; kl=kl+1;
data{kl,1}=        'Doodsonstart      = 55.565       '; kl=kl+1;
data{kl,1}=        'Doodsonstop       = 375.575      '; kl=kl+1;
data{kl,1}=        'Doodsoneps        = 0            '; kl=kl+1;
data{kl,1}=        'Salinity          = 0            '; kl=kl+1;
data{kl,1}=        'InitialSalinity   = 0            '; kl=kl+1;
data{kl,1}=        'Sal0abovezlev     = -999         '; kl=kl+1;
data{kl,1}=        'DeltaSalinity     = -999         '; kl=kl+1;
data{kl,1}=        'Backgroundsalinity= 0            '; kl=kl+1;
data{kl,1}=        'InitialTemperature= 15           '; kl=kl+1;
data{kl,1}=        'Secchidepth       = 2            '; kl=kl+1;
data{kl,1}=        'Stanton           = -1           '; kl=kl+1;
data{kl,1}=        'Dalton            = -1           '; kl=kl+1;
data{kl,1}=        'Backgroundwatertemperature= 1    '; kl=kl+1;
data{kl,1}=sprintf('SecondaryFlow     = %d',secflow); kl=kl+1;
data{kl,1}=sprintf('BetaSpiral        = %d',secflow); kl=kl+1;
data{kl,1}=        'Temperature       = 0            '; kl=kl+1;
data{kl,1}=        '                                                 '; kl=kl+1;

%%
data{kl,1}=        '[wind]                                  '; kl=kl+1;
data{kl,1}=        'ICdtyp            = 2                   '; kl=kl+1;
data{kl,1}=        'Cdbreakpoints     = 0.00063 0.00723     '; kl=kl+1;
data{kl,1}=        'Windspeedbreakpoints= 0 100             '; kl=kl+1;
data{kl,1}=        'Rhoair            = 1.205               '; kl=kl+1;
data{kl,1}=        'PavBnd            = 0                   '; kl=kl+1;
data{kl,1}=        'PavIni            = 0                   '; kl=kl+1;
%%
data{kl,1}=        '[waves]                                          '; kl=kl+1;
data{kl,1}=        'Wavemodelnr       = 0                            '; kl=kl+1;
data{kl,1}=        'WaveNikuradse     = 0.01                         '; kl=kl+1;
data{kl,1}=        'Rouwav            = FR84                         '; kl=kl+1;
data{kl,1}=        'Gammax            = 1                            '; kl=kl+1;
data{kl,1}=        '                                                 '; kl=kl+1;
%% TIME
data{kl,1}=        '[time]                                           '; kl=kl+1;
data{kl,1}=        'RefDate           = 20000101                     '; kl=kl+1;
data{kl,1}=        'Tzone             = 0                            '; kl=kl+1;
data{kl,1}=sprintf('DtUser            = %0.7E',Dt); kl=kl+1;
data{kl,1}=        'DtNodal           =                              '; kl=kl+1;
data{kl,1}=sprintf('DtMax             = %0.7E',Dt); kl=kl+1;
data{kl,1}=        'DtInit            = 1                            '; kl=kl+1;
data{kl,1}=        'Timestepanalysis  = 0                            '; kl=kl+1; %# 0=no, 1=see file *.steps
% data{kl,1}=        'Autotimestepdiff  = 1                            '; kl=kl+1; %# 0 = no, 1 = yes (Time limitation based on explicit diffusive term)
data{kl,1}=        'Tunit             = S                            '; kl=kl+1;
data{kl,1}=        'TStart            = 0                            '; kl=kl+1;
data{kl,1}=sprintf('TStop             = %d',Tstop); kl=kl+1;
data{kl,1}=        '                                                 '; kl=kl+1;
%%
data{kl,1}=        '[restart]                                        '; kl=kl+1;
data{kl,1}=        'RestartFile       =                              '; kl=kl+1;
data{kl,1}=        'RestartDateTime   = 20190418                     '; kl=kl+1;
data{kl,1}=        '                                                 '; kl=kl+1;
%%
data{kl,1}=        '[external forcing]                               '; kl=kl+1;
data{kl,1}=sprintf('ExtForceFile      = %s',simdef.mdf.ext)           ; kl=kl+1;
data{kl,1}=sprintf('ExtForceFileNew   = %s',simdef.mdf.extn)          ; kl=kl+1;
data{kl,1}=        '                                                 '; kl=kl+1;
%%
data{kl,1}=        '[trachytopes]                                    '; kl=kl+1;
data{kl,1}=        'TrtRou            = N                            '; kl=kl+1;
data{kl,1}=        'TrtDef            =                              '; kl=kl+1;
data{kl,1}=        'TrtL              =                              '; kl=kl+1;
data{kl,1}=        'DtTrt             = 60                           '; kl=kl+1;
data{kl,1}=        '                                                 '; kl=kl+1;
%%
data{kl,1}=        '[output]                                         '; kl=kl+1;
data{kl,1}=        'Wrishp_crs        = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_weir       = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_gate       = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_fxw        = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_thd        = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_obs        = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_emb        = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_dryarea    = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_enc        = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_src        = 0                            '; kl=kl+1;
data{kl,1}=        'Wrishp_pump       = 0                            '; kl=kl+1;
data{kl,1}=        'OutputDir         =                              '; kl=kl+1;
data{kl,1}=        'WAQOutputDir      =                              '; kl=kl+1;
data{kl,1}=        'FlowGeomFile      =                              '; kl=kl+1;
data{kl,1}=sprintf('ObsFile           = %s',obs_filename); kl=kl+1; 
data{kl,1}=        'CrsFile           =                              '; kl=kl+1;
data{kl,1}=        'HisFile           =                              '; kl=kl+1; 
data{kl,1}=sprintf('HisInterval       = %0.7E',Flhis_dt); kl=kl+1; 
data{kl,1}=        'XLSInterval       =                              '; kl=kl+1;
data{kl,1}=        'MapFile           =                              '; kl=kl+1;
data{kl,1}=sprintf('MapInterval       = %0.7E',Flmap_dt); kl=kl+1;
data{kl,1}=sprintf('RstInterval       = %0.7E',Flrst_dt); kl=kl+1;
data{kl,1}=        'S1incinterval     =                              '; kl=kl+1;
data{kl,1}=        'MapFormat         = 4                            '; kl=kl+1;
data{kl,1}=        'Wrihis_balance    = 1                            '; kl=kl+1;
data{kl,1}=        'Wrihis_structure_gen= 1                          '; kl=kl+1;
data{kl,1}=        'Wrihis_structure_dam= 1                          '; kl=kl+1;
data{kl,1}=        'Wrihis_structure_pump= 1                         '; kl=kl+1;
data{kl,1}=        'Wrihis_structure_gate= 1                         '; kl=kl+1;
data{kl,1}=        'Wrimap_waterlevel_s0= 0                          '; kl=kl+1;
data{kl,1}=        'Wrimap_waterlevel_s1= 1                          '; kl=kl+1;
data{kl,1}=        'Wrimap_velocity_component_u0= 0                  '; kl=kl+1;
data{kl,1}=        'Wrimap_velocity_component_u1= 1                  '; kl=kl+1;
data{kl,1}=        'Wrimap_velocity_vector= 1                        '; kl=kl+1;
data{kl,1}=        'Wrimap_upward_velocity_component= 1              '; kl=kl+1;
data{kl,1}=        'Wrimap_density_rho= 0                            '; kl=kl+1;
data{kl,1}=        'Wrimap_horizontal_viscosity_viu= 1               '; kl=kl+1;
data{kl,1}=        'Wrimap_horizontal_diffusivity_diu= 1             '; kl=kl+1;
data{kl,1}=        'Wrimap_flow_flux_q1= 1                           '; kl=kl+1;
data{kl,1}=        'Wrimap_flow_flux_q1_main= 1                      '; kl=kl+1; %mesh1d_q1_main = main channel flow dicharge per unit width
data{kl,1}=        'Wrimap_spiral_flow= 1                            '; kl=kl+1;
data{kl,1}=        'Wrimap_numlimdt   = 1                            '; kl=kl+1;
data{kl,1}=        'Wrimap_taucurrent = 1                            '; kl=kl+1;
data{kl,1}=        'Wrimap_chezy      = 1                            '; kl=kl+1;
data{kl,1}=        'Wrimap_turbulence = 1                            '; kl=kl+1;
data{kl,1}=        'Wrimap_wind       = 0                            '; kl=kl+1;
data{kl,1}=        'Wrimap_heat_fluxes= 0                            '; kl=kl+1;
data{kl,1}=        'MapOutputTimeVector=                             '; kl=kl+1;
data{kl,1}=        'FullGridOutput    = 0                            '; kl=kl+1;
data{kl,1}=        'EulerVelocities   = 0                            '; kl=kl+1;
data{kl,1}=        'ClassMapFile      =                              '; kl=kl+1;
data{kl,1}=        'WaterlevelClasses = 0.0                          '; kl=kl+1;
data{kl,1}=        'WaterdepthClasses = 0.0                          '; kl=kl+1;
data{kl,1}=        'ClassMapInterval  = 0                            '; kl=kl+1;
data{kl,1}=        'WaqInterval       = 0                            '; kl=kl+1;
data{kl,1}=        'StatsInterval     = -1                           '; kl=kl+1;
data{kl,1}=        'Writebalancefile  = 0                            '; kl=kl+1;
data{kl,1}=        'TimingsInterval   =                              '; kl=kl+1;
data{kl,1}=        'Richardsononoutput= 0                            '; kl=kl+1;
data{kl,1}=        '                                                 '; kl=kl+1;
%%
if morphology
data{kl,1}=        '[sediment]                                       '; kl=kl+1;
data{kl,1}=sprintf('MorFile           = %s                      ',simdef.mdf.mor); kl=kl+1;
data{kl,1}=sprintf('SedFile           = %s                      ',simdef.mdf.sed); kl=kl+1;
data{kl,1}=        'Sedimentmodelnr   = 4                            '; kl=kl+1;
data{kl,1}=        'MorCFL            = 0                            '; kl=kl+1; %Use morphological time step restriction (1, default) or not (0)

end
%% WRITE

% file_name=fullfile(dire_sim,sprintf('sim_%s%s.mdu',runid_serie,runid_number));
writetxt(file_name,data,'check_existing',check_existing);

%%

%
%[model]
%Program                      = D-Flow FM
%Version                      = 1.1.99.34297M
%AutoStart                    = 0                   # Autostart simulation after loading MDU or not (0=no, 1=autostart, 2=autostartstop).
%
%[geometry]
%NetFile                      = t01_net.nc          # *_net.nc
%BathymetryFile               = bathymetry.xyb      # *.xyb
%WaterLevIniFile              =                     # Initial water levels sample file *.xyz
%LandBoundaryFile             =                     # Only for plotting
%ThinDamFile                  =                     # *_thd.pli, Polyline(s) for tracing thin dams.
%ThindykeFile                 =                     # *_tdk.pli, Polyline(s) x,y,z, z = thin dyke top levels
%VertplizFile                 =                     # *_vlay.pliz), = pliz with x,y, Z, first Z =nr of layers, second Z = laytyp
%ProflocFile                  =                     # *_proflocation.xyz)    x,y,z, z = profile refnumber
%ProfdefFile                  =                     # *_profdefinition.def) definition for all profile nrs
%ProfdefxyzFile               =                     # *_profdefinition.def) definition for all profile nrs
%Uniformwidth1D               = 2.                  # Uniform width for 1D profiles not specified bij profloc
%ManholeFile                  =                     # *...
%WaterLevIni                  = 0.                  # Initial water level
%Bedlevuni                    = -5.                 # Uniform bottom level, (only if bedlevtype>=3, used at missing z values in netfile
%BedlevType                   = 1                   # 1 : Bottom levels at waterlevel cells (=flow nodes), like tiles xz, yz, bl , bob = max(bl left, bl right)
%                                                   # 2 : Bottom levels at velocity points  (=flow links),            xu, yu, blu, bob = blu,    bl = lowest connected link
%                                                   # 3 : Bottom levels at velocity points  (=flow links), using mean network levels xk, yk, zk  bl = lowest connected link
%                                                   # 4 : Bottom levels at velocity points  (=flow links), using min  network levels xk, yk, zk  bl = lowest connected link
%                                                   # 5 : Bottom levels at velocity points  (=flow links), using max  network levels xk, yk, zk  bl = lowest connected link
%PartitionFile                =                     # *_part.pol, polyline(s) x,y
%AngLat                       = 0.                  # Angle of latitude  S-N (deg), 0=no Coriolis
%AngLon                       = 0.                  # Angle of longitude E-W (deg), 0=Greenwich
%Conveyance2D                 = -1                   # -1:R=HU,0:R=H, 1:R=A/P, 2:K=analytic-1D conv, 3:K=analytic-2D conv
%Nonlin2D                     = 0                   # Non-linear 2D volumes, only icm ibedlevtype = 3
%Makeorthocenters             = 0                   # 1=yes, 0=no switch from circumcentres to orthocentres in geominit
%Dcenterinside                = 1.                  # limit cell center; 1.0:in cell <-> 0.0:on c/g
%
%[numerics]
%CFLMax                       = 0.7                 # Max. Courant nr.
%AdvecType                    = 33                   # Adv type, 0=no, 1= Wenneker, qu-udzt, 2=1, q(uio-u), 3=Perot q(uio-u), 4=Perot q(ui-u), 5=Perot q(ui-u) without itself
%TimeStepType                 = 2                   #  0=only transport, 1=transport + velocity update, 2=full implicit step_reduce, 3=step_jacobi, 4=explicit
%Limtypmom                    = 4                   # Limiter type for cell center advection velocity, 0=no, 1=minmod,2=vanLeer,3=Kooren,4=Monotone Central
%Limtypsa                     = 0                   # Limiter type for salinity transport,           0=no, 1=minmod,2=vanLeer,3=Kooren,4=Monotone Central
%Icgsolver                    = 4                   # Solver type , 1 = sobekGS_OMP, 2 = sobekGS_OMPthreadsafe, 3 = sobekGS, 4 = sobekGS + Saadilud, 5 = parallel/global Saad, 6 = parallel/Petsc, 7 = parallel/GS
%Tlfsmo                       = 0.                  # Fourier smoothing time on waterlevel boundaries (s)
%Slopedrop2D                  = 0.3                 # Apply droplosses only if local bottom slope > Slopedrop2D, <=0 =no droplosses
%cstbnd                       = 0                   # Delft-3D type velocity treatment near boundaries for small coastal models (1) or not (0)
%
%[physics]
%UnifFrictCoef                = 2.5d-2              # Uniform friction coefficient, 0=no friction
%UnifFrictType                = 2                   # 0=Chezy, 1=Manning, 2=White Colebrook, 3=z0 etc
%UnifFrictCoef1D              =                     # Uniform friction coefficient in 1D links, 0=no friction
%UnifFrictCoefLin             = 0.                  # Uniform linear friction coefficient for ocean models (m/s), 0=no
%Vicouv                       = 1e-6                  # Uniform horizontal eddy viscosity (m2/s)
%Dicouv                       = 1.                  # Uniform horizontal eddy diffusivity (m2/s)
%Smagorinsky                  = 0.                  # Add Smagorinsky horizontal turbulence : vicu = vicu + ( (Smagorinsky*dx)**2)*S, e.g. 0.1
%Elder                        = 0.                  # Add Elder contribution                : vicu = vicu + Elder*kappa*ustar*H/6),   e.g. 1.0
%irov                         = 0                   # 0=free slip, 1 = partial slip using wall_ks
%wall_ks                      = 0.                  # Nikuradse roughness for side walls, wall_z0=wall_ks/30
%Rhomean                      = 1000.               #  Average water density (kg/m3)
%Ag                           = 9.81                #  Gravitational acceleration
%TidalForcing                 = 1                   # Tidal forcing (0=no, 1=yes) (only for jsferic == 1)
%Salinity                     = 0                   # Include salinity, (0=no, 1=yes)
%Temperature                  = 0                   # Include temperature, (0=no, 1=only transport, 5=heat flux model (5) of D3D)
%Backgroundwatertemperature   = 20.
%Backgroundsalinity           = 0.
%
%[sediment]
%Sedimentmodelnr              = 4                   # Sediment model nr, (0=no, 1=Krone, 2=SvR2007)
%SedFile                      = t01.sed             # Sediment characteristics file (*.sed)
%MorFile                      = t01.mor             # Morphology settings file (*.mor)
%DredgeFile                   = Nourishment.dad            # dredging
%
%[wind]
%ICdtyp                       = 2                   # ( ),1=const, 2=S&B 2 breakpoints, 3= S&B 3 breakpoints, 4=Charnock constant
%Cdbreakpoints                = 2.5d-3 2.5d-3       # ( ),   e.g. 0.00063  0.00723
%Windspeedbreakpoints         = 0. 100.             # (m/s), e.g. 0.0      100.0
%
%[time]
%RefDate                      = 20160803            # Reference date (yyyymmdd)
%Tzone                        = 0.                  # Data Sources in GMT are interrogated with time in minutes since refdat-Tzone*60
%Tunit                        = M                   # Time units in MDU (H, M or S)
%DtUser                       = 0.05                # User timestep in seconds (interval for external forcing update & his/map output)
%DtMax                        = 0.05                # Max timestep in seconds
%DtInit                       = 1.                  # Initial timestep in seconds
%AutoTimestep                 = 0.                   # Use CFL timestep limit or not (1/0)
%TStart                       = 0.               # Start time w.r.t. RefDate (in TUnit)
%TStop                        = 20      # Stop  time w.r.t. RefDate (in TUnit)
%
%[restart]
%RestartFile                  =                     # Restart file, only from netcdf-file, hence: either *_rst.nc or *_map.nc
%RestartDateTime              = 20000218000000      # Restart time (YYYYMMDDHHMMSS), only relevant in case of restart from *_map.nc
%
%[external forcing]
%ExtForceFile                 = t01.ext             # *.ext
%
%[output]
%OutputDir                    = dflowfmoutput       # Output directory of map-, his-, rst-, dat- and timings-files, default: DFM_OUTPUT_<modelname>. Set to . for no dir/current dir.
%ObsFile                      = t01_obs.xyn         # *.xyn Coords+name of observation stations.
%CrsFile                      =          # *_crs.pli Polyline(s) definining cross section(s).
%HisInterval                  = 1.                 # History output, given as "interval" "start period" "end period" (s)
%XLSInterval                  = 0.                  # Interval (s) between XLS history
%FlowGeomFile                 =                     # *_flowgeom.nc Flow geometry file in NetCDF format.
%MapInterval                  = 3                 # Map file output, given as "interval" "start period" "end period" (s)
%MapFormat                    = 4                   # Map file format, 1: netCDF, 2: Tecplot, 3: netCFD and Tecplot
%Richardsononoutput           = 0                   # 1=yes,0=no
%RstInterval                  = 0.                  # Restart file output, given as "interval" "start period" "end period" (s)
%WaqInterval                  = 0.                  # Interval (in s) between Delwaq file outputs
%StatsInterval                = 0.                  # Interval (in s) between simulation statistics output.
%TimingsInterval              = 0.                  # Timings output interval
%TimeSplitInterval            = 0X                  # Time splitting interval, after which a new output file is started. value+unit, e.g. '1 M', valid units: Y,M,D,h,m,s.
%MapOutputTimeVector          =                     # File (.mpt) containing fixed map output times (s) w.r.t. RefDate
%FullGridOutput               = 0                   # 0:compact, 1:full time-varying grid data

