%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18270 $
%$Date: 2022-08-01 18:23:51 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: D3D_mdf.m 18270 2022-08-01 10:23:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mdf.m $
%
%mdf creation

%INPUT:
%   -dire_out = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.runid.serie = run serie [string] e.g. 'A'
%   -simdef.runid.number = run identification number [integer(1,1)] e.g. 36
%   -simdef.grd.M = number of nodes in the domain [-] [integer(1,1)] e.g. [1002]
%   -simdef.mdf.Tstop = simulation time [s] [double(1,1)] e.g. [48000]
%   -simdef.mdf.Dt = time step [s]
%   -simdef.mdf.C = Chezy friction coefficient [m/s^(1/2)] [double(1,1)] e.g. [25.5]
%   -simdef.mdf.Flmap_dt = printing map-file interval time [s] [double(1,1)] e.g. [60]
%
%OUTPUT:
%   -a .mdf file compatible with D3D is created in folder_out
%
%150717->150728
%   -Introduction of runid flag as input
%
%150728->151119
%   -Introductuion of friction as input
%   -Introduction of map print time as input

function D3D_mdf(simdef,varargin)

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

file_name=simdef.file.mdf;

% path_grd=fullfile(dire_sim,'grd.grd');
path_grd=simdef.file.grd;

%only straight flume!
% M=simdef.grd.M;
% N=simdef.grd.N;

%read grid
grd=wlgrid('read',path_grd);
M=size(grd.X,1)+1;
N=size(grd.X,2)+1;

K=simdef.grd.K;
restart=simdef.mdf.restart;
Tstart=simdef.mdf.Tstart;
Tunit=simdef.mdf.Tunit;
Tfact=simdef.mdf.Tfact;
Tstop=simdef.mdf.Tstop;
Dt=simdef.mdf.Dt;   
C=simdef.mdf.C;
Flmap_dt=simdef.mdf.Flmap_dt;
Flhis_dt=simdef.mdf.Flhis_dt;

Dpsopt=simdef.mdf.Dpsopt;
Dpuopt=simdef.mdf.Dpuopt;
secflow=simdef.mdf.secflow;

wall_rough=simdef.mdf.wall_rough;
wall_ks=simdef.mdf.wall_ks;

Vicouv=simdef.mdf.Vicouv;
Dicouv=simdef.mdf.Dicouv;
Vicoww=simdef.mdf.Vicoww;
Dicoww=simdef.mdf.Dicoww;

if K>1
    Thick=[simdef.grd.Thick,100-sum(simdef.grd.Thick)];
else
    Thick=100;
end
    
%% FILE

