function handles=AddAnnotation(handles,i,j,mode)

Fig=handles.Figure(i);
ann=Fig.Annotation(j);

if strcmp(mode,'new')
    switch ann.Type,
        case 'textbox'
            an=annotation('textbox');
            set(an,'Tag','textbox');
        case 'line'
            an=annotation('line');
            set(an,'Tag','line');
        case 'arrow'
            an=annotation('arrow');
            set(an,'Tag','arrow');
        case 'doublearrow'
            an=annotation('doublearrow');
            set(an,'Tag','doublearrow');
        case 'rectangle'
            an=annotation('rectangle');
            set(an,'Tag','rectangle');
        case 'ellipse'
            an=annotation('ellipse');
            set(an,'Tag','ellipse');
    end
    set(an,'UserData',[i,j]);
else
    switch ann.Type,
        case 'textbox'
            an=findall(gcf,'Tag','textbox','UserData',[i,j]);
        case 'line'
            an=findall(gcf,'Tag','line','UserData',[i,j]);
        case 'arrow'
            an=findall(gcf,'Tag','arrow','UserData',[i,j]);
        case 'doublearrow'
            an=findall(gcf,'Tag','doublearrow','UserData',[i,j]);
        case 'rectangle'
            an=findall(gcf,'Tag','rectangle','UserData',[i,j]);
        case 'ellipse'
            an=findall(gcf,'Tag','ellipse','UserData',[i,j]);
    end
end

sz=Fig.PaperSize;
pos0=ann.Position;
ann.Position(1)=pos0(1)/sz(1);
ann.Position(2)=pos0(2)/sz(2);
ann.Position(3)=pos0(3)/sz(1);
ann.Position(4)=pos0(4)/sz(2);

switch ann.Type,
    case 'textbox'
        set(an,'Position',ann.Position);
        set(an,'String',ann.String);
        set(an,'FontName',ann.Font);
        set(an,'FontSize',ann.FontSize*Fig.FontRed);
        set(an,'FontSize',ann.FontSize);
        set(an,'FontWeight',ann.FontWeight);
        set(an,'FontAngle',ann.FontAngle);
        set(an,'Color',FindColor(ann.FontColor));
        set(an,'HorizontalAlignment',ann.HorAl);
        if ann.Box
            set(an,'BackgroundColor',FindColor(ann.BackgroundColor));
            set(an,'EdgeColor',FindColor(ann.LineColor));
        else
            set(an,'BackgroundColor','none');
            set(an,'EdgeColor','none');
        end
        set(an,'LineWidth',ann.LineWidth);
        set(an,'LineStyle',ann.LineStyle);
    case 'line'
        set(an,'Position',ann.Position);
        set(an,'Color',FindColor(ann.LineColor));
        set(an,'LineWidth',ann.LineWidth);
        set(an,'LineStyle',ann.LineStyle);
    case 'arrow'
        set(an,'Position',ann.Position);
        set(an,'Color',FindColor(ann.LineColor));
        set(an,'LineWidth',ann.LineWidth);
        set(an,'LineStyle',ann.LineStyle);
        set(an,'HeadWidth',ann.Head1Width);
        set(an,'HeadStyle',ann.Head1Style);
        set(an,'HeadLength',ann.Head1Length);
    case 'doublearrow'
        set(an,'Position',ann.Position);
        set(an,'Color',FindColor(ann.LineColor));
        set(an,'LineWidth',ann.LineWidth);
        set(an,'LineStyle',ann.LineStyle);
        set(an,'Head1Width',ann.Head1Width);
        set(an,'Head1Style',ann.Head1Style);
        set(an,'Head1Length',ann.Head1Length);
        set(an,'Head2Width',ann.Head2Width);
        set(an,'Head2Style',ann.Head2Style);
        set(an,'Head2Length',ann.Head2Length);
    case 'rectangle'
        set(an,'Position',ann.Position);
        set(an,'FaceColor',FindColor(ann.BackgroundColor));
        set(an,'EdgeColor',FindColor(ann.LineColor));
        set(an,'LineWidth',ann.LineWidth);
        set(an,'LineStyle',ann.LineStyle);
    case 'ellipse'
        set(an,'Position',ann.Position);
        set(an,'FaceColor',FindColor(ann.BackgroundColor));
        set(an,'EdgeColor',FindColor(ann.LineColor));
        set(an,'LineWidth',ann.LineWidth);
        set(an,'LineStyle',ann.LineStyle);
end

set(an,'ButtonDownFcn',{@UIEditAnnotationOptions});
