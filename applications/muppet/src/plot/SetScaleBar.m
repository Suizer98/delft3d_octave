function ScaleBar=SetScaleBar(handles,i,j);

h=findobj(gcf,'Tag','scalebar','UserData',[i,j]);
delete(h);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);

ScaleBar=axes;

len=Ax.ScaleBar(3);
ht=len/20;
nb=5;

for ii=1:nb
 
    x1{ii}(1)=0;
    x1{ii}(2)=len/nb;
    x1{ii}(3)=len/nb;
    x1{ii}(4)=0;
    y1{ii}(1)=0;
    y1{ii}(2)=0;
    y1{ii}(3)=ht/2;
    y1{ii}(4)=ht/2;
    x1{ii}=x1{ii}+(ii-1)*len/nb;

    x2{ii}(1)=0;
    x2{ii}(2)=len/5;
    x2{ii}(3)=len/5;
    x2{ii}(4)=0;
    y2{ii}(1)=ht/2;
    y2{ii}(2)=ht/2;
    y2{ii}(3)=ht;
    y2{ii}(4)=ht;
    x2{ii}=x2{ii}+(ii-1)*len/5;
 
end

for ii=1:nb
    fl1=fill(x1{ii},y1{ii},'k');hold on;
    fl2=fill(x2{ii},y2{ii},'k');
    if round(ii/2)==ii/2
        set(fl1,'FaceColor',[1 1 1]);
        set(fl2,'FaceColor',[0 0 0]);
    else
        set(fl1,'FaceColor',[0 0 0]);
        set(fl2,'FaceColor',[1 1 1]);
    end
end
%axis equal;
view(2);
 
tick(ScaleBar,'x','none');
tick(ScaleBar,'y','none');
set(ScaleBar,'xlim',[0 len],'ylim',[0 ht]);

pos(1)=Ax.ScaleBar(1);
pos(2)=Ax.ScaleBar(2);
pos(3)=100*len/Ax.Scale;
pos(4)=100*ht/Ax.Scale;

set(ScaleBar,'Units',Fig.Units);
set(ScaleBar,'Position',pos*Fig.cm2pix);

tit=title(Ax.ScaleBarText);
set(tit,'FontSize',6);
set(tit,'HitTest','off');

box on;
axis on;

c=get(ScaleBar,'Children');
ff=findall(c,'HitTest','on');
set(ff,'HitTest','off');

set(ScaleBar,'Tag','scalebar','UserData',[i,j]);
set(ScaleBar,'ButtonDownFcn',{@SelectScaleBar});

clear x0 y0 x1 y1 z1 x2 y2 z2 tx
