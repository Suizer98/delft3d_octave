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
%$Id: march_step_dBdx.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/march_step_dBdx.m $
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


function [H_new, eta_new, ib_new] = march_step_dBdx(H,eta_old,dq,pq,input,dxi,j,Cf,La,Mak,AL,Bup,Bloc,dBdxloc)
if isfield(input.grd,'L_cut');
    input.grd.L = input.grd.L +input.grd.L_cut;
    %nx = input.grd.L/input.grd.dx;
else
    %nx = input.mdv.nx;
end

g = 9.81;
h_old = H-eta_old;
%ratio = input.grd.dx/dxi;
c_f = Cf(1);
u_old = (dq*Bup/Bloc)./h_old;
Fr_old = u_old./sqrt(g*h_old);

qw = (dq*Bup/Bloc);
qb = sediment_transport(input.aux.flg,input.aux.cnt,h_old,qw,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
dqw = qw + 1e-7;
dqbk = sediment_transport(input.aux.flg,input.aux.cnt,h_old,dqw,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN(1,2),NaN(1,2),NaN,NaN,NaN);
dqbdq = ((dqbk - qb)/(1e-7));  
lambda = dqbdq.*u_old./(1-Fr_old.^2);
mu = qb -qw.*dqbdq.*(1./(1-Fr_old.^2));

ib_new = (sum(pq.*lambda*c_f.*Fr_old.^2 +pq.*mu./Bloc.*dBdxloc))/sum(pq.*lambda);
eta_new = eta_old+ib_new*dxi;
h_new = h_old - (ib_new - c_f.*Fr_old.^2 + Fr_old.^2.*h_old./Bloc.*dBdxloc)./(1-Fr_old.^2)*dxi;
H_new = eta_new + h_new;

end






    %{
    
    % Create temporary variables
    u_old = (dq*B(1)/B(round(end-j/ratio)))./h_old;
    Fr_old = u_old./sqrt(g*h_old);

    switch input.tra.cr   
        case 2 %EH              
            % Create temporary variables
            alpha = m*n.*u_old.^(n-1).*(u_old./h_old)./(1-Fr_old.^2);
            ib_new = sum(pq.*alpha*c_f.*Fr_old.^2)/sum(pq.*alpha);
            eta_new = eta_old+ib_new*dxi;
            %[~,htemp] = backwater_step(x,h_old,ib_new,c_f,dq,input2);
            htemp = h_old - (ib_new - c_f.*Fr_old.^2)./(1-Fr_old.^2)*dxi;
            H = htemp + eta_new;

            ubc = (dq*B(1)/B(round(end-j/ratio)));
            qb = sediment_transport(input.aux.flg,input.aux.cnt,h_old,ubc,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN,NaN);


            %dz = solve_dz(dq*B(1)/B(round(end-j/ratio)), pq, htemp, AL*B(1)/B(round(end-j/ratio)), n, m, 0.01);
            %eta_new = eta_new - dz;

        otherwise % all other transport relations 
            % Get initial guesses for mean bed slope and water surface elevation
            ubc = (dq*B(1)/B(round(end-j/ratio)));
            qb = sediment_transport(input.aux.flg,input.aux.cnt,h_old,ubc,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN,NaN);
            du_old = (dq*B(1)/B(round(end-j/ratio)))./h_old + 0.001;
            dubc = du_old.*h_old;
            dqbk = sediment_transport(input.aux.flg,input.aux.cnt,h_old,dubc,Cf,La,Mak',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,NaN,NaN);

            dqbdu = ((dqbk - qb)/(0.001));           
            alpha = dqbdu.*(u_old./h_old)./(1-Fr_old.^2); 
            ib_new = sum(pq.*alpha*c_f.*Fr_old.^2)/sum(pq.*alpha);
            eta_new = eta_old+ib_new*dxi;
            htemp = h_old - (ib_new - c_f.*Fr_old.^2)./(1-Fr_old.^2)*dxi;
            H = htemp + eta_new;


    end

    %Check if width will change:
    if B(round(end-j/ratio))==B(round(end-(j-1)/ratio)) %NO
    else %YES
        disp('Width changes')
        j
        Fw = @(X)solve_equibed(X,H,input,dq*B(1)/B(round(end-j/ratio)),pq,AL*B(1)/B(round(end-j/ratio)));
        options=optimoptions('fsolve','TolFun',1e-20,'TolX',1e-20,'display','none','MaxFunEvals',1000);
        [X_s,~,~,~]=fsolve(Fw,eta_new,options);
        eta_new = X_s(1);
    end
%}