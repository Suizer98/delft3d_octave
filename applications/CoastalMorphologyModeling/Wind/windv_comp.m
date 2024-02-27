Cw0=.00063;Cw100=.00723;Chezy=65;g=9.81;rho=1000;Cd=g/Chezy^2;
uw=20;dt=60;dir=225;nt=1440;
rhoa=1.;
Cw=Cw0+uw/100*(Cw100-Cw0);
theta=pi/180*(270-dir);
tauw=rhoa*Cw*uw^2;
tauwx=tauw*cos(theta);
tauwy=tauw*sin(theta);
v00=sqrt(tauwy/rho/Cd);
for ih=1:4
   h=ih*4
   t(1,ih)=0;
   v(1,ih)=0;
   for i=2:nt;
      t(i,ih)=(i-1)*dt;
      
      v(i,ih)=v(i-1,ih)+(tauwy/rho/h-Cd*v(i-1,ih)^2/h)*dt;
   end
%      T=h*sqrt(rho/tauwy/Cd);
%      t(nt+1,ih)=nan;t(nt+2,ih)=0;t(nt+3,ih)=T;t(nt+4,ih)=nt*dt;
%      v(nt+1,ih)=nan;v(nt+2,ih)=0;v(nt+3,ih)=v00;v(nt+4,ih)=v00;
end
t=t/3600;
vs_use('D:\data\dano\boek\Cutie_backup\boek\d3d\2d_wind_225\trih-tes.dat')
 vdata=vs_get('his-series','ZCURV',{2,1});
 for i=1:length(vdata);vc(i,4)=vdata{i};end
 vdata=vs_get('his-series','ZCURV',{4,1});
 for i=1:length(vdata);vc(i,3)=vdata{i};end
 vdata=vs_get('his-series','ZCURV',{6,1});
 for i=1:length(vdata);vc(i,2)=vdata{i};end
 vdata=vs_get('his-series','ZCURV',{8,1});
 for i=1:length(vdata);vc(i,1)=vdata{i};end
tc=([1:length(vdata)]-1)/60;
figure(1)
plot(t(:,1),v(:,1),'k-',tc,vc(:,1),'k.', ...
     t(:,2),v(:,2),'b-',tc,vc(:,2),'b.', ...
     t(:,3),v(:,3),'r-',tc,vc(:,3),'r.', ...
     t(:,4),v(:,4),'g-',tc,vc(:,4),'g.', ...
     'linewidth',2);
set(gca,'fontsize',11','fontweight','bold')
set(gca,'xlim',[0 15])
legend('h = 4 m approx.','h = 4 m 2DH',...           
       'h = 8 m approx.','h = 8 m 2DH',...
       'h =12 m approx.','h =12 m 2DH',...
       'h =16 m approx.','h =16 m 2DH','location','southeast')
xlabel('time (h) ');ylabel ('velocity (m/s)');title(strcat('Wind velocity = ',num2str(uw),' m/s'))
print('-depsc','windvcomp.eps')
