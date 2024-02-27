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
%$Id: preissmann_1.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/test/scripts/preissmann_1.m $
%
%preissmann is the Preismmann scheme for unsteady flow update Implict scheme
%
%[U,H] = preissmann(u,h,etab,Cf,Hdown,qwup,input,fid_log,kt)
%
%INPUT:
%   -input = input structure
%
%OUTPUT:
%   -
%
%HISTORY:
%160513
%   -L. Created for the first time

function [U,H] = preissmann(u,h,etab,Cf,Hdown,qwup,input,fid_log,kt)
% version = '1';
% if kt==1; fprintf(fid_log,'flow_update version: %s\n',version); end 


%% Rename
K = input.mdv.nx;
g = input.mdv.g;
dx = input.grd.dx;
dt = input.mdv.dt;
c_f=Cf'; %warning('!constant or vector');


q_old = u'.*h';
H_old = h';
q_k = q_old;
H_k = H_old;
x_k = [H_k;q_k];
etab = etab';

switch input.mdv.flowtype
    case 2
        theta = 1;
    case 4
        theta = 0.5; % Perhaps make a parameter out of it later?
end


%% Loop
tol = 1e-12;
res = inf;
j=0;

while res > tol
    j=j+1;
    % Let Q = [H,q] where we have a Kx2 array
    %---------------------------------------------------------------%
    % Create continuity part of the matrix (K*2K) [A1,A2;A3,A4]; (internal)
    A1 = (1/(2*dt))*(diag(ones(K,1),0)+diag(ones(K-1,1),1)); % dh/dt
    A2 = (theta/dx)*(diag(-ones(K,1),0)+diag(ones(K-1,1),1)); % dq/dx
    Atop = [A1,A2];

    Btop = (1/(2*dt))*(H_old(2:K)+H_old(1:K-1)) ... %dh/dt
            - (1-theta)/dx*(q_old(2:K)-q_old(1:K-1)); % dq/dx, size K-1

    % Adjust last equation for downstream boundary condition;
    Atop(end,:) = zeros(1,2*K);
    Atop(end,K) = 1;
    Btop = [Btop; Hdown];

    %----------------------------------------------------------------%
    % Create momentum part of the matrix (K*2K)
    dedx = (etab(2:K)-etab(1:K-1))/dx;
    dedx = [dedx; 0]; % dummy value; is erased later
      
    A3 = 1/2*g*theta/dx*(diag(-H_k,0) +diag(H_k(2:end),1)) ... %dh/dx
        + g/2 * theta*(diag(dedx,0) + diag(dedx(1:K-1),1)); %dz/dx;
    
    switch input.mdv.flowtype
        case 2
            A4 = 1/2 * theta*(diag(c_f.*q_k./H_k.^2,0) + diag(c_f(2:K).*q_k(2:K)./H_k(2:K).^2,1)); %friction
            
            Bdown = - 1/2*g*(1-theta)/dx*(H_old(2:K).^2-H_old(1:K-1).^2) ... %dh/dx
                - g/2 * (1-theta)*(dedx(1:K-1).*H_old(2:K) + dedx(1:K-1).*H_old(1:K-1)) ... %dz/dx
                - 1/2 * (1-theta)*(c_f(2:K).*q_old(2:K).^2./H_old(2:K).^2 + c_f(1:K-1).*q_old(1:K-1).^2./H_old(1:K-1).^2); %friction
            
            dA3 = g*theta/dx*(diag(-H_k,0) +diag(H_k(2:end),1)) ... %dh/dx
                + g/2 * theta*(diag(dedx,0) + diag(dedx(1:K-1),1)) ... %dz/dz
                - theta*(diag(c_f.*q_k.^2./H_k.^3,0) + diag(c_f(2:K).*q_k(2:K).^2./H_k(2:K).^3,1)); %friction
            
            dA4 = theta*(diag(c_f.*q_k./H_k.^2,0) + diag(c_f(2:K).*q_k(2:K)./H_k(2:K).^2,1)); %friction
            
        case 4
            A4 = (1/(2*dt))*(diag(ones(K,1),0) + diag(ones(K-1,1),1)) ... %dq/dt
                + theta/dx*(diag(-q_k(1:K)./H_k(1:K),0) + diag(q_k(2:K)./H_k(2:K),1)) ...    %dqu/dx
                + 1/2 * theta*(diag(c_f.*q_k./H_k.^2,0) + diag(c_f(2:K).*q_k(2:K)./H_k(2:K).^2,1)); %friction
    
            Bdown = (1/(2*dt))*(q_old(2:K)+q_old(1:K-1)) ...    %dq/dt
                - 1/2*g*(1-theta)/dx*(H_old(2:K).^2-H_old(1:K-1).^2) ... %dh/dx
                - g/2 * (1-theta)*(dedx(1:K-1).*H_old(2:K) + dedx(1:K-1).*H_old(1:K-1)) ... %dz/dx
                - (1-theta)/dx*(q_old(2:K).^2./H_old(2:K)-q_old(1:K-1).^2./H_old(1:K-1)) ... % dqu/dx
                - 1/2 * (1-theta)*(c_f(2:K).*q_old(2:K).^2./H_old(2:K).^2 + c_f(1:K-1).*q_old(1:K-1).^2./H_old(1:K-1).^2); %friction
            
            dA3 = g*theta/dx*(diag(-H_k,0) +diag(H_k(2:end),1)) ... %dh/dx
                + g/2 * theta*(diag(dedx,0) + diag(dedx(1:K-1),1)) ... %dz/dz
                + theta/dx*(diag(q_k(1:K).^2./H_k(1:K).^2,0) + diag(-q_k(2:K).^2./H_k(2:K).^2,1)) ... %dqu/dx afgeleid naar h
                - theta*(diag(c_f.*q_k.^2./H_k.^3,0) + diag(c_f(2:K).*q_k(2:K).^2./H_k(2:K).^3,1)); %friction
            dA4 = (1/(2*dt))*(diag(ones(K,1),0) + diag(ones(K-1,1),1)) ...
                + 2*theta/dx*(diag(-q_k(1:K)./H_k(1:K),0) + diag(q_k(2:K)./H_k(2:K),1)) ... %dqu/dx afgeleid naar q
                + theta*(diag(c_f.*q_k./H_k.^2,0) + diag(c_f(2:K).*q_k(2:K)./H_k(2:K).^2,1)); %friction

    end

    Adown = [A3,A4];

    % Adjust last equation for upstream boundary condition;
    Adown(end,:) = zeros(1,2*K);
    Adown(end,K+1) = 1;
    Bdown = [Bdown; qwup];

    % We now have a system Ax = b; which is linearized;
    % So f = Ax-b = 0;
    %         
    dA1 = A1;
    dA2 = A2;

    dAtop = [dA1,dA2];
    dAtop(end,:) = zeros(1,2*K);
    dAtop(end,K) = 1;

    dAdown = [dA3,dA4];
    dAdown(end,:) = zeros(1,2*K);
    dAdown(end,K+1) = 1;

    A = [Atop; Adown];
    B = [Btop; Bdown];
    Jac = [dAtop; dAdown];
    
    A = sparse(A);
    Jac = sparse(Jac);
    
    x = x_k - mldivide(Jac,(A*x_k-B));
    res = max(abs(A*x_k-B));
    x_k = x;
    H_k = x(1:K);
    q_k = x(K+1:end);

    if j>100
        warning('More than 100 Newton-Raphson iterations are required')
        res
    end

    if j>5000
        error('No convergence in flow solver, >5000 iterations');
    end
end
U = x(K+1:end)./x(1:K);
H = x(1:K);


end