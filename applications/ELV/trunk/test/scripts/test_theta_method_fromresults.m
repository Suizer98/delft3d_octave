clear 
clc
close all

% dbstop if error

%% INPUT

dire_in='c:\Users\victorchavarri\temporal\ELV\trial\020\';

kf=2;

%% LOAD

load(fullfile(dire_in,'input.mat'))
output=load(fullfile(dire_in,'output.mat'));

nT=input.mdv.nT;
dx=input.grd.dx;
nx=input.mdv.nx;
nf=input.mdv.nf;

%% CALL

con_all=NaN(nT,1);
ran_all=NaN(nT,1);
Gammak_all=NaN(nT,nx);
E_all=NaN(nT,nx);
D_all=NaN(nT,nx);
vpk_all=NaN(nT,nx);
Dk_g_all=NaN(nT,nx);
Ek_g_all=NaN(nT,nx);
Dk_st_all=NaN(nT,nx);
Ek_st_all=NaN(nT,nx);

for kt=1:nT
% for kt=1:5:nT
    
dk=input.sed.dk(kf);

La=output.La(:,:,:,kt);
h=output.h(:,:,:,kt);
u=output.u(:,:,:,kt);
Gammak=output.Gammak(kf,:,:,kt);
cf_f=output.Cf(:,:,:,kt);
if kf~=nf
    Mak=output.Mak(kf,:,:,kt);
else
    Mak=La-sum(output.Mak(1:nf-1,:,:,kt),1);
end

cf_b=cf_f;

etab=output.etab(:,:,:,kt);
s_aux=diff(etab,1)/dx;
s=[s_aux,s_aux(end)];

Fr=u./sqrt(input.mdv.g.*h);
Sf=cf_f.*Fr.^2;

input.aux.flg.particle_activity=0; %to get qbk from CR for BC
[qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq]=sediment_transport(input.aux.flg,input.aux.cnt,h'               ,(u.*h)',cf_b',La',Mak',input.sed.dk,input.tra.param,input.tra.hiding_b,1,input.tra.E_param,input.tra.vp_param,Gammak');
[~,~,~,~,~,~,~,~,~,~,~,~,~,~,vpk_hdh,~,~                                                     ]=sediment_transport(input.aux.flg,input.aux.cnt,(h+input.mdv.dd)',(u.*h)',cf_b',La',Mak',input.sed.dk,input.tra.param,input.tra.hiding_b,1,input.tra.E_param,input.tra.vp_param,Gammak');
vpk=vpk(:,kf)';
dvpk_dh=(vpk_hdh(:,kf)'-vpk)./input.mdv.dd;

S1=Mak.*Ek_g(:,kf)';
S2=dvpk_dh./(1-Fr.^2).*(-s+Sf)-Dk_g(:,kf)';

E=sum(Ek,2)';
D=sum(Dk,2)';
Dk_g=Dk_g(:,kf)';
Ek_g=Ek_g(:,kf)';
Dk_st=Dk_st(:,kf)';
Ek_st=Ek_st(:,kf)';

%boundary condition
    %upstream
switch input.bcm.pa_u
    case 1
        Gammak_old(1)=C0;
        g_u=NaN(1,2);
        h_u=NaN(1,2);
    case 3
        g_u=-input.bcm.Qbk0(1,kf)*ones(1,2);
        h_u=[vpk(1),vpk(1)];
    otherwise
        error('shit!')        
end
    %downstream
switch input.bcm.pa_d
    case 1
        Gammak_old(end)=Gammak_eq(1);
        g_d=NaN(1,2);
        h_d=NaN(1,2);
    case 3
        g_d=-qbk(end,kf)*ones(1,2);
        h_d=[vpk(1),vpk(1)];
    otherwise
        error('shit!')        
end

%% CALL Gammal
Gammak_all(kt,:)=Gammak;
Gammak_new=theta_method(Gammak,vpk,input.tra.kappa(kf),S1,S2,g_u,h_u,g_d,h_d,input);

%% test condition and rank
if 0
Gammak_all(kt,:)=Gammak;
[Gammak_new,con,ran]=theta_method_full(Gammak,vpk,input.tra.kappa(kf),S1,S2,g_u,h_u,g_d,h_d,input);

con_all(kt)=con;
ran_all(kt)=ran;
end

%% save
E_all(kt,:)=E;
D_all(kt,:)=D;
vpk_all(kt,:)=vpk;
Ek_g_all(kt,:)=Ek_g;
Dk_g_all(kt,:)=Dk_g;
Dk_st_all(kt,:)=Dk_st;
Ek_st_all(kt,:)=Ek_st;

%% DISP

fprintf('%5.2f%%\n',kt/nT*100);

end %kT

%% check

diff_check=Gammak_all-squeeze(output.Gammak(kf,:,:,:))';

if max(max(abs(diff_check)))>1e-8
    sprintf('ups...')
end


%% PLOT

rT=1:1:nT;
dp=50;
% rTp=1:dp:nT;
% rTp=350:400;
rTp=385:435;
close all
nc=numel(rTp);
cmap=brewermap(nc,'RdBu');
set(groot,'defaultAxesColorOrder',cmap)

%% E-D
if 1

figure
hold on
plot(1:1:nx,E_all(rTp,:))
title('E')

figure
hold on
plot(1:1:nx,D_all(rTp,:))
title('D')

figure
hold on
plot(1:1:nx,D_all(rTp,:)-E_all(rTp,:))
title('D-E')

end
%% Gammak

figure
hold on
plot(1:1:nx,Gammak_all(rTp,:))
title('Gammak')

%% Ek_g Dk_g

figure
subaxis(3,1,1)
hold on
plot(1:1:nx,Dk_g_all(rTp,:))
title('Dk_g')

subaxis(3,1,2)
hold on
plot(1:1:nx,Ek_g_all(rTp,:))
title('Ek_g')

subaxis(3,1,3)
hold on
plot(1:1:nx,vpk_all(rTp,:))
title('vpk')

%%
figure
subaxis(3,1,1)
hold on
plot(1:1:nx,Dk_st_all(rTp,:))
title('D^*_k')

subaxis(3,1,2)
hold on
plot(1:1:nx,Ek_st_all(rTp,:))
title('E^*_k')

%% condition number and rank
if 0
    
figure
hold on
% plot(input.mdv.time_results,con_all,'-*')
plot(1:1:nT,con_all,'-*')

figure
hold on
% plot(input.mdv.time_results,con_all,'-*')
plot(1:1:nT,ran_all,'-*')
end

%% qbk 
if 0

qbk=NaN(2,nx);
dGammak_dx=(Gammak_all(:,3:end)-Gammak_all(:,1:end-2))/(2*dx);
qbk(:,2:end-1)=vpk(2:end-1)'.*Gammak_all(:,2:end-1)-kappa*dGammak_dx;

dp=1;

figure
plot(x,qbk(1:dp:end,:))

end

%% numerical - analytical

if 0
dp=1;

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

