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
%$Id: ini_Gammak.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/ini_Gammak.m $
%
%ini_Gammak creates the initial Gammak values for equilibrium
%
%La=ini_La(input,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%171005
%   -V. Created for the first time.

function Gammak=ini_Gammak(h,u,Cf_b,La,Mak,input,fid_log)

%%
%% RENAME
%% 

nf=input.mdv.nf;
nx=input.mdv.nx;


%%
%% CALC
%%

Gammak=NaN(nf,nx); %dummy

% [qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq]=sediment_transport(flg,cnt,h_u,u.*h_u,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);
[~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,Gammak_eq]=sediment_transport(...
    input.aux.flg,input.aux.cnt,h',(u.*h)',Cf_b',La',Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,input.tra.E_param,input.tra.vp_param,Gammak',fid_log);

Gammak=Gammak_eq';
end
