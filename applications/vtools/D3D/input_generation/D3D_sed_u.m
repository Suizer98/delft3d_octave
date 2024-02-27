%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17699 $
%$Date: 2022-02-01 16:11:11 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_sed_u.m 17699 2022-02-01 08:11:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_sed_u.m $
%
%sediment unstructured initial file creation

%INPUT:
%   -
%
%OUTPUT:
%   -a .sed file compatible with D3D is created in file_name

function D3D_sed_u(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

% dire_sim=simdef.D3D.dire_sim;
file_name=simdef.file.sed;
IFORM=simdef.tra.IFORM; %sediment transport flag [-] [integer(1,1)] 2=MPM; 4=MPM-based; 14=AM
sedTrans=simdef.tra.sedTrans;
dk=simdef.sed.dk;

node_relations=false;
if isfield(simdef.tra,'node_relations')
    node_relations=simdef.tra.node_relations;
end
    
%other
nf=length(dk); %number of fractions 

switch IFORM
    case 4
        ACal=sedTrans(:,1).*ones(nf,1);
        PowerB=zeros(nf,1).*ones(nf,1);
        PowerC=sedTrans(:,2).*ones(nf,1);
        ThetaC=sedTrans(:,3).*ones(nf,1);
        RipFac=ones(nf,1).*ones(nf,1);
    case 14
        ACal=sedTrans(:,1).*ones(nf,1);
        ThetaC=sedTrans(:,2).*ones(nf,1);
        PowerM=1.5*ones(nf,1).*ones(nf,1);
        PowerP=ones(nf,1).*ones(nf,1);
        PowerQ=ones(nf,1).*ones(nf,1);  

end

%% FILE

%preamble
kl=1;
data{kl,1}='[SedimentFileInformation]'; kl=kl+1;
data{kl,1}='   FileCreatedBy    = V         '; kl=kl+1;
data{kl,1}=sprintf('   FileCreationDate = %s         ',datestr(now)); kl=kl+1;  
data{kl,1}='   FileVersion      = 02.00                        '; kl=kl+1;
data{kl,1}='[SedimentOverall]'; kl=kl+1;
data{kl,1}='   Cref             =  1.6000000e+003      [kg/m3]  CSoil Reference density for hindered settling calculations'; kl=kl+1;
% data{7  ,1}='   IopSus           = 0                             If Iopsus = 1: susp. sediment size depends on local flow and wave conditions';

%fractions
for kf=1:nf
    data{kl,1}=        '[Sediment]'; kl=kl+1;
    data{kl,1}=sprintf('   Name             = #Sediment%d#                   Name of sediment fraction',kf); kl=kl+1;
    data{kl,1}=        '   SedTyp           = bedload                       Must be "sand", "mud" or "bedload"'; kl=kl+1;
    data{kl,1}=        '   IniSedThick      =  1.0000000e+000      [m]      Initial sediment layer thickness at bed (overuled if IniComp is prescribed)'; kl=kl+1;
    data{kl,1}=        '   RhoSol           =  2.6500000e+003      [kg/m3]  Specific density'; kl=kl+1;
    data{kl,1}=sprintf('   TraFrm           = %d                            Integer selecting the transport formula',IFORM); kl=kl+1;
    data{kl,1}=        '   CDryB            =  1.5900000e+003      [kg/m3]  Dry bed density'; kl=kl+1;
    data{kl,1}=sprintf('   SedDia           =  %0.7e      [m]      sediment diameter (D50)',dk(kf)); kl=kl+1;
    switch IFORM
        case 4
    data{kl,1}=sprintf('   ACal                  = %f                                Calibration coefficient                ',ACal(kf)); kl=kl+1;
    data{kl,1}=sprintf('   PowerB                = %f                                Power b                                ',PowerB(kf)); kl=kl+1;
    data{kl,1}=sprintf('   PowerC                = %f                                Power c                                ',PowerC(kf)); kl=kl+1;
    data{kl,1}=sprintf('   RipFac                = %f                                Ripple factor or efficiency factor     ',RipFac(kf)); kl=kl+1;
    data{kl,1}=sprintf('   ThetaC                = %f                                Critical mobility factor               ',ThetaC(kf)); kl=kl+1;
        case 14
    data{kl,1}=sprintf('   ACal                  = %f                                Calibration coefficient                ',ACal(kf)); kl=kl+1;
    data{kl,1}=sprintf('   ThetaC                = %f                                Critical mobility factor               ',ThetaC(kf)); kl=kl+1;
    data{kl,1}=sprintf('   PowerM                = %f                                Power b                                ',PowerM(kf)); kl=kl+1;
    data{kl,1}=sprintf('   PowerP                = %f                                Power c                                ',PowerP(kf)); kl=kl+1;
    data{kl,1}=sprintf('   PowerQ                = %f                                Ripple factor or efficiency factor     ',PowerQ(kf)); kl=kl+1;
    end
    if node_relations
    data{kl,1}=        '   NodeRelations         = #table.nrd#                       [ - ]    File with Overall Node Relations(relative path to sed)';    kl=kl+1;
    end
end

%% WRITE

% file_name=fullfile(dire_sim,'sed.sed');
writetxt(file_name,data,'check_existing',check_existing)
