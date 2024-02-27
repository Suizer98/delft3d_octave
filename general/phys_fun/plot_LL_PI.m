function plot_LL_PI(LL,PL)

% This function vizualises the Atterberg Limits. It creates a figure 
% with the Liquid Limit on the horizontal axis and the Plasticity 
% Index on the vertical axis. The plasticity index is computed from 
% the Liquid Limit and the Plastic Limit.
%
% Input:
% LL    Liquid Limit [%]
% PL    Plastic Limit [%]
%
% Output: figure and png in current directory

PI = LL-PL;

% Data needed for figure
LLa = (4/0.73+20):160;
LLb = (7/0.9+8):160;
Aline = 0.73*(LLa-20);
Bline = 0.9*(LLb-8);
LLm = 45:135;
LLk = 45:160;
LLi = 60:135;
Bm = 0.9*(LLm-9);
Ak = 0.73*(LLk-18.6);
Ai = 0.73*(LLi-21.4);

%%

figure
set(gcf,'Papersize',[6.5 11],'paperposition',[0.25 1.5 8 4])
plot([20 20],[0 120],'k:')
hold on
plot([35 35],[0 120],'k:')
hold on
plot([50 50],[0 120],'k:')
hold on
plot([70 70],[0 120],'k:')
hold on
plot([90 90],[0 120],'k:')
hold on
plot(LLm,Bm,'linewidth',3,'color',[1 0.8 0])
hold on
plot(LLk,Ak,'linewidth',3,'color',[0 0.8 1])
hold on
plot(LLi,Ai,'linewidth',3,'color',[0.6 1 0.3])
hold on
plot(LLa,Aline,'k')
hold on
plot(LLb,Bline,'k')
hold on
plot([0 LLa(1)],[4 4],'k:')
hold on
plot([0 LLb(1)],[7 7],'k:')
hold on

plot(LL,PI,'bo','markerfacecolor','b')

xlim([0 160])
xlabel('Liquid Limit LL [%]')
ylim([0 120])
ylabel('Plasticity Index PI [%]')
text(78,40,'A-line')
text(55,53,'B-line')
text(16,77,'A-line: 0.73*(LL - 20)','backgroundcolor','w')
text(16,70,'B-line: 0.90*(LL - 8)','backgroundcolor','w')
text(80,100,'inorganic soils')
text(100,30','silt and organic soils')
text(83,70,'montmorillonite \rightarrow','horizontalalignment','right','fontsize',8)
text(142,89,'\leftarrow kaolinite','fontsize',8)
text(96,55,'\leftarrow illite','fontsize',8)
set(gca,'xminortick','on','yminortick','on')

axes('position',[0 0.93 1 0.08],'visible','off')
text(0.18,0,'non-plastic','fontsize',8,'horizontalalignment','center','verticalalignment','bottom');
text(0.265,0,[{'low'};{'plasticity'}],'fontsize',8,'horizontalalignment','center','verticalalignment','bottom');
text(0.335,0,[{'medium'};{'plasticity'}],'fontsize',8,'horizontalalignment','center','verticalalignment','bottom');
text(0.42,0,[{'high'};{'plasticity'}],'fontsize',8,'horizontalalignment','center','verticalalignment','bottom');
text(0.52,0,[{'very high'};{'plasticity'}],'fontsize',8,'horizontalalignment','center','verticalalignment','bottom');
text(0.67,0,'extremely high plasticity','fontsize',8,'horizontalalignment','center','verticalalignment','bottom');

print(gcf,'-r300','-dpng','LL_vs_PI')
end