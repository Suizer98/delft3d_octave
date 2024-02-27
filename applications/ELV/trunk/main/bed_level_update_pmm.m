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
%$Id: bed_level_update_pmm.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_level_update_pmm.m $
%
%bed_level_update_pmm updates the bed elevationconsidering PMM
%
%etab_new=bed_level_update_pmm(etab,qbk,bc,pmm,input,fid_log,kt)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160330
%   -V. Addition of pre-conditioning mass terms
%
%160803
%	-Note by L that the cycled boundary conditions are only implemented for mixed sediment yet. This may perhaps be resolved by adjusting case 1??

function etab_new=bed_level_update_pmm(etab,qbk,bc,pmm,input,fid_log,kt)
%comment out fot improved performance if the version is clear from github
% version='1';
% if kt==1; fprintf(fid_log,'bed_level_update_pmm version: %s\n',version); end 

%%
%% RENAME
%%

dx=input.grd.dx;
dt=input.mdv.dt;    
MorFac=input.mor.MorFac;
cb=1-input.mor.porosity;
K=input.mdv.nx; %number of cells
UpwFac=input.mdv.UpwFac;
beta=pmm(2,:); 

%%
%% BOUNDARY CONDITION
%%

switch input.bcm.type
%%upstream bed load
    case {1,'set1'}
        qbk0=bc.qbk0(kt,:); %[1xnf double]
        qb0=sum(qbk0,2); %[1x1 double]
    case 2
        qbk0=qbk(:,end);
        qb0=sum(qbk0,1); %[1x1 double]
end

%%
%% EXNER
%%

switch input.mor.bedupdate
    case 0
        etab_new=etab;
        
    case 1
        %total load
        qb=sum(qbk,1); %[1xnf double]
        
%         etab_new=NaN(1,nx);
        etab_new(1,1    ) = etab(1,1    ) - MorFac * dt /cb /beta(1,1    ) *           ((qb(1    )-qb0)/(dx/2) );
        etab_new(1,2:K-1) = etab(1,2:K-1) - MorFac * dt./cb./beta(1,2:K-1).* (UpwFac * ((qb(2:K-1)-qb(1:K-2))./(dx)) + (1-UpwFac) * ((qb(3:K)-qb(2:K-1))./(dx)) );
        etab_new(1,K    ) = etab(1,K    ) - MorFac * dt /cb /beta(1,K    ) *           ((qb(K    )-qb(K-1))/(dx)  );  

%         if any(isnan(etab_new))
%             error('etab_new')
%         end
        
end
end
