function h=muppet_plotGrid(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

if isfield(data,'xdam')
    if size(data.xdam,1)>0
        h=thindam(data.x,data.y,data.xdam,data.xdam);
        set(h,'LineStyle',opt.linestyle,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
    else
        xdam=zeros(size(data.x));
        xdam=xdam+1;
        ydam=xdam;
        h=thindam(data.x,data.y,xdam,ydam);
        set(h,'LineStyle',opt.linestyle,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
    end
else
%     XDam=zeros(size(data.x));
%     XDam=XDam+1;
%     YDam=XDam;
%     h=thindam(data.x,data.y,XDam,YDam);
%     set(h,'LineStyle',opt.linestyle,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));

    if size(data.x,1)==1 || size(data.x,2)==1
        [x,y]=meshgrid(data.x,data.y);
    else
        x=data.x;
        y=data.y;
    end
    x(isnan(data.z))=NaN;
    y(isnan(data.y))=NaN;
    h=plot(x,y);
    set(h,'LineStyle',opt.linestyle,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
    h=plot(x',y');
    set(h,'LineStyle',opt.linestyle,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
end
