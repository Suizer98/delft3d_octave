clear all;close all
T=12.5*3600;nttide=50;n=70;ncont=1;nram=700;nstep=700/n+1;
h0=10;hsh=2;
L=200;
qmean=-1;
qamp=10;
a=1e-4;b=4;
dt=T/nttide;
omega=2*pi/T;
t=0:dt:701*T;
nt=length(t);
% brute force method
if 1
   zb1(1)=-h0;
   for it=1:nt
      h=-zb1(it);
      q=(qmean+qamp*sin(omega*t(it)))*(1-exp(-(h/hsh)^2));
      u(it)=q/h;
      Sx(it)=a*abs(u(it))^(b-1)*u(it);
      dSxdx(it)=Sx(it)/L;
      zb1(it+1)=zb1(it)-dSxdx(it)*dt;
   end
end
%tide-averaging method
zb2(1)=-h0;
t2(1)=0;
it=1;
for imorf=1:nstep
   Sxtot=0;
   for ittide=1:nttide
      h=-zb2(it);
      qc(ittide)=(qmean+qamp*sin(omega*t(ittide)))*(1-exp(-(h/hsh)^2));
   end
   for icont=1:ncont
      Sxtot=0;
      for ittide=1:nttide
         h=-zb2(it);
         u=qc(ittide)/h;
         Sx=a*(abs(u))^(b-1)*u;
         Sxtot=Sxtot+Sx/nttide;
      end   
      dSxdxavg=Sxtot/L;
      it=it+1;
      t2(it)=t2(it-1)+n/ncont*T;
      zb2(it)=zb2(it-1);      
      it=it+1;
      t2(it)=t2(it-1);
      zb2(it)=zb2(it-1)-dSxdxavg*n/ncont*T;
      zb2(it)=min(zb2(it),-0.1);
   end
end
% morphological factor
zb3(1)=-h0;
it3e=0;
for it=1:nt/n
   t3(it)=(it-1)*dt*n;
   h=-zb3(it);
   q=(qmean+qamp*sin(omega*t(it)))*(1-exp(-(h/hsh)^2));
   u(it)=q/h;
   Sx(it)=n*a*abs(u(it))^(b-1)*u(it);
   dSxdx(it)=Sx(it)/L;
   zb3(it+1)=zb3(it)-dSxdx(it)*dt;
   zb3(it+1)=min(zb3(it+1),-.1);
   if mod(it,nttide)==0
      it3e=it3e+1;
      t3e(it3e)=t3(it);
      zb3e(it3e)=zb3(it);
   end
end
% RAM
zb4(1)=-h0;
it=1;
it4e=0;
istep=1
for imorf=1:nstep
   Sxtot=0;
   for ittide=1:nttide
      h=-zb4(it);
      qc(ittide)=(qmean+qamp*sin(omega*t(ittide)))*(1-exp(-(h/hsh)^2));
      u(it)=qc(ittide)/h;
      Sx(it)=a*abs(u(it))^(b-1)*u(it);
      Sxtot=Sxtot+Sx(it)/nttide;  
   end
   A=Sxtot*h^b;
   for iram=1:nram;
      h=-zb4(istep);
      Sxtot=A/h^b*(1-exp(-(h/hsh)^2));     
      dSxdxavg=Sxtot/L;
      zb4(istep+1)=zb4(istep)-dSxdxavg*n/nram*T;
      it4e=it4e+1;
      t4e(it4e)=(it4e-1)*n/nram*T;
      zb4e(it4e)=zb4(istep+1);
      istep=istep+1;   
   end
end
figure(2)
fac=3600*24;
%p=plot(t/fac,zb1(1:nt),'k',t2/fac,zb2,'r-',t3/fac,zb3(1:length(t3)),'b',t3e/fac,zb3e,'b*')
p=plot(t/fac,zb1(1:nt),'k',t2/fac,zb2,'r-',t2(1:ncont:end)/fac,zb2(1:ncont:end),'r*',t3/fac,zb3(1:length(t3)),'b',t3e/fac,zb3e,'b*')
set(p,'linewidth',2);
%l=legend('Brute force solution','Tide-averaged','Morphological factor','MF after full cycle')
legend('Brute force solution','Tide-averaged','Flow recomputation ','Morphological factor','After full cycle','location','northwest','fontweight','bold','box','on');
title('Comparison of time-integration methods','fontweight','bold');
axis([0 370 -11 4]);
text(20,-2,strcat('h_{0}=',num2str(h0),'  h_{sh}=',num2str(hsh),'  q_{mean}=',num2str(qmean),'  q_{amp}=',num2str(qamp)),'fontweight','bold')
text(20,-4,strcat('a=',num2str(a),'  b=',num2str(b)),'fontweight','bold')
text(20,-6,strcat('n_{tide}=',num2str(nttide),'  n=',num2str(n),'  n_{cont}=',num2str(ncont)),'fontweight','bold')
xlabel('Time (days)','fontweight','bold');ylabel('z_{b} (m)');
drawnow();
print('-depsc','tidenteg.eps')
