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
%$Id: struiksma_reduction.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/struiksma_reduction.m $
%
%limit sediment transport according to Struiksma (1999)
%
%\texttt{}
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%200707
%   -V. Created for the first time.
%

function [qbk,psi]=struiksma_reduction(qbk,La,Ls,Mak,msk,input,fid_log)

%% RENAME

Struiksma=input.mor.Struiksma;
nx=input.mdv.nx; %number of cells
nef=input.mdv.nef;

%escape
if Struiksma==0
    psi=ones(1,nx);
    return
end

L_alluvial=input.mor.La;

nsl=input.mdv.nsl;

tol=1e-6;
tol_th=La*0.05;

%% CALC

%volume fractions at the substrate [-]; [nef,nx,nsl] double
fsk=msk./Ls;
fsk(isnan(fsk))=0;
fsk_all=NaN(nef+1,nx,nsl);
fsk_all(1:end-1,:,:)=fsk;
fsk_all(end,:,:)=1-sum(fsk_all(1:end-1,:,:),1);

imm_idx_m=find_immobile_fractions(qbk,La,Mak,input,fid_log);
imm_idx_m_subs=repmat(imm_idx_m,1,1,nsl);
fsk_all_imm=zeros(nef+1,nx,nsl);
fsk_all_imm(imm_idx_m_subs)=fsk_all(imm_idx_m_subs);
subs_imm_m=sum(fsk_all_imm,1)>1-tol; 
    
for kx=1:nx
    for ksl=1:nsl
        %if true, all sediment in that substrate layer is immobile and the
        %thickness of this layer and the ones below is set to 0. 
%         subs_imm=sum(fsk(imm_idx_m(:,kx),kx,ksl))==1; 
%         subs_imm=sum(fsk_all(imm_idx_m(:,kx),kx,ksl))>1-tol;
        if subs_imm_m(1,kx,ksl)
            Ls(1,kx,ksl:end)=0; 
        end
    end %ksl
end %kx

%a tolerance is necessary. Otherwise, Ltot is always larger than the active
%layer thickness
Ltot=La+sum(Ls,3)-tol_th; %total thickness of movable sediment [1,nx]

Lfrac=Ltot./L_alluvial;
Lfrac(Lfrac>1)=1;
psi=Lfrac.*(2-Lfrac);
qbk=qbk.*psi;

end %function













