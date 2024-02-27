function UIEditFigure(varargin)

zoom off;
pan off;
rotate3d off;

h=findall(gcf,'Tag','UIToggleToolEditFigure');
if strcmp(get(h,'State'),'on')
    set(gcf, 'windowbuttonupfcn', []);
    set(gcf, 'windowbuttondownfcn', []);
    set(gcf, 'windowbuttonmotionfcn', []);
    SetPlotEdit(1);
else
    SetPlotEdit(0);
end    
