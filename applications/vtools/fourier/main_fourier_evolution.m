%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18317 $
%$Date: 2022-08-19 15:13:48 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: main_fourier_evolution.m 18317 2022-08-19 07:13:48Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/fourier/main_fourier_evolution.m $
%
%Main script to compute the evolution of a linear solution based
%on Fourier modes.

%% PREAMBLE

clear
clc
fclose all;

%% PATHS

fpath_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\'; %path in the OET repository

%% ADD OET

if isunix
    fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
end
addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% INPUT

ECT_input.flg.sed_trans=1;
ECT_input.flg.friction_input=1;
ECT_input.flg.hiding=0;
ECT_input.flg.Dm=1;
ECT_input.flg.mu=0;
ECT_input.flg.anl=[10];
ECT_input.gsd=[0.001,0.004];
ECT_input.u=1;
ECT_input.h=1;
ECT_input.Cf=0.007;
ECT_input.La=1;
ECT_input.Fa1=[1];
ECT_input.Fi1=[1];
ECT_input.nu_mom=0.05;
ECT_input.Dh=ECT_input.nu_mom; 
ECT_input.diff_hir=NaN(size(ECT_input.gsd)); 
ECT_input.sedTrans=[10*0.05/ECT_input.Cf,2.5,0];
ECT_input.E_param=[0.0199,1.5]; 
ECT_input.vp_param=[11.5,0.7]; 
ECT_input.gsk_param=[1,0,0,0]; 
ECT_input.hiding=-0.8;
ECT_input.kappa=NaN(size(ECT_input.gsd)); 

dx=20;     
dy=20;     
nx=100;    
ny=100;     
T=2.414968686034367e+04;
nt=2;

pert_anl=1; %1=full
dim_ini=4; %perturbation in bed level

%initial condition
sig=50;
etab_max=1e-3;
    L=(nx-1)*dx;
    B=(ny-1)*dy;
mu=[L/2,B/2]; 

%% domain

x=(0:nx-1)*dx;        
y=(0:ny-1)*dy;        
t=linspace(0,T,nt); 

%% initial condition

[x_in,y_in]=meshgrid(x,y);
noise=etab_max.*exp(-((x_in-mu(1)).^2/sig^2+(y_in-mu(2)).^2/sig^2)); 

%% fourier modes

[fx,fy,P2]=fftV(x,y,noise);
[R,omega]=fourier_eigenvalues(x,y,ECT_input,pert_anl);
[Q,Q_rec]=fourier_evolution(x,y,t,P2,R,omega,dim_ini,'full',0);

%%
%% PLOT
%%

%% initial condition

noise_rec=ifftV(x,y,P2); %reconstruct initial condition

figure
subplot(1,2,1)
hold on
surf(x_in,y_in,noise,'edgecolor','none');
colorbar

subplot(1,2,2)
hold on
surf(x_in,y_in,noise_rec,'edgecolor','none');
colorbar

%% modes

han.fig=figure;
set(han.fig,'paperunits','centimeters','paperposition',[0,0,14.5,6],'visible',0)

subplot(1,2,1)
hold on
surf(fx,fy,real(P2),'edgecolor','none');
han.cbar=colorbar('location','eastoutside');
title({'real part of','Fourier coefficients [m]'})
axis equal
xlim([fx(1),fx(end)])
ylim([fy(1),fy(end)])
xlabel('x frequency [1/m]')
ylabel('y frequency [1/m]')

subplot(1,2,2)
hold on
surf(fx,fy,imag(P2),'edgecolor','none');
han.cbar=colorbar('location','eastoutside');
title({'imaginary part of','Fourier coefficients [m]'})
axis equal
xlim([fx(1),fx(end)])
ylim([fy(1),fy(end)])
xlabel('x frequency [1/m]')
ylabel('y frequency [1/m]')

set(findall(han.fig,'-property','FontSize'),'FontSize',10)

print(gcf,'modes.png','-dpng','-r300')
close(han.fig)

%% solution with time

cmap=turbo(nt);
ke=dim_ini;

for kt=1:nt
    
    Q_rec_t=squeeze(Q_rec(ke,:,:,kt))';
    han.fig=figure;
    set(han.fig,'paperunits','centimeters','paperposition',[0,0,14.5,10],'visible',0)
    
    hold on
    surf(x_in,y_in,Q_rec_t,'edgecolor','none');
    han.cbar=colorbar;
    han.cbar.Label.String='perturbation in bed level [m]';
    xlabel('streamwise coordinate [m]')
    ylabel('cross-wise coordinate [m]')
    title(sprintf('time = %3.1f h',t(kt)/3600))
    view([80,40])
    clim([-2e-4,1e-3])
    zlim([-2e-4,1e-3])

    set(findall(han.fig,'-property','FontSize'),'FontSize',10)
    print(han.fig,sprintf('F_evo_%02d.png',kt),'-dpng','-r300')
    close(han.fig)

end
