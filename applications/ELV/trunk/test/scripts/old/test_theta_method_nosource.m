clear
clc
close all

%% INPUT

input.grd.dx=0.001;
input.mdv.dt=0.0001;    
input.mdv.nx=1001; 
input.mdv.theta=0.5; 
input.mor.kappa=0.01;

nt=1000;

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

h=0.20*ones(1,input.mdv.nx)';
u=0.7*ones(1,input.mdv.nx)'; %0.7
cf_b=0.008*ones(1,input.mdv.nx)'; %bed
cf_f=0.01*ones(1,input.mdv.nx)'; %flow
dk=0.005;
La=0.01*ones(1,input.mdv.nx)'; 

etab=(u./h).^2.*cf_f./cnt.g./h.^3;


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

% S1=Mak*Ek_g(end);
% S2=dvpk_dh(kf)./(1-Fr.^2).*(-etab+Sf)-Dk_g(kf);
S1=zeros(input.mdv.nx,1);
S2=zeros(input.mdv.nx,1);

alpha=vpk'*input.mdv.dt/2/input.grd.dx;
beta=input.mor.kappa*input.mdv.dt/input.grd.dx^2*ones(1,input.mdv.nx);
gamma=input.mdv.dt*S1';
delta=input.mdv.dt*S2';

% Gammak_old=linspace(Gammak_eq(1)*0.9,Gammak_eq(end),input.mdv.nx);
Gammak_old=Gammak_eq';
na=1; %numer of nodes of the addition
ma=10; %multiplication factor of the addition
Gammak_old(round(input.mdv.nx/2-na):round(input.mdv.nx/2+na))=Gammak_old(1)*ma;

%% CALL
Gammak_all=NaN(nt,input.mdv.nx);
Gammak_all(1,:)=Gammak_old;
g_a=NaN(nt,input.mdv.nx);

x=-(input.mdv.nx)/2*input.grd.dx:input.grd.dx:(input.mdv.nx-1)/2*input.grd.dx;

for kt=2:nt
    Gammak_new=theta_method(Gammak_old,alpha,beta,gamma,delta,input);
    Gammak_all(kt,:)=Gammak_new;
    Gammak_old=Gammak_new;
    
    %anl
    sig=sqrt(2*input.mor.kappa*kt*input.mdv.dt);
    g_a(kt,:)=Gammak_eq(1)+numel(round(input.mdv.nx/2-na):round(input.mdv.nx/2+na))*input.grd.dx*Gammak_old(1)*ma/sqrt(2*3.1415926)/sig*exp(-(x-vpk(1)*kt*input.mdv.dt).^2/2/sig^2);
end

%% PLOT

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
