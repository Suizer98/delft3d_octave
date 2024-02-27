function UIAdjustAxes(varargin)

mpt=findobj('Name','Muppet');
data=guidata(mpt);
ifig=get(gcf,'UserData');
data.ActiveFigure=ifig;

SetPlotEdit(0);

data=AdjustAxes(data);
data=RefreshSubplots(data);
data=RefreshDatasetsInSubplot(data);
data=RefreshAxes(data);

figure(data.Figure(ifig).Handle);

guidata(mpt,data);

