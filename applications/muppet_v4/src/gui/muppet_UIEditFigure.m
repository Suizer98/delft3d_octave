function muppet_UIEditFigure(varargin)

zoom off;
pan off;
rotate3d off;

h=findall(gcf,'Tag','UIToggleToolEditFigure');
if strcmp(get(h,'State'),'on')
    set(gcf, 'windowbuttonupfcn', []);
    set(gcf, 'windowbuttondownfcn', []);
    set(gcf, 'windowbuttonmotionfcn', []);
    muppet_setPlotEdit(1);
else
    muppet_setPlotEdit(0);
end    
