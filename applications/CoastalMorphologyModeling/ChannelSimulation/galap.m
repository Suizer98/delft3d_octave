clear all;
dx=.1
u=2;
C=65;
rho=1000;
g=9.81;
ws=0.01;
a=0.1;
tau=rho*g/C^2*u^2;
ustar=sqrt(tau/rho);
alpha=1
h=5
ca=1
x=[0:dx:500];
figure;
%set(gca,'fontsize',11,'fontweight','bold')
title('Adaptation of concentration to equilibrium');
xlabel('distance (m)')
ylabel('c/c_a')
set(gcf,'color','w')
hold on
for ic=0:10
    c0=ic*.1
    c(1)=max(c0,ca*a/h);
    n=length(x);
    [z,cz,ceq]=rouse(a,ca,h,ws,ustar,1);
    for i=2:n
        S=(ceq/c(i-1)-1)*ws*max(ca,c(i-1));
        c(i)=c(i-1)+dx/u*S;
    end
    plot(x,c,'k','linewidth',2);hold on;
end
print('-depsc','concadaptation.eps')