function SetRosePlot(FigureProperties,SubplotProperties,ImageSize);
 
xlim=[-1.05 1.05];
ylim=[-1.05 1.05];
 
view(2);
 
set(gca,'Xlim',xlim,'YLim',ylim);
 
tick(gca,'x','none');
tick(gca,'y','none');

pos(1)=SubplotProperties.Position(1);
pos(2)=SubplotProperties.Position(2);
pos(3)=SubplotProperties.Position(3);
pos(4)=SubplotProperties.Position(3)* (ylim(2)-ylim(1))/(xlim(2)-xlim(1)) ;

set(gca,'Units',FigureProperties.Units);
set(gca,'Position',FigureProperties.cm2pix*pos);

if SubplotProperties.DrawBox
    box on;
    axis on;
else
    box off;
    axis off;
end
