%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: active_layer_mass_update_pmm.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/active_layer_mass_update_pmm.m $
%
%active_layer_mass_update_pmm is the same as active_layer_mass_update with the preconditioning mass matrix approach
%
%\texttt{Mak_new=active_layer_mass_update_pmm(Mak,detaLa,fIk,qbk,bc,pmm,input,fid_log,kt)}
%
%INPUT:
%   -\texttt{Mak} = effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%   -\texttt{detaLa} = variation in elevation of the interface between the active layer and the substarte [m]; [(1)x(nx) double]
%   -\texttt{fIk} = effective volume fraction content of sediment at the interface between the active layer and the substrate [-]; [(nf-1)x(nx) double]
%   -\texttt{qbk} = volume of sediment transported excluding pores per unit time and width and per size fraction [m^2/s]; [(nf)x(nx) double]
%   -\texttt{bc} = boundary conditions structure 
%   -\texttt{input} = input structure
%   -\texttt{fid_log} = identificator of the log file
%   -\texttt{kt} = time step counter [-]; [(1)x(1) double]
%
%OUTPUT:
%   -\texttt{Mak_new} = new effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160330
%   -V. Addition of pre-conditioning mass terms
%
%160413
%   -V. Correction of the terms, invclusion of beta in detaLa_dt
%
%160308
%	-L. Merged two versions 2; cases have been extended

function Mak_new=active_layer_mass_update_pmm(Mak,detaLa,fIk,qbk,bc,pmm,input,fid_log,kt)
%comment out fot improved performance if the version is clear from github
% version='2';
% if kt==1; fprintf(fid_log,'active_layer_mass_update version: %s\n',version); end 

%%
%% RENAME
%%

dx=input.grd.dx;
dt=input.mdv.dt;    
MorFac=input.mor.MorFac;
nef=input.mdv.nef;
cb=1-input.mor.porosity;
K=input.mdv.nx; %number of cells
nx=K;
UpwFac=input.mdv.UpwFac;

alpha=pmm(1,:);
beta=pmm(2,:);

%%
%% BOUNDARY CONDITION
%%

switch input.bcm.type
%%upstream bed load
    case {1,'set1'}
        qbk0=bc.qbk0(kt,:)'; %[1xnf double]
    case 2
        qbk0=qbk(:,end);  %[1xnf double]        
end

%%
%% ACTIVE LAYER EQUATION
%%

detaLa_dt=detaLa/dt; %%d(\eta-La)/dt [1xnx double]

Mak_new=NaN(nef,nx);

Mak_new(:,1    )=Mak(:,1    )-       dt./(alpha(1,1    ).*beta(1,1    ))        *(       beta(1,1    )       .*fIk(:,1    ).*       detaLa_dt(1,1    )       +MorFac/cb*(       (qbk(1:nef,1    )-qbk0(1:nef,1))/(dx/2)));
Mak_new(:,2:K-1)=Mak(:,2:K-1)-repmat(dt./(alpha(1,2:K-1).*beta(1,2:K-1)),nef,1).*(repmat(beta(1,2:K-1),nef,1).*fIk(:,2:K-1).*repmat(detaLa_dt(1,2:K-1),nef,1)+MorFac/cb*(UpwFac*(qbk(1:nef,2:K-1)-qbk (1:nef,1:K-2))/dx+(1-UpwFac)*(qbk(1:nef,3:K)-qbk(1:nef,2:K-1))/dx));
Mak_new(:,K    )=Mak(:,K    )-       dt./(alpha(1,K    ).*beta(1,K    ))        *(       beta(1,K    )       .*fIk(:,K    ).*       detaLa_dt(1,K    )       +MorFac/cb*(       (qbk(1:nef,K    )-qbk (1:nef,K-1  ))/dx));


