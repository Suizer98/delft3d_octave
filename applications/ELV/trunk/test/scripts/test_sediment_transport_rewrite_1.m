
clear all
clc

%% INPUT 

%% test

ni=1000;
nx=100;
nf=5;

%% CHECK IMPLEMENTATION

sed_trans_i=1:5;
hiding_i=0:3;
dm_i=1:2;

input_m=combvec(sed_trans_i,hiding_i,dm_i)';

nc=size(input_m,1);

%% loop

cnt.g=9.81;
cnt.rho_s=2650;
cnt.rho_w=1000;
cnt.p=0.0;
cnt.R=1.65;

flg.vp=1;
flg.E=1;
flg.mu=0;
flg.particle_activity=0;

E_param=[0.0199,1.5]; %FLvB
vp_param=[11.5,0.7]; %FLvB

q=80/0.4/1000*ones(nx,1);
cf_b=0.01*ones(nx,1);
% h=0.185*ones(nx,1);
h=linspace(0.05,0.5,nx)';
Fak=repmat(1/nf*ones(1,nf-1),nx,1);
La=ones(nx,1);
Mak=Fak.*repmat(La,1,nf-1);
dk=linspace(0.001,0.01,nf);
mor_fac=1;
hiding_param=-0.8;
Gammak=repmat(1e-3*ones(1,nf),nx,1);

for kc=1:nc
    
flg.sed_trans=input_m(kc,1);
flg.friction_closure=1;
flg.hiding=input_m(kc,2);
flg.Dm=input_m(kc,3);

switch flg.sed_trans
    case 1
        sed_trans_param=[8,1.5,0.047]; %MPM
    case 2
        sed_trans_param=[0.05,5]; %EH
    case 3
        sed_trans_param=[17,0.05]; %AM
    case 5
        sed_trans_param=[0.5,0.8,0.02]; %AM
end

%% call

% flg.E=1;
[qbk_1,Qbk_1,thetak_1,qbk_st_1,Wk_st_1,u_st_1,xik_1,Qbk_st_1,Ek_1,Ek_st_1,Ek_g_1,Dk_1,Dk_st_1,Dk_g_1,vpk_1,vpk_st_1,Gammak_eq_1,Dm_1]=sediment_transport_3(flg,cnt,h,q,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);;
% flg.E=0;
[qbk_2,Qbk_2,thetak_2,qbk_st_2,Wk_st_2,u_st_2,xik_2,Qbk_st_2,Ek_2,Ek_st_2,Ek_g_2,Dk_2,Dk_st_2,Dk_g_2,vpk_2,vpk_st_2,Gammak_eq_2,Dm_2]=sediment_transport_4(flg,cnt,h,q,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);

%% check

if abs(max(max(qbk_1-qbk_2)))>1e-16; error('...'); end
if abs(max(max(Qbk_1-Qbk_2)))>1e-12; error('...'); end
if abs(max(max(thetak_1-thetak_2)))>1e-16; error('...'); end
if abs(max(max(qbk_st_1-qbk_st_2)))>1e-12; error('...'); end
if abs(max(max(Wk_st_1-Wk_st_2)))>1e-12; error('...'); end
if abs(max(max(u_st_1-u_st_2)))>1e-16; error('...'); end
if abs(max(max(xik_1-xik_2)))>1e-16; error('...'); end
if abs(max(max(Qbk_st_1-Qbk_st_2)))>1e-12; error('...'); end
if abs(max(max(Ek_st_1-Ek_st_2)))>1e-16; error('...'); end
if abs(max(max(Ek_g_1-Ek_g_2)))>1e-16; error('...'); end
if abs(max(max(Dk_st_1-Dk_st_2)))>1e-12; error('...'); end
if abs(max(max(Dk_g_1-Dk_g_2)))>1e-10; error('...'); end
if abs(max(max(vpk_1-vpk_2)))>1e-16; error('...'); end
if abs(max(max(vpk_st_1-vpk_st_2)))>1e-16; error('...'); end
if abs(max(max(Gammak_eq_1-Gammak_eq_2)))>1e-16; error('...'); end
if abs(max(max(Dm_1-Dm_2)))>1e-16; error('...'); end
end

%% TEST TIME

%% input

flg.sed_trans=3;
flg.friction_closure=1;
flg.hiding=3;
flg.Dm=1;
flg.E=1;

cnt.g=9.81;
cnt.rho_s=2650;
cnt.rho_w=1000;
cnt.p=0.0;
cnt.R=1.65;

q=80/0.4/1000*ones(nx,1);
cf_b=0.01*ones(nx,1);
h=0.185*ones(nx,1);
Fak=repmat(1/nf*ones(1,nf-1),nx,1);
La=ones(nx,1);
Mak=Fak.*repmat(La,1,nf-1);
dk=linspace(0.001,0.01,nf);

sed_trans_param=[17,0.05]; %AM

hiding_param=NaN;
mor_fac=1;

%% call

% flg.E=1;
tic_1=tic;
for ki=1:ni
    qbk_1=sediment_transport_3(flg,cnt,h,q,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);
end
t1=toc(tic_1);

% flg.E=0;
tic_2=tic;
for ki=1:ni
    qbk_2=sediment_transport_4(flg,cnt,h,q,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);
end
t2=toc(tic_2);

%% disp

fprintf('after rewriting we gain %4.1f %% time \n',-(t2-t1)/t1*100)


