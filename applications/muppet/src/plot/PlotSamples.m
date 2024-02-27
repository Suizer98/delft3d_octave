function handles=PlotSamples(handles,i,j,k,mode)

DeleteObject(i,j,k);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

x=Data.x;
y=Data.y;
z=zeros(size(x));
col=[0 1];

if strcmp(lower(Plt.Marker),'none')==0 & strcmp(lower(Plt.MarkerFaceColor),'auto')==1 
    if strcmp(lower(Ax.ContourType),'limits')
        col=[Ax.CMin:Ax.CStep:Ax.CMax];
    else
        col=Ax.Contours;
    end
    ncol=size(col,2)-1;
    clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
    colormap(clmap);
    c1=col(1);
    c2=col(end);
    zz1=max(Data.z,c1);
    zz1=min(zz1,c2);
    zz1=Data.z;
    zz1(isnan(Data.z))=NaN;
    z=zz1;
    for ii=1:ncol
        z(and(z>=col(ii),z<col(ii+1)))=col(ii);
    end
end

z1=zeros(size(x));
z1=z1+3000;

if strcmp(lower(Plt.Marker),'none')==0
    s=scatter3(x,y,z1,Plt.MarkerSize,z,'filled',Plt.Marker);
    if strcmp(lower(Plt.MarkerEdgeColor),'none')==0 & strcmp(lower(Plt.MarkerEdgeColor),'auto')==0
        set(s,'MarkerEdgeColor',FindColor(Plt.MarkerEdgeColor));
    end
    if strcmp(lower(Plt.MarkerFaceColor),'auto')==0
        set(s,'MarkerFaceColor',FindColor(Plt.MarkerFaceColor));
    end
    caxis([col(1) col(end-1)]);
    handles.Figure(i).Axis(j).Plot(k).Handle=s(1);
    SetObjectData(s,i,j,k,'samples');
end

hold on;

if Plt.AddText
    sz=length(x);
    for ii=1:sz       
        dist=0.0015*Ax.Scale;
        switch lower(Plt.TextPosition),
            case{'northeast','east','southeast'}
                x1=x(ii)+dist;
                HorAl='left';
            case{'north','middle','south'}
                x1=x(ii);
                HorAl='center';
            case{'northwest','west','southwest'}
                x1=x(ii)-dist;
                HorAl='right';
        end                
        switch lower(Plt.TextPosition),
            case{'northeast','north','northwest'}
                y1=y(ii)+dist;
                VerAl='bottom';
            case{'east','middle','west'}
                y1=y(ii);
                VerAl='middle';
            case{'southeast','south','southwest'}
                y1=y(ii)-dist;
                VerAl='top';
        end                   
        str=num2str(Data.z(ii));
        tx=text(x1,y1,3000,str);
        set(tx,'FontName',Plt.Font);
        set(tx,'FontWeight',Plt.FontWeight);
        set(tx,'FontAngle',Plt.FontAngle);
        set(tx,'FontSize',Plt.FontSize);
        set(tx,'Color',Plt.FontColor);
        set(tx,'HorizontalAlignment',HorAl,'VerticalAlignment',VerAl);
        set(tx,'Clipping','on');
        SetObjectData(tx,i,j,k,'sampletext');
        hold on;
    end
end
 
clear x y z tx col zz1

