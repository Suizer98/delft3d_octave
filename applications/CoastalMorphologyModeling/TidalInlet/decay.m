clear all; close all;
h=30;g=9.81;theta=43;
Omega=2*pi/24/3600
f=2*Omega*sin(theta*pi/180)
c=sqrt(g*h)
L=round(c/f/100)*100;
x=[-L:100:0]
dec1=exp(f*x/c);
dec2=1+f*x/c;
figure()
plot(x*f/c,dec1,x*f/c,dec2,'linewidth',2);
title('Amplitude decay in Kelvin wave')
legend('Exponential','Linear','location','southeast')
xlabel('f*x/c');ylabel('\eta/\eta_{0}')
print('-depsc','decay.eps')
print('-dpng','decay.png')