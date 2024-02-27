c=load('icons_zoominout.mat']);

cpan=load(['icons_pan.mat']);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
set(h,'ClickedCallback','ZoomInOutPan(1)');
set(h,'Tag','UIToggleToolZoomIn');
set(h,'cdata',c.ico.zoomin16);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
set(h,'ClickedCallback','ZoomInOutPan(2)');
set(h,'Tag','UIToggleToolZoomOut');
set(h,'cdata',c.ico.zoomout16);

h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
set(h,'ClickedCallback','ZoomInOutPan(3)');
set(h,'Tag','UIToggleToolPan');
set(h,'cdata',cpan.icons.pan);
