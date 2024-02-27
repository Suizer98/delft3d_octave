function handles=PlotLint(handles,i,j,k,mode)
 
DeleteObject(i,j,k);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);
Plt=handles.Figure(i).Axis(j).Plot(k);
Data=handles.DataProperties(Plt.AvailableDatasetNr);
 
yarr(1)=0.50;  xarr(1)=-5;
yarr(2)=0.50;  xarr(2)=2;
yarr(3)=1.5;   xarr(3)=2;
yarr(4)=0;     xarr(4)=5;
yarr(5)=-1.5;  xarr(5)=2;
yarr(6)=-0.50; xarr(6)=2;
yarr(7)=-0.50; xarr(7)=-5;
yarr(8)=0.50 ; xarr(8)=-5;
 
[x,y]=landboundary('read',Data.PolygonFile);
trcum0=Data.z;
%trcum=PlotOptions.LintScale*trcum0;
trcum=trcum0;
 
polno=1;
jj=1;
for ii=1:size(x,1)
    if (isnan(x(ii)))
        polno=polno+1;
        jj=1;
    else
        lintldb{polno}(jj,1)=x(ii);
        lintldb{polno}(jj,2)=y(ii);
        lintldb{polno}(jj,3)=500;
        jj=jj+1;
    end
end
 
for ii=1:polno;
    x0 = lintldb{ii}(1,1);
    x1 = lintldb{ii}(end,1);
    y0 = lintldb{ii}(1,2);
    y1 = lintldb{ii}(end,2);
    alfa0 = atan2((y1-y0),(x1-x0));
    if (trcum(ii)>=0)
        alfa(ii)=alfa0+pi/2;
    else
        alfa(ii)=alfa0-pi/2;
    end
    xcen=0.5*(x0+x1);ycen=0.5*(y0+y1);
    if Plt.UnitArrow==0    
        logval=log10(abs(max(trcum)));
    else
        logval=log10(abs(Plt.UnitArrow));
    end        
    minval=logval-3;
    scaling(ii)=Plt.LintScale*Ax.Scale*max(log10(abs(trcum(ii)))-minval,0);
    scaling(ii)=scaling(ii)*0.005;
%    if abs(trcum(i))<1000
%        scaling=0;
%    end
    for jj=1:8;
        dist=scaling(ii)*0.1*sqrt(xarr(jj)^2+yarr(jj)^2);
        ang0=atan2(yarr(jj),xarr(jj));
        ang1=ang0+alfa(ii);
        arr{ii}(jj,1)=dist*cos(ang1)+xcen;
        arr{ii}(jj,2)=dist*sin(ang1)+ycen;
        arr{ii}(jj,3)=3000+ii*10;
    end
    dist=0.002*Ax.Scale;
    if (cos(alfa(ii))>=0)
        ang0=atan2(1.2,-0.5);ang1=ang0+alfa(ii);
        txx(ii)=dist*cos(ang1)+xcen;
        txy(ii)=dist*sin(ang1)+ycen;
        txz(ii)=3000;
        txtang(ii)=180*alfa(ii)/pi;
    else
        ang0=atan2(-1.2,-0.5);ang1=ang0+alfa(ii);
        txx(ii)=dist*cos(ang1)+xcen;
        txy(ii)=dist*sin(ang1)+ycen;
        txtang(ii)=180*alfa(ii)/pi-180;
        txz(ii)=3000+ii*10;
    end
end
 
for ii=1:polno;
    if scaling(ii)>0
        if Plt.FillPolygons
            fl=fill3(arr{ii}(:,1),arr{ii}(:,2),arr{ii}(:,3),'r');hold on;
            set(fl,'FaceColor',FindColor(Plt.ArrowColor),'LineStyle','none');
            SetObjectData(fl,i,j,k,'lintarrow');
        end
 
        lin=line(arr{ii}(:,1),arr{ii}(:,2),arr{ii}(:,3));hold on;
        set(lin,'LineWidth',Plt.LineWidth,'Color',FindColor(Plt.LineColor));hold on;
        SetObjectData(lin,i,j,k,'lintarrow');

        if Plt.AddText
            frmt=['%0.' num2str(Plt.Decim) 'f'];
            tx=num2str(abs(trcum(ii))*Plt.Multiply,frmt);
            txt=text(txx(ii),txy(ii),txz(ii),tx);
            set(txt,'Rotation',txtang(ii),'HorizontalAlignment','center','Clipping','on');
            set(txt,'VerticalAlignment','baseline');
            set(txt,'FontName',Plt.Font);
            set(txt,'FontWeight',Plt.FontWeight);
            set(txt,'FontAngle',Plt.FontAngle);
            set(txt,'FontSize',Plt.FontSize);
            set(txt,'Color',FindColor(Plt.FontColor));
            SetObjectData(txt,i,j,k,'linttext');

        end
    end
end
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
