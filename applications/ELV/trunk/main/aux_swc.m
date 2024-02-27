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
%$Id: aux_swc.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/aux_swc.m $
%
%aux_swc is an auxiliary function of side_wall_corection
%
%\texttt{F=aux_swc(X,u,Sf,input)}
%
%INPUT:
%	-X = 
%	-u = 
%	-Sf =
%   -input = 
%
%OUTPUT:
%   -F = 
%
%HISTORY:
%170315
%   -V. Created for the first time.
%

function F=aux_swc(X,u,Sf,input_i)

%check Guo15: Junke Guo (2015) Sidewall and non-uniformity corrections for flume experiments, Journal of Hydraulic Research, 53:2, 218-229, DOI: 10.1080/00221686.2014.971449
%% RENAME

R_w=X(1);
Cf_w=X(2);

g=input_i.mdv.g;
nu=input_i.mdv.nu;

f_w=8*Cf_w;

%% OBJ

Re_w=4*u*R_w/nu; %Reynolds wall

% F must be equal to 0
F(1)=2*log10(Re_w*sqrt(f_w))-0.8-1/sqrt(f_w); %Von Karman - Prandtl
F(2)=f_w*u^2/8/g/Sf-R_w; %Chezy
