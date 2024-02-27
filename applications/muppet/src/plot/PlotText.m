function [tx,txc]=PlotText(DataProperties,PlotOptions,DefaultColors,FontRed,opt,varargin);

if nargin==6
    k=varargin{1};
    DataProperties.String=DataProperties.Annotation{k};
    DataProperties.Position(1)=DataProperties.x(k);
    DataProperties.Position(2)=DataProperties.y(k);
    DataProperties.Rotation=DataProperties.Rotation(k);
    DataProperties.Curvature=DataProperties.Curvature(k);
end

if DataProperties.Curvature==0

    tx=text(DataProperties.Position(1),DataProperties.Position(2),8000,DataProperties.String);
    set(tx,'FontSize',PlotOptions.FontSize*FontRed);
    set(tx,'FontAngle',PlotOptions.FontAngle);
    set(tx,'FontName',PlotOptions.Font);
    Color=FindColor(PlotOptions,'FontColor',DefaultColors);
    set(tx,'Color',Color);
    set(tx,'HorizontalAlignment',PlotOptions.HorAl);
    set(tx,'VerticalAlignment',PlotOptions.VerAl);
    ext=get(tx,'Extent');
    len=sqrt(ext(3)^2 + ext(4)^2);
    set(tx,'Rotation',DataProperties.Rotation);
    set(tx,'HitTest','off');
    set(tx,'Clipping','on');
    txc=-1;

else

    nn=20;
    tx=text(DataProperties.Position(1),DataProperties.Position(2),8000,DataProperties.String);
    set(tx,'HorizontalAlignment','center');
    set(tx,'FontSize',PlotOptions.FontSize*FontRed);
    set(tx,'FontSize',PlotOptions.FontSize);
    set(tx,'FontAngle',PlotOptions.FontAngle);
    set(tx,'FontWeight',PlotOptions.FontWeight);
    set(tx,'FontName',PlotOptions.Font);
    ext=get(tx,'Extent');
    len=sqrt(ext(3)^2 + ext(4)^2);
    set(tx,'Visible','off');

    for i=1:length(DataProperties.String)
        t1=text(DataProperties.Position(1),DataProperties.Position(2),8000,DataProperties.String(i));
        set(t1,'HorizontalAlignment','center');
        set(t1,'FontSize',PlotOptions.FontSize*FontRed);
        set(t1,'FontAngle',PlotOptions.FontAngle);
        set(t1,'FontWeight',PlotOptions.FontWeight);
        set(t1,'FontName',PlotOptions.Font);
        ext1=get(t1,'Extent');
        delete(t1);
        t10=text(DataProperties.Position(1),DataProperties.Position(2),8000,repmat(DataProperties.String(i),1,nn));
        set(t10,'HorizontalAlignment','center');
        set(t10,'FontSize',PlotOptions.FontSize*FontRed);
        set(t10,'FontAngle',PlotOptions.FontAngle);
        set(t10,'FontWeight',PlotOptions.FontWeight);
        set(t10,'FontName',PlotOptions.Font);
        ext10=get(t10,'Extent');
        delete(t10);
        dx(i)=(ext10(3)-ext1(3))/(nn-1);
    end
    ext10;
    ext1;
    extt=sum(dx);
    rel(i)=0.5*dx(i);
    relp(i)=rel(i)/extt;
    for i=2:length(DataProperties.String)
        rel(i)=rel(i-1)+0.5*dx(i-1)+0.5*dx(i);
        relp(i)=rel(i)/extt;
    end

    r=DataProperties.Curvature;
    x0=DataProperties.Position(1)+r*sin(pi*DataProperties.Rotation/180);
    y0=DataProperties.Position(2)-r*cos(pi*DataProperties.Rotation/180);
    if r>0
        r=max(r,1e-3);
    else
        r=min(r,-1e-3);
    end
    tt=0:2*pi/200:2*pi;
    for i=1:length(DataProperties.String)
        ang=360*(relp(i)-0.5)*(extt/(2*pi*r))-DataProperties.Rotation;
        px(i)=x0+r*cos(pi/2-pi*ang/180);
        py(i)=y0+r*sin(pi/2-pi*ang/180);
        txc(i)=text(px(i),py(i),8000,DataProperties.String(i));
        set(txc(i),'Rotation',-ang);
        set(txc(i),'VerticalAlignment','baseline');
        set(txc(i),'HorizontalAlignment','center');
        set(txc(i),'FontSize',PlotOptions.FontSize*FontRed);
        set(txc(i),'FontAngle',PlotOptions.FontAngle);
        set(txc(i),'FontWeight',PlotOptions.FontWeight);
        set(txc(i),'FontName',PlotOptions.Font);
        Color=FindColor(PlotOptions,'FontColor',DefaultColors);
        set(txc(i),'Color',Color);
        set(txc(i),'HitTest','off');
        set(txc(i),'Clipping','on');
    end
end

if opt==1

    tx0=text(DataProperties.Position(1),DataProperties.Position(2),DataProperties.String);
    set(tx0,'HorizontalAlignment',PlotOptions.HorAl);
    set(tx0,'FontSize',PlotOptions.FontSize*FontRed);
    set(tx0,'FontAngle',PlotOptions.FontAngle);
    set(tx0,'FontWeight',PlotOptions.FontWeight);
    set(tx0,'FontName',PlotOptions.Font);
    set(tx0,'Rotation',DataProperties.Rotation);
    ext=get(tx0,'Extent');
    set(tx0,'Visible','off');
    
    ext=get(tx0,'Extent');
    cenx=ext(1)+0.5*ext(3);
    ceny=ext(2)+0.5*ext(4);
    extentx=[cenx-0.5*len*cos(DataProperties.Rotation*pi/180) cenx+0.5*len*cos(DataProperties.Rotation*pi/180)];
    extenty=[ceny-0.5*len*sin(DataProperties.Rotation*pi/180) ceny+0.5*len*sin(DataProperties.Rotation*pi/180)];
    
    sh(1)=plot(extentx(1),extenty(1),'ko');
    sh(2)=plot(cenx,ceny,'ko');
    sh(3)=plot(extentx(2),extenty(2),'ko');

    for k=1:3
        set(sh(k),'Tag','SelectionHighlight','MarkerSize',3);
        set(sh(k),'ButtonDownFcn',{@UIEditText});
        shusd.Parent=tx;
        shusd.nr=k;
        set(sh(k),'UserData',shusd);
    end

    usd.SelectionHighlights=sh;

    usd.tx=tx;
    usd.Name=DataProperties.Name;
    usd.txc=txc;
    
    set(tx,'Tag','FreeText');
    set(tx,'UserData',usd);
    set(usd.tx,'Clipping','on');

end
