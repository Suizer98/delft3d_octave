eta1=1;eta2=.5;h=10;g=9.81;
T=12.5*3600;
omega=2*pi/T;
c=sqrt(g*h);
k=omega/c;
L=c*T
x=[0:100:round(2*L/100)*100];
r=eta2/eta1
etamp=eta1*sqrt((1-r)^2+4*r*(cos(k*x)).^2);
figure(1);clf;
for it=1:12;
   t=T/12*it;
   etas=2*eta2*cos(omega*t)*cos(k*x);
   etap=(eta1-eta2)*cos(omega*t-k*x);
   etat=etas+etap;
   subplot(311);axis([0 1 -2 2]);
   p1=plot(x/L,etas/eta1);hold on;
   set(p1,'Color',[(12-it)/12 (12-it)/12 (12-it)/12]);
   text(.25,1.5,'Standing mode');
   ylabel('\eta/\eta1');
   set(gca,'XTick',[0:0.25:1]);
   subplot(312);axis([0 1 -2 2]);
   p2=plot(x/L,etap/eta1);hold on;
   set(p2,'Color',[(12-it)/12 (12-it)/12 (12-it)/12]);
   text(.25,1.5,'Propagating mode');
   ylabel('\eta/\eta1');
   set(gca,'XTick',[0:0.25:1]);
   subplot(313);axis([0 1 -2 2]);
   p3=plot(x/L,etat/eta1);hold on;
   set(p3,'Color',[(12-it)/12 (12-it)/12 (12-it)/12]);
   text(.25,1.5,'Total');
   ylabel('\eta/\eta1');
   xlabel('x/L');
   set(gca,'XTick',[0:0.25:1]);
end
subplot(313);
plot(x/L,etamp,'--k',x/L,-etamp,'--k');
print('-deps2','resonance.eps')
print('-dpng','resonance.png')
figure(2);clf;
for i=2:2:10;
   r=i*.1;
   y=sqrt((1-r)^2+4*r)./sqrt((1-r)^2+4*r*(cos(k*x)).^2);
   p4=plot(x/L,y);hold on;
   ylabel('Amplification factor');
   xlabel('X/L');
   set(p4,'Color',[(10-i)/10 (10-i)/10 (10-i)/10]);
   axis([0 1 1 10]);
   set(gca,'XTick',[0:0.25:1]);
   title('Tidal amplification factor');
   legend ('r=0.2','r=0.4','r=0.6','r=0.8','r=1.0')
end
print('-deps2','amplification.eps')
print('-dpng','amplification.png')

