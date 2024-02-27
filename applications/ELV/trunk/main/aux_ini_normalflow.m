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
%$Id: aux_ini_normalflow.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/aux_ini_normalflow.m $
%
%aux_ini_normalflow is an auxiliary function that returns the difference between the boundary condition values of q and qbk and the computed ones
%
%\texttt{F=aux_ini_normalflow(X,objective,flg,cnt,cf,La,dk,sed_trans_param,hiding_param,mor_fac)}
%
%INPUT:
%   -\texttt{input} = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160615
%   -V. Change of optimization variable. Adjusted order of magnitude of
%   objective function. Forcing of Mak<1
%
%160802
%   -V. order(0)=-Inf; this causes a problem

function F=aux_ini_normalflow(X,objective,flg,cnt,cf,La,dk,sed_trans_param,hiding_param,mor_fac)
%comment out fot improved performance if the version is clear from github
% version='3';
% fprintf(fid_log,'aux_ini_normalflow version: %s\n',version);

h=X(1);
u=X(2);
Mak=X(3:end);

Mak(Mak>1)=1;

q=u*h;
[qbk,~]=sediment_transport(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,NaN(1,2),NaN(1,2),NaN,NaN,NaN);

if sum(qbk)==0
    qbk_om=max(order(objective(2:end)));
else
    qbk_om=max(order(qbk));    
end
% qbk_om=max(order(qbk));
% qbk_om(qbk_om<0)=0; %remove order(0)=-Inf

q_scaled=q*10^qbk_om;
nf=numel(qbk);
F=([q_scaled,qbk]-objective.*[10^qbk_om,ones(1,nf)]).*10^(-qbk_om);

%make scalar
% F=sum(F);


