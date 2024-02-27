colour  = {'r','r','g'};ii=1;

for ii=1:10
    txturl{ii}=['number',num2str(ii-1),'.png'];
    scaleFAC=1;
    figure('visible','off');
    set(gcf,'MenuBar','None','Position',[50 50 15 30],'PaperSize',[10,30],'PaperPosition',[0 0 0.4*scaleFAC 0.6*scaleFAC]);
    h3=text(0.97,0.5,num2str(ii-1),'FontSize',20,'HorizontalAlignment','Right','Color','r','FontWeight','Bold');
    axis off;set(gca,'Position',[0,0,1,1],'Color',[0 0 0]);
    print(gcf,'-dpng',txturl{ii});
    I =imread(txturl{ii});
    imwrite(I,txturl{ii},'transparency',[0 0 0],'background',[0.0 0.0 0.0]);close all;
end

txturl{ii}=['numberdot.png'];
scaleFAC=1;
CMAP = colormap;
figure('visible','off');
set(gcf,'MenuBar','None','Position',[50 50 15 30],'PaperSize',[10,30],'PaperPosition',[0 0 0.2*scaleFAC 0.6*scaleFAC]);
h3=text(0.97,0.5,'.','FontSize',20,'HorizontalAlignment','Right','Color','r','FontWeight','Bold');
axis off;set(gca,'Position',[0,0,1,1],'Color',[0.0 0.0 0.0]);
print(gcf,'-dpng',txturl{ii});
I =imread(txturl{ii});
imwrite(I,txturl{ii},'transparency',[0.0 0.0 0.0],'background',[0.0 0.0 0.0]);close all;
%imwrite(I,txturl{ii},'Alpha',I3);close all;

txturl{ii}=['numberminus.png'];
scaleFAC=1;
figure('visible','off');
set(gcf,'MenuBar','None','Position',[50 50 15 30],'PaperSize',[10,30],'PaperPosition',[0 0 0.3*scaleFAC 0.6*scaleFAC]);
h3=text(0.84,0.5,'-','FontSize',20,'HorizontalAlignment','Right','Color','r','FontWeight','Bold');
axis off;set(gca,'Position',[0,0,1,1],'Color',[0 0 0]);
print(gcf,'-dpng',txturl{ii});
I =imread(txturl{ii});
imwrite(I,txturl{ii},'transparency',[0 0 0],'background',[0.0 0.0 0.0]);close all;

txturl{ii}=['numbereuro.png'];
scaleFAC=1;
figure('visible','off');
set(gcf,'MenuBar','None','Position',[50 50 15 30],'PaperSize',[10,30],'PaperPosition',[0 0 0.4*scaleFAC 0.6*scaleFAC]);
h3=text(0.97,0.5,sprintf('%c',8364),'FontSize',20,'HorizontalAlignment','Right','Color','r','FontWeight','Bold');
axis off;set(gca,'Position',[0,0,1,1],'Color',[0 0 0]);
print(gcf,'-dpng',txturl{ii});
I =imread(txturl{ii});
imwrite(I,txturl{ii},'transparency',[0 0 0],'background',[0.0 0.0 0.0]);close all;


txturl{ii}=['numbermillion.png'];
scaleFAC=1;
figure('visible','off');
set(gcf,'MenuBar','None','Position',[50 50 15 30],'PaperSize',[10,30],'PaperPosition',[0 0 0.8*scaleFAC 0.6*scaleFAC]);
h3=text(0.97,0.5,'\cdot10^6','FontSize',11,'HorizontalAlignment','Right','Color','r','FontWeight','Bold');
axis off;set(gca,'Position',[0,0,1,1],'Color',[0 0 0]);
print(gcf,'-dpng',txturl{ii});
I =imread(txturl{ii});
imwrite(I,txturl{ii},'transparency',[0 0 0],'background',[0.0 0.0 0.0]);close all;
