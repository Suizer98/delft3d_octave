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
%$Id: theta_method_171005.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/test/scripts/old/theta_method_171005.m $
%
%active_layer_mass_update updates the mass (volume) of sediment at the active layer.
%
%\texttt{Mak_new=active_layer_mass_update(Mak,detaLa,fIk,qbk,bc,input,fid_log,kt)}
%
%INPUT:
%   -\texttt{Mak} = effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%   -\texttt{detaLa} = variation in elevation of the interface between the active layer and the substarte [m]; [(1)x(nx) double]
%   -\texttt{fIk} = effective volume fraction content of sediment at the interface between the active layer and the substrate [-]; [(nf-1)x(nx) double]
%   -\texttt{g} = boundary condition function [m^2/s]; [(nf)x(nx) double]
%   -\texttt{h} = boundary conditions structure 
%   -\texttt{input} = input structure
%   -\texttt{fid_log} = identificator of the log file
%
%OUTPUT:
%   -\texttt{Mak_new} = new effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%
%HISTORY:
%171002
%   -V. Created it for the first time

function C_new=theta_method(C_old,v,kappa,S1,S2,g_u,h_u,g_d,h_d,input,fid_log)

%%
%% RENAME
%%

dt=input.mdv.dt;
dx=input.grd.dx;
nx=input.mdv.nx; 
theta=input.mdv.theta;

%outcome have size [nx,1]
alpha=v'*dt/2/dx;
beta=kappa*dt/dx^2*ones(nx,1);
gamma=dt*S1';
delta=dt*S2';
C_old=C_old';

%added here in case a different function is added at a later stage
g_u=g_u/kappa;
h_u=h_u/kappa;

%%
%% FILL MATRIX
%%

%% MATRIX

%source term
R=NaN(nx,1); 
R(2:end-1,1)=C_old(2:end-1)-alpha(2:end-1).*(1-theta).*(C_old(3:end)-C_old(1:end-2))+beta(2:end-1).*(1-theta).*(C_old(3:end)-2.*C_old(2:end-1)+C_old(1:end-2))+gamma(2:end-1)+delta(2:end-1).*(1-theta).*C_old(2:end-1);
%matrix with the tridiagonals
T=NaN(nx,3);
T(:,:)=[[-theta*(alpha(2:end)+beta(2:end));0],1+2.*beta(1:end).*theta-delta(1:end).*theta,[0;theta.*(alpha(1:end-1)-beta(1:end-1))]];

%% BOUNDARY CONDITIONS

%upstream
switch input.bcm.pa_u
    case 1 %dirichlet
        %source term
        R(2)=R(2)+theta*(alpha(2)+beta(2))*C_old(1);
        idx_i=2; %index of initial node (upstream)
        %tridiagonal matrix
        %(no mofication)
    case 2 %neuman
        %to do!
    case 3 %robin: dC/dx=h_u*c+g_u
        %source term
        C_old_0=C_old(2)-2*dx*(g_u(1)+h_u(1)*C_old(1)); %ghost node
        R(1)=C_old(1)-alpha(1)*(1-theta)*(C_old(2)-C_old_0)+beta(1)*(1-theta)*(C_old(2)-2*C_old(1)+C_old_0)+gamma(1)+delta(1)*(1-theta)*C_old(1)-theta*(alpha(1)+beta(1))*2*dx*g_u(2);
        idx_i=1; %index of initial node (upstream)
        %tridiagonal matrix
        T(1,:)=T(1,:)+[0,theta*(alpha(1)+beta(1))*2*dx*h_u(2),0];
        T(2,:)=T(2,:)+[0,0,-theta*(alpha(1)+beta(1))];
end

%downstream
switch input.bcm.pa_d
    case 1 %dirichlet
        %source term
        R(end-1)=R(end-1)-theta*(alpha(end-1)-beta(end-1))*C_old(end);   
        idx_f=nx-1; %index of final node (downstream)
        %tridiagonal matrix
        %(no mofication)
    case 2 %neuman
        %to do!
    case 3 %robin
        %to do!
%         g_u h_d
end

%cut the nodes to solve
B=R(idx_i:idx_f,:);
D=T(idx_i:idx_f,:);

%% SOLVE SYSTEM

%system matrix
A=spdiags(D,[-1,0,1],size(D,1),size(D,1));
%solve
x=mldivide(A,B); %Ax=B

%% ADD BOUNDARY CONDITIONS

C_new=NaN(1,nx);
C_new(1,idx_i:idx_f)=x';

%upstream
switch input.bcm.pa_u
    case 1 %dirichlet
        C_new(1)=C_old(1);
    case 2 %neuman
        
%     case 3 %robin
        %nothing to be done
end

%downstream
switch input.bcm.pa_d
    case 1 %dirichlet
        C_new(end)=C_old(end);
    case 2 %neuman
        
%     case 3 %robin
        %nothing to be done
end


