function muppet_UIExport(varargin)

handles=getHandles;

muppet_setPlotEdit(0);

ifig=get(gcf,'UserData');
muppet_exportFigure(handles,ifig,'guiexport');
delete('curvecpos.*.dat');

figure(ifig);
