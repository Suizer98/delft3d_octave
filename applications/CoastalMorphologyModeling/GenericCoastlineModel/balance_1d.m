function [E,Hrms,Er,Qb,Dw,Dr,eta,h,k,C,Cg,dir,Fx,Fy]= ...
    balance_1d(Hrms0,dir0,eta0,Tp,x,zb,gamma,beta,hmin)
%BALANCE_1D Solve 1D wave energy, roller energy and cross-shore momentum
% balance , yielding cross-shore distribution of wave height and energym,
% roller energy, water level and longshore component of radiation stress
% gradient.
rho=1025;g=9.81;eps=1e-6;
%% Initialise arrays
eta=zeros(size(x));
E=zeros(size(x));
Hrms=zeros(size(x));
Er=zeros(size(x));
Qb=zeros(size(x));
Dw=zeros(size(x));
Dr=zeros(size(x));
eta=zeros(size(x));
h=zeros(size(x));
k=zeros(size(x));
C=zeros(size(x));
Cg=zeros(size(x));
dir=zeros(size(x));
Fx=zeros(size(x));
Fy=zeros(size(x));
%% Set boundary conditions
E(1)=1/8*rho*g*Hrms0^2;
Hrms(1)=Hrms0;
Er(1)=0;
h(1)=eta(1)-zb(1);
i=1;
[k(i),omega,C(i),Cg(i),n(i),Dw(i),Qb(i),Dr(i),dir(i)]= ...
    waveparams(h(i),Tp,E(i),gamma,beta,Er(i),dir0);
nx=length(x);
%% Start loop in x-direction
for i=2:nx
    % First estimate of eta(i+1),E(i+1),Er(i+1)
    eta(i)=eta(i-1);
    E(i)=E(i-1);
    Er(i)=Er(i-1);
    dx=x(i)-x(i-1);
    %% Two-step integration scheme
    for step=1:2;
        h(i)=eta(i)-zb(i);
        %% Check if h>hmin; otherwise leave parameters zero
        if h(i)>hmin
            %% Local functions
            [k(i),omega,C(i),Cg(i),n(i),Dw(i),Qb(i),Dr(i),dir(i)]= ...
                waveparams(h(i),Tp,E(i),gamma,beta,Er(i),dir0);
            %% Wave energy
            E(i)=(E(i-1)*Cg(i-1)*cos(dir(i-1))-.5*(Dw(i-1)+Dw(i))*dx)...
                /(Cg(i)*cos(dir(i)));
            %E(i)=min(E(i),1/8*rho*g*h(i)^2);
            E(i)=max(E(i),eps);
            %% Roller energy
            Er(i)=(Er(i-1)*C(i-1)*cos(dir(i-1))...
                +.5*(Dw(i-1)+Dw(i)-Dr(i-1)-Dr(i))*dx)...
                /(C(i)*cos(dir(i)));
            Er(i)=max(Er(i),eps);
            %% Wave force in x-direction
            Fx(i)=-(   (n(i  )*(cos(dir(i  )))^2+n(i  )-.5)*E(i  )...
                - (n(i-1)*(cos(dir(i-1)))^2+n(i-1)-.5)*E(i-1)...
                + (cos(dir(i  )))^2*Er(i  )...
                - (cos(dir(i-1)))^2*Er(i-1)   )/dx;
            eta(i)=eta(i-1)+2*Fx(i)/rho/g/(h(i-1)+h(i))*dx;
            %% Wave force in x-direction
            Fy(i)=Dr(i)*sin(dir(i))/C(i);
            Hrms(i)=sqrt(8*E(i)/rho/g);
        end
    end
end