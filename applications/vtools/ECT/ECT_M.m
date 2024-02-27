%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18313 $
%$Date: 2022-08-19 14:17:43 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: ECT_M.m 18313 2022-08-19 06:17:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/ECT_M.m $
%
%
%Compute system matrix, eigenvectors, and eigenvalues
%
%INPUT:
%	-pert_anl     = type of perturbation analysis: 1 = full system, 2 = no friction, 3 = no friction and no diffusion
%	-kwx          = wavenumber in x-direction [1/m]
%	-kwy          = wavenumber in y-direction [1/m]
%	-Dx           = diffusion matrix in x-direction
%	-Dy           = diffusion matrix in y-direction
%	-Ax           = flux matrix in x-direction
%	-Ay           = flux matrix in y-direction
%	-B            = friction terms matrix
%	-M_pmm        = preconditioning mass matrix
%                 
%OUTPUT:          
%	-M            = system matrix
%	-eigenvector  = right eigenvectors matrix
%	-eigenvalue   = eigenvalues matrix
%	-eigenvectorL = left eigenvectors
%	-eigenvalue_v = eigenvalues vector

function [M,eigenvector,eigenvalue,eigenvectorL,eigenvalue_v]=ECT_M(pert_anl,kwx,kwy,Dx,Dy,C,Ax,Ay,B,M_pmm)

switch pert_anl
        case 1 %full
            M=Dx*kwx^2*1i+Dy*kwy^2*1i+C*kwx*kwy*1i+Ax*kwx+Ay*kwy-B*1i; 
        case 2 %no friction
            M=Dx*kwx^2*1i+Dy*kwy^2*1i+C*kwx*kwy*1i+Ax*kwx+Ay*kwy; 
        case 3 %no friction no diffusion
            M=Ax*kwx+Ay*kwy; 
        case 4 %full PMM
            M=inv(M_pmm)*Dx*kwx^2*1i+inv(M_pmm)*Dy*kwy^2*1i+inv(M_pmm)*C*kwx*kwy*1i+inv(M_pmm)*Ax*kwx+inv(M_pmm)*Ay*kwy-inv(M_pmm)*B*1i; 
%             M=Dx_1*kwx^2*1i+Dy_1*kwy^2*1i+C_1*kwx*kwy*1i+inv(M_pmm)*Ax_1*kwx+inv(M_pmm)*Ay_1*kwy-inv(M_pmm)*B_1*1i; 
        case 5 %no friction PMM
            M=inv(M_pmm)*Dx*kwx^2*1i+inv(M_pmm)*Dy*kwy^2*1i+inv(M_pmm)*C*kwx*kwy*1i+inv(M_pmm)*Ax*kwx+inv(M_pmm)*Ay*kwy; 
        case 6 %no friction no diffusion PMM
            M=inv(M_pmm)*Ax*kwx+inv(M_pmm)*Ay*kwy; 
        otherwise
            error('implement')
end
    
[eigenvector,eigenvalue,eigenvectorL]=eig(M);
eigenvalue_v=diag(eigenvalue);

end %function