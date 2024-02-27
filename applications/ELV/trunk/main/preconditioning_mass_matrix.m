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
%$Id: preconditioning_mass_matrix.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/preconditioning_mass_matrix.m $
%
%preconditioning_mass_matrix does this and that
%
%pmm=preconditioning_mass_matrix(ell_idx,out_en,u,input,fid_log,kt)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%160330
%   -V. Created for the first time.
%
%160502
%   -V. Implementation of 3 fractions
%
%160504
%   -V. cases 5 and 7 for 3 fractions
%
%181107
%   -V. added eigenvalues at output for CFL based time step

function [pmm,out_en]=preconditioning_mass_matrix(ell_idx,out_en,u,input,fid_log,~)
%comment out fot improved performance if the version is clear from github
% version='3';
% if kt==1; fprintf(fid_log,'preconditioning_mass_matrix version: %s\n',version); end 

%% 
%% RENAME
%% 

nx=input.mdv.nx; 
nf=input.mdv.nf;

lb=out_en.lb;
ls=out_en.ls;
gamma=out_en.gamma;
mu=out_en.mu;
if nf==3
    A_3qs=out_en.A;
end

pmm_alpha_eps=input.mor.pmm_alpha_eps;

%trick: if gsdupdate==9, we may have more than two size fractions, but the calculations are the same as if we have two size fractions.
if input.mor.gsdupdate==9
    nf=2;
end

%% 
%% UPDATE
%% 

%preallocate, no correction
%ones rather than NaN for alread having the case of no change. 
alpha=ones(1,nx);
beta=ones(1,nx);

switch nf
    %% 2 FRACTIONS
    case 2 

        %dimensionless
        A_2qs=NaN(2,nx,2); %at (:,:,kx) we have the 2x2 matrix corresponding to node kx

        A_2qs(1,:,1)=lb;
        A_2qs(2,:,1)=lb.*gamma;
        A_2qs(2,:,2)=ls;
        A_2qs(1,:,2)=ls./mu;
        
        %dimensional
        A_2qs=repmat(u,2,1,2).*A_2qs;
        
        a11a22=A_2qs(1,:,1).*A_2qs(2,:,2); %[1,nx]
        a12a21=A_2qs(1,:,2).*A_2qs(2,:,1); %[1,nx]
        a11_2 =A_2qs(1,:,1).^2; %[1,nx]
        
        %% alpha (dMak/dt)
        switch input.mor.gsdupdate
            case {4,6}
                alpha_c=1./a11_2.*(-2*a12a21+a11a22-2*sqrt(a12a21.*(a12a21-a11a22))); %-
                alpha_c=(1-pmm_alpha_eps).*alpha_c; %avoid equal eigenvalues
            case {5,7,9}
                alpha_c=1./a11_2.*(-2*a12a21+a11a22+2*sqrt(a12a21.*(a12a21-a11a22))); %+
                alpha_c=(1+pmm_alpha_eps).*alpha_c; %avoid equal eigenvalues
            case 8
                alpha_c=pmm_alpha_eps*ones(1,nx); %trick in case you want to impose alpha
        end
        
        alpha(ell_idx)=alpha_c(ell_idx); %substitute only the elliptic ones
        
        %% beta (all time derivatives)
        switch input.mor.gsdupdate
            case {4,5}        
                beta=(A_2qs(1,:,1)+1./alpha.*A_2qs(2,:,2))./(A_2qs(1,:,1)+A_2qs(2,:,2));
            case {6,7,8,9}
%                 beta=ones(1,nx); %it is already preallocated
        end
                
        
        %% debug
%         kx=2;
%         M=[beta(1,kx),0;0,beta(1,kx)*alpha(1,kx)]; %pmm
%         eigen_r=eig(reshape(A_2qs(:,kx,:),2,2)); %normal eigenvalues
%         eigen_m=eig(reshape(A_2qs(:,kx,:),2,2)*inv(M)); %#ok [we are not solving a system of equations] eigenvalues after correction (must be real)
        
        %max and min values of alpha and beta
