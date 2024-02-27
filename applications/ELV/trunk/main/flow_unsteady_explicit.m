%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16602 $
%$Date: 2020-09-25 18:28:13 +0800 (Fri, 25 Sep 2020) $
%$Author: chavarri $
%$Id: flow_unsteady_explicit.m 16602 2020-09-25 10:28:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/flow_unsteady_explicit.m $
%
%flow_update updates the flow depth and the mean flow velocity.
%
%[u_new,h_new]=flow_update(u,h,etab,Cf,bc,input,fid_log,kt)
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
%160418
%   -L. bwc bug with qw=q_old
%

%160428
%   -L. Update hbc and Qbc cases
%       - Update case numbers
%       - Modulo construction for repeated time steps
%

%160513
%   -L. Implicit Preismann scheme
%
%
%160623
%   -V. cyclic boundary conditions
%
%160702
%   -V. tiny performance improvements
%
%160803
%	-L. Merged Vv4 Lv4
%
%160818
%   -L. Adjusted for variable flow.
%
%161130
%   -L. Geklooi met breedte_variaties
%
%170724
%   -Pepijn Addition of branches
%
%200925
%   -V. For some strange reason BC were not passed!

function [u_new,h_new]=flow_unsteady_explicit(u,h,etab,Cf,Hdown,qwup,input,fid_log,kt)

%% RENAME

g=input.mdv.g;
nx=input.mdv.nx;
dt=input.mdv.dt;
dx=input.grd.dx;

etab=etab'; %why do you make my life soooo difficult Liselot!!! :D

%% CALC

H_old=h'; %water depth [m]; [nxx1 double]
q_old=(u.*h)'; %specific water discharge [m^2/s]; [nxx1 double]

%----------------- GHOST CELLS AROUND BOUNDARIES -----------------%

% Store old data in Kx2 array
Q = [H_old,q_old]; %size K

% Adjust BCs
% nQ(1,2) = qwup;
Q(1,1) = qwup;
Q(end,1)= Hdown;

% Q has 4 ghost cells; two on each end.       
% First order of extrapolation at both ends
Qgu1 = Q(1,:) - (Q(2,:)-Q(1,:));
Qgu2 = Qgu1 - (Q(1,:)-Qgu1);
Qgd1 = Q(end,:) + (Q(end,:)-Q(end-1,:));
Qgd2 = Qgd1 + (Qgd1-Q(end,:));
Q = [Qgu2; Qgu1; Q; Qgd1; Qgd2];

% -------------- COMPUTATION AQ+ and AQ- ------------------------%
% The system will be solved by summing the contribution of the
% individual wave is in the system. Therefore the eigenvalues and
% left and right eigenvectors are computed. From now on, 1 refers
% to the positive eigenvalue, and 2 to the negative one.

l11= Q(:,2)./Q(:,1) + sqrt(g*Q(:,1));
l22= Q(:,2)./Q(:,1) - sqrt(g*Q(:,1));

temp = 2*sqrt(g*Q(:,1));
left_eig1 = [-l11.*l22./temp, l11./temp];
left_eig2 = [l11.*l22./temp, -l22./temp];       
right_eig1(:,:) = [1./l11(:,1)'; ones(1,nx+4)];
right_eig2(:,:) = [1./l22(:,1)'; ones(1,nx+4)];

Dq = Q(2:end,:)-Q(1:end-1,:); %difference between adjacent cells

% Computation alpha; alpha1 is for the first eigenvalue (+), and
% alpha2 for the second eigenvalue (-). Alpha is defined at cell
% boundaries as the left eigenvalue multiplied by the difference in
% Q. The upwind value for the left eigenvalue is used.


% OLD LOOP :)
%alpha1 = zeros(1,K+3); alpha2 = zeros(1,K+3);                       
%parfor i=1:K+3
%    alpha1(i) = left_eig1(i,:)*Dq(i,:)'; 
%    alpha2(i) = left_eig2(i+1,:)*Dq(i,:)';  
%end

alpha1 = sum(left_eig1(1:nx+3,:).*Dq(1:nx+3,:),2);
alpha2 = sum(left_eig2(2:nx+4,:).*Dq(1:nx+3,:),2);
alpha1 = alpha1';
alpha2 = alpha2';

% OLD LOOP :)
%AplusDq = zeros(K+3,2); AminDq = zeros(K+3,2);
%!!!!!! % For now compute in loop, replace later on;
%for i=1:K+3
%   AplusDq(i,:) = l11(i)*alpha1(i)*right_eig1(:,i); 
%   AminDq(i,:) = l22(i+1)*alpha2(i)*right_eig2(:,i+1); 
%end

AplusDq = (ones(2,1)*(l11(1:nx+3)'.*alpha1(1:nx+3))).*right_eig1(:,1:nx+3);
AminDq =  (ones(2,1)*(l22(2:nx+4)'.*alpha2(1:nx+3))).*right_eig2(:,2:nx+4);

AplusDq = AplusDq';
AminDq = AminDq';


% ------------------ FLUX LIMITER CORRECTION STEP-----------------%
% Computation of theta, theta at a cell boundary is defined as the
% ration between alpha at the upwind cell boundary, divided by
% alpha at the current cell boundary.       
% Theta is size K+2
theta1 = alpha1(1:end-1)./alpha1(2:end); %theta1(i-1/2)=alpha1(i-3/2)/alpha1(i-1/2)
theta2 = alpha2(2:end)./alpha2(1:end-1); %theta2(i-1/2)=alpha2(i+1/2)/alpha2(i-1/2)

% Compute flux limited alpha;
alpha1_tilde = phi_func(theta1(1:nx+1),input).*alpha1(2:nx+2); %size K+1 
alpha2_tilde = phi_func(theta2(2:nx+2),input).*alpha2(2:nx+2); %size K+1

% OLD LOOP:)
%Fl =zeros(K+1,2);
%for i=1:K+1
%    Fl(i,:) = 0.5*abs(l11(i+1)).*(1-dt/dx*abs(l11(i+1)))*alpha1_tilde(i)*right_eig1(:,i+1) + ...
%    0.5*abs(l22(i+2)).*(1-dt/dx*abs(l22(i+2)))*alpha2_tilde(i)*right_eig2(:,i+2);              
%end
Fl = (ones(2,1)*(0.5*abs(l11(2:nx+2)').*(ones(1,nx+1)-dt/dx*abs(l11(2:nx+2)').*alpha1_tilde(1:nx+1)))).*right_eig1(:,2:nx+2) + ...
     (ones(2,1)*(0.5*abs(l22(3:nx+3)').*(ones(1,nx+1)-dt/dx*abs(l22(3:nx+3)').*alpha2_tilde(1:nx+1)))).*right_eig2(:,3:nx+3);


% ----------------- SOURCE TERMS ---------------------------------%
etab = [2*etab(1,1)-etab(2,1); etab; 2*etab(end,1)-etab(end-1,1)];
S0 = -(etab(3:end,:) - etab(1:end-2,:))/(2*dx);
S = [zeros(nx,1), g*Q(3:end-2,1).*S0 - (Cf' .* (Q(3:end-2,2).^2)) ./ (Q(3:end-2,1).^2)];

% ----------------- UPDATE ---------------------------------------%
Q_new = Q(3:nx+2,:) -(dt/dx)*(AplusDq(2:nx+1,:)+AminDq(3:nx+2,:)) +dt*S -(dt/dx)*(Fl(:,2:nx+1)'-Fl(:,1:nx)');

qw = Q_new(:,2)';
h_new = (Q_new(:,1))';
u_new = (qw./h_new);


            


