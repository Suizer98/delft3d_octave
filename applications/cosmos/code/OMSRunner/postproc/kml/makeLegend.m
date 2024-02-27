function makeLegend(fname,col,wdt,marker,txt)


sz1=6;
sz2=2;

n=length(col);

x=[0.1 0.5];

figure(999)
set(gcf,'Visible','off');
set(gcf,'Units','pixels');
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0  sz1 sz2]);
set(gcf,'PaperSize',[sz1 sz2]);
axes;
set(gca,'Units','centimeters');
set(gca,'Position',[-0.1 -0.1 sz1+0.2 sz2+0.2]);

for i=1:n
    y=[n+1-i n+1-i];
    plt=plot(x,y);hold on;
    set(plt,'Color',col{i});
    set(plt,'LineWidth',wdt(i));
    tx=text(0.6,y(1),txt{i});
    set(tx,'Color',[1 1 0]);
    set(tx,'FontSize',10);
end

set(gca,'xlim',[0 3],'ylim',[0 n+1]);
set(gca,'XTick',[-1000 1000]);
set(gca,'YTick',[-1000 1000]);

set(gcf,'Units','pixels');
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0 0  sz1 sz2]);
set(gcf,'PaperSize',[sz1 sz2]);
set(gca,'Units','centimeters');
set(gca,'Position',[-0.1 -0.1 sz1+0.2 sz2+0.2]);

print('-dpng','-r100',fname,'-opengl');

close(999);

cdata = imread(fname);
cc=sum(cdata,3);
alp=ones(size(cdata,1),size(cdata,2));
alp(cc==765)=0;
imwrite(cdata, fname, 'png', 'alpha', alp);
