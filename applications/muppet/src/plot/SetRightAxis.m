function SetRightAxis(FigureProperties,SubplotProperties,ax)

set(gca,'Ylim',[SubplotProperties.YMinRight SubplotProperties.YMaxRight]);
if SubplotProperties.YTickRight>-900.0
    yticks=[SubplotProperties.YMinRight:SubplotProperties.YTickRight:SubplotProperties.YMaxRight];
    set(gca,'ytick',yticks);

    if SubplotProperties.DecimYRight>=0
        frmt=['%0.' num2str(SubplotProperties.DecimYRight) 'f'];
        for i=1:size(yticks,2)
            ylabls{i}=sprintf(frmt,yticks(i));
        end
        set(gca,'yticklabel',ylabls);
    end

    if SubplotProperties.DecimYRight==-999.0
        for i=1:size(yticks,2)
            ylabls{i}='';
        end
        set(gca,'yticklabel',ylabls);
    end
else
    tick(gca,'y','none');
end

tick(gca,'x','none');

set(gca,'YAxisLocation','right');
set(gca,'Color','none');

set(gca,'FontName',SubplotProperties.AxesFont);
set(gca,'FontSize',SubplotProperties.AxesFontSize*FigureProperties.FontRed);
set(gca,'FontAngle',SubplotProperties.AxesFontAngle);
set(gca,'FontWeight',SubplotProperties.AxesFontWeight);
set(gca,'XColor',FindColor(SubplotProperties.AxesFontColor));
set(gca,'YColor',FindColor(SubplotProperties.AxesFontColor));
set(gca,'Units',FigureProperties.Units);
set(gca,'Position',SubplotProperties.Position*FigureProperties.cm2pix);

box on;

ylabel(SubplotProperties.YLabelRight,'FontSize',SubplotProperties.YLabelFontSizeRight*FigureProperties.FontRed,'FontName',SubplotProperties.YLabelFontRight,'Color',FindColor(SubplotProperties.YLabelFontColorRight),'FontWeight',SubplotProperties.YLabelFontWeightRight,'FontAngle',SubplotProperties.YLabelFontAngleRight);
