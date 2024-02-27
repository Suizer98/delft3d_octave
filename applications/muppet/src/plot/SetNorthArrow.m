function NorthArrow=SetNorthArrow(handles,i,j)

h=findobj(gcf,'Tag','northarrow','UserData',[i,j]);
delete(h);

Fig=handles.Figure(i);
Ax=handles.Figure(i).Axis(j);

NorthArrow=axes;

sz=Ax.NorthArrow(3);
angle=Ax.NorthArrow(4);

x0=0;
y0=0;
s1=1.0;
s2=0.4;

for ii=1:4
 
    a=pi*(angle+(ii-1)*90)/180;
    x1{ii}(1)=0;
    x1{ii}(2)=s2*cos(a-pi/4);
    x1{ii}(3)=s1*cos(a);
    x1{ii}(4)=0;
    x1{ii}(1)=0;
    y1{ii}(2)=s2*sin(a-pi/4);
    y1{ii}(3)=s1*sin(a);
    y1{ii}(4)=0;
    x1{ii}=x1{ii}+x0;
    y1{ii}=y1{ii}+y0;
 
    x2{ii}(1)=0;
    x2{ii}(2)=s1*cos(a);
    x2{ii}(3)=s2*cos(a+pi/4);
    x2{ii}(4)=0;
    y2{ii}(1)=0;
    y2{ii}(2)=s1*sin(a);
    y2{ii}(3)=s2*sin(a+pi/4);
    y2{ii}(4)=0;
    x2{ii}=x2{ii}+x0;
    y2{ii}=y2{ii}+y0;
 
    z1{ii}=zeros(size(x1{ii}))+10;
    z2{ii}=z1{ii};
 
    tx{ii}=1.4*s1*cos(a)+x0;
    ty{ii}=1.4*s1*sin(a)+y0;
 
end
 
for ii=1:4
    fl=fill3(x1{ii},y1{ii},z1{ii},'k');hold on;
    set(fl,'FaceColor',[0 0 0]);
    fl=fill3(x2{ii},y2{ii},z2{ii},'k');
    set(fl,'FaceColor',[1 1 1]);
    axis equal;view(2);
end
 
txt{1}=text(tx{1},ty{1},10,'N');
set(txt{1},'FontName','Times','FontSize',sz*8,'Rotation',angle-90,'HorizontalAlignment','center','VerticalAlignment','middle');
txt{2}=text(tx{2},ty{2},10,'W');
set(txt{2},'FontName','Times','FontSize',sz*8,'Rotation',angle-90,'HorizontalAlignment','center','VerticalAlignment','middle');
txt{3}=text(tx{3},ty{3},10,'S');
set(txt{3},'FontName','Times','FontSize',sz*8,'Rotation',angle-90,'HorizontalAlignment','center','VerticalAlignment','middle');
txt{4}=text(tx{4},ty{4},10,'E');
set(txt{4},'FontName','Times','FontSize',sz*8,'Rotation',angle-90,'HorizontalAlignment','center','VerticalAlignment','middle');

tick(NorthArrow,'x','none');
tick(NorthArrow,'y','none');
set(NorthArrow,'color','none');
set(NorthArrow,'xlim',[-1 1],'ylim',[-1 1]);

pos(1)=Ax.NorthArrow(1);
pos(2)=Ax.NorthArrow(2);
pos(3)=Ax.NorthArrow(3);
pos(4)=Ax.NorthArrow(3);

set(NorthArrow,'Units',Fig.Units);
set(NorthArrow,'Position',pos*Fig.cm2pix);

if Fig.cm2pix==1
    box off;
    axis off;
else
    set(NorthArrow,'XColor',[0.8 0.8 0.8]);
    set(NorthArrow,'YColor',[0.8 0.8 0.8]);
    box on;
end

view(2);
axis equal;

c=get(NorthArrow,'Children');
ff=findall(c,'HitTest','on');
set(ff,'HitTest','off');

set(NorthArrow,'Tag','northarrow','UserData',[i,j]);
set(NorthArrow,'ButtonDownFcn',{@SelectNorthArrow});

clear x0 y0 x1 y1 z1 x2 y2 z2 tx
