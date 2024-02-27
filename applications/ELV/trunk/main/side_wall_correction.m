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
%$Id: side_wall_correction.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/side_wall_correction.m $
%
%side_wall_correction
%
%[Cf_t,Cf_b,Cf_w,u_st_b]=side_wall_correction(input_i,u,h,Sf)
%
%INPUT:
%   -Mak = effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%	-detaLa = variation in elevation of the interface between the active layer and the substarte [m]; [(1)x(nx) double]
%	-fIk = effective volume fraction content of sediment at the interface between the active layer and the substrate [-]; [(nf-1)x(nx) double]
%	-qbk = volume of sediment transported excluding pores per unit time and width and per size fraction [m^2/s]; [(nf)x(nx) double]
%	-bc = boundary conditions structure 
%	-input = input structure
%	-fid_log = identificator of the log file
%	-kt = time step counter [-]; [(1)x(1) double]
%
%OUTPUT:
%   -Mak_new = new effective volume of sediment per unit of bed area in the active layer [m]; [(nf-1)x(nx) double]
%
%HISTORY:
%170315
%   -V. Created for the first time.
%

function [Cf_t,Cf_b,Cf_w,u_st_b]=side_wall_correction(input_i,u,h,Sf)

%% RENAME

g=input_i.mdv.g;
B=input_i.grd.B;

%% COMP

Cf_t=g*h*Sf/u^2;

F=@(X)aux_swc(X,u,Sf,input_i);
% X0=[B*h,Cf_t]; %[R_w,Cf_w]
X0=[1e-3,1e-3]; %[R_w,Cf_w]

options=optimoptions('fsolve','display','off'); %display={off,iter,final,final-detailed}
% options=optimoptions('fsolve','TolFun',1e-16,'TolX',1e-16,'display','final','MaxFunEvals',50000,'FunValCheck','on','MaxIter',40000); %display={off,iter,final,final-detailed}
[X_s,~,exitflag,output]=fsolve(F,X0,options);
% [X_s,~,exitflag,output]=fsolve(F,X0);

R_w=X_s(1);
Cf_w=X_s(2);

R_b=h*(1-2*R_w/B);
Cf_b=g*R_b*Sf/u^2;
u_st_b=sqrt(g*R_b*Sf);

if exitflag<=0
    error('something went wrong in the minimization')
end