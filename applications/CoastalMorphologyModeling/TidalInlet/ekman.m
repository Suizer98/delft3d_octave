%% Program to plot Ekman spiral
%% Input section
clear all; close all;
i=sqrt(-1)                   % To make sure i is the complex i
h=120;                       % Water depth
nut=.02;                     % (constant) turbulence viscosity
phi=51;                      % Latitude (deg.)
rho=1000;                    % Water density
tauwx=0;                     % Wind shear stress x-direction
tauwy=1;                     % Wind shear stress y-direction
tau=tauwx+tauwy*i;           % Shear stress vector 
                             % in complex notation
f=2*7.27e-5*sin(phi*pi/180); % Coriolis coefficient
dek=sqrt(2*nut/f)            % Ekman depth
dz=5;                        % Vertical step size
zek=[-h:dz:0];               % Vertical coordinate
%% Define some additional matrices for plotting purposes
xek=zeros(size(zek));        
yek=zeros(size(zek));
taux=zeros(size(zek));
tauy=zeros(size(zek));
taux(end)=tauwx;
tauy(end)=tauwy;
%% Solution of Ekman spiral
s=tau*dek/rho/(1+i)/nut*exp((1+i)/dek*zek);
uek=real(s);
vek=imag(s);
%% Plot results
figure(1);
quiver3(xek,yek,zek,uek,vek,zeros(size(vek)),'linewidth',2);
hold on
quiver3(xek,yek,zek,taux,tauy,zeros(size(tauy)),'r','linewidth',2);
title('Ekman spiral')
xlabel('u');ylabel('v');
zlabel('z')
print('-dpng','ekman.png')
print('-depsc','ekman.eps')