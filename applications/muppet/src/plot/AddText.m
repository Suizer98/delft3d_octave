function AddText(FigureProperties,DefaultColors);
 
 
txt=0;
for i=1:9
    if size(FigureProperties.Text(i).Text,2)>0
        txt=1;
    end
end
 
if txt==1
    subplt=axes;
 
    set(subplt,'Units',FigureProperties.Units);
    set(subplt,'Position',[0.0 0.0 FigureProperties.PaperSize(1)*FigureProperties.cm2pix FigureProperties.PaperSize(2)*FigureProperties.cm2pix]);
    set(subplt,'XLim',[0 FigureProperties.PaperSize(1)],'YLim',[0 FigureProperties.PaperSize(2)]);
    set(subplt,'color','none');
    tick(subplt,'x','none');
    tick(subplt,'y','none');
    box off;
 
    for i=1:9
        if size(FigureProperties.Text(i).Text,2)>0
            Color=FindColor(FigureProperties.Text(i),'Color',DefaultColors);
            tx(i)=text(FigureProperties.Text(i).Position(1),FigureProperties.Text(i).Position(2),FigureProperties.Text(i).Text);
            set(tx(i),'FontSize',FigureProperties.Text(i).Size*FigureProperties.FontRed);
            set(tx(i),'FontAngle',FigureProperties.Text(i).Angle);
            set(tx(i),'FontName',FigureProperties.Text(i).Font);
            set(tx(i),'Color',Color);
            set(tx(i),'HorizontalAlignment',FigureProperties.Text(i).HorAl);
            set(tx(i),'VerticalAlignment',FigureProperties.Text(i).VerAl);
        end
    end
end
