function sc=muppet_plotAnnotation(handles,i,j,k)

fig=handles.figures(i).figure;
plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

x=data.x;
y=data.y;

% if ~isempty(opt.selectedtext)
%     itxt=strmatch(opt.selectedtext,data.text,'exact');
%     i1=itxt;
%     i2=itxt;    
% else
    i1=1;
    i2=length(x);    
% end

for ii=i1:i2
    
    if ~strcmpi(opt.marker,'none')
%        sc=scatter3(x(ii),y(ii),1000,opt.markersize,opt.marker);
        sc=scatter(x(ii),y(ii),opt.markersize,opt.marker);
        set(sc,'markeredgecolor',colorlist('getrgb','color',opt.markeredgecolor),'markerfacecolor',colorlist('getrgb','color',opt.markerfacecolor));
        set(sc,'Clipping','on');
    else
%        sc=scatter3(x(ii),y(ii),1000);
        sc=scatter(x(ii),y(ii));
        set(sc,'markeredgecolor','none','markerfacecolor','none');
    end
    
    hold on;
    
    if opt.addtext
        
        switch plt.type
            case{'map'}
                switch plt.coordinatesystem.type
                    case{'geographic'}
                        plt.fscale=111111;
                    otherwise
                        plt.fscale=1;
                end
                dist=0.001*(opt.font.size/20)*plt.scale/plt.fscale;
            case{'xy'}
                dist=0.0;
        end
        
        dstshade=dist*0.15*opt.font.size/8;
        switch lower(opt.textposition)
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
        switch lower(opt.textposition)
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
        
        if opt.addtextshade
            txshade=text(x1+dstshade,y1-dstshade,[data.text{ii}]);
        end
        
        x1=x1+2;
        
        tx=text(x1,y1,[data.text{ii}]);
                
%         opt.font.size=10;
        
        set(tx,'FontName',opt.font.name);
        set(tx,'FontWeight',opt.font.weight);
        set(tx,'FontAngle',opt.font.angle);
        set(tx,'Fontsize',opt.font.size*fig.fontreduction);
        set(tx,'color',colorlist('getrgb','color',opt.font.color));
        set(tx,'HorizontalAlignment',horal,'VerticalAlignment',veral);
        set(tx,'Rotation',data.rotation(ii));
        set(tx,'Clipping','on');
        
%        set(tx,'Rotation',-90);
        set(tx,'Rotation',0);
        
        if opt.addtextshade
            set(txshade,'FontName',opt.font.name);
            set(txshade,'FontWeight',opt.font.weight);
            set(txshade,'FontAngle',opt.font.angle);
            set(txshade,'Fontsize',opt.font.size*fig.fontreduction);
            set(txshade,'color',colorlist('getrgb','color','black'));
            set(txshade,'HorizontalAlignment',horal,'VerticalAlignment',veral);
            set(txshade,'Rotation',data.rotation(ii));
            set(txshade,'Clipping','on');
        end
    
    end
end
