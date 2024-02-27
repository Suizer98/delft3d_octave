function handles=PlotCrossSections(handles,i,j,k,mode)

DeleteObject(i,j,k);

Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

x=Data.x;
y=Data.y;
z=zeros(size(x));
z=z+2000;

lin=line(x,y,z);
set(lin,'LineStyle',Plt.LineStyle,'LineWidth',Plt.LineWidth,'Color',FindColor(Plt.LineColor));hold on;

sz=length(Data.Annotation);

for ii=1:sz
    x0=x(3*ii-2);
    x1=x(3*ii-1);
    y0=y(3*ii-2);
    y1=y(3*ii-1);
    x2=0.5*(x0+x1);
    y2=0.5*(y0+y1);
    tx=text(x2,y2,2000,deblank(['  ' Data.Annotation{ii}]));hold on;
    set(tx,'FontName',Plt.Font);
    set(tx,'FontWeight',Plt.FontWeight);
    set(tx,'FontAngle',Plt.FontAngle);
    set(tx,'FontSize',Plt.FontSize);
    set(tx,'Color',Plt.FontColor);
    set(tx,'Rotation',Data.Rotation(i));
    set(tx,'HorizontalAlignment','center');
    set(tx,'Clipping','on');
    SetObjectData(tx,i,j,k,'crosssection');
    hold on;
end

clear x y z x0 x1 x2 y0 y1 y2

