function mp_plot2DSurface(handles,Data,Plt,Ax)

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
            col=Plt.CMin:Plt.CStep:Plt.CMax;
        else
            col=Plt.Contours;
        end
end

c1=col(1);
c2=col(end);
dc=col(2)-col(1);

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
        x=Data.x;
        y=Data.y;
        z=Data.zz;
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

zc=z;
cax=[col(1) col(end)];
contours=col(1:end);

        
switch(lower(Plt.PlotRoutine))
    case{'plotpatches'}
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,64);
        colormap(clmap);
        h=pcolor(x,y,zc);shading flat;
        caxis(cax);
    case{'plotcontourmap','plotcontourmaplines'}

        
        if strcmpi(Ax.ContourType,'limits')
            zc=z;
            cax=[col(1) col(end-1)];
            contours=col(1:end-1);
        else
            isn=isnan(z);
            zc=z;
            zc=max(zc,col(1));
            zc=min(zc,col(end));
            zc=interp1(col,1:length(col),zc);
            zc(isn)=NaN;
            cax=[1 length(col)-1];
            contours=1:length(col)-1;
        end
        
        
        
        ncol=size(col,2)-1;
%        clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,64);
%        [c,h,wp]=contourf_mvo(x,y,zc,[contours(1)-dc:dc:contours(end)]);
%        [c,h,wp]=contourf_mvo(x,y,zc,[contours(1):dc:contours(end-1)]);
        [c,h,wp]=contourf_mvo(x,y,zc,contours);
%        colormap('jet');
        colormap(clmap);
%        caxis([col(1)-dc col(end)+dc]);
%        caxis([col(1)-dc col(end)]);
%        caxis([col(1) col(end-1)]);
        caxis(cax);
%        [c,h,wp]=contourf(x,y,zc,contours);
    case{'plotshadesmap'}
        ncol=128;
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
        colormap(clmap);
        h=surf(x,y,zc);
        shading interp;
        caxis(cax);
    case{'plotcontourlines'}
        [c,h]=contour(x,y,z,col);
        if strcmpi(Plt.LineColor,'auto')==0
            set(h,'LineColor',FindColor(Plt.LineColor));
        end
        set(h,'LineStyle',Plt.LineStyle);
        set(h,'LineWidth',Plt.LineWidth);
end

hold on;

if strcmpi(Plt.PlotRoutine,'plotcontourmaplines')
    [c,h]=contour(x,y,z,col(2:end-1));
    if strcmpi(Plt.LineColor,'auto')==0
        set(h,'LineColor',FindColor(Plt.LineColor));
    else
        set(h,'LineColor','k');
    end
    set(h,'LineStyle',Plt.LineStyle);
    set(h,'LineWidth',Plt.LineWidth);
end

if strcmpi(Plt.PlotRoutine,'plotcontourmap') && Plt.ContourLabels
    [c,h]=contour(x,y,z,col(2:end-1));
    set(h,'LineStyle','none');
end

if Plt.ContourLabels==1
    hh=clabel(c,h,'FontSize',Plt.FontSize,'LabelSpacing',Plt.LabelSpacing);
    set(hh,'FontSize',Plt.FontSize);
    set(hh,'Color',FindColor(Plt.FontColor));
end
