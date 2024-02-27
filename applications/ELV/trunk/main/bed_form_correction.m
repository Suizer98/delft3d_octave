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
%$Id: bed_form_correction.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_form_correction.m $
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

function [Cf_ibl,Cf_obl,u_st_ibl_s,u_st_obl_s]=bed_form_correction(input_i,u_st_b,u)

%% RENAME

% g=input.mdv.g;
% nk=input.frc.nk;
% d90=max(input.sed.dk(end)); %this is not formally correct
% d50=mean(input.sed.dk(end)); %this is not formally correct
% 
% switch input_i.frc.bfc_type
%     %% Smith77
%     case 1


F=@(X)aux_bfc(X,u_st_b,input_i);
X0=[u_st_b,u_st_b]./2; %[u_st_ibl,u_st_obl]

options=optimoptions('fsolve','display','off'); %display={off,iter,final,final-detailed}
% options=optimoptions('fsolve','TolFun',1e-16,'TolX',1e-16,'display','off','MaxFunEvals',50000,'FunValCheck','on','MaxIter',40000); %display={off,iter,final,final-detailed}
[X_s,~,exitflag,output]=fsolve(F,X0,options);
% [X_s,~,exitflag,output]=fsolve(F,X0);

u_st_ibl_s=X_s(1);
u_st_obl_s=X_s(2);

Cf_ibl=(u_st_ibl_s/u)^2;
Cf_obl=(u_st_obl_s/u)^2;

if exitflag<=0
    error('something went wrong in the minimization')
end
%     %% VanRijn84_3
%     case 2
% 
% ksg=nk*d90; %Equation 17
% 
% D_st=d50*()^(1/3); %Equation 6
% Psi=Delta/lambda; %steepnes
% ksf=1.1*Delta*(1-exp(-25*Psi)); %Equation 19
% 
% ks=ksg+ksf; %Equation 20
% C=18*log10(12*Rh/ks); %Equation 21
% Cf_ibl=g/C^2;
% 
% %other output
% Cf_obl=NaN;
% u_st_ibl_s=NaN;
% u_st_obl_s=NaN;
% 
% end

end %function