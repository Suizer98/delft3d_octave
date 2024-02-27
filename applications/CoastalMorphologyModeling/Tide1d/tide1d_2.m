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
d0		=50;
slope	=0.01;
dx		=25;
X		=5500;
dt		=60;
nt		=1500;
eps	=1e-10;
%
% Derived quantities
%
nx=X/dx+1;
x=[0:dx:X];
d=d0-x*slope;
h=d;
zb=-d;
omega=2*pi/T;
k=2*pi/L;
Cd=g/C^2;
%
% Initialisations
%
v=zeros(size(x));
eta=zeros(size(x));
vt=zeros([nt nx]);
etat=zeros([nt nx]);
vamp=ones(size(x));
%
for iter=1:100
   labda=pi/4*Cd*vamp;
   a=g*k/omega./(1+(labda./h/omega).^2)*etamp;
   b=-g*k./(labda./h)./(1+(omega*h./labda).^2)*etamp;
   vamp=sqrt(a.^2+b.^2);
   vamp(h<=0)=0;
   theta=atan2(b,a);
   theta(h<=0)=0;
   figure(3);plot(x,vamp);drawnow;
end
%
% Time loop
%
t=0;
for it=1:nt
   vt(it,:)=a*cos(omega*t)+b*sin(omega*t);
   t=it*dt;
end 
%
% Output
%
etamin=min(min(etat));
etamax=max(max(etat));
vmin=min(min(vt));
vmax=max(max(vt));
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
 %  axis([0 X 2*(etamin+etamp) 2*(etamax-etamp)])
   axis([0 X -.1 .1])
   title('setup profile');
   xlabel(' X (m)');
   ylabel(' level (m)');
   subplot(313);
   plot(x,vt(it,:));
   axis([0 X vmin vmax])
   title('velocity profile');
   xlabel(' X (m)');
   ylabel(' v (m/s)');
   drawnow   
   end
end
tt=[1:nt]*dt;
figure(4);
subplot(131);
plot(etat(750:1500,1),tt(750:1500));
subplot(132);
pcolor(x,tt(750:1500)',vt(750:1500,:));
shading interp;
caxis([-1 1]);
colorbar;
subplot(133);
plot(detady(750:1500),tt(750:1500));
      
