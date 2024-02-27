%% Make plots

%%
figure(21);
subplot(211)
plot(ul.s,ul.asR,'b-',unl.s,unl.asR,'r-',s_exp_US,alfas_R_exp_US,'ko')

xlim([-2 32]);
legend('linear','non-linear','from measurements')
title('Upstream skewed')
ylim([-5 5]);
ylabel('\alpha_s/R (1/m)')
hold on;
annotation('arrow',[0.15 0.23],[0.85 0.85])
hold off
subplot(212)
plot(30-dl.s,-dl.asR,'b-',30-dnl.s,-dnl.asR,'r-',30-s_exp_DS,-alfas_R_exp_DS,'ko')
ylim([-5 5]);
xlim([-2 32]);
title('Downstream skewed')
ylabel('\alpha_s/R (1/m)')
xlabel('s-location (m)')
hold on;
annotation('arrow',[0.88 0.80],[0.38 0.38])
hold off


%%
figure(22);
subplot(211)
plot(ul.s,ul.asR,'k-','LineWidth',0.5)
hold on;
plot(unl.s,unl.asR,'k-','LineWidth',1.5)
plot(s_exp_US,alfas_R_exp_US,'ko')

xlim([-2 32]);
legend('linear','non-linear','from measurements')
title('Upstream skewed')
ylim([-5 5]);
ylabel('\alpha_s/R (1/m)')
hold on;
annotation('arrow',[0.15 0.23],[0.85 0.85])
hold off
subplot(212)
plot(30-dl.s,-dl.asR,'k-','LineWidth',0.5)
hold on;
plot(30-dnl.s,-dnl.asR,'k-','LineWidth',1.5)
plot(30-s_exp_DS,-alfas_R_exp_DS,'ko')
ylim([-5 5]);
xlim([-2 32]);
title('Downstream skewed')
ylabel('\alpha_s/R (1/m)')
xlabel('s-location (m)')
hold on;
annotation('arrow',[0.88 0.80],[0.38 0.38])
hold off


%%
figure(31);
subplot(211)
plot(ul.s,ul.F1+ul.F2+ul.F3+ul.F4,ul.s,ul.F1,ul.s,ul.F2,ul.s,ul.F3)

xlim([0 30]);
ylim([-50 50]);
xlabel('Distance along channel axis (m)')
title('Linear forcing terms')
legend('Forcing F_{as/R}','transverse bed/water slope','changes in curvature','momentum redistribution due to sec. flow','Location','NorthEast')
subplot(212)
plot(unl.s,unl.F1+unl.F2+unl.F3+unl.F4,unl.s,unl.F1,unl.s,unl.F2,unl.s,unl.F3,unl.s,unl.F4)
grid on;
xlim([0 30]);
ylim([-50 50]);
xlabel('Distance along channel axis (m)')
title('Non-linear forcing terms')
suptitle('Upstream skewed Kinoshita curve')
legend('Forcing F_{as/R}','transverse bed/water slope','changes in curvature','momentum redistribution due to sec. flow','changes in transverse water/bed slope','Location','NorthEast')

%%
load watlevel_data_DS.mat
load watlevel_data_US.mat

figure(51)
subplot(211)
plot(ul.s,ul.h,'b-',unl.s,unl.h,'r-',US_s_exp,US_h_exp,'ko')
ylim([0.135 0.155])
xlim([-2 32])
title('Upstream skewed')
ylabel('water level (m)')
legend('linear','non-linear','from measurements')
hold on;
annotation('arrow',[0.15 0.23],[0.85-0.2 0.85-0.2])
hold off
subplot(212)
plot(-dl.s+30,dl.h,'b-',-dnl.s+30,dnl.h,'r-',DS_s_exp,DS_h_exp,'ko')
ylim([0.135 0.155])
xlim([-2 32])
hold on;
annotation('arrow',[0.88 0.80],[0.38-0.2 0.38-0.2])
hold off

title('Downstream skewed')
xlabel('s-location (m)')
ylabel('water level (m)')

% Downstream boundary 0.137 m (s = 32 m).
% Upstream boundary as/R = 0  (straight inflow at s = -2 m) 
%
% US_slope: Nonlinear = -0.000390 ; Measured = -0.000399
% DS_slope: Nonlinear =  0.000395 ; Measured =  0.000444


%%
figure(52)
subplot(211)
plot(ul.s,ul.h,'k-','LineWidth',0.5)
hold on;
plot(unl.s,unl.h,'k-','LineWidth',1.5)
plot(US_s_exp,US_h_exp,'ko')