kl=1;
data{kl,1}=        'Ident  = #Delft3D-FLOW 3.56.29165#'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Filcco = #grd.grd#'; kl=kl+1;
data{kl,1}=        'Anglat =  0.0000000e+000'; kl=kl+1;
data{kl,1}=        'Grdang =  0.0000000e+000'; kl=kl+1;
data{kl,1}=        'Filgrd = #enc.enc#'; kl=kl+1;
data{kl,1}=sprintf('MNKmax = %d %d %d',M,N,K); kl=kl+1;
data{kl,1}=sprintf('Thick  = %0.7E',Thick(1)); kl=kl+1;
for cl=1:numel(Thick)-1
data{kl,1}=sprintf('         %0.7E',Thick(cl+1)); kl=kl+1;
end
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Fildep = #dep.dep#'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Commnt =                 no. dry points: 0'; kl=kl+1;
data{kl,1}=        'Commnt =                 no. thin dams: 0'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Itdate = #2000-01-01#'; kl=kl+1;
data{kl,1}=sprintf('Tunit  = #%s#',Tunit); kl=kl+1;
data{kl,1}=sprintf('Tstart = %0.7E',Tstart*Tfact); kl=kl+1;
data{kl,1}=sprintf('Tstop  = %0.7E',Tstop*Tfact); kl=kl+1;
data{kl,1}=sprintf('Dt     = %0.7E',Dt*Tfact); kl=kl+1;
if restart==1
data{kl,1}=        'Restid  = #trim-restart#'; kl=kl+1;
end
data{kl,1}=        'Tzone  = 0'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
if secflow==1
data{kl ,1}=        'Sub1   = #   I#'; kl=kl+1; %with computation of advection-diffusion of secondary flow intensity
else
data{kl ,1}=        'Sub1   = #    #'; kl=kl+1; %without computation of advection-diffusion of secondary flow intensity
end
data{kl,1}=        'Sub2   = #   #'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Wnsvwp = #N#'; kl=kl+1;
data{kl,1}=        'Wndint = #Y#'; kl=kl+1;
data{kl,1}=        'Commnt =                 initial conditions from initial conditions file'; kl=kl+1;
data{kl,1}=        'Filic  = #fini.ini#                 '; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Commnt =                 no. open boundaries: 2'; kl=kl+1;
data{kl,1}=        'Filbnd = #bnd.bnd#'; kl=kl+1;
data{kl,1}=        'FilbcT = #bct.bct#'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Ag     =  9.8100000e+000'; kl=kl+1;
data{kl,1}=        'Rhow   =  1.0000000e+003'; kl=kl+1;
data{kl,1}=        'Tempw  =  1.5000000e+001'; kl=kl+1;
data{kl,1}=        'Salw   =  0.0000000e+001'; kl=kl+1;
data{kl,1}=        'Wstres =  6.3000000e-004  0.0000000e+000  7.2300000e-003  1.0000000e+002  7.2300000e-003  1.0000000e+002'; kl=kl+1;
data{kl,1}=        'Rhoa   =  1.0000000e+000'; kl=kl+1;
data{kl,1}=        'Betac  =  1.0000000e+000'; kl=kl+1;
data{kl,1}=        'Equili = #N#'; kl=kl+1; %flag for computation of equilibrium secondary flow
data{kl,1}=        'Tkemod = #K-epsilon   #'; kl=kl+1; %turbulence closure model #Constant    #, #Algebraic #, #K-epsilon   #
data{kl,1}=        'Ktemp  = 0'; kl=kl+1;
data{kl,1}=        'Fclou  =  0.0000000e+000'; kl=kl+1;
data{kl,1}=        'Sarea  =  0.0000000e+000'; kl=kl+1;
data{kl,1}=        'Temint = #Y#'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
switch simdef.mdf.FrictType
    case 0
data{kl,1}=        'Roumet = #C#'; kl=kl+1; %C, W
    case 2
data{kl,1}=        'Roumet = #W#'; kl=kl+1; %C, W
    otherwise
        error('in Delft3D-4, friction can only be chezy or White-Colebrook')
