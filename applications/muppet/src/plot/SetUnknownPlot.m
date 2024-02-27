function SetUnknownPlot(FigureProperties,SubplotProperties);
 
xlim=[0 1];
ylim=[0 1];
 
set(gca,'Xlim',xlim,'YLim',ylim);
 
tick(gca,'x','none');
tick(gca,'y','none');

box on;
 
set(gca,'Units',FigureProperties.Units);
set(gca,'Position',SubplotProperties.Position*FigureProperties.cm2pix);
set(gca,'Layer','top');
 
