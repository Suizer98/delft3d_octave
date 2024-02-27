function plot_zetapotential(pH,zetapot)

% This function creates a figure with the pH on the x-axis and the
% zeta-potential on the y-axis. Lines for Montmorillolite, Kaolinite and
% Illite are added to the plot.

% Input:
% pH    
% zetapot   Zeta Potential in [mV]
%
% Output: figure and png in current directory

figure;
set(gcf,'Papersize',[6.5 11],'paperposition',[0.25 1.5 8 4])

plot(pH,zetapot,'ko');
    
plot([2.04,2.27,2.51,2.99,3.49,4.36,5.14,5.76,6.17,7.07,8.00,9.12,10.03],[-31.45,-31.38,-31.07,-30.58,-32.10,-34.41,-35.98,-36.35,-36.55,-36.49,-36.44,-36.43,-36.14],'k','linewidth',1.5,'displayname','Montmorillonite')
hold on
plot([1.96,2.90,3.05,3.93,4.31,5.01,6.02,6.54,7.36,7.85,8.05,8.31,8.81,9.06,9.83],[-1.58,-6.51,-7.61,-11.10,-12.60,-14.40,-23.01,-25.01,-28.73,-30.84,-31.35,-33.78,-38.85,-40.68,-42.25],'k--','linewidth',1.5,'displayname','Kaolinite')
hold on
plot([2.61,2.68,2.91,3.29,3.72,4.27,4.95,5.70,6.80,7.65,8.67,9.58,10.25,11.12],[-0.05,-3.63,-9.59,-14.67,-19.00,-22.44,-25.20,-27.13,-29.37,-31.05,-33.17,-35.60,-37.85,-41.48],'k:','linewidth',1.5,'displayname','Illite')
text(4.5,-12,'kaolinite','fontsize',8)
text(4.35,-22,'illite','fontsize',8)
text(4.2,-33,'montmorillonite','fontsize',8)
ylabel('\zeta potential [mV]')
xlabel('pH')
ylim([-50 0])
xlim([0 12])
grid on

print(gcf,'-r300','-dpng','ZetaPotential')