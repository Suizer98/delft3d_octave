%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 17437 $
%$Date: 2021-08-02 11:19:02 +0800 (Mon, 02 Aug 2021) $
%$Author: chavarri $
%$Id: bed_flux_BS.m 17437 2021-08-02 03:19:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_flux_BS.m $
%
%bed_level_update updates the bed elevation
%
%etab_new=bed_level_update(etab,qbk,bc,input,fid_log,kt)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%201102
%   -V. Created for the first time.
%

function flux_BS=bed_flux_BS(Qb,B)

vm=2:numel(Qb);

fp05_p=f_BS_p(vm  ,Qb./B); %f_(m+1.5) when upwind positive
fm05_p=f_BS_p(vm-1,Qb./B); %f_(m-1.5) when upwind positive

% fp05_n=f_BS_n(vm  ,Qb./B); %f_(m+1.5) when upwind negative
% fm05_n=f_BS_n(vm-1,Qb./B); %f_(m-1.5) when upwind negative

Fp=fp05_p-fm05_p;
% Fn=fp05_n-fm05_n;

% flux_BS=UpwFac*Fp+(1-UpwFac)*Fn;
flux_BS=Fp;

end %function

%%
%% FUNCTIONS
%%

function f_BS_p=f_BS_p(vm,Qb)
f_BS_p=Qb(vm);
end

% function f_BS_n=f_BS_n(vm,Qb)
% f_BS_n=Qb(vm+1);
% end