end
data{kl,1}=sprintf('Ccofu  =  %0.7E',C); kl=kl+1;
data{kl,1}=sprintf('Ccofv  =  %0.7E',C); kl=kl+1;
data{kl,1}=        'Xlo    =  0.0000000e+000'; kl=kl+1;
data{kl,1}=sprintf('Vicouv =  %0.7E',Vicouv); kl=kl+1;
data{kl,1}=sprintf('Dicouv =  %0.7E',Dicouv); kl=kl+1;
data{kl,1}=sprintf('Vicoww =  %0.7E',Vicoww); kl=kl+1;
data{kl,1}=sprintf('Dicoww =  %0.7E',Dicoww); kl=kl+1;
data{kl,1}=        'Htur2d = #N#'; kl=kl+1;
data{kl,1}=sprintf('Irov   = %d',wall_rough); kl=kl+1;
data{kl,1}=sprintf('Z0v    = %0.7E',wall_ks/30); kl=kl+1;
if simdef.mor.morphology
data{kl,1}=sprintf('Filsed = #%s#',simdef.mdf.sed); kl=kl+1;
data{kl,1}=sprintf('Filmor = #%s#',simdef.mdf.mor); kl=kl+1;
end
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Iter   =      2'; kl=kl+1;
%data{kl,1}=        'Dryflp = #YES#'; kl=kl+1;
data{kl,1}=sprintf('Dpsopt = #%s#',Dpsopt); kl=kl+1; %flow depth at cell centres: DP=depth specified at cell centres; kl=kl+1; MAX; kl=kl+1; MEAN; kl=kl+1; MIN
data{kl,1}=sprintf('Dpuopt = #%s#',Dpuopt); kl=kl+1; %flow depth at cell interface: ATT! DPSOPT = DP and DPUOPT = MEAN should not be used together. dpuopt = #mean_dps#, 
data{kl,1}=        'Dryflc =  1.0000000e-003'; kl=kl+1;
data{kl,1}=        'Dco    = -9.9900000e+002'; kl=kl+1;
data{kl,1}=        'Tlfsmo =  0.0000000e+001'; kl=kl+1; %smoothing boundary conditions time [6.0000000e+001]
data{kl,1}=        'ThetQH =  0.0000000e+000'; kl=kl+1;
data{kl,1}=        'Forfuv = #Y#'; kl=kl+1;
data{kl,1}=        'Forfww = #N#'; kl=kl+1;
data{kl,1}=        'Sigcor = #N#'; kl=kl+1;
data{kl,1}=        'Trasol = #Cyclic-method#'; kl=kl+1;
data{kl,1}=        'Momsol = #Cyclic#'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Commnt =                 no. discharges: 0'; kl=kl+1;
data{kl,1}=        'Commnt =                 no. observation points: 0'; kl=kl+1;
if isfield(simdef.mdf,'obs_name')
data{kl,1}=        'Filsta= #obs.obs#'; kl=kl+1;
data{kl,1}=        'Fmtsta= #FR#'; kl=kl+1;
end
data{kl,1}=        'Commnt =                 no. drogues: 0'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'Commnt =                 no. cross sections: 0'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'SMhydr = #YYYYY#     '; kl=kl+1;
data{kl,1}=        'SMderv = #YYYYYY#    '; kl=kl+1;
data{kl,1}=        'SMproc = #YYYYYYYYYY#'; kl=kl+1;
data{kl,1}=        'PMhydr = #YYYYYY#    '; kl=kl+1;
data{kl,1}=        'PMderv = #YYY#       '; kl=kl+1;
data{kl,1}=        'PMproc = #YYYYYYYYYY#'; kl=kl+1;
data{kl,1}=        'SHhydr = #YYYY#      '; kl=kl+1;
data{kl,1}=        'SHderv = #YYYYY#     '; kl=kl+1;
data{kl,1}=        'SHproc = #YYYYYYYYYY#'; kl=kl+1;
data{kl,1}=        'SHflux = #YYYY#      '; kl=kl+1;
data{kl,1}=        'PHhydr = #YYYYYY#    '; kl=kl+1;
data{kl,1}=        'PHderv = #YYY#       '; kl=kl+1;
data{kl,1}=        'PHproc = #YYYYYYYYYY#'; kl=kl+1;
data{kl,1}=        'PHflux = #YYYY#      '; kl=kl+1;
% data{kl,1}=sprintf('Flmap  =  0.0000000e+000 %0.7e   %0.7e',Flmap_dt,ceil(Tstop/Flmap_dt)*Flmap_dt); kl=kl+1;
data{kl,1}=sprintf('Flmap  =  %0.7e %0.7e   %0.7e',Flmap_dt(1)*Tfact,Flmap_dt(2)*Tfact,Tstop*Tfact); kl=kl+1;
data{kl,1}=sprintf('Flhis  =  0.0000000e+000 %0.7e   %0.7e',Flhis_dt*Tfact,Tstop*Tfact); kl=kl+1;
data{kl,1}=        'Flpp   =  0.0000000e+000 0    0.0000000e+000'; kl=kl+1;
data{kl,1}=        'Flrst  = 0'; kl=kl+1;
data{kl,1}=        'Commnt =                  '; kl=kl+1;
data{kl,1}=        'CflMsg = #Y#'; kl=kl+1; %write more than 100 CFL cheks
data{kl,1}=        'Online = #N#'; kl=kl+1;
data{kl,1}=        'chezy  = #Y#'; kl=kl+1; %output Chezy friction
data{kl,1}=        'Commnt =                  '; kl=kl+1;
if simdef.mor.morphology
data{kl,1}=sprintf('TraFrm = #%s#',simdef.mdf.tra); 
end


%% WRITE

% file_name=fullfile(dire_sim,sprintf('sim_%s%s.mdf',runid_serie,runid_number));
% writetxt(file_name,data)
writetxt(file_name,data,'check_existing',check_existing);
