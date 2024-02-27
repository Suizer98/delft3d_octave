%% Input section
Hrms0=1;
dir0=30;
eta0=.5;
Tp=7;
gamma=.75;
beta=.1;
hmin=.1;
ks=0.05;
rho=1025;
dir0=dir0*pi/180; 
dx=2;
%% Profile definition
zr=6;b=0.323;
A=1.4;
Ab=1;
xb=300;Rb=200;
Lb=200;Tb=20;t=0;
x=-2000:dx:0;
zbmean=zr-A*(-x).^b;
zb=zbmean-Ab*exp(-((-x-xb)/Rb).^2).*cos(2*pi*(x/Lb-t/Tb));
%% Solve wave, roller energy balance and setup
[E,Hrms,Er,Qb,Dw,Dr,eta,h,k,C,Cg,dir,Fx,Fy]= ...
    balance_1d(Hrms0,dir0,eta0,Tp,x,zb,gamma,beta,hmin);
%% Solve longshore current with stationary solver
[vs]=longshore_current(x,Fy,h,Hrms,Tp,k,ks,rho,hmin);
%% Solve longshore current with instationary solver, including viscosity
[vt,Dh]=longshore_current_t(x,Fy,h,Hrms,Tp,Dr,k,ks,rho,hmin);
%% Plot results
figure(1);
subplot(321);
plot(x,zb,x,eta,'linewidth',2);
title('Profile');ylabel('z_{b}, eta (m)');
axis([-800 0 min(zb) max(zb)]);
subplot(323);
plot(x,Hrms,'linewidth',2);
title('Wave height');ylabel('H_{rms} (m)');
axis([-800 0 min(Hrms) 1.1*max(Hrms)]);
subplot(325); 
plot(x,dir*180/pi,'linewidth',2);
title('Wave direction');xlabel('x (m)');ylabel('Dir (°)');
axis([-800 0 0 1.1*max(dir*180/pi)]);
subplot(322);
plot(x,Dw,x,Dr,'linewidth',2);
title('Dissipation');ylabel('D_w,D_r (W/m²)');
axis([-800 0 0 1.1*max(Dw)]);
subplot(324);
plot(x,Dh,'linewidth',2);
title('Hor. viscosity');ylabel('D_h (m²/s)');
axis([-800 0 0 1.1*max(Dh)]);
subplot(326);
plot(x,vs,x,vt,'linewidth',2);
title('Longshore velocity');xlabel('x (m)');ylabel('v (m/s)');
axis([-800 0 0 1.1*max(vs)]);
print('-depsc2','profilemodel.eps')
print('-dpng','profilemodel.png')
