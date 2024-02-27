function scalebar=muppet_setScaleBar(fig,ifig,isub)

% Delete existing scale bar
h=findobj(gcf,'Tag','scalebar','UserData',[ifig,isub]);
delete(h);

plt=fig.subplots(isub).subplot;

% if plt.scalebar.position(3)==0
%     % No position data available
%     x0=plt.position(1)+1.5;
%     y0=plt.position(2)+1.5;
%     z0=round(0.04*plt.scale);
%     plt.scalebar.position=[x0 y0 z0];
%     plt.scalebar.text=[num2str(z0) ' m'];
% end

scalebar=axes;

%len=plt.scalebar.position(3);
len=plt.scalebar.length;
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
%     set(fl1,'EdgeColor',[1 1 1]);
%     set(fl2,'EdgeColor',[1 1 1]);
end

view(2);
 
tick(scalebar,'x','none');
tick(scalebar,'y','none');
set(scalebar,'xlim',[0 len],'ylim',[0 ht]);

pos(1)=plt.scalebar.position(1)+plt.position(1);
pos(2)=plt.scalebar.position(2)+plt.position(2);
pos(3)=100*len/plt.scale;
pos(4)=100*ht/plt.scale;

set(scalebar,'Units',fig.units);
set(scalebar,'Position',pos*fig.cm2pix);

set(scalebar,'XColor',colorlist('getrgb','color',plt.scalebar.boxcolor));
set(scalebar,'YColor',colorlist('getrgb','color',plt.scalebar.boxcolor));

tit=title(plt.scalebar.text);
set(tit,'FontName',plt.scalebar.font.name);
set(tit,'FontSize',plt.scalebar.font.size*fig.fontreduction);
set(tit,'FontWeight',plt.scalebar.font.weight);
set(tit,'FontAngle',plt.scalebar.font.angle);
set(tit,'Color',colorlist('getrgb','color',plt.scalebar.font.color));
set(tit,'HitTest','off');

box on;
axis on;

c=get(scalebar,'Children');
ff=findall(c,'HitTest','on');
set(ff,'HitTest','off');

set(scalebar,'Tag','scalebar','UserData',[ifig,isub]);
