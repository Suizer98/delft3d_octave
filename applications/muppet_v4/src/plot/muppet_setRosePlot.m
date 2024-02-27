function muppet_setRosePlot(handles,ifig,isub)

plt=handles.figures(ifig).figure.subplots(isub).subplot;
cm2pix=handles.figures(ifig).figure.cm2pix;
units=handles.figures(ifig).figure.units;

xlim=[-1.05 1.05];
ylim=[-1.05 1.05];
 
view(2);
 
set(gca,'Xlim',xlim,'YLim',ylim);
 
tick(gca,'x','none');
tick(gca,'y','none');

pos(1)=plt.position(1);
pos(2)=plt.position(2);
pos(3)=plt.position(3);
pos(4)=plt.position(3)* (ylim(2)-ylim(1))/(xlim(2)-xlim(1)) ;

set(gca,'Units',units);
set(gca,'Position',cm2pix*pos);

if plt.drawbox
    box on;
    axis on;
else
    box off;
    axis off;
end
