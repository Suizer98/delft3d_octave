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
%$Id: ini_normalflow.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/ini_normalflow.m $
%
%ini_normalflow is a function that finds the normal flow conditions at the first time step. 
%
%[u,h,slopeb,Fak]=ini_normalflow(input,Cf,fid_log)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160502
%   -V. Bug in repmat(Fak...) for 3 fractions
%
%160615
%   -V. Change of optimization variable

function [u,h,slopeb,Fak]=ini_normalflow(input,Cf,fid_log)
%comment out fot improved performance if the version is clear from github
% version='3';
% fprintf(fid_log,'ini_normalflow version: %s\n',version);

%% 
%% RENAME
%%

nef=input.mdv.nef;
nf=input.mdv.nf;
nx=input.mdv.nx;
h=input.ini.h;
% slopeb=input.ini.slopeb;
Fak=input.ini.Fak;

qbk0=input.bcm.Qbk0(1,:)./input.grd.B(1); %specific sediment discharge at the upstream end at time 0 [1xnf double]
q0=input.bch.Q0(1)/input.grd.B(1); %[1x1 double]


%%
%% MINIMIZE
%%

objective=[q0,qbk0]; %objective, target

%variable = X:
% h=X(1);
% u=X(2);
% Fak=X(3:end);


X0=[h,q0/h,Fak(:,1)'];

La=1; %for obtaining fractions rather than mass
mor_fac=1; 

F=@(X)aux_ini_normalflow(X,objective,input.aux.flg,input.aux.cnt,Cf,La,input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,mor_fac);

options=optimoptions('fsolve','TolFun',1e-16,'TolX',1e-16,'display','none','MaxFunEvals',50000,'FunValCheck','on','MaxIter',40000);
[X_s,~,exitflag,output]=fsolve(F,X0,options);

h0=X_s(1);
u0=X_s(2);
slopeb0=(Cf*(h0*u0)^2/input.mdv.g/h0^3);
Fak0=X_s(3:end);

h=repmat(h0,1,nx);
u=repmat(u0,1,nx);
slopeb=repmat(slopeb0,1,nx);
Fak=repmat(Fak0',1,nx);

%output
if exitflag>0 %correct exiting
    fprintf(fid_log,'Normal flow initial condition found. First order optimality = %6.4e\n',output.firstorderopt);
    aux_str=sprintf('%s%s%s','h0=%6.4f m; u0=%6.4f m/s; slopeb0=%1.5e; Fak0=[ ',repmat('%5.3f ',1,nef),']\n');
    fprintf(fid_log,aux_str,h0,u0,slopeb0,Fak0);
else %problems in exit
    [qbk0_pred,~]=sediment_transport(input.aux.flg,input.aux.cnt,h0,h0*u0,Cf,La,Fak0,input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,mor_fac,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
    fprintf(fid_log,'ATTENTION!!! Normal flow initial condition not found. First order optimality = %6.4e\n',output.firstorderopt);
    aux_str=sprintf('%s%s%s%s%s%s','h0=%6.4f m; u0=%6.4f m/s; slopeb0=%1.5e; Fak0=[ ',repmat('%5.3f ',1,nef),']',' qbk0=[ ',repmat('%5.3e ',1,nf),']\n');
    fprintf(fid_log,aux_str,h0,u0,slopeb0,Fak0,qbk0_pred);
end
