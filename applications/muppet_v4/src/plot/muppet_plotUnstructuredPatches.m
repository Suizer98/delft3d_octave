function h=muppet_plotUnstructuredPatches(handles,ifig,isub,id)

h=[];

plt=handles.figures(ifig).figure.subplots(isub).subplot;
nr=plt.datasets(id).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(id).dataset;

if ~plt.usecustomcontours
    col=plt.cmin:plt.cstep:plt.cmax;
else
    col=plt.customcontours;
end

%h = trisurfcorcen(data.G.tri,data.G.cor.x,data.G.cor.y,data.z(data.G.map3));
h = trisurfcorcen(data.G.tri,data.G.node.x,data.G.node.y,data.z(data.G.map3));
set(h,'edgeColor','none'); % we do not want to see the triangle edges as they do not exist on D-Flow FM network

hold on;

if opt.plotgrid
    dflowfm.plotNet(data.G,'face',[],'node',[]); 
end

clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
colormap(clmap);
caxis([col(1) col(end)]);
