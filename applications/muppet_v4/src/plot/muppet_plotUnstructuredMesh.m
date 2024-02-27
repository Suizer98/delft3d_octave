function h=muppet_plotUnstructuredMesh(handles,ifig,isub,id)

plt=handles.figures(ifig).figure.subplots(isub).subplot;
nr=plt.datasets(id).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(id).dataset;

hold on;

h=dflowfm.plotNet(data.G,'face',[],'node',[]); 
set(h.edge,'Color',opt.linecolor);
set(h.edge,'LineWidth',opt.linewidth);
set(h.edge,'LineStyle',opt.linestyle);
set(h.edge,'LineWidth',0.1);

h=h.edge;
