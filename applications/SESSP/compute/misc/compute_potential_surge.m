function [surge,taunor,fnl]=compute_potential_surge(vnor,vtan,iid,a)

% rhoa=1.20;
rhoa=1.20;
rhow=1024;
g=9.81;

vabs=sqrt(vnor.^2+vtan.^2);

brpv=[     0     28     60   1000];
brpc=[0.0010 0.0031 0.0015 0.0015];

%cd0=0.0010;
%cd1=0.0025;
%v1=28;
%cd=cd0+vrms*(cd1-cd0)/v1;
%cd(vrms>v1)=cd1;

cd=interp1(brpv,brpc,vabs);

beta2=atan2(vnor,vtan);
phi_shore=0;
% Shore normal component
theta=beta2-phi_shore-pi/2; % wind angle wrt shore normal

tau=rhoa.*cd.*vabs.^2;
taunor=tau.*cos(theta);

fnl=compute_normal_surge_so_factor(taunor,iid,a);

surge=fnl.*taunor.*iid./(rhow*g);
