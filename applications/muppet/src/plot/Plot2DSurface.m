function handles=Plot2DSurface(handles,i,j,k,mode)

DeleteObject(i,j,k);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);
Data.x=Data.x(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor1:end);
Data.y=Data.y(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor1:end);
Data.z=Data.z(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor1:end);
Data.zz=Data.zz(1:Plt.FieldThinningFactor1:end,1:Plt.FieldThinningFactor1:end);

if Ax.AxesEqual==0
    VertScale=(Ax.YMax-Ax.YMin)/Ax.Position(4);
    HoriScale=(Ax.XMax-Ax.XMin)/Ax.Position(3);
    Multi=HoriScale/VertScale;
else
    Multi=1.0;
end
Multi=1.0;
Data.y=Multi*Data.y;

switch(lower(Plt.PlotRoutine)),
    case{'plotpatches','plotshadesmap','plotcontourmap','plotcontourmaplines'}
        if strcmpi(Ax.ContourType,'limits')
            col=[Ax.CMin:Ax.CStep:Ax.CMax];
        else
            col=Ax.Contours;
        end
    case{'plotcontourlines'}
        if strcmpi(Plt.ContourType,'limits')
            col=[Plt.CMin:Plt.CStep:Plt.CMax];
        else
            col=Plt.Contours;
        end
end

c1=col(1);
c2=col(end);

switch(lower(Plt.PlotRoutine)),
    case{'plotpatches'}
        zz1=max(Data.zz,c1);
        zz1=min(zz1,c2);
        zz1(isnan(Data.zz))=NaN;
        xx=Data.x(1:end-1,1:end-1);
        yy=Data.y(1:end-1,1:end-1);
        zz=zz1(2:end,2:end);
        n=(size(xx,1)-1)*(size(xx,2)-1);
        x=xx';
        y=yy';
        z=zz';
        xp(1,:)=reshape(x(1:end-1,1:end-1),1,n);
        xp(2,:)=reshape(x(2:end,1:end-1),1,n);
        xp(3,:)=reshape(x(2:end,2:end),1,n);
        xp(4,:)=reshape(x(1:end-1,2:end),1,n);
        yp(1,:)=reshape(y(1:end-1,1:end-1),1,n);
        yp(2,:)=reshape(y(2:end,1:end-1),1,n);
        yp(3,:)=reshape(y(2:end,2:end),1,n);
        yp(4,:)=reshape(y(1:end-1,2:end),1,n);
        zp=reshape(z(1:end-1,1:end-1),1,n);
        xp(1,isnan(zp))=NaN;
        yp(1,isnan(zp))=NaN;
        x=xp;
        y=yp;
        z=zp;
    case{'plotshadesmap','plotcontourlines'}
        x=Data.x;
        y=Data.y;
        z=Data.z;
    case{'plotcontourmap','plotcontourmaplines'}
        z=max(Data.z,c1);
        z=min(z,c2);
        z(isnan(Data.z))=NaN;
        x=Data.x;
        y=Data.y;
        xmean=mean(x(isfinite(x)));
        ymean=mean(y(isfinite(y)));
        z(isnan(x))=NaN;
        x(isnan(x))=xmean;
        y(isnan(y))=ymean;
end


switch(lower(Plt.PlotRoutine)),
    case{'plotpatches'}
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,64);
        colormap(clmap);
        h=patch(x,y,z);shading flat;
        caxis([col(1) col(end)]);
    case{'plotcontourmap','plotcontourmaplines'}
        ncol=size(col,2)-1;
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
        [c,h,wp]=contourf_mvo(x,y,z,col,clmap);
        SetObjectData(wp,i,j,k,'2dsurface');
        if length(col)>3
            caxis([col(2) col(end-1)]);
        end        
    case{'plotshadesmap'}
        ncol=128;
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
        colormap(clmap);
        h=surf(x,y,z);
        shading interp;
        caxis([col(1) col(end)]);
    case{'plotcontourlines'}
        [c,h]=contour(x,y,z,col);
        if strcmpi(Plt.LineColor,'auto')==0
            set(h,'LineColor',FindColor(Plt.LineColor));
        end
        set(h,'LineStyle',Plt.LineStyle);
        set(h,'LineWidth',Plt.LineWidth);
end
SetObjectData(h,i,j,k,'2dsurface');

hold on;

if strcmpi(Plt.PlotRoutine,'plotcontourmaplines')
    [c,h]=contour(x,y,z,col);
    if strcmpi(Plt.LineColor,'auto')==0
        set(h,'LineColor',FindColor(Plt.LineColor));
    else
        set(h,'LineColor','k');
    end
    set(h,'LineStyle',Plt.LineStyle);
    set(h,'LineWidth',Plt.LineWidth);
    SetObjectData(h,i,j,k,'2dsurface');
end

if strcmpi(Plt.PlotRoutine,'plotcontourmap') && Plt.ContourLabels
    [c,h]=contour(x,y,z,col);
    set(h,'LineStyle','none');
    SetObjectData(h,i,j,k,'2dsurface');
end

if Plt.ContourLabels==1
    hh=clabel(c,h,'FontSize',Plt.FontSize,'LabelSpacing',Plt.LabelSpacing);
    set(hh,'FontSize',Plt.FontSize);
    set(hh,'Color',FindColor(Plt.FontColor));
    SetObjectData(hh,i,j,k,'2dsurface');
end

clear x;
clear y;
clear zz1;
clear z;
clear c
clear h
clear xmean ymean xp yp xx yy zz
