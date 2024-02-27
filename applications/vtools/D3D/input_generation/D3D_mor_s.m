%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17062 $
%$Date: 2021-02-12 20:47:20 +0800 (Fri, 12 Feb 2021) $
%$Author: chavarri $
%$Id: D3D_mor_s.m 17062 2021-02-12 12:47:20Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mor_s.m $
%
%morphological initial file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.mor.ThTrLyr = active layer thickness [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.ThUnLyr = thickness of each underlayer [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.total_ThUnLyr = thickness of the entire bed [m] [double(1,1)] e.g. [1.5]
%   -simdef.mor.IHidExp = hiding exposure flag [-] [integer(1,1)] e.g. [1]  1=none; 2=Egiazaroff; 3=Ashida-Michiue; 4=Power Law
%   -simdef.mor.ASKLHE = Power Law hiding factor (in case simdef.mor.hiding=4). ATTENTION! in ECT is defined with a change of sign!
%   -simdef.mor.MorStt = spin-up time [s] [double(1,1)] e.g. [1800]
%   -simdef.mor.MorFac = morphological accelerator factor [-] [double(1,1)] e.g. 10
%
%OUTPUT:
%   -a .mor compatible with D3D is created in file_name

function D3D_mor_s(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

IHidExp=simdef.mor.IHidExp;
ASKLHE=simdef.mor.ASKLHE;
ThTrLyr=simdef.mor.ThTrLyr;
ThUnLyr=simdef.mor.ThUnLyr;
total_ThUnLyr=simdef.mor.total_ThUnLyr;
MorStt=simdef.mor.MorStt;
MorFac=simdef.mor.MorFac;
ISlope=simdef.mor.ISlope;
AShld=simdef.mor.AShld;
BShld=simdef.mor.BShld;
CShld=simdef.mor.CShld;
DShld=simdef.mor.DShld;
IBedCond=simdef.mor.IBedCond;
ICmpCond=simdef.mor.ICmpCond;
secflow=simdef.mdf.secflow;
upstream_nodes=simdef.mor.upstream_nodes;

HiranoCheck=simdef.mor.HiranoCheck;
HiranoCheckPerturbation=1e-6;
HiranoCheckEigThr=1e-6;

%other
MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
nf=numel(simdef.sed.dk);

%update
if simdef.mor.BedUpd==1
    BedUpd='true';
    UpdInf='true';
else
    BedUpd='false';
    UpdInf='false';
end
if simdef.mor.CmpUpd==1
    CmpUpd='true';
else
    CmpUpd='false';
end
if simdef.mor.UpwindBedload==1
    UpwindBedload='true';
else
    UpwindBedload='false';
end

%% FILE

kl=1;
data{kl,1}=        '[MorphologyFileInformation]'; kl=kl+1;
data{kl,1}=        '   FileCreatedBy    = V'; kl=kl+1;
data{kl,1}=        '   FileCreationDate = today :D'; kl=kl+1;
data{kl,1}=        '   FileVersion      = 02.00'; kl=kl+1;
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[Morphology]'; kl=kl+1;
data{kl,1}=        '   EpsPar           = false                         Vertical mixing distribution according to van Rijn (overrules k-epsilon model)'; kl=kl+1;
data{kl,1}=        '   IopKCW           = 1                             Flag for determining Rc and Rw'; kl=kl+1;
data{kl,1}=        '   RDC              = 0.01                 [m]      Current related roughness height (only used if IopKCW <> 1)'; kl=kl+1;
data{kl,1}=        '   RDW              = 0.02                 [m]      Wave related roughness height (only used if IopKCW <> 1)'; kl=kl+1;
data{kl,1}=sprintf('   MorFac           =  %0.7E               [-]      Morphological scale factor',MorFac); kl=kl+1;
data{kl,1}=sprintf('   MorStt           =  %0.7E               [s]      Spin-up interval from TStart till start of morphological changes',MorStt); kl=kl+1;
data{kl,1}=sprintf('   Thresh           =  %0.7E               [m]      Threshold sediment thickness for transport and erosion reduction',ThTrLyr); kl=kl+1;
data{kl,1}=sprintf('   BedUpd           = %s                            Update bed levels during FLOW simulation',BedUpd); kl=kl+1;
data{kl,1}=sprintf('   UpdInf           = %s                            Update bed levels at inflow boundaries during FLOW simulation',UpdInf); kl=kl+1;
data{kl,1}=sprintf('   CmpUpd           = %s                            Update bed composition during flow run',CmpUpd); kl=kl+1;
data{kl,1}=        '   EqmBc            = true                          Equilibrium sand concentration profile at inflow boundaries'; kl=kl+1;
data{kl,1}=        '   DensIn           = false                         Include effect of sediment concentration on fluid density'; kl=kl+1;
data{kl,1}=        '   AksFac           =  1.0000000e+000      [-]      van Rijn''s reference height = AKSFAC * KS'; kl=kl+1;
data{kl,1}=        '   RWave            =  1.0000000e+000      [-]      Wave related roughness = RWAVE * estimated ripple height. Van Rijn Recommends range 1-3'; kl=kl+1;
data{kl,1}=        '   AlfaBs           =  0.0000000e+000      [-]      Streamwise bed gradient factor for bed load transport'; kl=kl+1;
data{kl,1}=        '   AlfaBn           =  0.0000000e+000      [-]      Transverse bed gradient factor for bed load transport'; kl=kl+1;
data{kl,1}=        '   Sus              =  1.0000000e+000      [-]      Multiplication factor for suspended sediment reference concentration'; kl=kl+1;
data{kl,1}=        '   Bed              =  1.0000000e+000      [-]      Multiplication factor for bed-load transport vector magnitude'; kl=kl+1;
data{kl,1}=        '   SusW             =  1.0000000e+000      [-]      Wave-related suspended sed. transport factor'; kl=kl+1;
data{kl,1}=        '   BedW             =  1.0000000e+000      [-]      Wave-related bed-load sed. transport factor'; kl=kl+1;
data{kl,1}=        '   SedThr           =  1.0000000e-003      [m]      Minimum water depth for sediment computations'; kl=kl+1;
data{kl,1}=        '   ThetSD           =  0.0000000e+000      [-]      Factor for erosion of adjacent dry cells'; kl=kl+1;
data{kl,1}=        '   HMaxTH           =  1.5000000e+000      [m]      Max depth for variable THETSD. Set < SEDTHR to use global value only'; kl=kl+1;
data{kl,1}=        '   FWFac            =  1.0000000e+000      [-]      Vertical mixing distribution according to van Rijn (overrules k-epsilon model)'; kl=kl+1;
data{kl,1}=        '   EpsPar = false     [T/F] Only for waves in combination with k-epsilon turbulence model'; kl=kl+1;
data{kl,1}=        '                            TRUE : Van Rijn''s parabolic-linear mixing distribution for current-related mixing '; kl=kl+1;
data{kl,1}=        '                            FALSE: Vertical sediment mixing values from K-epsilon turbulence model'; kl=kl+1;
data{kl,1}=        '   IopKCW = 1         [ - ] Flag for determining Rc and Rw'; kl=kl+1;
data{kl,1}=        '                            1 (default): Rc from flow, Rw=RWAVE*0.025'; kl=kl+1;
data{kl,1}=        '                            2          : Rc=RDC and Rw=RDW as read from this file'; kl=kl+1;
data{kl,1}=        '                            3          : Rc=Rw determined from mobility'; kl=kl+1;
data{kl,1}=        '   RDC    = 0.01      [ - ] Rc in case IopKCW = 2'; kl=kl+1;
data{kl,1}=        '   RDW    = 0.02      [ - ] Rw in case IopKCW = 2'; kl=kl+1;
if secflow
data{kl,1}=        '   Espir  = 1.0       [ - ] Calibration factor spiral flow'; kl=kl+1;
else
data{kl,1}=        '   Espir  = 0.0       [ - ] Calibration factor spiral flow'; kl=kl+1;
end
data{kl,1}=sprintf('   ISlope = %d         [ - ] Flag for bed slope effect',ISlope); kl=kl+1;
data{kl,1}=        '                            1          : None'; kl=kl+1;
data{kl,1}=        '                            2 (default): Bagnold'; kl=kl+1;
data{kl,1}=        '                            3          : Koch & Flokstra'; kl=kl+1;
data{kl,1}=sprintf('   AShld  = %f       [ - ] Bed slope parameter Koch & Flokstra',AShld); kl=kl+1;
data{kl,1}=sprintf('   BShld  = %f       [ - ] Bed slope parameter Koch & Flokstra',BShld); kl=kl+1;
data{kl,1}=sprintf('   CShld  = %f       [ - ] Bed slope parameter Koch & Flokstra',CShld); kl=kl+1;
data{kl,1}=sprintf('   DShld  = %f       [ - ] Bed slope parameter Koch & Flokstra',DShld); kl=kl+1;
data{kl,1}=sprintf('   IHidExp= %d        [ - ] Flag for hiding & exposure',IHidExp); kl=kl+1;
data{kl,1}=        '                            1 (default): none'; kl=kl+1;
data{kl,1}=        '                            2          : Egiazaroff'; kl=kl+1;
data{kl,1}=        '                            3          : Ashida & Michiue, modified Egiazaroff'; kl=kl+1;
data{kl,1}=        '                            4          : Soehngen, Kellermann, Loy'; kl=kl+1;
data{kl,1}=        '                            5          : Wu, Wang, Jia'; kl=kl+1;
if any(IBedCond==[3,5])
data{kl,1}=        '   BcFil  = bcm.bcm'; kl=kl+1;
else
data{kl,1}=        '   BcFil  =        '; kl=kl+1;
end
data{kl,1}=sprintf('   ASKLHE = %0.7E',ASKLHE); kl=kl+1;
for kn=1:upstream_nodes
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[Boundary]'; kl=kl+1;
data{kl,1}=sprintf('  Name = Upstream_%02d',kn); kl=kl+1;
data{kl,1}=sprintf('  IBedCond = %d',IBedCond); kl=kl+1;
data{kl,1}=sprintf('  ICmpCond = %d',ICmpCond); kl=kl+1;
end
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[Boundary]'; kl=kl+1;
data{kl,1}=        '  Name = Downstream'; kl=kl+1;
data{kl,1}=        '  IBedCond = 0'; kl=kl+1;
data{kl,1}=        '  ICmpCond = 0'; kl=kl+1;
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[Output]'; kl=kl+1;
data{kl,1}=        '  Dm = false'; kl=kl+1;
data{kl,1}=        '  Dg = false'; kl=kl+1;
data{kl,1}=        '  HidExp = false'; kl=kl+1;
data{kl,1}=        '  Percentiles = 10'; kl=kl+1;
data{kl,1}=        ''; kl=kl+1;
data{kl,1}=        '[Numerics]'; kl=kl+1;
data{kl,1}=sprintf('  HiranoCheck = %d       [ - ] Flag for well-posedness of Hirano check',HiranoCheck); kl=kl+1;
data{kl,1}=        '                            0 (default): Off'; kl=kl+1;
data{kl,1}=        '                            1          : On'; kl=kl+1;
data{kl,1}=sprintf('  HiranoCheckPertubation = %0.7E',HiranoCheckPerturbation); kl=kl+1;
data{kl,1}=sprintf('  HiranoCheckEigThr = %0.7E',HiranoCheckEigThr); kl=kl+1;
data{kl,1}=sprintf('  UpwindBedload = %s',UpwindBedload); kl=kl+1;
data{kl,1}=        ''; kl=kl+1;
%% UNDERLAYER
data{kl,1}=        '[Underlayer]'; kl=kl+1;
data{kl,1}=sprintf('  IUnderLyr = %d       [ - ] Flag for underlayer concept',simdef.mor.IUnderLyr); kl=kl+1;
data{kl,1}=        '                            1 (default): one fully mixed layer'; kl=kl+1;
data{kl,1}=        '                            2          : graded sediment underlayers'; kl=kl+1;
if nf>1
data{kl,1}=        '  IniComp          = mini.ini'; kl=kl+1;
data{kl,1}=        '  ExchLyr = false     [T/F] Switch for exchange layer'; kl=kl+1;
data{kl,1}=        '  TTLForm = 1         [ - ] Transport layer thickness formulation'; kl=kl+1;
data{kl,1}=        '                            1 (default): constant (user-specified) thickness'; kl=kl+1;
data{kl,1}=sprintf('  ThTrLyr = %0.7E       [ m ] Thickness of the transport layer',ThTrLyr); kl=kl+1;
data{kl,1}=sprintf('  MxNULyr = %d          [ - ] Number of underlayers (excluding final well mixed layer)',MxNULyr); kl=kl+1;
data{kl,1}=sprintf('  ThUnLyr = %0.7E       [ m ] Thickness of each underlayer',ThUnLyr); 
end
%% WRITE

file_name=fullfile(dire_sim,'mor.mor');

%check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
for kl=1:numel(data)
    fprintf(fileID_out,'%s \n',data{kl,1});
end

fclose(fileID_out);