ylim([0.135 0.155])
xlim([-2 32])
title('Upstream skewed')
ylabel('water level (m)')
legend('linear','non-linear','from measurements')
hold on;
annotation('arrow',[0.15 0.23],[0.85-0.2 0.85-0.2])
hold off
subplot(212)
plot(-dl.s+30,dl.h,'k-','LineWidth',0.5)
hold on;
plot(-dnl.s+30,dnl.h,'k-','LineWidth',1.5)
plot(DS_s_exp,DS_h_exp,'ko')

%plot(-dl.s+30,dl.h,'b-',-dnl.s+30,dnl.h,'r-',DS_s_exp,DS_h_exp,'kd')
ylim([0.135 0.155])
xlim([-2 32])
hold on;
annotation('arrow',[0.88 0.80],[0.38-0.2 0.38-0.2])
hold off

title('Downstream skewed')
xlabel('s-location (m)')
ylabel('water level (m)')

% Downstream boundary 0.137 m (s = 32 m).
% Upstream boundary as/R = 0  (straight inflow at s = -2 m) 
%
% US_slope: Nonlinear = -0.000390 ; Measured = -0.000399
% DS_slope: Nonlinear =  0.000395 ; Measured =  0.000444




%%
% strcol = 'C'
% linestr = {'-','-','-','--','--'};
% colstr = {[1 0.6 0],[ 1 0 0],[0 0 1],[0 0 0],[0 0 0]};
% linwid = {1.5, 1.5, 1.5, 0.5, 2.5};
strcol = 'BW'
linestr = {'-','-','-','--','--'};
colstr = {[0.5 0.5 0.5],[ 0 0 0],[0 0 0],[0 0 0],[0 0 0]};
linwid = {1.5, 1.5, 0.5, 0.5, 2.5};
figure(61)
clf
subplot(221)
plot(ul.s,ul.F1,linestr{1},'Color',colstr{1},'LineWidth',linwid{1})
hold on;
plot(ul.s, ul.F2,linestr{2},'Color',colstr{2},'LineWidth',linwid{2})
plot(ul.s, ul.F3,linestr{3},'Color',colstr{3},'LineWidth',linwid{3})
plot(ul.s, ul.F1+ul.F2+ul.F3+ul.F4,linestr{5},'Color',colstr{5},'LineWidth',linwid{5})
xlim([10 20])
ylim([-50 50])
ylabel('(1/m)')
set(gca,'YTick',-40:20:40);
set(gca,'YGrid','on')
title('a) Upstream skewed (linear)')
xlabel('s-location (m)')

subplot(222)
plot(unl.s,unl.F1,linestr{1},'Color',colstr{1},'LineWidth',linwid{1})
hold on;
plot(unl.s,unl.F2,linestr{2},'Color',colstr{2},'LineWidth',linwid{2})
plot(unl.s,unl.F3,linestr{3},'Color',colstr{3},'LineWidth',linwid{3})
plot(unl.s,unl.F4,linestr{4},'Color',colstr{4},'LineWidth',linwid{4})
plot(unl.s,unl.F1+unl.F2+unl.F3+unl.F4,linestr{5},'Color',colstr{5},'LineWidth',linwid{5})
xlim([10 20])
ylim([-50 50])
set(gca,'YTick',-40:20:40);
set(gca,'YGrid','on')
title('b) Upstream skewed (non-linear)')
xlabel('s-location (m)')

subplot(223)
plot(30-dl.s,-dl.F1,linestr{1},'Color',colstr{1},'LineWidth',linwid{1})
hold on;
plot(30-dl.s,-dl.F2,linestr{2},'Color',colstr{2},'LineWidth',linwid{2})
plot(30-dl.s,-dl.F3,linestr{3},'Color',colstr{3},'LineWidth',linwid{3})
plot(30-dl.s,-dl.F1-dl.F2-dl.F3-dl.F4,linestr{5},'Color',colstr{5},'LineWidth',linwid{5})
xlim([10 20])
ylim([-50 50])
ylabel('(1/m)')
set(gca,'YTick',-40:20:40);
set(gca,'YGrid','on')
title('c) Downstream skewed (linear)')
subplot(224)
plot(30-dnl.s,-dnl.F1,linestr{1},'Color',colstr{1},'LineWidth',linwid{1})
hold on;
plot(30-dnl.s,-dnl.F2,linestr{2},'Color',colstr{2},'LineWidth',linwid{2})
plot(30-dnl.s,-dnl.F3,linestr{3},'Color',colstr{3},'LineWidth',linwid{3})
plot(30-dnl.s,-dnl.F4,linestr{4},'Color',colstr{4},'LineWidth',linwid{4})
plot(30-dnl.s,-dnl.F1-dnl.F2-dnl.F3-dnl.F4,linestr{5},'Color',colstr{5},'LineWidth',linwid{5})
xlim([10 20])
ylim([-50 50])
set(gca,'YTick',-40:20:40);
set(gca,'YGrid','on')
title('d) Downstream skewed (non-linear)')
leghandle = legend('I','II','III','IV','F_w','Orientation','horizontal')
set(leghandle,'Position',[0.2742 0.0165 0.4664 0.0528]);%[0.2775 0.4795 0.4657 0.0528])

