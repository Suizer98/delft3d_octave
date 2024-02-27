clear 
clc
close all

dbstop if error

%% INPUT

dx=0.01;
dt=0.01;    
nx=1001; 
theta=0.5; 
kappa=0.1;

pa_u=3; %1=dirichlet; 3=robin;
pa_d=1; %1=dirichlet; 3=robin;

nt=5000;

flg.sed_trans=1;
flg.friction_closure=1;
flg.hiding=0;
flg.Dm=1;
flg.vp=1;
flg.E=1;
cnt.g=9.81;
cnt.rho_s=2650;
cnt.rho_w=1000;
cnt.p=0.0;
cnt.R=1.65;

sed_trans_param=[5.7,1.5,0.047]; %FLvB
E_param=[0.0199,1.5]; %FLvB
vp_param=[11.5,0.7]; %FLvB

%
hiding_param=NaN;
mor_fac=1;

%%

input.bcm.pa_u=pa_u;
input.bcm.pa_d=pa_d;
input.grd.dx=dx;
input.mdv.dt=dt;    
input.mdv.nx=nx; 
input.mdv.theta=theta; 
input.mor.kappa=kappa;

h_u=0.20*ones(1,nx)';
u=0.7*ones(1,nx)'; %0.7
cf_b=0.008*ones(1,nx)'; %bed
cf_f=0.01*ones(1,nx)'; %flow
dk=0.005;
La=0.01*ones(1,nx)'; 

s=(u.*h_u).^2.*cf_f./cnt.g./h_u.^3;

Gammak=10; %dummy

Fak=1*ones(1,nx)';
Mak=Fak.*La;
Fr=u./sqrt(cnt.g.*h_u);
Sf=cf_f.*Fr.^2;

[qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq]=sediment_transport_full(flg,cnt,h_u,u.*h_u,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);
dh=1e-6;
[~,~,~,~,~,~,~,~,~,~,~,~,~,~,vpk_hdh,~,~]=sediment_transport_full(flg,cnt,h_u+dh,u.*h_u,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);

dvpk_dh=(vpk_hdh-vpk)./dh;
kf=1;

S1=Mak'.*Ek_g';
S2=dvpk_dh(kf)./(1-Fr'.^2).*(-s'+Sf')-Dk_g';

% S1=1e-10*ones(1,nx);
% S2=-1e-12*ones(1,nx);

% S1=zeros(1,nx);
% S2=zeros(1,nx);

%initial condition
C1=Gammak_eq(1)*0.9;
Gammak_old=C1*ones(1,nx);

%boundary condition
    %upstream
C0=Gammak_eq(1)*0.8;
switch input.bcm.pa_u
    case 1
        Gammak_old(1)=C0;
        g_u=NaN(1,2);
        h_u=NaN(1,2);
    case 3
        g_u=[-vpk(1)*C0,-vpk(1)*C0];
        h_u=[vpk(1),vpk(1)];
    otherwise
        error('shit!')        
end
    %downstream
switch input.bcm.pa_d
    case 1
%         Gammak_old(end)=C1;
        Gammak_old(end)=Gammak_eq(1);
        g_d=NaN(1,2);
        h_d=NaN(1,2);
    otherwise
        error('shit!')        
end

%% CALL
Gammak_all=NaN(nt,input.mdv.nx);
Gammak_all(1,:)=Gammak_old;
C_at1=NaN(nt,nx);
C_at2=NaN(nt,nx);

%analytical constants
x=0:dx:(nx-1)*dx;
v=vpk(1);
mu=-S2(1);
gamma=S1(1);
ua=v*sqrt(1+4*mu*kappa/v^2);

for kt=2:nt
    
    %NUMERICAL
    Gammak_new=theta_method(Gammak_old,vpk',kappa,S1,S2,g_u,h_u,g_d,h_d,input);
    Gammak_all(kt,:)=Gammak_new;
    Gammak_old=Gammak_new;
    
    %ANALYTICAL
    t=kt*dt;
    sig2=2*sqrt(kappa*t);
    switch input.bcm.pa_u
        case 1
            %no source term
            A1=0.5*erfc((x-v*t)/sig2)+0.5*exp(v*x/kappa).*erfc((x+v*t)/sig2);
            C_a1=C1+(C0-C1)*A1;
            %source term
            if mu~=0 && gamma~=0
            A2=exp(-mu*t)*(1-0.5*erfc((x-v*t)/sig2)-0.5*exp(v*x/kappa).*erfc((x+v*t)/sig2));
            B2=0.5*exp((v-ua)*x/2/kappa).*erfc((x-ua*t)/sig2)+0.5*exp((v+ua)*x/2/kappa).*erfc((x+ua*t)/sig2);
            C_a2=gamma/mu+(C1-gamma/mu)*A2+(C0-gamma/mu)*B2;
            else
            C_a2=NaN(1,nx);
            end
        case 3
            %no source term
            A1=0.5*erfc((x-v*t)/sig2)+sqrt(v^2*t/pi/kappa)*exp(-(x-v*t).^2/4/kappa/t)-0.5*(1+v*x/kappa+v^2*t/kappa).*exp(v*x/kappa).*erfc((x+v*t)/sig2);
            C_a1=C1+(C0-C1)*A1;
            %source term
            if mu~=0 && gamma~=0
            A2=exp(-mu*t)*(1-0.5*erfc((x-v*t)/sig2)-sqrt(v^2*t/pi/kappa)*exp(-(x-v*t).^2/4/kappa/t)+0.5*(1+v*x/kappa+v^2*t/kappa).*exp(v*x/kappa).*erfc((x+v*t)/sig2));
            B2=v/(v+ua)*exp((v-ua)*x/2/kappa).*erfc((x-ua*t)/sig2)+v/(v-ua)*exp((v+ua)*x/2/kappa).*erfc((x+ua*t)/sig2)+v^2/2/mu/kappa*exp(v*x/kappa-mu*t).*erfc((x+v*t)/sig2);
            C_a2=gamma/mu+(C1-gamma/mu)*A2+(C0-gamma/mu)*B2;
            else
            C_a2=NaN(1,nx);
            end
    end
    C_at1(kt,:)=C_a1;
    C_at2(kt,:)=C_a2;
end

%% PLOT

%% numerical - analytical

if 1
dp=100;

figure
subaxis(1,2,1)
plot(x,Gammak_all(1:dp:end,:)')
set(gca,'ColorOrderIndex',1); %reset color index
% ylim([1.5,4]*1e-6)
title('numerical')
subaxis(1,2,2)
plot(x,C_at2(1:dp:end,:)')
set(gca,'ColorOrderIndex',1); %reset color index
title('analytical')
% ylim([1.5,4]*1e-6)
end

%% analytical no source - analytical source

if 1
dp=100;

figure
subaxis(1,2,1)
plot(x,C_at1(1:dp:end,:)')
set(gca,'ColorOrderIndex',1); %reset color index
% ylim([1.5,4]*1e-6)
title('analytical no source')
subaxis(1,2,2)
plot(x,C_at2(1:dp:end,:)')
set(gca,'ColorOrderIndex',1); %reset color index
title('analytical source')
% ylim([1.5,4]*1e-6)
end

