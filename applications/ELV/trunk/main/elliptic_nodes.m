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
%$Id: elliptic_nodes.m 16757 2020-11-02 06:34:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/elliptic_nodes.m $
%
%elliptic_nodes does this and that
%
%[ell_idx,out]=elliptic_nodes(u,h,Cf,La,qbk,Mak,fIk,input,fid_log,kt)
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
%160415
%   -V. Bug solved. mu_kk was not correctly written for 3 fractions
%
%160429
%   -V. 3 fractions
%
%181107
%   -V. eigen as output

function [ell_idx,out]=elliptic_nodes(u,h,Cf,La,qbk,Mak,fIk,input,fid_log,kt)

%%
%% RENAME
%%

g=input.mdv.g;
nf=input.mdv.nf;
nef=input.mdv.nef;
nx=input.mdv.nx;
dk=input.sed.dk;

%% 
%% DERIVATIVES
%% 

[dqb_dq,dqbk_dq,dqb_dMal,dqbk_dMal,dqb_dDm,dqbk_dDm]=derivatives(u,h,Cf,La,qbk,Mak,input,fid_log,kt);

%dqb_dq    [1   , nx , 1     double]
%dqbk_dq   [nf  , nx , 1     double]
%dqb_dMal  [1   , nx , nef   double]
%dqbk_dMal [nf  , nx , nef   double]
%dqb_dDm   [1   , nx , 1     double]
%dqbk_dDm  [nf  , nx , 1     double]

%%
%% ELLIPTIC NODES
%%

Fr=u./sqrt(g*h);
psi=dqb_dq; %double [1,nx]
lb=psi./(1-Fr.^2); %double [1,nx]

