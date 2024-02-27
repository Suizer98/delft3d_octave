clear all; close all;
Cw0=.00063;Cw100=.00723;Chezy=65;g=9.81;rho=1025;Cd=g/Chezy^2;
uw=10;dt=60;nt=1440;
rhoa=1.;
Cw=Cw0+uw/100*(Cw100-Cw0);
tauw=rhoa*Cw*uw^2;
v00=sqrt(tauw/rho/Cd);
for ih=1:4
   h=ih*4
   t(1,ih)=0;
   v(1,ih)=0;
   for i=2:nt;
      t(i,ih)=(i-1)*dt;
      v(i,ih)=v(i-1,ih)+(tauw/rho/h-Cd*v(i-1,ih)^2/h)*dt;
   end
   T=h*sqrt(rho/tauw/Cd);
   t(nt+1,ih)=nan;t(nt+2,ih)=0;t(nt+3,ih)=T;t(nt+4,ih)=nt*dt;
   v(nt+1,ih)=nan;v(nt+2,ih)=0;v(nt+3,ih)=v00;v(nt+4,ih)=v00;
end
t=t/3600;
figure(1)
if exist('octave_config_info')
	plot(t(:,1),v(:,1),'linewidth',2,t(:,2),v(:,2),'linewidth',2,t(:,3),v(:,3),'linewidth',2,t(:,4),v(:,4),'linewidth',2);	% octave
else
	plot(t(:,1),v(:,1),t(:,2),v(:,2),t(:,3),v(:,3),t(:,4),v(:,4),'linewidth',2);	% matlab
end
set(gca,'fontsize',11','fontweight','bold')
legend('h = 4 m','h = 8 m','h =12 m','h =16 m','location','southeast');
xlabel('time (h) ');ylabel ('velocity (m/s)');title(strcat('Wind velocity = ',num2str(uw),' m/s'))
print('-depsc','windv.eps')
print('-dpng','windv.png')
