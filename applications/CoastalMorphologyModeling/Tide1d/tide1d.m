%
% Input
%
T		=12.5*3600; 
etamp	=1;
L		=400000;
C		=65;
fcor	=1e-4;
g		=9.81;
rho	=1000;
d0		=20;
slope	=0.01;
dx		=25;
X		=2000;
dt		=60;
nt		=1500;
%
% Derived quantities
%
nx=X/dx+1;
x=[0:dx:X];
d=d0-x*slope;
zb=-d;
omega=2*pi/T;k=2*pi/L;Cd=g/C^2;
%
% Initialisations
%
v=zeros(size(x));
eta=zeros(size(x));
vt=zeros([nt nx]);
etat=zeros([nt nx]);
%
% Time loop
%
t=0;
for it=1:nt
   % Solve water level
   eta(1)=cos(omega*t);
   detady(it)=k*sin(omega*t);
   for ix=2:nx
      eta(ix)	=eta(ix-1)+dx/g*fcor*.5*(v(ix-1)+v(ix));
   end
   % Solve longshore velocity next time level
   h=d+eta;
   tauby=rho*Cd*v.*abs(v);
   v=v+dt*(-g*detady(it)-tauby/rho./h);
   v(h<=0)=0;
   t=it*dt;     
   etat(it,:)=eta;
   vt(it,:)=v;
end 
%
% Output
%
etamin=min(min(etat));
etamax=max(max(etat));
vmin=min(min(vt));
vmax=max(max(vt));
tt=[1:1500]/60;
figure(1);
for it=1:nt;
   if mod(it,10)-1==0
   subplot(311);
   plot(x,zb,x,etat(it,:));
   axis([0 X -d0 etamax])
   title('depth/water level profile');
   xlabel(' X (m)');
   ylabel(' level (m)');
   subplot(312);   
   plot(x,etat(it,:)-etat(it,1));
   axis([0 X 2*(etamin+etamp) 2*(etamax-etamp)])
   title('setup profile');
   xlabel(' X (m)');
   ylabel(' level (m)');
   subplot(313);
   plot(x,vt(it,:));
   axis([0 X vmin vmax])
   title('setup profile');
   xlabel(' X (m)');
   ylabel(' v (m/s)');
   drawnow   
   end
end
figure(2);
subplot(131);
plot(etat(750:1500,1),tt(750:1500));
subplot(132);
pcolor(x,tt(750:1500)',vt(750:1500,:));
shading interp;
caxis([-1 1]);
colorbar;
%subplot(133);
%plot(detady(750:1500),tt(750:1500));
figure(3);
plot(x,vt(750,:),'b-',x,vt(870,:),'b-.',x,vt(1000,:),'b:',x,vt(1120,:),'r-',x,vt(1250,:),'r-.',x,vt(1380,:),'r:')
set(gca,'fontsize',11,'fontweight','bold')
legend('0/6T','1/6T','2/6T','3/6T','4/6T','5/6T');
title ('Longshore tidal velocity profiles');
xlabel('Cross-shore distance (m)');
ylabel('Longshore velocity (m/s)')
