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
%$Id: march_step_dBdx_mixed.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/march_step_dBdx_mixed.m $
%
%function_name does this and that
%
%\texttt{[output]=function_name(input)}
%
%INPUT:
%   -\texttt{input} = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -\texttt{output} = variable containing the output [struct] e.g. input
%
%HISTORY:
%160223
%   -V. Created for the first time.


function [H_new, eta_new, Fak_new, ib_new, dFak_new] = march_step_dBdx_mixed(H,eta_old,Fak_old,dq,pq,input,dxi,j,Cf,La,Mak,AL,Bup,Bloc,dBdxloc,X0)
B = input.grd.B(1,:);
K = numel(dq);
if isfield(input.grd,'L_cut')
    input.grd.L = input.grd.L +input.grd.L_cut;
else

end

g = 9.81;
h_old = H-eta_old;
c_f = Cf(1);

% Get sediment transport capacity gradients
u_old = (dq*Bup/Bloc)./h_old;
Fr_old = u_old./sqrt(g*h_old);

q = (dq*Bup/Bloc);
Mak = repmat(Mak,K,1);
qbk = sediment_transport(input.aux.flg,input.aux.cnt,h_old,q,Cf,La,Mak,input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
Fak_tot = [Fak_old,1-sum(Fak_old)];
Qbk = qbk./repmat(Fak_tot,K,1); 

du_old = q./h_old + 1e-9;
dq2 = du_old.*h_old;
dqbk = sediment_transport(input.aux.flg,input.aux.cnt,h_old,dq2,Cf,La,Mak,input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
dQbk = dqbk./repmat(Fak_tot,K,1);                                
dQbkdu = ((dQbk - Qbk)/(1e-9))';        
            
% Solve for gradients
F2 = @(X)solve_mixed_dBdx(X,input,Fak_old, Qbk, dQbkdu', h_old, Fr_old, u_old, pq, K, AL*B(1)/Bloc, dxi, q,Bloc,dBdxloc);
[X_s,~,~,~]=fsolve(F2,X0,input.ini.sp.options);
%mass_check = abs((solve_mixed_dBdx(X_s,input,Fak_old, Qbk, dQbkdu', h_old, Fr_old, u_old, pq, K, AL*B(1)/Bloc, dxi, q, Bloc,dBdxloc))./AL);
ib_new = X_s(1);
dFak_new = X_s(2:end);

% Update
eta_new = eta_old+ib_new*dxi;
h_new = h_old - (ib_new - c_f.*Fr_old.^2)./(1-Fr_old.^2)*dxi;
H_new = h_new + eta_new;
Fak_new = Fak_old + dFak_new'*dxi;
 

end

