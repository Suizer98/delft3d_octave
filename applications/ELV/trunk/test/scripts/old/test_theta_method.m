clear
clc
close all

%% INPUT

dx=0.01;
dt=0.01;    
nx=1001; 
theta=0.5; 
kappa=0.01;

nt=10000;

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

input.grd.dx=dx;
input.mdv.dt=dt;    
input.mdv.nx=nx; 
input.mdv.theta=theta; 
input.mor.kappa=kappa;

h=0.20*ones(1,nx)';
u=0.7*ones(1,nx)'; %0.7
cf_b=0.008*ones(1,nx)'; %bed
cf_f=0.01*ones(1,nx)'; %flow
dk=0.005;
La=0.01*ones(1,nx)'; 

s=(u.*h).^2.*cf_f./cnt.g./h.^3;

Gammak=10; %dummy

Fak=1*ones(1,input.mdv.nx)';
Mak=Fak.*La;
Fr=u./sqrt(cnt.g.*h);
Sf=cf_f.*Fr.^2;

[qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq]=sediment_transport_full(flg,cnt,h,u.*h,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);
dh=1e-6;
[~,~,~,~,~,~,~,~,~,~,~,~,~,~,vpk_hdh,~,~]=sediment_transport_full(flg,cnt,h+dh,u.*h,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);

dvpk_dh=(vpk_hdh-vpk)./dh;
kf=1;

S1=Mak*Ek_g(end);
S2=dvpk_dh(kf)./(1-Fr.^2).*(-s+Sf)-Dk_g(kf);

% S1=1e-7*ones(nx,1);
% S2=1e-7*ones(nx,1);

alpha=vpk'*dt/2/dx;
beta=kappa*dt/dx^2*ones(1,nx);
gamma=dt*S1';
delta=dt*S2';

%initial condition
Gammak_old=Gammak_eq(1)*0.9*ones(1,nx);
Gammak_old(1)=Gammak_eq(1)*0.8;

%% CALL
Gammak_all=NaN(nt,input.mdv.nx);
Gammak_all(1,:)=Gammak_old;
C_at1=NaN(nt,nx);
C_at2=NaN(nt,nx);

%analytical constants
x=0:dx:(nx-1)*dx;
v=vpk(1);
mua=-S2(1);
gammaa=S1(1);
ua=v*sqrt(1+4*mua*kappa/v^2);
C1=Gammak_old(2); 
C0=Gammak_old(1);

for kt=2:nt
    
    %NUMERICAL
    Gammak_new=theta_method(Gammak_old,alpha,beta,gamma,delta,input);
    Gammak_all(kt,:)=Gammak_new;
    Gammak_old=Gammak_new;
    
    %ANALYTICAL
    t=kt*dt;
    sig2=2*sqrt(kappa*t);
    %no source term
    A1=0.5*erfc((x-v*t)/sig2)+0.5*exp(v*x/kappa).*erfc((x+v*t)/sig2);
    C_a1=C1+(C0-C1)*A1;
    %source term
    A2=exp(-mua*t)*(1-0.5*erfc((x-v*t)/sig2)-0.5*exp(v*x/kappa).*erfc((x+v*t)/sig2));
    B2=0.5*exp((v-ua)*x/2/kappa).*erfc((x-ua*t)/sig2)+0.5*exp((v+ua)*x/2/kappa).*erfc((x+ua*t)/sig2);
    C_a2=gammaa/mua+(C1-gammaa/mua)*A2+(C0-gammaa/mua)*B2;
    
    C_at1(kt,:)=C_a1;
    C_at2(kt,:)=C_a2;
end

%% PLOT

if 0
dp=100;

figure
subaxis(1,2,1)
plot((0:input.grd.dx:(input.mdv.nx-1)*input.grd.dx)',Gammak_all(1:dp:end,:)')
set(gca,'ColorOrderIndex',1); %reset color index
ylim([1.5,4]*1e-6)
% ylim([0,10]*1e-3)
title('numerical')
subaxis(1,2,2)
plot((0:input.grd.dx:(input.mdv.nx-1)*input.grd.dx)',g_a(1:dp:end,:)')
set(gca,'ColorOrderIndex',1); %reset color index
title('analytical')
ylim([1.5,4]*1e-6)
end

%% numerical - analytical

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

%% analytical no source - analytical source

if 0
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

