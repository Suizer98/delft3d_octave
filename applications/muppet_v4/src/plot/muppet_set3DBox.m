function muppet_set3DBox(handles,ifig,isub)

fig=handles.figures(ifig).figure;
plt=fig.subplots(isub).subplot;

ax1=axes;

set(ax1,'position',[0.2 0.0 0.1 0.1]);

x1=0.0;
x2=plt.position(1);
x3=plt.position(1)+plt.position(3);
x4=fig.width;

y1=0.0;
y2=plt.position(2);
y3=plt.position(2)+plt.position(4);
y4=fig.height;

bgc=colorlist('getrgb','color',fig.backgroundcolor);

fl(1)=fill([x1 x4 x4 x1],[y1 y1 y2 y2],bgc,'EdgeColor','none');hold on;
fl(2)=fill([x1 x4 x4 x1],[y3 y3 y4 y4],bgc,'EdgeColor','none');hold on;
fl(3)=fill([x1 x2 x2 x1],[y1 y1 y4 y4],bgc,'EdgeColor','none');hold on;
fl(4)=fill([x3 x4 x4 x3],[y1 y1 y4 y4],bgc,'EdgeColor','none');hold on;
set(fl,'HitTest','off');

p=plot([x2 x3 x3 x2 x2],[y2 y2 y3 y3 y2],'k','LineWidth',0.6);
set(p,'HitTest','off');

set(ax1,'xlim',[0 fig.width]);
set(ax1,'ylim',[0 fig.height]);

set(gca,'Units',fig.units);

paperwidth=fig.width*fig.cm2pix;
paperheight=fig.height*fig.cm2pix;

set(ax1,'position',[0.0 0.0 paperwidth paperheight],'Color','none');box off;

txtx=plt.position(1)+0.5*plt.position(3);
txty=plt.position(2)+plt.position(4)+0.4;
txt=text(txtx,txty,plt.title.text,'FontSize',plt.title.font.size*fig.fontreduction,'FontName',plt.title.font.name, ...
    'Color',plt.title.font.color,'FontWeight',plt.title.font.weight,'FontAngle',plt.title.font.angle);
set(txt,'HorizontalAlignment','center');
set(txt,'VerticalAlignment','bottom');
set(ax1,'HitTest','off');
