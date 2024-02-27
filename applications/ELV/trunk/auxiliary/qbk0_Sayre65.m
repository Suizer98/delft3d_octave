
function [qbk,vpk]=qbk0_Sayre65(input)

%%
%% RENAME
%%
   
flg.sed_trans=input.tra.cr;
flg.friction_closure=1;
flg.hiding=input.tra.hid;
flg.Dm=input.tra.Dm;
flg.vp=input.tra.vp_cr;
flg.E=input.tra.E_cr;
flg.mu=input.tra.mu;
flg.particle_activity=0;
flg.extra=1;

cnt.g=input.mdv.g;
cnt.rho_s=input.sed.rhos;
cnt.rho_w=input.mdv.rhow;
cnt.p=0.0;
cnt.R=(cnt.rho_s-cnt.rho_w)/cnt.rho_w;

sed_trans_param=input.tra.param;
vp_param=input.tra.vp_param;
E_param=input.tra.E_param;
dk=input.sed.dk;
if isfield(input.tra,'hiding_b')
    hiding_param=input.tra.hiding_b;
else
    hiding_param=NaN;
end

s=input.ini.slopeb;
q=input.bch.Q0(1);
cf_b=input.frc.Cfb;
cf_f=input.frc.Cf;

Fak=input.ini.Fak(:,1);
% Fak=[Fak_aux;1-sum(Fak_aux)];

h=(cf_f*q^2/cnt.g/s)^(1/3);
u=q/h;

%Sayre65
% u=0.6910;
% h=0.6256;
% cf_b=0.0049;
% cf_f=0.0107;

% dk=[0.000104880884817015;0.000147901994577490;0.000209165006633519;0.000209165006633519;0.000295803989154981;0.000295803989154981;0.000418330013267038;0.000418330013267038;0.000591607978309962;0.000836660026534076;0.00128491244837927;0.00234368875919991;0.00559943282842111]';

%tracer
% Fak=[0.0200000000000000;0.0400000000000000;0.229684316344881;0.000315683655119070;0.387474530759048;0.00252546924095256;0.229333556728082;0.000666443271918037;0.0499999999999999;0.0100000000000000;0.0100000000000000;0.0100000000000000]';
%no tracer
% Fak=[0.0200000000000000;0.0400000000000000;0.230000000000000;0                   ;0.390000000000000;0                  ;0.230000000000000;0                   ;0.0499999999999999;0.0100000000000000;0.0100000000000000;0.0100000000000000]';
    
Gammak=zeros(1,numel(dk));
La=1; 
Mak=Fak*La;

%% CALC

Cf=cf_b;
sedTrans=sed_trans_param;
hiding=hiding_param;
gsd=dk;

[qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq]=sediment_transport(flg,cnt,h,u*h,Cf,La,Mak,gsd,sedTrans,hiding,1,E_param,vp_param,Gammak);

