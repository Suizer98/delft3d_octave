%test of the backwater solver using flow depth and using energy on a regular and an irregular bed

close all
clear

%% INPUT

nt=1;

L=40000; %70000
dx=0.001;

qwup=5;
Hdown=9;
Cf=0.01;
slopeb=1e-4;
B=1;

g=9.81;

n_amp=1; %noise amplitude [m]
n_lambda=5; %wave length of the noise [m]

%% CALC

%rename
nx=round(L/dx);
input.mdv.nx=nx;
input.grd.dx=dx;
input.grd.B=B*ones(1,nx);
input.mdv.g=g;
input.mdv.flowtype=1;

Cf=Cf*ones(1,nx);
etab=fliplr(linspace(0,L*slopeb,input.mdv.nx));

xp=-fliplr(linspace(0,nx*dx,nx));

%noise
noise=n_amp*sin(2*pi/n_lambda.*xp);
etab=etab+noise;

%call
[~,H1]=flow_steady_energy_euler(qwup,Hdown,Cf,etab,input); %energy Euler
[~,H2]=flow_steady_energy_RK4(qwup,Hdown,Cf,etab,input); %energy RK4
[~,H4]=flow_steady_depth_euler(qwup,Hdown,Cf,etab,input); %depth Euler
[~,H5]=flow_steady_depth_RK4(qwup,Hdown,Cf,etab,input); %depth RK4

%% PLOT

% figure
% plot(xp,noise)

figure
hold on
plot(xp,etab,'k')
han_p(1)=plot(xp,etab+H1);
han_p(2)=plot(xp,etab+H2);
han_p(3)=plot(xp,etab+H4);
han_p(4)=plot(xp,etab+H5);

legend(han_p,{'energy Euler','energy RK4','depth Euler','depth RK4'})