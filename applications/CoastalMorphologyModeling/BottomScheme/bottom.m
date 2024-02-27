clear all; close all;
h0=5;
x0=1000;R=200;
height=-2;
x=[0:10:5000];
u0=1;
b=4;
a=1.e-4;
nt=450;
cfl=0.9
%zb0=-h0+height*exp(-((x-x0)/R).^2);cfl=.9
zb0=-ones(size(x))*h0;
zb0(abs(x-x0)<R)=-h0+height;
%zb0=zb0+height*exp(-((x-x0)/R).^2);
q=h0*u0;dx=x(2)-x(1);dt=1*24*3600;
zb=zb0;
figure(1);
for it=1:nt
   h=-zb;
   u=q./h;
   Sx=a*u.^b;
   celer=b*Sx./h;
   dt=cfl*dx/max(celer);
   dSxdx=zeros(size(Sx));
   dSxdx(2:end)=(Sx(2:end)-Sx(1:end-1))/dx;
   dzb=-dt*dSxdx;
   if it==1
      dzb0=dzb;
      Sx0=Sx;
   end
   zb=zb+dzb;
   if mod(it,50)==0
      subplot(311)
      plot(x,zb0,x,zb,'linewidth',2,'Color',[(nt-it)/nt (nt-it)/nt (nt-it)/nt]);hold on
      ylabel('bottom level (m)');
      subplot(312)
      plot(x,Sx0,x,Sx,'linewidth',2,'Color',[(nt-it)/nt (nt-it)/nt (nt-it)/nt]);hold on
      ylabel('sediment transport (m3/m)')
      subplot(313)
      plot(x,dzb0,x,dzb,'linewidth',2,'Color',[(nt-it)/nt (nt-it)/nt (nt-it)/nt]);hold on
      ylabel('bottom level change (m)')
   end
   xlabel('distance (m)');
end
