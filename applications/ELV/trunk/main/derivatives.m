%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16757 $
%$Date: 2020-11-02 14:34:08 +0800 (Mon, 02 Nov 2020) $
%$Author: chavarri $
%$Id: derivatives.m 16757 2020-11-02 06:34:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/derivatives.m $
%
%function_name does this and that
%
%[dqb_dq,dqbk_dq,dqb_dMal,dqbk_dMal]=derivatives(u,h,Cf,La,qbk,Mak,input,fid_log,kt)
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

function [dqb_dq,dqbk_dq,dqb_dMal,dqbk_dMal,dqb_dDm,dqbk_dDm]=derivatives(u,h,Cf,La,qbk,Mak,input,fid_log,kt)
%comment out fot improved performance if the version is clear from github
% version='1';
% if kt==1; fprintf(fid_log,'derivatives version: %s\n',version); end 

%% 
%% RENAME
%% 

dd=input.mdv.dd;
nf=input.mdv.nf;
nef=input.mdv.nef;
nx=input.mdv.nx;
dk=input.sed.dk;

%we compute the derivatives for the active layer model (not for entrainment-deposition model). Thus, in the computation of the derivatives we do not take into account the diffusive behavior or the particle activity.
input.aux.flg.particle_activity=0; 

%% 
%% SEDIMENT TRANSPORT AT var+dvar
%%

%% dq

[qbk_aux,~]=sediment_transport(input.aux.flg,input.aux.cnt,h',(u.*h)'+dd,Cf,La',Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,fid_log,kt);
qbk_qdq=qbk_aux'; %qbk(q+dq) [nf x nx]
qb_qdq=sum(qbk_qdq,1); %qb(q+dq) [1 x nx]

%% dMal

if nf>1
    
qb_MaldMal=NaN(1,nx,nef);
qbk_MaldMal=NaN(nf,nx,nef);
for kl=1:nef
    Mal_dMal=Mak;
    Mal_dMal(kl,:)=Mal_dMal(kl,:)+dd;

    [qbk_aux,~]=sediment_transport(input.aux.flg,input.aux.cnt,h',(u.*h)',Cf,La',Mal_dMal',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,fid_log,kt);
    qbk_MaldMal(:,:,kl)=qbk_aux'; %qbk(Mal+dMal) [nf x nx]

    qb_MaldMal(1,:,kl)=sum(qbk_MaldMal(:,:,kl),1); %qb(Mal+dMal) [1 x nx]
end

end

%% 
%% DERIVATIVE
%%

qb=sum(qbk,1);

%d(qb)/d(q) ; %double [1,nx]
dqb_dq=(qb_qdq-qb)/dd; 

%d(qbk)/d(q) ; double [nf,nx]
dqbk_dq=(qbk_qdq-qbk)/dd;

if nf>1
    
    %d(qb)/d(Mal) ; double [1,nx,nef]
    qb_Mal=repmat(qb,1,1,nef); %qb(Mal) 
    dqb_dMal=(qb_MaldMal-qb_Mal)/dd;

    %d(qbk)/d(Mal) ; double [nf,nx,nef]
    qbk_Mal=repmat(qbk,1,1,nef); %qbk(Mal)
    dqbk_dMal=(qbk_MaldMal-qbk_Mal)/dd;

    %d(qbk)/d(Dm) ; double [nf,nx,1]
    aux_invdkdiff=repmat(reshape(1./(dk(1:end-1)-dk(end)),1,1,nef),nf,nx,1); %double [nf,nx,nef]. When taking (:,kx,:) you have [1/(d1-d3), 1/(d1-d3), 1/(d1-d3); 1/(d2-d3), 1/(d2-d3), 1/(d2-d3)]
    dqbk_dDm=La.*sum(aux_invdkdiff.*dqbk_dMal,3); % double [nf,nx,1]. When taking (:,kx,1) you have [dqb1_Dm; dqb2_Dm; dqb3_Dm] 
    dqb_dDm=sum(dqbk_dDm,1); %double [1,nx,1]

else
    dqb_dMal=NaN(1,nx);
    dqbk_dMal=NaN(1,nx);
    dqb_dDm=NaN(1,nx);
    dqbk_dDm=NaN(1,nx);
end

