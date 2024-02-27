%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16814 $
%$Date: 2020-11-19 12:33:47 +0800 (Thu, 19 Nov 2020) $
%$Author: chavarri $
%$Id: flow_steady_energy_RK4.m 16814 2020-11-19 04:33:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/flow_steady_energy_RK4.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%[U,H]=flow_steady_energy_RK4(qwup,Hdown,Cf,etab,input)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%??????
%   -V. Created for the first time.

function [U,H]=flow_steady_energy_RK4(qwup,Hdown,Cf,etab,input)

%%
%% RENAME
%%

g =input.mdv.g;
nx=input.mdv.nx;
dx=input.grd.dx;
B =input.grd.B;

qw=(qwup*B(1)./B); %it is constant everywhere, does not matter position

%% 
%% downstream condition
%%

%first step is different because the dowsntream boundary condition is at the cell edge
H_ce=Hdown; %flow depth at cell edge
etab_ce=3/2*etab(nx)-1/2*etab(nx-1); %bed elevation at cell edge (linear interpolation of slope)
Energy_ce=etab_ce+H_ce+0.5*qw(1,nx)^2/(g*H_ce^2); %enerfy at cell edge

%march first dx/2 to get to cell centre of last cell
kx=nx;

R1=dx/2*Sf_fun(H_ce     ,qw(kx),Cf(kx),g);
R2=dx/2*Sf_fun(H_ce+R1/2,qw(kx),Cf(kx),g);
R3=dx/2*Sf_fun(H_ce+R2/2,qw(kx),Cf(kx),g);
R4=dx/2*Sf_fun(H_ce+R3  ,qw(kx),Cf(kx),g);

Energy(1,kx)=Energy_ce+1/6*(R1+2*R2+2*R3+R4);

%  Invert the energy function analytically
acoeff=1;
bcoeff=-(Energy(1,kx)-etab(1,kx));
ccoeff=0;
dcoeff=0.5*qw(1,kx)^2/g;
root=analytical_cubic_root(acoeff,bcoeff,ccoeff,dcoeff);
H(1,kx)=max(root); %Select the subcritical value

%wrong because it is assumed that the flow depth at the cell centre of the last cell is the same than the flow depth at the dowsntream end
% H(1,nx)=Hdown;
% qw=(qwup*B(1)./B);
% Energy(1,nx)=etab(1,nx)+Hdown+0.5*qw(1,nx)^2/(g*Hdown^2);

%% 
%% LOOP
%%
for kx=nx-1:-1:1      
    R1=dx*Sf_fun(H(kx+1)     ,qw(kx+1),Cf(kx+1),g);
    R2=dx*Sf_fun(H(kx+1)+R1/2,qw(kx+1),Cf(kx+1),g);
    R3=dx*Sf_fun(H(kx+1)+R2/2,qw(kx+1),Cf(kx+1),g);
    R4=dx*Sf_fun(H(kx+1)+R3  ,qw(kx+1),Cf(kx+1),g);

    Energy(1,kx)=Energy(1,kx+1)+1/6*(R1+2*R2+2*R3+R4);

    %  Invert the energy function analytically
    acoeff=1;
    bcoeff=-(Energy(1,kx)-etab(1,kx));
    ccoeff=0;
    dcoeff=0.5*qw(1,kx)^2/g;
    root=analytical_cubic_root(acoeff,bcoeff,ccoeff,dcoeff);
    H(1,kx)=max(root); %Select the subcritical value
end
U=qw./H; %[1x(nx) double]
end %function

function Sf_v=Sf_fun(H_v,qw_v,Cf_v,g)
%friction term in one point

Sf_v=Cf_v*qw_v^2/(g*H_v^3);
    
end %function