annotation('arrow',[0.44 0.36],[0.38 0.38])
annotation('arrow',[0.88 0.80],[0.38 0.38])
annotation('arrow',[0.15 0.23],[0.85 0.85])
annotation('arrow',[0.59 0.67],[0.85 0.85])



%%
figure(62)
subplot(221)
plot(ul.s,ul.F1,'Color',[0.3 0.3 0.3],'LineWidth',0.5)
hold on;
plot(ul.s,ul.F2,'-','Color',[0 0 0],'LineWidth',1.5)
plot(ul.s,ul.F3,'-','Color',[0 0 0],'LineWidth',0.5)
plot(ul.s,ul.F4,'-.','Color',[0.3 0.3 0.3],'LineWidth',0.5)
plot(ul.s,ul.F1+ul.F2+ul.F3+ul.F4,'k--','LineWidth',2.5)
xlim([10 20])
ylim([-55 55])
set(gca,'YTick',-40:20:40);
set(gca,'YGrid','on')
title('a) Upstream skewed (linear)')
subplot(222)
plot(unl.s,unl.F1,'Color',[0.3 0.3 0.3],'LineWidth',0.5)
hold on;
plot(unl.s,unl.F2,'-','Color',[0 0 0],'LineWidth',1.5)
plot(unl.s,unl.F3,'-','Color',[0 0 0],'LineWidth',0.5)
plot(unl.s,unl.F4,'-.','Color',[0.3 0.3 0.3],'LineWidth',0.5)
plot(unl.s,unl.F1+unl.F2+unl.F3+unl.F4,'k--','LineWidth',2.5)
xlim([10 20])
ylim([-55 55])
set(gca,'YTick',-40:20:40);
set(gca,'YGrid','on')
title('b) Upstream skewed (non-linear)')
subplot(223)
plot(30-dl.s,-dl.F1,'Color',[0.3 0.3 0.3],'LineWidth',0.5)
hold on;
plot(30-dl.s,-dl.F2,'-','Color',[0 0 0],'LineWidth',1.5)
plot(30-dl.s,-dl.F3,'-','Color',[0 0 0],'LineWidth',0.5)
plot(30-dl.s,-dl.F1-dl.F2-dl.F3-dl.F4,'k--','LineWidth',2.5)
xlim([10 20])
ylim([-55 55])
set(gca,'YTick',-40:20:40);
set(gca,'YGrid','on')
title('c) Downstream skewed (linear)')
subplot(224)
plot(30-dnl.s,-dnl.F1,'Color',[0.3 0.3 0.3],'LineWidth',0.5)
hold on;
plot(30-dnl.s,-dnl.F2,'-','Color',[0 0 0],'LineWidth',1.5)
plot(30-dnl.s,-dnl.F3,'-','Color',[0 0 0],'LineWidth',0.5)
plot(30-dnl.s,-dnl.F4,'-.','Color',[0.3 0.3 0.3],'LineWidth',0.5)
plot(30-dnl.s,-dnl.F1-dnl.F2-dnl.F3-dnl.F4,'k--','LineWidth',2.5)
xlim([10 20])
ylim([-55 55])
set(gca,'YTick',-40:20:40);
set(gca,'YGrid','on')
title('d) Downstream skewed (non-linear)')
leghandle = legend('I','II','III','IV','F_w','Orientation','horizontal')
set(leghandle,'Position',[0.2742 0.0165 0.4664 0.0528]);%[0.2775 0.4795 0.4657 0.0528])

annotation('arrow',[0.44 0.36],[0.38 0.38])
annotation('arrow',[0.88 0.80],[0.38 0.38])
annotation('arrow',[0.15 0.23],[0.85 0.85])
annotation('arrow',[0.59 0.67],[0.85 0.85])




%%
figure(222);
plot(ul.s,ul.asR,'k-','LineWidth',0.5)
hold on;
plot(unl.s,unl.asR,'k-','LineWidth',1.5)
plot(s_exp_US,alfas_R_exp_US,'ko')

xlim([10 20]);
legend('linear','non-linear','from measurements','location','NorthWest')
ylim([-5 5]);
ylabel('\alpha_s/R (1/m)')
hold off

