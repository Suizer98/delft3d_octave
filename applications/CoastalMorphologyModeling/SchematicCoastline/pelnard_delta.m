d=10;sx=500000;S=350000;phi0=.5*S/sx
a=sx/d;
x1=-3:0.01:3
u1=abs(x1)
theta=1-erf(u1);
 y1=(exp(-u1.^2)-u1.*theta*sqrt(pi));
 figure(1);
 subplot(211)
 plot(x1,y1,'linewidth',2);axis([-3 3 -1 1]);
 xlabel('x_{*}');ylabel('y_{*}');grid
subplot(212)
c=['b','g','r','k']
for i=1:4
    t=i^2;
    x=x1*sqrt(a*t)
    y=y1*sqrt(a*t/sqrt(pi))*phi0
    plot(x,y,c(i),'linewidth',2); axis([-3000 3000 -300 300]);hold on
end
xlabel('x (m)');ylabel('y (m)');legend('after 1 year','after 2 years','after 4 years','after 8 years')
print('-depsc','pelnarddelta.eps')
print('-dpng','pelnarddelta.png')