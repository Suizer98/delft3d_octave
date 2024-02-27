function SetImagePlot(FigureProperties,SubplotProperties,PlotOptions,DataProperties,ImageSize);


n=PlotOptions(1).AvailableDatasetNr;
 
DataProperties(n).x=DataProperties(n).x(1:PlotOptions(1).FieldThinningFactor1:end,1:PlotOptions(1).FieldThinningFactor1:end);
ImageSize=size(DataProperties(n).x');

xlim(1)=1;xlim(2)=ImageSize(1);
ylim(1)=1;ylim(2)=ImageSize(2);

view(2);
 
set(gca,'Xlim',xlim,'YLim',ylim);

tick(gca,'x','none');
tick(gca,'y','none');
 
height=SubplotProperties.Position(3)*ImageSize(2)/ImageSize(1);
 
set(gca,'Units',FigureProperties.Units);
set(gca,'Position',FigureProperties.cm2pix*[SubplotProperties.Position(1) SubplotProperties.Position(2) SubplotProperties.Position(3) height]);
 
if SubplotProperties.DrawBox
    box on;
    axis on;
else
    box off;
    axis off;
end

clear DataProperties
