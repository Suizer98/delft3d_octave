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
%$Id: march_step_uni.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/march_step_uni.m $
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


function [H_new, eta_new, ib_new] = march_step_uni(H,eta_old,dq,pq,input,dxi,j,Cf,La,Mak,AL)
B = input.grd.B(1,:);

if isfield(input.grd,'L_cut')
    input.grd.L = input.grd.L +input.grd.L_cut;
    nx = input.grd.L/input.grd.dx;
else
    nx = input.mdv.nx;
end

if length(B) == 1
    B = B*ones(nx+2,1);
else
    B = [B(1), B, B(end)];
end

g = 9.81;
h_old = H-eta_old;
c_f = Cf(1);

%Check if width will change:
xloc1 = input.grd.L - (j-1)*dxi;
xind1 = round((xloc1+input.grd.dx/2)/input.grd.dx)+1;
xloc2 = input.grd.L - (j)*dxi;
xind2 = round((xloc2+input.grd.dx/2)/input.grd.dx)+1;

% Get sediment transport gradients
u_old = (dq*B(1)/B(xind1))./h_old;
Fr_old = u_old./sqrt(g*h_old);

q = dq*B(1)/B(xind1);
qb = sediment_transport(input.aux.flg,input.aux.cnt,h_old,q,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);

du_old = q./h_old + 1e-9;
dq2 = du_old.*h_old;
dqbk = sediment_transport(input.aux.flg,input.aux.cnt,h_old,dq2,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);

dqbdu = ((dqbk - qb)/(1e-9));           
alpha = dqbdu.*(u_old./h_old)./(1-Fr_old.^2); 
ib_new = sum(pq.*alpha*c_f.*Fr_old.^2)/sum(pq.*alpha);
eta_new = eta_old+ib_new*dxi;
h_new = h_old - (ib_new - c_f.*Fr_old.^2)./(1-Fr_old.^2)*dxi;
H_new = eta_new + h_new;

if B(xind1)==B(xind2) %NO
else %YES, but abrupt
    disp(strcat('Width changes abruptly at location:',num2str(j)));
    if B(xind2)<B(xind1)
        Xguess = eta_new;
    else
        Xguess = eta_new+min(h_new)-1;
        ib_new = 1e-3;
    end  
    F = @(X)solve_equibed(X,H,input,(dq*B(1)/B(xind2)),pq,AL*B(1)/B(xind2));
    eta_new = fzero(F,Xguess);
end
end



