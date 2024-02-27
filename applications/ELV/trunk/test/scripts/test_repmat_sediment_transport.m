
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

q=80/0.4/1000*ones(nx,1);
cf_b=0.01*ones(nx,1);
h=0.185*ones(nx,1);
Fak=repmat(1/nf*ones(1,nf-1),nx,1);
La=ones(nx,1);
Mak=Fak.*repmat(La,1,nf-1);
dk=linspace(0.001,0.01,nf);
mor_fac=1;
hiding_param=-0.8;

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

qbk_1=sediment_transport_1(flg,cnt,h,q,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac);
qbk_2=sediment_transport_2(flg,cnt,h,q,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac);

%% check

if abs(max(max(qbk_1-qbk_2)))>1e-16; error('...'); end

end

%% TEST TIME

%% input

flg.sed_trans=3;
flg.friction_closure=1;
flg.hiding=3;
flg.Dm=1;

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

tic_1=tic;
for ki=1:ni
    qbk_1=sediment_transport_1(flg,cnt,h,q,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac);
end
t1=toc(tic_1);

tic_2=tic;
for ki=1:ni
    qbk_2=sediment_transport_2(flg,cnt,h,q,cf_b,La,Mak,dk,sed_trans_param,hiding_param,mor_fac);
end
t2=toc(tic_2);

%% disp

fprintf('without repmat we gain %4.1f %% time \n',-(t2-t1)/t1*100)