%         if kt==1
%         if any(alpha~=1) || any(beta~=1)
%         max_alpha=max(alpha);
%         min_alpha=min(alpha);
%         max_beta=max(beta);
%         min_beta=min(beta);
%         
%         fprintf(fid_log,'max alpha=%6.3f; max beta=%6.3f; min alpha=%6.3f; min beta=%6.3f\n',max_alpha,max_beta,min_alpha,min_beta);
%         end
        
    %% 3 FRACTIONS    
    case 3
        %the loop is necessary to use 'roots' :(
        xvec_id=1:1:nx;
        for kx=xvec_id(ell_idx)
            %scalars
            a11=A_3qs(1,kx,1); a12=A_3qs(1,kx,2); a13=A_3qs(1,kx,3);
            a21=A_3qs(2,kx,1); a22=A_3qs(2,kx,2); a23=A_3qs(2,kx,3);
            a31=A_3qs(3,kx,1); a32=A_3qs(3,kx,2); a33=A_3qs(3,kx,3);

            %coefficients of the polynomial representing the discriminant of the
            %characteristic polynomial as a function of alpha, being alpha the
            %preconditioning factor of all active layer equations
            pc=[ a11^2*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^2 - 4*a11^3*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31), 18*a11*(a11*a22 - a12*a21 + a11*a33 - a13*a31)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) - 4*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^3 + 2*a11*(a22 + a33)*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^2 + 2*a11^2*(a22*a33 - a23*a32)*(a11*a22 - a12*a21 + a11*a33 - a13*a31) - 12*a11^2*(a22 + a33)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31), a11^2*(a22*a33 - a23*a32)^2 + (a22 + a33)^2*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^2 - 12*(a22*a33 - a23*a32)*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^2 - 27*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31)^2 - 12*a11*(a22 + a33)^2*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) + 18*a11*(a22*a33 - a23*a32)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) + 18*(a22 + a33)*(a11*a22 - a12*a21 + a11*a33 - a13*a31)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) + 4*a11*(a22 + a33)*(a22*a33 - a23*a32)*(a11*a22 - a12*a21 + a11*a33 - a13*a31), 2*(a22 + a33)^2*(a22*a33 - a23*a32)*(a11*a22 - a12*a21 + a11*a33 - a13*a31) - 4*(a22 + a33)^3*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) - 12*(a22*a33 - a23*a32)^2*(a11*a22 - a12*a21 + a11*a33 - a13*a31) + 18*(a22 + a33)*(a22*a33 - a23*a32)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) + 2*a11*(a22 + a33)*(a22*a33 - a23*a32)^2, (a22 + a33)^2*(a22*a33 - a23*a32)^2 - 4*(a22*a33 - a23*a32)^3];
            %pt=[ alpha1^6, alpha1^5, alpha1^4, alpha1^3, alpha1^2]; %terms of the coefficients in 'pc'

            %obtain the values of alpha that make the discriminant 0
            pr=roots([pc,0,0]); %this may be very expensive
            %% alpha
            switch input.mor.gsdupdate
                case {4,6}
                    %get the maximum value of possible alphas that is real, different than 0, and smaller than 1
                    alpha(kx)=max(pr(imag(pr)==0 & real(pr)~=0 & real(pr)<1)); 

                    %safety coefficient
                    alpha(kx)=(1-pmm_alpha_eps)*alpha(kx); 
                case {5,7}
                    %get the maximum value of possible alphas that is real, different than 0, and larger than 1
                    alpha(kx)=max(pr(imag(pr)==0 & real(pr)~=0 & real(pr)>1)); 

                    %safety coefficient
                    alpha(kx)=(1+pmm_alpha_eps)*alpha(kx); 
                otherwise
                    error('Not implemented')
            end %input.mor.gsdupdate

            %% beta
            switch input.mor.gsdupdate
                case {4,5}
                    beta(kx)=beta_pmm(reshape(A_3qs(:,kx,:),3,3),alpha(kx),fid_log);
                case {6,7}
                    beta(kx)=1;
                otherwise 
                    error('Not implemented')
            end %input.mor.gsdupdate
            
            %% debug

%             eigen_r=eig(reshape(A_3qs(:,kx,:),3,3)); %eigenvalues before correction (must be complex)
%             %only alpha
%             M=[beta(kx),0,0;0,beta(kx)*alpha(kx),0;0,0,beta(kx)*alpha(kx)];
%             eigen_m=eig(reshape(A_3qs(:,kx,:),3,3)*inv(M)); %#ok [we are not solving a system of equations] eigenvalues after correction (must be real)   
                    

        end %for kx=xvec_id(ell_idx)
%         %print (only for debbuging)
%         max_alpha=max(alpha);
%         min_alpha=min(alpha);
%         max_beta=max(beta);
%         min_beta=min(beta);
% 
%         fprintf(fid_log,'max alpha=%6.3f; max beta=%6.3f; min alpha=%6.3f; min beta=%6.3f\n',max_alpha,max_beta,min_alpha,min_beta);
    otherwise
        error('Only for 2 or 3 fractions :(')
        %minimazation as it is implemented for beta
end

%% CORRECTED EIGENVALUES

if input.mdv.dt_type==2 %if we need the eigenvalues for CFL time step
    switch nf
        case 2
            %the discriminan is 0 when regularizing the system with alpha_c, but it is not when an epsilon is added
            %moreover, computing it in this form we guarantee that when non-regularized, the eigenvalues are also correct.
            disc=lb.^2.*alpha.^2+2*lb.*ls.*(2.*gamma./mu-1).*alpha+ls.^2;
            eigen_pmm(1,:)=1./(2.*beta).*(lb+ls./alpha+sqrt(disc)./alpha);
            eigen_pmm(2,:)=1./(2.*beta).*(lb+ls./alpha-sqrt(disc)./alpha);
        case 3
            for kx=1:nx
                M=[beta(kx),0,0;0,beta(kx)*alpha(kx),0;0,0,beta(kx)*alpha(kx)];
                eigen_pmm(:,kx)=eig(reshape(A_3qs(:,kx,:),3,3)*inv(M))'; %#ok [we are not solving a system of equations] eigenvalues after correction (must be real)
            end
    end
end

%%
%% OUTPUT
%%

pmm(1,:)=alpha;
pmm(2,:)=beta;

if input.mdv.dt_type==2
    out_en.eigen_pmm=eigen_pmm;
else
    out_en.eigen_pmm=[]; %avoid dissimilar structures
end

