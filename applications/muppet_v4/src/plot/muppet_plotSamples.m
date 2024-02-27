function h=muppet_plotSamples(handles,i,j,k)

fig=handles.figures(i).figure;
plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

x=data.x;
y=data.y;
z=data.z;

%% Set color limits
if ~strcmpi(opt.marker,'none') && strcmpi(opt.markerfacecolor,'automatic')
    % Only when markers are plotted and when their color is set
    % automatically
    col=plt.cmin:plt.cstep:plt.cmax;
    ncol=size(col,2)-1;
    for ii=1:ncol
        z(and(z>=col(ii),z<col(ii+1)))=col(ii);
    end
    caxis([col(1) col(end-1)]);
end

z1=zeros(size(x));
z1=z1+0;

%% Plot samples
h=[];
if ~strcmpi(opt.marker,'none')
    s=scatter3(x,y,z1,opt.markersize,z,'filled',opt.marker);
%    s=scatter(x,y,opt.markersize,z,'filled',opt.marker);
%    sz=10*z;
%    sz=100*max(log10(sz),0.001);
%    sz=max(sz,5);
%    s=scatter(x,y,sz,z,'filled',opt.marker);
    if ~strcmpi(opt.markeredgecolor,'automatic')
        set(s,'MarkerEdgeColor',colorlist('getrgb','color',opt.markeredgecolor));
    end
    if ~strcmpi(opt.markerfacecolor,'automatic')
        set(s,'MarkerFaceColor',colorlist('getrgb','color',opt.markerfacecolor));
    end
    h=s(1);
    set(s,'Clipping','on');

    clmap=muppet_getColors(handles.colormaps,plt.colormap,64);
%    caxis(cax);
    colormap(clmap);
    
end

%% Add text
if opt.addtext
    for ii=1:length(x)
        if opt.decimals>=0
            data.text{ii}=num2str(data.z(ii),['%0.' num2str(opt.decimals) 'f']);
        else
            data.text{ii}=num2str(data.z(ii));
        end
        dist=0.001*plt.scale;
        switch lower(opt.textposition),
            case{'northeast','east','southeast'}
                x1=x(ii)+dist;
                horal='left';
            case{'north','middle','south'}
                x1=x(ii);
                horal='center';
            case{'northwest','west','southwest'}
                x1=x(ii)-dist;
                horal='right';
        end
        switch lower(opt.textposition),
            case{'northeast','north','northwest'}
                y1=y(ii)+dist;
                veral='bottom';
            case{'east','middle','west'}
                y1=y(ii);
                veral='middle';
            case{'southeast','south','southwest'}
                y1=y(ii)-dist;
                veral='top';
        end
        tx=text(x1,y1,data.text{ii});
        set(tx,'FontName',opt.font.name);
        set(tx,'FontWeight',opt.font.weight);
        set(tx,'FontAngle',opt.font.angle);
        set(tx,'Fontsize',opt.font.size*fig.fontreduction);
        set(tx,'color',colorlist('getrgb','color',opt.font.color));
        set(tx,'HorizontalAlignment',horal,'VerticalAlignment',veral);
        set(tx,'Clipping','on');
    end
end
