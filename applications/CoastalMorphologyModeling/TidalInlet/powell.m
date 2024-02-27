clear all;close all
pa=load('powell_PA.txt');
omega=2*pi/(12.5*3600);
f=figure(1);
set(f,'color','w')
vmax1=0.5;vmax2=1.06;vmax3=2;
a1=6.25e-5;a2=1/(2*vmax1/omega);a3=1/(2*vmax2/omega);a4=1/(2*vmax3/omega)
loglog(pa(:,1),pa(:,2),'o',a1*pa(:,2),pa(:,2),'k',...
    a2*pa(:,2),pa(:,2),'b',a3*pa(:,2),pa(:,2),'g',a4*pa(:,2),pa(:,2), ...
    'r','linewidth',2,'markersize',5)
set(gca,'fontweight','bold','linewidth',2)
xlabel('Cross-sectional area Ac (m^2)');ylabel('Tidal prism P (m^3)')
legend('data Powell et al','Best fit','v_{max}=0.5 m/s', ...
    'v_{max}=1.06 m/s','v_{max}=2 m/s','location','northwest')
print('-dpng','powell.png')
print('-depsc2','powell.eps')


