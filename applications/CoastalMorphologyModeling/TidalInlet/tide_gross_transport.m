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
xlabel('Cross-sectional ara Ac (m^2)');ylabel('Tidal prism P (m^3)')
legend('data Powell et al','Best fit','v_m_a_x=0.5 m/s', ...
    'v_m_a_x=1.06 m/s','v_m_a_x=2 m/s','location','northwest')
obrien=4.69e-4/(0.3048)^(3*0.85)*0.3048^2;
Ac=0:10:50000;
delta=1.65;D50=0.000500;
Cf=0.004;
g=9.81;
T=12.5*3600;
omega=2*pi/T;
A=150e6;
col=['b','r','g']
Lgorge=2000
h=sqrt(Ac/100);
etamp=1;
B=Ac./h
fac=.1
uamp=1.0;
labda=pi/4*Cf*uamp;
mu=Ac.*h/A*g./labda/Lgorge;
phi=omega./mu;
uamp=A./Ac*omega./sqrt(1+phi.^2)*etamp;
P=2*A./sqrt(1+phi.^2)*etamp;
u3=0.42*uamp.^3;
u5=0.34*uamp.^5;
TMPM=fac*8/delta/g*Cf^1.5*u3*3600*24*365.*B;
TEH=0.05*Cf^1.5/g^2/delta^2/D50*u5*3600*24*365.*B;
Ac1=interp1(uamp(300:end),Ac(300:end),5);
Ac2=interp1(uamp(300:end),Ac(300:end),1);
B1=interp1(uamp(300:end),B(300:end),5);
B2=interp1(uamp(300:end),B(300:end),1);
Ac3=interp1(TMPM(300:end),Ac(300:end),.5e6);
uamp3=interp1(Ac(300:end),uamp(300:end),Ac3);
TEH1=0.05*Cf^1.5/g^2/delta^2/D50*0.34*5^5*3600*24*365.*B1;
TEH2=0.05*Cf^1.5/g^2/delta^2/D50*0.34*1^5*3600*24*365.*B2;
TMPM1=fac*8/delta/g*Cf^1.5*0.42*5^3*3600*24*365.*B1;
TMPM2=fac*8/delta/g*Cf^1.5*0.42*1^3*3600*24*365.*B2;

f=figure(2)
set(f,'color','w','resize','off')
subplot(211)
semilogy(Ac,TMPM,'k',Ac1,TMPM1,'or',Ac2,TMPM2,'ob',Ac,.5e6*ones(size(Ac)),Ac3,.5e6,'og','linewidth',2);hold on
set(gca,'fontweight','bold','fontsize',10,'linewidth',2,...
    'xlim',[0 50000],'ylim',[1e5 1e9],'ytick',[ 1e5 1e6 1e7 1e8])
xlabel('A_c (m^2)');ylabel('Gross transport (m^3/yr)')
subplot(212)
plot(Ac,uamp,'k',Ac1,5,'or',Ac2,1,'ob',Ac3,uamp3,'og','linewidth',2)
set(gca,'fontweight','bold','fontsize',10,'linewidth',2,'xlim',[0 50000])
xlabel('A_c (m^2)');ylabel('V_m_a_x (m/s)')
print('-dpng','tide_gross_transport.png')
print('-depsc2','tide_gross_transport.eps')
figure(1);hold on;plot(Ac(353:2100),P(353:2100),Ac(353),P(353),'+r',Ac(1600),P(1600),'+g',Ac(2100),P(2100),'+b','linewidth',4')
print('-dpng','powell.png')
print('-depsc2','powell.eps')

