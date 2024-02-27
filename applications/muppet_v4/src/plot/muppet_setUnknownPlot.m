function muppet_setUnknownPlot(fig,isub)

cm2pix=fig.cm2pix;
units=fig.units;

xlim=[0 1];
ylim=[0 1];
 
set(gca,'Xlim',xlim,'YLim',ylim);
 
tick(gca,'x','none');
tick(gca,'y','none');

box on;
 
set(gca,'Units',units);
set(gca,'Position',fig.subplots(isub).subplot.position*cm2pix);
set(gca,'Layer','top');
