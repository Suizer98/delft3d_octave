%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18312 $
%$Date: 2022-08-19 14:16:54 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: fourier_eigenvalues.m 18312 2022-08-19 06:16:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/fourier/fourier_eigenvalues.m $
%
%INPUT:
%   For 2D:
%       -x = independent variable; double, [1,nx];
%       -y = independent variable; double, [1,ny];
%		-ECT_input = input for computing the matrices, struct. See <input_ECT_2D>.
%			ECT_input.flg.sed_trans=1; %sediment transport relation
%			    % 1 = Meyer-Peter, Muller (1948)    
%			    % 2 = Engelund-Hansen (1967)
%			    % 3 = Ashida-Michiue (1972)
%			    % 4 = Wilcock-Crowe (2003)
%			ECT_input.flg.friction_input=1; %friction parameter input
%			    % 1 = non-dimensional friction coefficient (cf)
%			    % 2 = dimensional Chezy friction coefficient (C)
%			    % 3 = non-dimensional Chezy friction coefficient (Cz)
%			ECT_input.flg.hiding=0; %hiding-exposure formulation
%			    % 0 = no hiding-exposure 
%			    % 1 = Egiazaroff (1965)
%			    % 2 = Power law
%			    % 3 = Ashida-Michiue (1972)
%			ECT_input.flg.Dm=1; %mean grain size type
%			    % 1 = geometric
%			    % 2 = arithmetic 
%			ECT_input.flg.mu=0; %ripple factor
%			    % 0 = no
%			    % 1 = constant
%			    % 2 = C/C90 relation
%			ECT_input.flg.anl=10; %type of analysis
%			    % 1 = fully coupled
%			    % 2 = quasi-steady
%			    % 3 = variable active layer thickness
%			    % 4 = Ribberink
%			    % 5 = advection-decay
%			    % 6 = 2D Shallow Water Hirano no secondary flow
%			    % 7 = 2D Shallow Water Hirano with secondary flow
%			    % 8 = 2D Shallow Water fixed bed no secondary flow
%			    % 9 = 2D Shallow Water fixed bed with secondary flow
%			    %10 = 2D Shallow Water Exner no secondary flow
%			    %11 = 2D Shallow Water Exner with secondary flow
%			    %12 = Entrainement-deposition
%			ECT_input.gsd=[0.001,0.004]; %characteristic grain sizes [m]
%			ECT_input.u=1; %velocity in streamwise direction [m/s]
%			ECT_input.h=1; %flow depth [m]
%			ECT_input.Cf=0.007; %friction coefficient (units depend on <friction_input>)
%			ECT_input.La=0.05; %active layer thickness [m]
%			ECT_input.Fa1=[1]; %effective (i.e., nf-1) volume fraction contents in the active layer
%			ECT_input.Fi1=[1]; %effective (i.e., nf-1) volume fraction contents at the interface between the active layer and the substrate
%			ECT_input.nu_mom=0; %diffusion coefficient in the momentum equation [m^2/s]
%			ECT_input.Dh=ECT_input.nu_mom; %secondary flow diffusivity [m^2/s]
%			ECT_input.diff_hir=NaN(size(ECT_input.gsd)); %diffusion hirano
%			ECT_input.sedTrans=[0.05/ECT_input.Cf,2.5,0];
%			    % MPM48    = [a_mpm,b_mpm,theta_c] [-,-,-] ; double [3,1] | double [1,3]; MPM = [8,1.5,0.047], FLvB = [5.7,1.5,0.047] ; Ribberink = [15.85,1.5,0.0307]
%			    % EH67     = [m_eh,n_eh] ; [s^4/m^3,-] ; double [2,1] | double [1,2] ; original = [0.05,5]
%			    % AM72     = [a_am,theta_c] [-,-] ; double [2,1] | double [1,2] ; original = [17,0.05]
%			    % GL       = [r,w,tau_ref]
%			    % Ribb     = [m_r,n_r,l_r] [s^5/m^(2.5),-,-] ; double [2,1] ; original = [2.7e-8,6,1.5]	
%			ECT_input.E_param=[0.0199,1.5]; %parameters of the entrainement-deposition formulation 
%			ECT_input.vp_param=[11.5,0.7]; %parameters of the particle-velocity formulation
%			ECT_input.gsk_param=[1,0,0,0]; %bed-slope-effect parameters 
%			ECT_input.hiding=-0.8; %hiding-exposure parameter
%			ECT_input.kappa=NaN(size(ECT_input.gsd)); %diffusivity of Gammak
%		-pert_anl = type of perturbation analysis: 1 = full system, 2 = no friction, 3 = no friction and no diffusion
%
%OUTPUT:
%       -R     = right-side eigenvectors; double, [ne,ne,nx,ny]
%       -omega = eigenvalues [ne,nx,ny]
%
%TO DO:
%	-Check that everything works in 1D
%

function [R,omega]=fourier_eigenvalues(x,y,ECT_input,pert_anl)

%% CALC

%% frequencies

[dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y);

%% matrices

[ECT_matrices,sed_trans]=call_ECT(ECT_input);
v2struct(ECT_matrices);

%% eigenvalues

ne=numel(diag(ECT_matrices.Ax));
nmx=numel(fx2);
nmy=numel(fy2);

omega=NaN(ne,nmx,nmy);
R=NaN(ne,ne,nmx,nmy);
for kmx=1:nmx
    for kmy=1:nmy
        kx_fou=2*pi*fx2(kmx);
        ky_fou=2*pi*fy2(kmy);
        [~,R(:,:,kmx,kmy),~,~,omega(:,kmx,kmy)]=ECT_M(pert_anl,kx_fou,ky_fou,Dx,Dy,C,Ax,Ay,B,M_pmm);
    end %kmy
    fprintf('computing eigenvalues %4.2f %% \n',kmx/nmx*100);   
end %kmx

end %function