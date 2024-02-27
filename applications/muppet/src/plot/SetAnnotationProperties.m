function ChangeAnnotationProperties(an,ann,DefaultColors,PaperSize);
 
    sz=PaperSize;
    pos0=ann.Position;
    ann.Position(1)=pos0(1)/sz(1);
    ann.Position(2)=pos0(2)/sz(2);
    ann.Position(3)=pos0(3)/sz(1);
    ann.Position(4)=pos0(4)/sz(2);

    LineColor=FindColor(ann,'LineColor',DefaultColors);
    BackgroundColor=FindColor(ann,'BackgroundColor',DefaultColors);
    FontColor=FindColor(ann,'FontColor',DefaultColors);

    switch ann.Type,
        case 'textbox'
            set(an,'Position',ann.Position);
            set(an,'String',ann.String);
            set(an,'FontName',ann.Font);
            set(an,'FontSize',ann.FontSize);
            set(an,'FontWeight',ann.FontWeight);
            set(an,'FontAngle',ann.FontAngle);
            set(an,'Color',FontColor);
            set(an,'HorizontalAlignment',ann.HorAl);
            if ann.Box
                set(an,'BackgroundColor',BackgroundColor);
                set(an,'EdgeColor',LineColor);
            else
                set(an,'BackgroundColor','none');
                set(an,'EdgeColor','none');
            end                
            set(an,'LineWidth',ann.LineWidth);
            set(an,'LineStyle',ann.LineStyle);
        case 'line'
            x=[ann.Position(1) ann.Position(3)];
            y=[ann.Position(2) ann.Position(4)];
            an=annotation('line',x,y);
            set(an,'Tag','line');
            set(an,'Color',LineColor);
            set(an,'LineWidth',ann.LineWidth);
            set(an,'LineStyle',ann.LineStyle);
         case 'arrow'
            x=[ann.Position(1) ann.Position(3)];
            y=[ann.Position(2) ann.Position(4)];
            an=annotation('arrow',x,y);
            set(an,'Tag','arrow');
            set(an,'Color',LineColor);
            set(an,'LineWidth',ann.LineWidth);
            set(an,'LineStyle',ann.LineStyle);
            set(an,'HeadWidth',ann.Head1Width);
            set(an,'HeadStyle',ann.Head1Style);
            set(an,'HeadLength',ann.Head1Length);
         case 'doublearrow'
            x=[ann.Position(1) ann.Position(3)];
            y=[ann.Position(2) ann.Position(4)];
            an=annotation('doublearrow',x,y);
            set(an,'Tag','doublearrow');
            set(an,'Color',LineColor);
            set(an,'LineWidth',ann.LineWidth);
            set(an,'LineStyle',ann.LineStyle);
            set(an,'Head1Width',ann.Head1Width);
            set(an,'Head1Style',ann.Head1Style);
            set(an,'Head1Length',ann.Head1Length);
            set(an,'Head2Width',ann.Head2Width);
            set(an,'Head2Style',ann.Head2Style);
            set(an,'Head2Length',ann.Head2Length);
         case 'rectangle'
            an=annotation('rectangle',ann.Position);
            set(an,'Tag','rectangle');
            set(an,'FaceColor',BackgroundColor);
            set(an,'EdgeColor',LineColor);
            set(an,'LineWidth',ann.LineWidth);
            set(an,'LineStyle',ann.LineStyle);
         case 'ellipse'
            an=annotation('ellipse',ann.Position);
            set(an,'Tag','ellipse');
            set(an,'FaceColor',BackgroundColor);
            set(an,'EdgeColor',LineColor);
            set(an,'LineWidth',ann.LineWidth);
            set(an,'LineStyle',ann.LineStyle);
    end

    AnnOpt.Box=ann.Box;
    AnnOpt.LineColor=ann.LineColor;
    AnnOpt.BackgroundColor=ann.BackgroundColor;
    AnnOpt.FontColor=ann.FontColor;
    set(an,'UserData',AnnOpt);
    
    AddAnnotationMenu(an);

    
end
