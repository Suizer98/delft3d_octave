function an=muppet_addAnnotation(fig,i,isub,j)

ann=fig.subplots(isub).subplot.datasets(j).dataset;

an=findobj(gcf,'Tag','annotation','UserData',[i,j]);
delete(an);

% Add new annotation
switch lower(ann.plotroutine)
    case 'text box'
        style='textbox';
    case 'single line'
        style='line';
    case 'arrow'
        style='arrow';
    case 'double arrow'
        style='doublearrow';
    case 'rectangle'
        style='rectangle';
    case 'ellipse'
        style='ellipse';
end
an=annotation(style);
set(an,'Tag','annotation');
set(an,'UserData',[i,j]);
set(an,'ButtonDownFcn',{@muppet_UIEditAnnotationOptions});
setappdata(an,'style',ann.plotroutine);

pos0=ann.position;


ann.position(1)=pos0(1)/fig.width;
ann.position(2)=pos0(2)/fig.height;
ann.position(3)=pos0(3)/fig.width;
ann.position(4)=pos0(4)/fig.height;



switch lower(ann.plotroutine)
    case 'text box'
        str1{1}=ann.string(1,:);
        set(an,'position',ann.position);
        set(an,'string',ann.string(1,:));
%        set(an,'string',str1);
        set(an,'fontname',ann.font.name);
        set(an,'fontsize',ann.font.size*fig.fontreduction);
%        set(an,'fontsize',ann.font.size);
        set(an,'fontweight',ann.font.weight);
        set(an,'fontangle',ann.font.angle);
        set(an,'color',colorlist('getrgb','color',ann.font.color));
        set(an,'HorizontalAlignment',ann.font.horizontalalignment);
        set(an,'VerticalAlignment',ann.font.verticalalignment);
        if ann.box
            set(an,'backgroundcolor',colorlist('getrgb','color',ann.backgroundcolor));
            set(an,'Edgecolor',colorlist('getrgb','color',ann.linecolor));
        else
            set(an,'backgroundcolor','none');
            set(an,'Edgecolor','none');
        end
        set(an,'linewidth',ann.linewidth);
        set(an,'linestyle',ann.linestyle);
        set(an,'FitBoxToText','on');
    case 'single line'
        set(an,'position',ann.position);
        set(an,'color',colorlist('getrgb','color',ann.linecolor));
        set(an,'linewidth',ann.linewidth);
        set(an,'linestyle',ann.linestyle);
    case 'arrow'
        set(an,'position',ann.position);
        set(an,'color',colorlist('getrgb','color',ann.linecolor));
        set(an,'linewidth',ann.linewidth);
        set(an,'linestyle',ann.linestyle);
        set(an,'headwidth',ann.head1width);
        set(an,'headstyle',ann.head1style);
        set(an,'headlength',ann.head1length);
    case 'double arrow'
        set(an,'position',ann.position);
        set(an,'color',colorlist('getrgb','color',ann.linecolor));
        set(an,'linewidth',ann.linewidth);
        set(an,'linestyle',ann.linestyle);
        set(an,'head1width',ann.head1width);
        set(an,'head1style',ann.head1style);
        set(an,'head1length',ann.head1length);
        set(an,'head2width',ann.head2width);
        set(an,'head2style',ann.head2style);
        set(an,'head2length',ann.head2length);
    case 'rectangle'
        set(an,'position',ann.position);
        set(an,'Facecolor',colorlist('getrgb','color',ann.backgroundcolor));
        set(an,'Edgecolor',colorlist('getrgb','color',ann.linecolor));
        set(an,'linewidth',ann.linewidth);
        set(an,'linestyle',ann.linestyle);
    case 'ellipse'
        set(an,'position',ann.position);
        set(an,'Facecolor',colorlist('getrgb','color',ann.backgroundcolor));
        set(an,'Edgecolor',colorlist('getrgb','color',ann.linecolor));
        set(an,'linewidth',ann.linewidth);
        set(an,'linestyle',ann.linestyle);
end


