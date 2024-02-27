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
%$Id: ini_normalflow_L.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/ini_normalflow_L.m $
%
%ini_normalflow_L is a function that finds the normal flow conditions at the first time step. 
%
%[u,h,slopeb,Fak]=ini_normalflow_L(input,Cf,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%170328
%   V. Created for the first time
%

function [u,h,slopeb,Fak]=ini_normalflow_L(input,Cf,Cfb,fid_log)

%% 
%% RENAME
%%

nef=input.mdv.nef;
nf=input.mdv.nf;
nx=input.mdv.nx;

g=input.mdv.g;

Qbk0=input.bcm.Qbk0(1,:); %specific sediment discharge at the upstream end at time 0 [1xnf double]
Qb0=sum(input.bcm.Qbk0(1,:)); %total sediment discharge at the upstream end at time 0 [1xnf double]
pb0=Qbk0/Qb0;
Q0=input.bch.Q0(1); %specific water discharge at the upstream end at time 0 [1x1 double]
B=input.grd.B(1); %width at the upstream end [1x1];

input.aux.flg.particle_activity=0; %when searching for boundary conditions we compute transport directly, without kappa*dGammak_dx

%%
%% MINIMIZE
%%

[slopeb0,Fak0,sum_Fak_obj,max_rel_error]=get_equivals_V(Q0,input,Qb0,pb0);
h0=(Cf.*(Q0/B).^2/(g*slopeb0)).^(1/3);
u0=(Q0/B)/h0;
Fak0=Fak0(1:nef);

[qbk0_pred,~]=sediment_transport(input.aux.flg,input.aux.cnt,h0,h0*u0,Cfb,1,Fak0,input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);

h=repmat(h0,1,nx);
u=repmat(u0,1,nx);
slopeb=repmat(slopeb0,1,nx);
Fak=repmat(Fak0,1,nx); 

%output
if max_rel_error<0.001 && sum_Fak_obj<1e-8
    fprintf(fid_log,'Normal flow initial condition found. Maximum relative error = %6.4e; sum of objective function = %6.4e \n',max_rel_error,sum_Fak_obj);
    aux_str=sprintf('%s%s%s%s%s%s','h0=%6.4f m; u0=%6.4f m/s; slopeb0=%1.5e; Fak0=[ ',repmat('%5.3f ',1,nef),']',' qbk0=[ ',repmat('%5.3e ',1,nf),']\n');
    fprintf(fid_log,aux_str,h0,u0,slopeb0,Fak0,qbk0_pred);
else %problems in exit
    fprintf(fid_log,'ATTENTION!!! Normal flow initial condition not found. Maximum relative error = %6.4e; sum of objective function = %6.4e \n',max_rel_error,sum_Fak_obj);
    aux_str=sprintf('%s%s%s%s%s%s','h0=%6.4f m; u0=%6.4f m/s; slopeb0=%1.5e; Fak0=[ ',repmat('%5.3f ',1,nef),']',' qbk0=[ ',repmat('%5.3e ',1,nf),']\n');
    fprintf(fid_log,aux_str,h0,u0,slopeb0,Fak0,qbk0_pred);
end
