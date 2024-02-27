function handles=PlotAnnotation(handles,i,j,k,mode)

DeleteObject(i,j,k);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);

x=Data.x;
y=Data.y;

sz=length(x);

for ii=1:sz

    if strcmpi(Plt.Marker,'none')==0
        sc=scatter3(x(ii),y(ii),1000,Plt.MarkerSize,Plt.Marker);hold on;
        set(sc,'MarkerEdgeColor',FindColor(Plt.MarkerEdgeColor),'MarkerFaceColor',FindColor(Plt.MarkerFaceColor));
        handles.Figure(i).Axis(j).Plot(k).Handle=sc;
        set(sc,'Clipping','on');
    else
        sc=scatter3(x(ii),y(ii),1000);hold on;        
        set(sc,'MarkerEdgeColor','none','MarkerFaceColor','none');
        handles.Figure(i).Axis(j).Plot(k).Handle=sc;
    end
    SetObjectData(sc,i,j,k,'annotationmarker');

    hold on;
    
    if Plt.AddText
        if strcmpi(Plt.Marker,'none')
            PlotText(Data,Plt,handles.DefaultColors,Fig.FontRed,0,ii);
        else
            dist=0.001*Ax.Scale;
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
            tx=text(x1,y1,1000,[Data.Annotation{ii}]);
            set(tx,'FontName',Plt.Font);
            set(tx,'FontWeight',Plt.FontWeight);
            set(tx,'FontAngle',Plt.FontAngle);
            set(tx,'FontSize',Plt.FontSize*Fig.FontRed);
            set(tx,'Color',FindColor(Plt.FontColor));
            set(tx,'HorizontalAlignment',HorAl,'VerticalAlignment',VerAl);
            set(tx,'Rotation',Data.Rotation(ii));
            set(tx,'Clipping','on');
            SetObjectData(tx,i,j,k,'annotationtext');
        end
    end
end
 
clear x y z x1 y1 tx sc


