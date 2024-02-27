function h=muppet_plotFreeText(handles,i,j,k)

h=[];

fig=handles.figures(i).figure;
plt=fig.subplots(j).subplot;
opt=plt.datasets(k).dataset;
nr=muppet_findDatasetNumber(handles,opt.name);
fontred=fig.fontreduction;
data=handles.datasets(nr).dataset;

data.text=handles.datasets(nr).dataset.text;
data.x=handles.datasets(nr).dataset.x;
data.y=handles.datasets(nr).dataset.y;
data.rotation=handles.datasets(nr).dataset.rotation;
data.curvature=handles.datasets(nr).dataset.curvature;
data.name=handles.datasets(nr).dataset.name;

if data.curvature==0

    tx=text(data.x,data.y,data.text);
    set(tx,'Fontsize',opt.font.size*fontred);
    set(tx,'Fontangle',opt.font.angle);
    set(tx,'FontName',opt.font.name);
    set(tx,'color',colorlist('getrgb','color',opt.font.color));
    set(tx,'HorizontalAlignment','center');
%     set(tx,'VerticalAlignment',opt.font.verticalalignment);
%     ext=get(tx,'Extent');
%     len=sqrt(ext(3)^2 + ext(4)^2);
%     set(tx,'rotation',data.rotation);
    set(tx,'HitTest','off');
    set(tx,'Clipping','on');
    txc=-1;

else

    nn=20;
    tx=text(data.x,data.y,8000,data.String);
    set(tx,'HorizontalAlignment','center');
    set(tx,'Fontsize',opt.font.size*fontred);
    set(tx,'Fontsize',opt.font.size);
    set(tx,'Fontangle',opt.font.angle);
    set(tx,'Fontweight',opt.font.weight);
    set(tx,'FontName',opt.font.name);
    ext=get(tx,'Extent');
    len=sqrt(ext(3)^2 + ext(4)^2);
    set(tx,'Visible','off');

    for i=1:length(data.text)
        t1=text(data.x,data.y,8000,data.text(i));
        set(t1,'HorizontalAlignment','center');
        set(t1,'Fontsize',opt.font.size*fontred);
        set(t1,'Fontangle',opt.font.angle);
        set(t1,'Fontweight',opt.font.weight);
        set(t1,'FontName',opt.font.name);
        ext1=get(t1,'Extent');
        delete(t1);
        t10=text(data.x,data.y,8000,repmat(data.text(i),1,nn));
        set(t10,'HorizontalAlignment','center');
        set(t10,'Fontsize',opt.font.size*fontred);
        set(t10,'Fontangle',opt.font.angle);
        set(t10,'Fontweight',opt.font.weight);
        set(t10,'FontName',opt.font.name);
        ext10=get(t10,'Extent');
        delete(t10);
        dx(i)=(ext10(3)-ext1(3))/(nn-1);
    end
    
    extt=sum(dx);
    rel(i)=0.5*dx(i);
    relp(i)=rel(i)/extt;
    for i=2:length(data.text)
        rel(i)=rel(i-1)+0.5*dx(i-1)+0.5*dx(i);
        relp(i)=rel(i)/extt;
    end

    r=data.Curvature;
    x0=data.x+r*sin(pi*data.rotation/180);
    y0=data.y-r*cos(pi*data.rotation/180);
    if r>0
        r=max(r,1e-3);
    else
        r=min(r,-1e-3);
    end
    tt=0:2*pi/200:2*pi;
    for i=1:length(data.text)
        ang=360*(relp(i)-0.5)*(extt/(2*pi*r))-data.rotation;
        px(i)=x0+r*cos(pi/2-pi*ang/180);
        py(i)=y0+r*sin(pi/2-pi*ang/180);
        txc(i)=text(px(i),py(i),8000,data.text(i));
        set(txc(i),'rotation',-ang);
        set(txc(i),'VerticalAlignment','baseline');
        set(txc(i),'HorizontalAlignment','center');
        set(txc(i),'Fontsize',opt.font.size*fontred);
        set(txc(i),'Fontangle',opt.font.angle);
        set(txc(i),'Fontweight',opt.font.weight);
        set(txc(i),'FontName',opt.font.name);
        set(txc(i),'color',colorlist('getrgb','color',opt.font.color));
        set(txc(i),'HitTest','off');
        set(txc(i),'Clipping','on');
    end
end

iopt=1;

if iopt==1

    tx0=text(data.x,data.y,data.text);
    set(tx0,'HorizontalAlignment',opt.font.horizontalalignment);
    set(tx0,'Fontsize',opt.font.size*fontred);
    set(tx0,'Fontangle',opt.font.angle);
    set(tx0,'Fontweight',opt.font.weight);
    set(tx0,'FontName',opt.font.name);
    set(tx0,'rotation',data.rotation);
    set(tx0,'Visible','off');
    
    ext=get(tx0,'Extent');
    len=ext(3);
    cenx=ext(1)+0.5*ext(3);
    ceny=ext(2)+0.5*ext(4);
    extentx=[cenx-0.5*len*cos(data.rotation*pi/180) cenx+0.5*len*cos(data.rotation*pi/180)];
    extenty=[ceny-0.5*len*sin(data.rotation*pi/180) ceny+0.5*len*sin(data.rotation*pi/180)];
    
    sh(1)=plot(extentx(1),extenty(1),'ko');
    sh(2)=plot(cenx,ceny,'ko');
    sh(3)=plot(extentx(2),extenty(2),'ko');

    for k=1:3
        set(sh(k),'Tag','SelectionHighlight','Markersize',3);
        set(sh(k),'ButtonDownFcn',{@muppet_UIEditText});
        shusd.Parent=tx;
        shusd.nr=k;
        set(sh(k),'UserData',shusd);
    end

    usd.SelectionHighlights=sh;

    usd.tx=tx;
    usd.name=data.name;
    usd.txc=txc;
    
    set(tx,'Tag','FreeText');
    set(tx,'UserData',usd);
    set(usd.tx,'Clipping','on');

end
