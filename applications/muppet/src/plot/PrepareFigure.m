function handles=PrepareFigure(handles,i,mode)

if strcmp(mode,'preview')
    handles.Figure(i).Units='pixels';
    a=get(0,'ScreenSize');
    asprat=handles.Figure(i).PaperSize(1)/handles.Figure(i).PaperSize(2);
    if asprat<a(3)/a(4)
        y1=0.88*a(4);
        handles.Figure(i).cm2pix=y1/handles.Figure(i).PaperSize(2);
    else
        x1=0.88*a(3);
        handles.Figure(i).cm2pix=x1/handles.Figure(i).PaperSize(1);
    end
    ScreenPixelsPerInch=get(0,'ScreenPixelsPerInch');
    cm2pix=handles.Figure(i).cm2pix;
    handles.Figure(i).FontRed=2.5*cm2pix/ScreenPixelsPerInch;
else
    handles.Figure(i).Units='centimeters';
    handles.Figure(i).cm2pix=1;
    handles.Figure(i).FontRed=1;
end

PaperSize=handles.Figure(i).PaperSize*handles.Figure(i).cm2pix;
BackgroundColor=FindColor(handles.Figure(i).BackgroundColor);

if strcmp(mode,'export') || strcmp(mode,'guiexport')
    % Exporting figure
    fig=figure(999);
    set(fig,'visible','off');
    set(fig,'PaperUnits',handles.Figure(i).Units);
    if strcmp(handles.Figure(i).Orientation,'l')
        set(fig,'PaperSize',[PaperSize(2) PaperSize(1)]);
    else
        set(fig,'PaperSize',[PaperSize(1) PaperSize(2)]);
    end         
    set(fig,'PaperPosition',[0.0 0.0 PaperSize(1) PaperSize(2)]);
    set(fig,'Renderer',handles.Figure(i).Renderer);
    set(fig,'Tag','figure','UserData',i);
    for k=1:handles.Figure(i).NrSubplots
        if strcmpi(handles.Figure(i).Axis(k).PlotType,'3d') && handles.Figure(i).Axis(k).DrawBox
            BackgroundColor=FindColor(handles.Figure(i).Axis(k).BackgroundColor);
        end
    end
