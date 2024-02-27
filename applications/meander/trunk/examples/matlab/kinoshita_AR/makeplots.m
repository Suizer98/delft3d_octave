close all;
figure(1)
plot(ul.s,ul.AR,'k--',unl.s,unl.AR,'c-')

load('measuredbed')
hold on;
plot([usi(2:end-1),usi(2:end-1)+10,usi(2:end-1)+20],[uARi(2:end-1),uARi(2:end-1),uARi(2:end-1)],'r-')
ylim([-5 5])
xlim([10 20]);
xlabel('s-location [m]')
ylabel('A/R [1/m]')

legend('linear','non-linear','from measurements','Location','South')

 set(gcf,'PaperPositionMode', 'auto');
 set(gcf,'PaperUnits','centimeters')
 set(gcf,'PaperPosition',[0 0 8.6 7]*1.5)
box on;
lineobj = findobj('type', 'line');
set(lineobj, 'linewidth', 1.5);
 
%%

figure(3)
plot(30-dl.s,dl.AR,'k--',30-dnl.s,dnl.AR,'c-')
hold on;
plot(30-([dsi(2:end-1),dsi(2:end-1)+10,dsi(2:end-1)+20]),[dARi(2:end-1),dARi(2:end-1),dARi(2:end-1)],'r-')
ylim([-5 5])
xlim([10 20]);
xlabel('s-location [m]')
ylabel('A/R [1/m]')
legend('linear','non-linear','from measurements','Location','North')

 set(gcf,'PaperPositionMode', 'auto');
 set(gcf,'PaperUnits','centimeters')
 set(gcf,'PaperPosition',[0 0 8.6 7]*1.5)
box on;
lineobj = findobj('type', 'line');
set(lineobj, 'linewidth', 1.5);

%%
figure(4)
plot(ul.s(1:end-2),ul.FAR1(1:end-2),'c-',ul.s(1:end-2),ul.FAR2(1:end-2),'k-')
box on;
grid on;
ylim([-5 5])
xlim([10 20]);
xlabel('s-location [m]')
ylabel('Forcing [1/m]')
legend('I','II')

 set(gcf,'PaperPositionMode', 'auto');
 set(gcf,'PaperUnits','centimeters')
 set(gcf,'PaperPosition',[0 0 8.6 7]*1.5)
box on;
title('Upstream skewed (linear)')

lineobj = findobj('type', 'line');
set(lineobj, 'linewidth', 1.5);
hold on;

%%
figure(5)
plot(unl.s(1:end-2),unl.FAR1(1:end-2),'c-',unl.s(1:end-2),unl.FAR2(1:end-2),'k-',unl.s(1:end-2),unl.FAR3(1:end-2),'k--')
box on;
grid on;
ylim([-5 5])
xlim([10 20]);
xlabel('s-location [m]')
ylabel('Forcing [1/m]')
legend('I','II','III')

 set(gcf,'PaperPositionMode', 'auto');
 set(gcf,'PaperUnits','centimeters')
 set(gcf,'PaperPosition',[0 0 8.6 7]*1.5)
box on;

lineobj = findobj('type', 'line');
set(lineobj, 'linewidth', 1.5);
hold on;

title('Upstream skewed (non-linear)')

%%
figure(6)
plot(dl.s(1:end-2),dl.FAR1(1:end-2),'c-',dl.s(1:end-2),dl.FAR2(1:end-2),'k-')
box on;
grid on;
ylim([-5 5])
xlim([10 20]);
xlabel('s-location [m]')
ylabel('Forcing [1/m]')
legend('I','II')

 set(gcf,'PaperPositionMode', 'auto');
 set(gcf,'PaperUnits','centimeters')
 set(gcf,'PaperPosition',[0 0 8.6 7]*1.5)
box on;

lineobj = findobj('type', 'line');
set(lineobj, 'linewidth', 1.5);
hold on;
%plot([0 0],[-5 5],'k-',[193/360*2*pi*1.7 193/360*2*pi*1.7],[-2 4],'k-')
%print('-dpng','-r300',['Figure_Forcing_D_L_Ashld=',num2str(Ashld0),'_Bshld=',num2str(Bshld0),'.png'])
%print('-depsc','-r300',['Figure_Forcing_D_L_Ashld=',num2str(Ashld0),'_Bshld=',num2str(Bshld0),'.eps'])

title('Downstream skewed (linear)')

%%

figure(7)
plot(dnl.s(1:end-2),dnl.FAR1(1:end-2),'c-',dnl.s(1:end-2),dnl.FAR2(1:end-2),'k-',dnl.s(1:end-2),dnl.FAR3(1:end-2),'k--')
box on;
grid on;
ylim([-5 5])
xlim([10 20]);
xlabel('s-location [m]')
ylabel('Forcing [1/m]')
legend('I','II','III')

 set(gcf,'PaperPositionMode', 'auto');
 set(gcf,'PaperUnits','centimeters')
 set(gcf,'PaperPosition',[0 0 8.6 7]*1.5)
box on;

lineobj = findobj('type', 'line');
set(lineobj, 'linewidth', 1.5);
hold on;
%plot([0 0],[-5 5],'k-',[193/360*2*pi*1.7 193/360*2*pi*1.7],[-2 4],'k-')
%print('-dpng','-r300',['Figure_Forcing_D_NL_Ashld=',num2str(Ashld0),'_Bshld=',num2str(Bshld0),'.png'])
%print('-depsc','-r300',['Figure_Forcing_D_NL_Ashld=',num2str(Ashld0),'_Bshld=',num2str(Bshld0),'.eps'])
title('Downstream skewed (non-linear)')
