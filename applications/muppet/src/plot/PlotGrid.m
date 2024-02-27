function handles=PlotGrid(handles,i,j,k,mode)

Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);
 
z=zeros(size(Data.x));
z=z+500;

if isfield(Data,'XDam')
    if size(Data.XDam,1)>0
        h=thindam(Data.x,Data.y,Data.XDam,Data.YDam);
        set(h,'LineStyle',Plt.LineStyle,'LineWidth',Plt.LineWidth,'Color',FindColor(Plt.LineColor));
    else
        XDam=zeros(size(Data.x));
        XDam=XDam+1;
        YDam=XDam;
        h=thindam(Data.x,Data.y,XDam,YDam);
        set(h,'LineStyle',Plt.LineStyle,'LineWidth',Plt.LineWidth,'Color',FindColor(Plt.LineColor));
    end
    SetObjectData(h,i,j,k,'marker');
else
    XDam=zeros(size(Data.x));
    XDam=XDam+1;
    YDam=XDam;
    h=thindam(Data.x,Data.y,XDam,YDam);
    set(h,'LineStyle',Plt.LineStyle,'LineWidth',Plt.LineWidth,'Color',FindColor(Plt.LineColor));
    SetObjectData(h,i,j,k,'marker');
end

hold on;
