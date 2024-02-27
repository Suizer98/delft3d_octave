function h=muppet_plotKub(handles,i,j,k)

h=[];

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

xmin=plt.cmin;
xmax=plt.cmax;

sz=size(data.z,1);

clmap=muppet_getColors(handles.colormaps,plt.colormap,100);
colormap(clmap);

for ii=1:sz;
    x0=data.average(ii);
    x0=max(min(x0,xmax),xmin);
    x=(x0-xmin)/(xmax-xmin);
    ix=round(99*x)+1;
    col{ii}(1)=clmap(ix,1);
    col{ii}(2)=clmap(ix,2);
    col{ii}(3)=clmap(ix,3);
end

for ii=1:sz
    
    switch opt.kubfill
        case 1
            % Filled polygons
            ldbplt=fill(data.polygon(ii).x,data.polygon(ii).y,'r');hold on;
            set(ldbplt,'FaceColor',[col{ii}(1) col{ii}(2) col{ii}(3)]);
            set(ldbplt,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
            set(ldbplt,'LineWidth',opt.linewidth);
            set(ldbplt,'FaceAlpha',opt.opacity);
        case 0
            % No fill color
            xxxx=data.polygon(ii).x;
            yyyy=data.polygon(ii).y;
            ldbplt=plot(xxxx,yyyy);hold on;
            set(ldbplt,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
    end
    
    xtxt=0.5*(max(data.polygon(ii).x(1:end-1))+min(data.polygon(ii).x(1:end-1)));
    ytxt=0.5*(max(data.polygon(ii).y(1:end-1))+min(data.polygon(ii).y(1:end-1)));
    
    tx=[];
    switch lower(opt.areatext)
        case{'values'}
            % Plot actual values
            frmt=['%0.' num2str(opt.decimals) 'f'];
            tx=num2str(data.z(ii)*opt.multiply,frmt);
        case{'polygonnumbers'}
            % Just plot indices of polygons
            tx=num2str(ii);
        case{'polygonnames'}
            % Polygon names
            tx=data.polygon(ii).name;
    end
    
    if ~isempty(tx)
        txt=text(xtxt,ytxt,tx);
        set(txt,'HorizontalAlignment','center','VerticalAlignment','middle','Clipping','on');
        set(txt,'FontName',opt.font.name);
        set(txt,'FontWeight',opt.font.weight);
        set(txt,'FontAngle',opt.font.angle);
        set(txt,'FontSize',opt.font.size*handles.figures(i).figure.fontreduction);
        set(txt,'Color',colorlist('getrgb','color',opt.font.color));
    end
    
end

caxis([xmin xmax]);
