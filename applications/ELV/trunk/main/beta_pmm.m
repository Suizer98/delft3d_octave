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
%$Id: beta_pmm.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/beta_pmm.m $
%
%beta_pmm computes the value of beta such that the eigenvalues of the modified matrix A have the same value of than in the original system matrix.
%
%beta_o=beta_pmm(A,alpha_i,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%160502
%   -V. Created for the first time.

function beta_o=beta_pmm(A,alpha_i,fid_log)
%comment out fot improved performance if the version is clear from github
% version='1';
% if kt==1; fprintf(fid_log,'beta_pmm version: %s\n',version); end 

%% 
%% RENAME
%% 

%% 
%% COMPUTE
%% 

%ATTENTION! for 3 size fractions there is 2 complex conjugate eigenvalues.
%It does not matter which one you take. For more size fractions this needs
%to be rethought. 
eigen_r=eig(A); %eigenvalues before correction (must be complex)
eigen_r_idx=imag(eigen_r)~=0;
idx=find(eigen_r_idx,1);
objective=real(eigen_r(idx)); %get the real part of the imaginary eigenvalues

%variable = X:
%   beta=X(1)

X0=1;

F=@(X)aux_beta_pmm(X,objective,A,alpha_i,idx);

% options=optimoptions('fsolve','TolFun',1e-12,'TolX',1e-12,'display','none','MaxFunEvals',1000);
options=optimoptions('fsolve','TolFun',1e-8,'TolX',1e-8,'display','none','MaxFunEvals',100);
[X_s,~,exitflag,output]=fsolve(F,X0,options); 

beta_o=X_s(1);

%output
% if exitflag>0
%     fprintf(fid_log,'beta = %6.4f; first order optimality = %6.4e\n',beta_o,output.firstorderopt);
% else
%     fprintf(fid_log,'ATTENTION!!! Normal flow initial condition not found. First order optimality = %6.4e\n',output.firstorderopt);
% end



end %beta_pmm

function F=aux_beta_pmm(X,objective,A,alpha_i,idx)
    beta_aux=X;
    M=beta_aux.*[1,0,0;0,alpha_i,0;0,0,alpha_i];
    eigen_m=eig(A*inv(M)); %#ok [we are not solving a system of equations] eigenvalues after correction (must be real)   
    eigen_m_R1=eigen_m(idx); %ATT!!! ad-hoc, we use the eigenvalue in the same position as the target one, but that has no mathematical basis.
    F=eigen_m_R1-objective;
end