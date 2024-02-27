function figh=muppet_prepareFigure(handles,ifig,mode)

fig=handles.figures(ifig).figure;

paperwidth=fig.width*fig.cm2pix;
paperheight=fig.height*fig.cm2pix;
backgroundcolor=colorlist('getrgb','color',fig.backgroundcolor);

if strcmp(mode,'export') || strcmp(mode,'guiexport')
    % Exporting figure
    figh=figure(999);
    set(figh,'visible','off');
%    set(figh,'Units','centimeters');
    set(figh,'Units','pixels');
    set(figh,'PaperUnits','centimeters');
    set(figh,'Position',[0 0 paperwidth paperheight]);
    set(figh,'PaperPosition',[0 0 fig.width fig.height]);
    
%     if strcmp(fig.orientation,'landscape')
%         set(figh,'PaperSize',[paperheight paperwidth]);
%     else
%         set(figh,'PaperSize',[paperwidth paperheight]);
%     end         
%     set(figh,'PaperPosition',[0.0 0.0 paperwidth paperheight]);
    set(figh,'Renderer',fig.renderer);
    set(figh,'Tag','figure','UserData',ifig);
    for k=1:fig.nrsubplots
        if strcmpi(fig.subplots(k).subplot.type,'3d') && fig.subplots(k).subplot.drawbox
            backgroundcolor=colorlist('getrgb','color',fig.subplots(k).subplot.backgroundcolor);
        end
    end
else
    % Previewing figure
    hf=findobj('Tag','figure','UserData',ifig);
    if ~isempty(hf)
        oldposition=get(figure(ifig),'Position');
    else
        oldposition=[0 0 0 0];
    end
    figh=figure;
    set(figh,'Tag','figure','UserData',ifig);
        
    clf;

    try
        fh = get(gcf,'JavaFrame'); % Get Java Frame
        fh.setFigureIcon(javax.swing.ImageIcon([handles.settingsdir 'icons' filesep 'deltares.gif']));
    end

    set(figh,'menubar','none');
    tbh=uitoolbar(gcf);

    icons=load([handles.settingsdir 'icons' filesep 'ico.mat']);
    c=icons.icon;

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
    set(h,'ClickedCallback',{@muppet_zoomInOutPan,1});
    set(h,'Tag','UIToggleToolZoomIn');
    set(h,'cdata',c.zoomin16);

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
    set(h,'ClickedCallback',{@muppet_zoomInOutPan,2});
    set(h,'Tag','UIToggleToolZoomOut');
    set(h,'cdata',c.zoomout16);

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
    set(h,'ClickedCallback',{@muppet_zoomInOutPan,3}');
    set(h,'Tag','UIToggleToolPan');
    set(h,'cdata',c.pan);

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Rotate 3D');
    set(h,'ClickedCallback',{@muppet_zoomInOutPan,4}');
    set(h,'Tag','UIToggleToolPan');
    set(h,'cdata',c.rotate3d);

    edi = uitoggletool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Edit Figure');
    set(edi,'ClickedCallback',{@muppet_UIEditFigure});
    set(edi,'Tag','UIToggleToolEditFigure');
    set(edi,'cdata',c.pointer);

    adj = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Keep New Layout');
    set(adj,'ClickedCallback',{@muppet_fixAxes});
    set(adj,'Tag','UIPushToolAdjustAxes');
    set(adj,'cdata',c.properties_doc16);

    red = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Redraw');
    set(red,'ClickedCallback',{@muppet_UIRedraw});
    set(red,'Tag','UIPushToolRedraw');
    set(red,'cdata',c.refresh_doc16);

    addsubplot = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Add Subplot');
    set(addsubplot,'ClickedCallback',{@muppet_UIAddSubplot});
    set(addsubplot,'Tag','UIPushToolAddSubplot');
    set(addsubplot,'cdata',c.graph_bar16);

    addtextbox = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Add Textbox');
    set(addtextbox,'ClickedCallback',{@muppet_UIAddTextBox});
    set(addtextbox,'Tag','UIPushToolAddTextBox');
    set(addtextbox,'cdata',c.tool_text);

    addline = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Line');
    set(addline,'ClickedCallback',{@muppet_UIAddLine});
    set(addline,'Tag','UIPushToolAddLine');
    set(addline,'cdata',c.tool_line);

    addarrow = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Arrow');
    set(addarrow,'ClickedCallback',{@muppet_UIAddArrow});
    set(addarrow,'Tag','UIPushToolAddArrow');
    set(addarrow,'cdata',c.tool_arrow);

    adddoublearrow = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Double Arrow');
    set(adddoublearrow,'ClickedCallback',{@muppet_UIAddDoubleArrow});
    set(adddoublearrow,'Tag','UIPushToolAddDoubleArrow');
    set(adddoublearrow,'cdata',c.tool_double_arrow);

    addrectangle = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Rectangle');
    set(addrectangle,'ClickedCallback',{@muppet_UIAddRectangle});
    set(addrectangle,'Tag','UIPushToolAddRectangle');
    set(addrectangle,'cdata',c.tool_rectangle);

    addellipse = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Ellipse');
    set(addellipse,'ClickedCallback',{@muppet_UIAddEllipse});
    set(addellipse,'Tag','UIPushToolAddEllipse');
    set(addellipse,'cdata',c.tool_ellipse);

    h = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Draw Polyline');
    set(h,'ClickedCallback',{@muppet_UIDrawFreeHand,1});
    set(h,'Tag','UIPushToolDrawPolyline');
    cda=single(MakeIcon([handles.settingsdir 'icons' filesep 'polyline.bmp'],18,0.99));
    set(h,'cdata',cda);

    h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Draw Spline');
    set(h,'ClickedCallback',{@muppet_UIDrawFreeHand,2});
    set(h,'Tag','UIPushToolSpline');
    cda=single(MakeIcon([handles.settingsdir 'icons' filesep 'spline.bmp'],18,0.99));
    set(h,'cdata',cda);

    h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Draw Curved Arrow');
    set(h,'ClickedCallback',{@muppet_UIDrawFreeHand,3});
    set(h,'Tag','UIPushToolDrawCurvedVector');
    cda=single(MakeIcon([handles.settingsdir 'icons' filesep 'curvec2.bmp'],18,0.99));
    set(h,'cdata',cda);

    h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Text');
    set(h,'ClickedCallback',{@muppet_UIAddText});
    set(h,'Tag','UIPushToolAddText');
    set(h,'cdata',c.tool_text);

    a=get(0,'ScreenSize');
    newposition=[round(a(3)/2)-0.5*paperwidth round(a(4)/2)-0.5*paperheight-10 paperwidth paperheight];
    if abs(oldposition(3)-newposition(3))>2 || abs(oldposition(4)-newposition(4))>2 
        set(figh,'Position',newposition);
    end
    
    set(figh,'Renderer',fig.renderer);
    set(figh,'Name',[fig.name],'NumberTitle','off');
    set(figh,'Resize','off');
    set(figh,'ButtonDownFcn',[]);

    set(figh,'CloseRequestFcn',{@muppet_closeFigure});

    plotedit off;

end

set(figh,'Color',backgroundcolor);
set(figh, 'InvertHardcopy', 'off');
set(figh,'Tag','figure','UserData',ifig);
set(figh,'Visible','off');
