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
%$Id: flow_steady_depth_RK4.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/test/scripts/flow_steady_depth_RK4.m $
%
%check_input is a function that checks that the input is enough and makes sense
%
%input_out=check_input(input,path_file_input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -input = variable containing the input [struct] e.g. input
%
%HISTORY:
%170727
%   -V. Created for the first time.

function [U,H]=flow_steady_depth_RK4(qwup,Hdown,Cf,etab,input)

%Fully based on the standard steady state solver 
g =input.mdv.g;
nx=input.mdv.nx;
dx=input.grd.dx;
B =input.grd.B;
slopeb=-[NaN,diff(etab)/dx];

%downstream condition
H(1,nx)=Hdown;
qw=(qwup*B(1)./B);
for kx=nx-1:-1:1      
    R1=dx*dH_dx(H(kx+1)     ,qw(kx+1),Cf(kx+1),slopeb(kx+1),g);
    R2=dx*dH_dx(H(kx+1)+R1/2,qw(kx+1),Cf(kx+1),slopeb(kx+1),g);
    R3=dx*dH_dx(H(kx+1)+R2/2,qw(kx+1),Cf(kx+1),slopeb(kx+1),g);
    R4=dx*dH_dx(H(kx+1)+R3  ,qw(kx+1),Cf(kx+1),slopeb(kx+1),g);

    H(1,kx)=H(1,kx+1)-1/6*(R1+2*R2+2*R3+R4);
end
U=qw./H; %[1x(nx) double]
end %function

function dH_dx_v=dH_dx(H_v,qw_v,Cf_v,slopeb_v,g)
%friction term in one point

Fr2_v=qw_v^2/(g*H_v^3);
dH_dx_v=(slopeb_v-Cf_v*Fr2_v)/(1-Fr2_v);
    
end %function










