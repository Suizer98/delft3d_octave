clear all; close all;
B=2000
h=15
A=300e6
Lgorge=20000
labda=2e-3
g=9.81
T=12.5*3600;
omega=2*pi/T
mu=B*h^2/A*g/labda/Lgorge;
phi=omega/mu
etamp=1;
dt=60
t=0:dt:T;
eta1=etamp*cos(omega*t);
eta2=1/sqrt(1+phi^2)*etamp*cos(omega*t-atan(phi));
figure(1)
subplot(211)
plot(t/3600,eta1,t/3600,eta2)
legend('Outside basin','Inside the basin','location','southeast');

ylabel('Water level (m)');
Q=(eta2(2:end)-eta2(1:end-1))/dt*A;
v=Q/h/B;
subplot(212)
plot(t(2:end)/3600,v)
ylabel('v_{inlet} (m/s)');
xlabel('time (h)');
print('-dpng','basin.png');

