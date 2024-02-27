function h=muppet_plotGrid3D(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

h=mesh(data.x,data.y,data.z);
set(h,'LineStyle',opt.linestyle);
set(h,'LineWidth',opt.linewidth);

if opt.onecolor
    set(h,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
end

caxis([plt.cmin plt.cmax]);
