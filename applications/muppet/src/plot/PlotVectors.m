function handles=PlotVectors(handles,i,j,k,mode)

DeleteObject(i,j,k);

Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

switch lower(Plt.FieldThinningType),
    case{'none'}
        x=Data.x;
        y=Data.y;
        u=Data.u;
        v=Data.v;
    case{'uniform'}
        x=Data.x(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor2:end);
        y=Data.y(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor2:end);
        u=Data.u(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor2:end);
        v=Data.v(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor2:end);
end

z=zeros(size(x));
z=z+500;
w=zeros(size(u));

if Ax.AxesEqual==0
    VertScale=(Ax.YMax-Ax.YMin)/Ax.Position(4);
    HoriScale=(Ax.XMax-Ax.XMin)/Ax.Position(3);
    MultiY=HoriScale/VertScale;
else
    MultiY=1.0;
end
MultiY=1.0;
MultiV=Plt.VerticalVectorScaling;

if strcmpi(Plt.PlotRoutine,'plotvectors')
    qv=quiver3(x,MultiY*y,z,Plt.UnitVector*u,MultiV*Plt.UnitVector*v,w,0);hold on;
    set(qv,'Color',FindColor(Plt.VectorColor));
else
    if ~Plt.PlotColorBar
        if strcmpi(Ax.ContourType,'limits')
            col=[Ax.CMin:(Ax.CMax-Ax.CMin)/64:Ax.CMax];
        else
            col=Ax.Contours;
        end
        ncol=size(col,2)-1;
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
        colormap(clmap);
        caxis([col(2) col(end-1)]);
        qv=quiver3(x,MultiY*y,z,Plt.UnitVector*u,MultiV*Plt.UnitVector*v,w,0);hold on;
        qv=mp_colquiver(qv,sqrt(u.^2+v.^2));
    else
        colorfix;
        col=[Plt.CMin:(Plt.CMax-Plt.CMin)/64:Plt.CMax];
        ncol=size(col,2)-1;
        clmap=GetColors(handles.ColorMaps,Plt.ColMap,ncol);
        colormap(clmap);
        caxis([col(2) col(end-1)]);
        qv=quiver3(x,MultiY*y,z,Plt.UnitVector*u,MultiV*Plt.UnitVector*v,w,0);hold on;
        qv=mp_colquiver(qv,sqrt(u.^2+v.^2));
        colorfix;
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
        colormap(clmap);
    end
end
SetObjectData(qv,i,j,k,'vectors');

