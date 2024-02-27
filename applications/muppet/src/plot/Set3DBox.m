function Set3DBox(FigureProperties,SubplotProperties);

ax1=axes;

set(ax1,'Position',[0.2 0.0 0.1 0.1]);

x1=0.0;
x2=SubplotProperties.Position(1);
x3=SubplotProperties.Position(1)+SubplotProperties.Position(3);
x4=FigureProperties.PaperSize(1);

y1=0.0;
y2=SubplotProperties.Position(2);
y3=SubplotProperties.Position(2)+SubplotProperties.Position(4);
y4=FigureProperties.PaperSize(2);

%         fill([x1 x4 x4 x1],[y1 y1 y2 y2],[0.999 0.999 0.999],'EdgeColor','none');hold on;
%         fill([x1 x4 x4 x1],[y3 y3 y4 y4],[0.999 0.999 0.999],'EdgeColor','none');hold on;
%         fill([x1 x2 x2 x1],[y1 y1 y4 y4],[0.999 0.999 0.999],'EdgeColor','none');hold on;
%         fill([x3 x4 x4 x3],[y1 y1 y4 y4],[0.999 0.999 0.999],'EdgeColor','none');hold on;
fl(1)=fill([x1 x4 x4 x1],[y1 y1 y2 y2],FigureProperties.BackgroundColor,'EdgeColor','none');hold on;
fl(2)=fill([x1 x4 x4 x1],[y3 y3 y4 y4],FigureProperties.BackgroundColor,'EdgeColor','none');hold on;
fl(3)=fill([x1 x2 x2 x1],[y1 y1 y4 y4],FigureProperties.BackgroundColor,'EdgeColor','none');hold on;
fl(4)=fill([x3 x4 x4 x3],[y1 y1 y4 y4],FigureProperties.BackgroundColor,'EdgeColor','none');hold on;
set(fl,'HitTest','off');

plt=plot([x2 x3 x3 x2 x2],[y2 y2 y3 y3 y2],'k','LineWidth',0.6);
set(plt,'HitTest','off');

set(ax1,'xlim',[0 FigureProperties.PaperSize(1)]);
set(ax1,'ylim',[0 FigureProperties.PaperSize(2)]);

set(gca,'Units',FigureProperties.Units);

t=SubplotProperties.Position*FigureProperties.cm2pix;
PaperSize=FigureProperties.PaperSize*FigureProperties.cm2pix;

set(ax1,'Position',[0.0 0.0 PaperSize(1) PaperSize(2)],'Color','none');box off;

txtx=SubplotProperties.Position(1)+0.5*SubplotProperties.Position(3);
txty=SubplotProperties.Position(2)+SubplotProperties.Position(4)+0.4;
txt=text(txtx,txty,SubplotProperties.Title,'FontSize',SubplotProperties.TitleFontSize*FigureProperties.FontRed,'FontName',SubplotProperties.TitleFont,'Color',SubplotProperties.TitleFontColor,'FontWeight',SubplotProperties.TitleFontWeight,'FontAngle',SubplotProperties.TitleFontAngle);
set(txt,'HorizontalAlignment','center');
set(txt,'VerticalAlignment','bottom');
set(ax1,'HitTest','off');