%    drawnow;
else
    % Previewing figure
    hf=findobj('Tag','figure','UserData',i);
    if ~isempty(hf)
        OldPosition=get(figure(i),'Position');
    else
        OldPosition=[0 0 0 0];
    end
    figure(i);
    fig=gcf;
    set(fig,'Tag','figure','UserData',i);
    clf;

    try
        fh = get(gcf,'JavaFrame'); % Get Java Frame
        fh.setFigureIcon(javax.swing.ImageIcon([handles.MuppetPath 'settings' filesep 'icons' filesep 'deltares.gif']));
    end

    handles.Figure(i).Zoom='none';
    set(fig,'menubar','none');
    tbh=uitoolbar(gcf);

    icons=load([handles.MuppetPath 'settings' filesep 'icons' filesep 'ico.mat']);
    c=icons.icon;

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
    set(h,'ClickedCallback',{@mp_zoomInOutPan,1});
    set(h,'Tag','UIToggleToolZoomIn');
    set(h,'cdata',c.zoomin16);

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
    set(h,'ClickedCallback',{@mp_zoomInOutPan,2});
    set(h,'Tag','UIToggleToolZoomOut');
    set(h,'cdata',c.zoomout16);

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
    set(h,'ClickedCallback',{@mp_zoomInOutPan,3}');
    set(h,'Tag','UIToggleToolPan');
    set(h,'cdata',c.pan);

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Rotate 3D');
    set(h,'ClickedCallback',{@mp_zoomInOutPan,4}');
    set(h,'Tag','UIToggleToolPan');
    set(h,'cdata',c.rotate3d);

    edi = uitoggletool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Edit Figure');
    set(edi,'ClickedCallback',{@UIEditFigure});
    set(edi,'Tag','UIToggleToolEditFigure');
    set(edi,'cdata',c.pointer);

    adj = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Keep New Layout');
    set(adj,'ClickedCallback',{@UIAdjustAxes});
    set(adj,'Tag','UIPushToolAdjustAxes');
    set(adj,'cdata',c.properties_doc16);

    red = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Redraw');
    set(red,'ClickedCallback',{@UIRedraw});
    set(red,'Tag','UIPushToolRedraw');
    set(red,'cdata',c.refresh_doc16);

    xpor = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Export Figure');
    set(xpor,'ClickedCallback',{@UIExport});
    set(xpor,'Tag','UIPushToolExport');
    set(xpor,'cdata',c.save_green16);

    addsubplot = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Add Subplot');
    set(addsubplot,'ClickedCallback',{@UIAddSubplot});
    set(addsubplot,'Tag','UIPushToolAddSubplot');
    set(addsubplot,'cdata',c.graph_bar16);

    addtextbox = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Add Textbox');
    set(addtextbox,'ClickedCallback',{@UIAddTextBox});
    set(addtextbox,'Tag','UIPushToolAddTextBox');
    set(addtextbox,'cdata',c.tool_text);

    addline = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Line');
    set(addline,'ClickedCallback',{@UIAddLine});
    set(addline,'Tag','UIPushToolAddLine');
    set(addline,'cdata',c.tool_line);

    addarrow = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Arrow');
    set(addarrow,'ClickedCallback',{@UIAddArrow});
    set(addarrow,'Tag','UIPushToolAddArrow');
    set(addarrow,'cdata',c.tool_arrow);

    adddoublearrow = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Double Arrow');
    set(adddoublearrow,'ClickedCallback',{@UIAddDoubleArrow});
    set(adddoublearrow,'Tag','UIPushToolAddDoubleArrow');
    set(adddoublearrow,'cdata',c.tool_double_arrow);

    addrectangle = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Rectangle');
    set(addrectangle,'ClickedCallback',{@UIAddRectangle});
    set(addrectangle,'Tag','UIPushToolAddRectangle');
    set(addrectangle,'cdata',c.tool_rectangle);

    addellipse = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Ellipse');
    set(addellipse,'ClickedCallback',{@UIAddEllipse});
    set(addellipse,'Tag','UIPushToolAddEllipse');
    set(addellipse,'cdata',c.tool_ellipse);

    h = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Draw Polyline');
    set(h,'ClickedCallback',{@UIDrawFreeHand,1});
    set(h,'Tag','UIPushToolDrawPolyline');
    cda=single(MakeIcon([handles.MuppetPath 'settings' filesep 'icons' filesep 'polyline.bmp'],18,0.99));
    set(h,'cdata',cda);

    h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Draw Spline');
    set(h,'ClickedCallback',{@UIDrawFreeHand,2});
    set(h,'Tag','UIPushToolSpline');
    cda=single(MakeIcon([handles.MuppetPath 'settings' filesep 'icons' filesep 'spline.bmp'],18,0.99));
    set(h,'cdata',cda);

    h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Draw Curved Arrow');
    set(h,'ClickedCallback',{@UIDrawFreeHand,3});
    set(h,'Tag','UIPushToolDrawCurvedVector');
    cda=single(MakeIcon([handles.MuppetPath 'settings' filesep 'icons' filesep 'curvec2.bmp'],18,0.99));
    set(h,'cdata',cda);

    h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Text');
    set(h,'ClickedCallback',{@UIAddText});
    set(h,'Tag','UIPushToolAddText');
    set(h,'cdata',c.tool_text);

    a=get(0,'ScreenSize');
    NewPosition=[round(a(3)/2)-0.5*PaperSize(1) round(a(4)/2)-0.5*PaperSize(2)-10 PaperSize(1) PaperSize(2)];
    if abs(OldPosition(3)-NewPosition(3))>2 || abs(OldPosition(4)-NewPosition(4))>2 
        set(fig,'Position',NewPosition);
    end
%     if strcmp(lower(handles.Figure(i).Renderer),'painters')
%         set(fig,'Renderer','zbuffer');
%     end
    set(fig,'Renderer',handles.Figure(i).Renderer);
    set(fig,'Name',[handles.Figure(i).Name],'NumberTitle','off');
    set(fig,'Resize','off');
    set(fig,'ButtonDownFcn',[]);

    set(fig,'CloseRequestFcn',{@CloseFigure});

    plotedit off;

end

set(fig,'Color',BackgroundColor);
set(fig, 'InvertHardcopy', 'off');

% if strcmp(lower(BackgroundColor),'white')
%     set(fig, 'InvertHardcopy', 'on');
% else
%     set(fig,'Color',BackgroundColor);
%     set(fig, 'InvertHardcopy', 'off');
% end
set(fig,'Tag','figure','UserData',i);
handles.Figure(i).Handle=fig;
set(fig,'Visible','off');
