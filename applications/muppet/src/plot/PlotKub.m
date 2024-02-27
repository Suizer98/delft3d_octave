function handles=PlotKub(handles,i,j,k,mode)

DeleteObject(i,j,k);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);
 
xmin=Ax.CMin;
xmax=Ax.CMax;
cstep=Ax.CStep;
nocol=floor((xmax-xmin)/cstep);
 
[x,y]=landboundary('read',Data.PolygonFile);
 
polno=1;
jj=1;
for ii=1:size(x,1)
    if (isnan(x(ii)))
        polno=polno+1;
        jj=1;
    else
        xldb{polno}(jj)=x(ii);
        yldb{polno}(jj)=y(ii);
        jj=jj+1;
    end
end
 
sz=size(Data.z,1);
 
clmap=GetColors(handles.ColorMaps,Ax.ColMap,100);
 
for ii=1:sz;
    x0=Data.z(ii);
    x0=max(min(x0,xmax),xmin);
    x=(x0-xmin)/(xmax-xmin);
    ix=round(99*x)+1;
    col{ii}(1)=clmap(ix,1);
    col{ii}(2)=clmap(ix,2);
    col{ii}(3)=clmap(ix,3);
end
 
for ii=1:sz
 
    switch Plt.KubFill,
        case 1
            ldbplt=fill(xldb{ii},yldb{ii},'r');hold on;
            set(ldbplt,'FaceColor',[col{ii}(1) col{ii}(2) col{ii}(3)]);
            set(ldbplt,'EdgeColor',FindColor(Plt.LineColor));
            set(ldbplt,'LineWidth',Plt.LineWidth);
        case 0
            xxxx=xldb{ii};
            yyyy=yldb{ii};
            cl=FindColor(Plt.LineColor);
            ldbplt=plot(xxxx,yyyy);hold on;
            set(ldbplt,'LineWidth',Plt.LineWidth,'Color',cl);
    end
    SetObjectData(ldbplt,i,j,k,'kubintarea');

    xtxt=0.5*(max(xldb{ii}(1:end-1))+min(xldb{ii}(1:end-1)));
    ytxt=0.5*(max(yldb{ii}(1:end-1))+min(yldb{ii}(1:end-1)));
 
    if Plt.AreaText==1
        frmt=['%0.' num2str(Plt.Decim) 'f'];
        tx=num2str(Data.z(ii)*Plt.Multiply,frmt);
        txt=text(xtxt,ytxt,3000,tx);
        set(txt,'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on');
        set(txt,'FontName',Plt.Font);
        set(txt,'FontWeight',Plt.FontWeight);
        set(txt,'FontAngle',Plt.FontAngle);
        set(txt,'FontSize',Plt.FontSize);
        set(txt,'Color',FindColor(Plt.FontColor));
    elseif Plt.AreaText==2
        tx=num2str(ii);
        txt=text(xtxt,ytxt,3000,tx);
        set(txt,'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on');
        set(txt,'FontName',Plt.Font);
        set(txt,'FontWeight',Plt.FontWeight);
        set(txt,'FontAngle',Plt.FontAngle);
        set(txt,'FontSize',Plt.FontSize);
        set(txt,'Color',FindColor(Plt.FontColor));
    end
    SetObjectData(txt,i,j,k,'kubinttext');

end
 
clmap=GetColors(handles.ColorMaps,Ax.ColMap,nocol);
colormap(clmap);
 
caxis([xmin xmax]);