switch input.mor.ellcheck
    %% full model
    case 1 

        %dimensionless
        chi=1./repmat(u,1,1,nef).*dqb_dMal; %double [1,nx,nef]
        c=dqbk_dq(1:nef,:)./repmat(psi,nef,1); %double [nef,nx]
        gamma=c-fIk; %double [nef,nx]
        d=dqbk_dMal(1:nef,:,:)./repmat(u,nef,1,nef)./repmat(chi,nef,1,1); %double [nef,nx,nef] d_{12}=d(2,kx,1)
        mu=d-repmat(fIk,1,1,nef); %double [nef,nx,nef] mu_{12}=mu(2,kx,1)
        mu_kk=sum(repmat(reshape(eye(nef,nef),nef,1,nef),1,nx,1).*mu,3); %double [nef,nx,1]
        ls=reshape(chi,nx,nef)'.*mu_kk; %double [nef,nx]

        %dimensional
        uFr2=u./(1-Fr.^2); %double [1,nx]

        %if there is a tracer fraction with the same grain size as the largest fraction, dqb_dMal will have zeros and ls=NaN
        %easy to avoid by using a different expression for ls
        for kf=1:nef
           if input.sed.dk(kf)==input.sed.dk(end)
               ls(kf,:)=dqbk_dMal(kf,:)./u; %-chi*fIk (which is equal to 0)
           end
        end

        if nf==1 %specific for 1 fraction
            eigen=lb;
            ell_idx=false(1,nx);

        elseif nf==2 %specific for 2 fractions
                
            ls1=ls;
            disc=(lb-ls1).^2+4*gamma./mu.*lb.*ls1; %dimensionless discriminant
            ell_idx=disc<0; %elliptic indices

            %eigen is not necessary, it is only to check, comment out if unnecessary
            if input.mdv.dt_type==2 
            eigen=NaN(2,nx); %dimensionless eigenvalues
            eigen(1,:)=1/2*(lb+ls1-sqrt(disc)); %dimensioneless eigenvalue 1
            eigen(2,:)=1/2*(lb+ls1+sqrt(disc)); %dimensioneless eigenvalue 2
            end

        %this option for the specific case with three size fractions does not require writting the matrix but it is not always applicable as mu can be 0

        % elseif nf==3
        %     %dimensionless
        %     A_3qs=NaN(3,nx,3); %at (:,kx,:) we have the 3x3 matrix corresponding to node kx
        % 
        %     A_3qs(1,:,1)=lb;
        %     A_3qs(2,:,1)=lb.*gamma(1,:);
        %     A_3qs(3,:,1)=lb.*gamma(2,:);
        %     
        %     A_3qs(1,:,2)=ls(1,:)./mu(1,:,1);
        %     A_3qs(2,:,2)=ls(1,:);
        %     A_3qs(3,:,2)=ls(1,:).*mu(2,:,1)./mu(1,:,1);
        %     
        %     A_3qs(1,:,3)=ls(2,:)./mu(2,:,2);
        %     A_3qs(2,:,3)=ls(2,:).*mu(1,:,2)./mu(2,:,2);
        %     A_3qs(3,:,3)=ls(2,:);
        %     
        %     %this renaming can be avoided, but it is handy to chech the
        %     %implementation
        %     a11=A_3qs(1,:,1); a12=A_3qs(1,:,2); a13=A_3qs(1,:,3);
        %     a21=A_3qs(2,:,1); a22=A_3qs(2,:,2); a23=A_3qs(2,:,3);
        %     a31=A_3qs(3,:,1); a32=A_3qs(3,:,2); a33=A_3qs(3,:,3);
        %     
        %     a=1;
        %     b=- a11 - a22 - a33;
        %     c=a11.*a22 - a12.*a21 + a11.*a33 - a13.*a31 + a22.*a33 - a23.*a32;
        %     d=a11.*a23.*a32 - a11.*a22.*a33 + a12.*a21.*a33 - a12.*a23.*a31 - a13.*a21.*a32 + a13.*a22.*a31;    
        %     
        %     disc=18*a.*b.*c.*d-4.*b.^3.*d+b.^2.*c.^2-4.*a.*c.^3-27.*a.^2.*d.^2;
        %     ell_idx=disc<0; %elliptic indices
        %     
        %     %compute eigenvalues
        %     if input.mdv.dt_type==2 %dimensionless eigenvalues necessary to compute time step
        %     eigen=NaN(3,nx);
        %     for kx=1:nx
        %         eigen(:,kx)=roots([a,b(kx),c(kx),d(kx)]);
        %     end
        %     end

        else

            %dimensional
            A_qs=NaN(nef+1,nx,nef+1); %at (:,kx,:) we have the (nef,nef) matrix corresponding to node kx

            A_qs(1    ,:,1    )=uFr2.*dqb_dq;
            A_qs(2:end,:,1    )=uFr2.*(dqbk_dq(1:nef,:)-fIk.*dqb_dq);
            A_qs(1    ,:,2:end)=dqb_dMal;
            A_qs(2:end,:,2:end)=dqbk_dMal(1:nef,:,:)-fIk.*dqb_dMal;

            eigen=NaN(nef+1,nx);
            for kx=1:nx
               eigen(:,kx)=eig(reshape(A_qs(:,kx,:),nef+1,nef+1))./u(kx); %dimensionless
            end
            ell_idx=sum(abs(imag(eigen)),1)~=0;

        end

    %% approximate model
    case 2
        
        %dimensionless 
        fIm=sum(dk.*[fIk;1-sum(fIk,1)])./La; %[1,nx,1]

        chi=1./u.*dqb_dDm; %double [1,nx,1]
        c=sum(dk.*dqbk_dq,1)./psi./La; %double [1,nx,1]
        gamma=c-fIm; %double [1,nx,1]
        d=1./u./chi./La.*sum(dk.*dqbk_dDm,1); %double [1,nx,1] 
        mu=d-fIm; %double [1,nx,1]
        ls=chi.*mu; %double [1,nx,1]

        ls1=ls;
        disc=(lb-ls1).^2+4*gamma./mu.*lb.*ls1; %dimensionless discriminant
        ell_idx=disc<0; %elliptic indices

        %eigen is not necessary, it is only to check, comment out if unnecessary
        if input.mdv.dt_type==2 
        eigen=NaN(2,nx); %dimensionless eigenvalues
        eigen(1,:)=1/2*(lb+ls1-sqrt(disc)); %dimensioneless eigenvalue 1
        eigen(2,:)=1/2*(lb+ls1+sqrt(disc)); %dimensioneless eigenvalue 2
        end

end %input.mor.ellcheck

%%
%% OUTPUT
%%

%dimensionless
out.ls=ls;
out.lb=lb;
out.gamma=gamma;
out.mu=mu;
if input.mdv.dt_type==2
out.eigen=eigen;
else
out.eigen=[];
end

%in the 2 fractions case there is no need of A for finding the elliptic
%nodes but it is necessary in the 3 fractions case.
out.A=[]; %give an output to avoid dissimilar structures error
if nf>2 && input.mor.ellcheck~=2
%     out.A=A_3qs;
    out.A=A_qs;
end
