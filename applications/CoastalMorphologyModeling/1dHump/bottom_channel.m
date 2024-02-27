clear all;
dt=3              %timestep in hr
x = 0:0.2:16;
lx = length(x);
y = zeros(1,lx);
y0 =-0.1* (sin((pi*(x - 2.0))/8.0)).^2;
y0(x>10|x<2)=0
y(1,:)=y0
A=plot(x,y-0.6,'-k','LineWidth',2);axis

hold on
title('Along river profile','FontName','TimesNewRoman','FontSize', 16);
xlabel('Distance from upstream -> (m)','FontName','TimesNewRoman','FontSize', 16);
ylabel('Bed level (m)','FontName','TimesNewRoman','FontSize', 16);
xlim([0,16]);
ylim([-0.8,0]);

n = 0.4;
Chezy = 45.57;
grav = 9.81;
%Cd = (2*grav)/(Chezy^2);
Q = 0.25*1.1;
s = 1.65;
D = 0.15*10^(-3);

h = 0.6-y(1,:);
u=Q./h;
Qs = 0.05*u.^5/((s^2)*(grav^0.5)*D*(Chezy^3));   % E-H in m2/s
c = 5.*Qs./h;

for i=1:4               % for 4 hours
x1 = x+c*3600*i*dt;
B(i) = plot(x1,y-0.6,'--r','LineWidth',2);
end

print('-depsc','bottomchannel.eps')
print('-dpng','bottomchannel.png')

