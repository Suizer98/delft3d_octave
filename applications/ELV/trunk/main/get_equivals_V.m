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
%$Id: get_equivals_V.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/get_equivals_V.m $
%
%get_equivals_V is a slight modification of get_equivals to not display output
%
%[S0,Fak0,sum_Fak_obj,max_rel_error] = get_equivals_V(Qw,input_1,AL,sedp_1)
%
%INPUT:
%   -input = input structure
%
%OUTPUT:
%   -
%
%HISTORY:
%170328
%   V. Created it.
%

function [S0,Fak0,sum_Fak_obj,max_rel_error] = get_equivals_V(Qw,input_1,AL,sedp_1)

%% solve for the possibility of no transport in one frac
input_2=input_1;

qbk0_nz_idx=sedp_1>0; %minimize over the values different than 0;

sedp=sedp_1(qbk0_nz_idx);
input_2.sed.dk=input_1.sed.dk(qbk0_nz_idx);
input_2.mdv.nf=numel(input_2.sed.dk);
input_2.tra.kappa=input_1.tra.kappa(qbk0_nz_idx);

%%

ALp = AL * sedp;
input_2 = add_sedflags(input_2);
input_2.aux.flg.particle_activity=0; %when searching for boundary conditions we compute transport directly, without kappa*dGammak_dx
F = @(X)solve_nfbc(X,input_2,Qw,ALp);

nf=numel(input_2.sed.dk);
ntr=10; %number of trials
if nf>1
Fak_v=linspace(0,1,ntr);
aux_str=repmat('Fak_v,',1,nf-1);
aux_str=aux_str(1:end-1);
% eval(sprintf('Fak_m=combvec(%s)'';',aux_str));
eval(sprintf('Fak_m=allcomb(%s)'''';',aux_str));
end

ktr=1;
sum_Fak_obj=1;
max_rel_error=1;
while (max_rel_error>0.001 || sum_Fak_obj>1e-8) && ktr<=ntr
    if nf>1
        X0=[1e-1,Fak_m(ktr,:)];
    else 
        X0=1e-1;
    end
    options=optimoptions('fsolve','TolFun',1e-16,'TolX',1e-16,'display','none','MaxFunEvals',1000);
    [X_s,~,~,~]=fsolve(F,X0,options);

%     options=optimoptions('fsolve','TolFun',1e-16,'TolX',1e-16,'display','none','MaxFunEvals',1000);
%     [X_s,~,~,~]=fsolve(F,X0);

    sum_Fak_obj=sum(abs(solve_nfbc(X_s,input_2,Qw,ALp)));
    rel_error = solve_nfbc(X_s,input_2,Qw,ALp)./ALp;
    max_rel_error=max(abs(rel_error));

    ktr=ktr+1;
end

S0 = X_s(1);
Fk = X_s(2:end);
if numel(input_2.sed.dk)>1
    Fk = [Fk 1-sum(Fk)];
else
    Fk=NaN(1,2);
end

%% rename 
Fak0=zeros(numel(input_1.sed.dk),1);
if numel(input_2.sed.dk)>1
    Fak0(qbk0_nz_idx)=Fk;
else
    Fak0(qbk0_nz_idx)=1;
end

end
