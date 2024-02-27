function northarrow=muppet_setNorthArrow(fig,ifig,isub)

h=findobj(gcf,'Tag','northarrow','UserData',[ifig,isub]);
delete(h);

plt=fig.subplots(isub).subplot;

northarrow=axes;

% if plt.northarrow.position(1)==0
%     x0=plt.position(1)+1.5;
%     y0=plt.position(2)+plt.position(4)-1.5;
%     sz=1.0;
%     angle=90;
%     plt.northarrow.position=[x0 y0 sz angle];
% end

sz=plt.northarrow.position(3);
angle=plt.northarrow.position(4);

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

tick(northarrow,'x','none');
tick(northarrow,'y','none');
set(northarrow,'color','none');
set(northarrow,'xlim',[-1 1],'ylim',[-1 1]);

pos(1)=plt.northarrow.position(1)+plt.position(1);
pos(2)=plt.northarrow.position(2)+plt.position(2);
pos(3)=plt.northarrow.position(3);
pos(4)=plt.northarrow.position(3);

set(northarrow,'Units',fig.units);
set(northarrow,'Position',pos*fig.cm2pix);

if fig.export
    box off;
    axis off;
else
    set(northarrow,'XColor',[0.8 0.8 0.8]);
    set(northarrow,'YColor',[0.8 0.8 0.8]);
    box on;
end

view(2);
axis equal;

c=get(northarrow,'Children');
ff=findall(c,'HitTest','on');
set(ff,'HitTest','off');

set(northarrow,'Tag','northarrow','UserData',[ifig,isub]);
% set(northarrow,'ButtonDownFcn',{@muppet_selectNorthArrow});
