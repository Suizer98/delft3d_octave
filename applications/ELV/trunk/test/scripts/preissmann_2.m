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
%$Id: preissmann_2.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/test/scripts/preissmann_2.m $
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

function [U,H] = preissmann_2(u,h,etab,Cf,Hdown,qwup,input,~,~)

%% Rename
nx = input.mdv.nx;
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
    d_v=[ones(nx,1),[0;ones(nx-1,1)]];
    A1=(1/(2*dt))*spdiags(d_v,[0;1],nx,nx);
    d_v=[-ones(nx,1),[0;ones(nx-1,1)]];
    A2=(theta/dx)*spdiags(d_v,[0;1],nx,nx);
    Atop = [A1,A2];
    
    Btop_1 = (1/(2*dt))*(H_old(2:nx)+H_old(1:nx-1)) ... %dh/dt
            - (1-theta)/dx*(q_old(2:nx)-q_old(1:nx-1)); % dq/dx, size K-1

    % Adjust last equation for downstream boundary condition;
    Atop(end,:) = zeros(1,2*nx);
    Atop(end,nx) = 1;
    Btop = [Btop_1; Hdown];

    %----------------------------------------------------------------%
    % Create momentum part of the matrix (K*2K)
    dedx_1 = (etab(2:nx)-etab(1:nx-1))/dx;
    dedx = [dedx_1; 0]; % dummy value; is erased later
    
    d_v=[-1/2*g*theta/dx.*H_k+g/2*theta*dedx,[0;1/2*g*theta/dx.*H_k(2:end)+g/2*theta.*dedx(1:nx-1)]];
    A3=spdiags(d_v,[0;1],nx,nx);

    switch input.mdv.flowtype
        case 2
            d_v=[c_f.*q_k./H_k.^2,[0;c_f(2:nx).*q_k(2:nx)./H_k(2:nx).^2]];
            A4=1/2*theta*spdiags(d_v,[0;1],nx,nx);
            
            Bdown_1 = - 1/2*g*(1-theta)/dx*(H_old(2:nx).^2-H_old(1:nx-1).^2) ... %dh/dx
                - g/2 * (1-theta)*(dedx(1:nx-1).*H_old(2:nx) + dedx(1:nx-1).*H_old(1:nx-1)) ... %dz/dx
                - 1/2 * (1-theta)*(c_f(2:nx).*q_old(2:nx).^2./H_old(2:nx).^2 + c_f(1:nx-1).*q_old(1:nx-1).^2./H_old(1:nx-1).^2); %friction
            
            d_v=[g*theta/dx*-H_k+g/2*theta*dedx-theta*c_f.*q_k.^2./H_k.^3,[0;g*theta/dx*H_k(2:end)+g/2*theta*dedx(1:nx-1)-theta*c_f(2:nx).*q_k(2:nx).^2./H_k(2:nx).^3]];
            dA3=spdiags(d_v,[0;1],nx,nx);
            
            d_v=[c_f.*q_k./H_k.^2,[0;c_f(2:nx).*q_k(2:nx)./H_k(2:nx).^2]];
            dA4=theta*spdiags(d_v,[0;1],nx,nx);
            
        case 4
            d_v=[(1/(2*dt))*ones(nx,1)+theta/dx*-q_k(1:nx)./H_k(1:nx)+1/2*theta*c_f.*q_k./H_k.^2,[0;(1/(2*dt))*ones(nx-1,1)+theta/dx*q_k(2:nx)./H_k(2:nx)+1/2*theta*c_f(2:nx).*q_k(2:nx)./H_k(2:nx).^2]];
            A4=spdiags(d_v,[0;1],nx,nx);
                
            Bdown_1 = (1/(2*dt))*(q_old(2:nx)+q_old(1:nx-1)) ...    %dq/dt
                - 1/2*g*(1-theta)/dx*(H_old(2:nx).^2-H_old(1:nx-1).^2) ... %dh/dx
                - g/2 * (1-theta)*(dedx(1:nx-1).*H_old(2:nx) + dedx(1:nx-1).*H_old(1:nx-1)) ... %dz/dx
                - (1-theta)/dx*(q_old(2:nx).^2./H_old(2:nx)-q_old(1:nx-1).^2./H_old(1:nx-1)) ... % dqu/dx
                - 1/2 * (1-theta)*(c_f(2:nx).*q_old(2:nx).^2./H_old(2:nx).^2 + c_f(1:nx-1).*q_old(1:nx-1).^2./H_old(1:nx-1).^2); %friction
            
            d_v=[g*theta/dx*-H_k+g/2*theta*dedx+theta/dx*q_k(1:nx).^2./H_k(1:nx).^2-theta*c_f.*q_k.^2./H_k.^3,[0;g*theta/dx*H_k(2:end)+g/2*theta*dedx(1:nx-1)+theta/dx*-q_k(2:nx).^2./H_k(2:nx).^2-theta*c_f(2:nx).*q_k(2:nx).^2./H_k(2:nx).^3]];
            dA3=spdiags(d_v,[0;1],nx,nx);
            
            d_v=[(1/(2*dt))*ones(nx,1)+2*theta/dx*-q_k(1:nx)./H_k(1:nx)+theta*c_f.*q_k./H_k.^2,[0;(1/(2*dt))*ones(nx-1,1)+2*theta/dx*q_k(2:nx)./H_k(2:nx)+theta*c_f(2:nx).*q_k(2:nx)./H_k(2:nx).^2]];
            dA4=spdiags(d_v,[0;1],nx,nx);

    end

    Adown = [A3,A4];

    % Adjust last equation for upstream boundary condition;
    Adown(end,:) = zeros(1,2*nx);
    Adown(end,nx+1) = 1;
    Bdown = [Bdown_1; qwup];

    % We now have a system Ax = b; which is linearized;
    % So f = Ax-b = 0;
    
    dA1 = A1;
    dA2 = A2;

    dAtop = [dA1,dA2];
    dAtop(end,:) = zeros(1,2*nx);
    dAtop(end,nx) = 1;

    dAdown = [dA3,dA4];
    dAdown(end,:) = zeros(1,2*nx);
    dAdown(end,nx+1) = 1;

    A = [Atop; Adown];
    B = [Btop; Bdown];
    Jac = [dAtop; dAdown];
    
    x = x_k - mldivide(Jac,(A*x_k-B));
    res = max(abs(A*x_k-B));
    x_k = x;
    H_k = x(1:nx);
    q_k = x(nx+1:end);

    if j>100
        warning('More than 100 Newton-Raphson iterations are required')
        fprintf('residual = %f \n',res);
    end

    if j>5000
        error('No convergence in flow solver, >5000 iterations');
    end
end
U = x(nx+1:end)./x(1:nx);
H = x(1:nx);


end