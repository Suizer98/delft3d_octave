function muppet_setRightAxis(handles,ifig,isub)

plt=handles.figures(ifig).figure.subplots(isub).subplot;
fontred=handles.figures(ifig).figure.fontreduction;
cm2pix=handles.figures(ifig).figure.cm2pix;
units=handles.figures(ifig).figure.units;

set(gca,'Ylim',[plt.yminright plt.ymaxright]);
if plt.ytickright>-900.0
    yticks=plt.yminright:plt.ytickright:plt.ymaxright;
    set(gca,'ytick',yticks);

    if plt.ydecimalsright>=0
        frmt=['%0.' num2str(plt.ydecimalsright) 'f'];
        for i=1:size(yticks,2)
            ylabls{i}=sprintf(frmt,yticks(i));
        end
        set(gca,'yticklabel',ylabls);
    end

    if plt.ydecimalsright==-999.0
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

set(gca,'FontName',plt.font.name);
set(gca,'FontSize',plt.font.size*fontred);
set(gca,'FontAngle',plt.font.angle);
set(gca,'FontWeight',plt.font.weight);
set(gca,'XColor',colorlist('getrgb','color',plt.font.color));
set(gca,'YColor',colorlist('getrgb','color',plt.font.color));
set(gca,'Units',units);
set(gca,'Position',plt.position*cm2pix);

box on;

ylabel(plt.ylabelright.text,'FontSize',plt.ylabelright.font.size*fontred,'FontName',plt.ylabelright.font.name, ...
    'Color',colorlist('getrgb','color',plt.ylabelright.font.color),'FontWeight',plt.ylabelright.font.weight,'FontAngle',plt.ylabelright.font.angle);
