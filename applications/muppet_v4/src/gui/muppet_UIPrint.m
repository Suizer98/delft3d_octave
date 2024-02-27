function UIPrint(varargin)

mpt=findobj('Name','Muppet');
data=guidata(mpt);
SetPlotEdit(0);
ifig=get(gcf,'UserData');
ExportFigure(data,ifig,'print');
figure(ifig);
