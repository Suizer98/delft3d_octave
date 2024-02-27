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
%$Id: bed_flux_limiter.m 17437 2021-08-02 03:19:02Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_flux_limiter.m $
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

function bed_flux_limiter=bed_flux_limiter(input,Qb,B)

vm=3:numel(Qb)-1;

fp05_p=f_flux_p(input,vm  ,Qb./B); %f_(m+1.5) when upwind positive
fm05_p=f_flux_p(input,vm-1,Qb./B); %f_(m-1.5) when upwind positive

bed_flux_limiter=fp05_p-fm05_p;

end %function

%%
%% FUNCTIONS
%%

function r=f_r(vm,Qb)
r=(Qb(vm+1)-Qb(vm))./(Qb(vm)-Qb(vm-1));
end

function phir=f_phi(input,r)
switch input.mor.scheme
    case 4 %van leer
        phir=(r+abs(r))./(1+r); 
end
end

function f_flux_p=f_flux_p(input,vm,Qb)
r=f_r(vm,Qb);
phir=f_phi(input,r);
f_flux_p=Qb(vm)+0.5*(Qb(vm)-Qb(vm-1)).*phir;
end
