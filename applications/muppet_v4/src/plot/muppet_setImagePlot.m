function muppet_setImagePlot(handles,ifig,isub)

plt=handles.figures(ifig).figure.subplots(isub).subplot;

cm2pix=handles.figures(ifig).figure.cm2pix;
units=handles.figures(ifig).figure.units;

n=plt.datasets(1).dataset.number;

data=handles.datasets(n).dataset;

%data.x=data.x(1:plt.datasets(1).dataset.fieldthinningfactor1:end,1:plt.datasets(1).dataset.fieldthinningfactor1:end);
%imagesize=size(data.x');
imagesize(1)=size(data.c,1);
imagesize(2)=size(data.c,2);

xlim(1)=1;xlim(2)=imagesize(2);
ylim(1)=1;ylim(2)=imagesize(1);

view(2);
 
set(gca,'Xlim',xlim,'YLim',ylim);

tick(gca,'x','none');
tick(gca,'y','none');
 
height=plt.position(3)*imagesize(1)/imagesize(2);
 
set(gca,'Units',units);
set(gca,'Position',cm2pix*[plt.position(1) plt.position(2) plt.position(3) height]);
 
if plt.drawbox
    box on;
    axis on;
else
    box off;
    axis off;
end
