function SelectLegend(varargin)

h=get(gcf,'CurrentObject');
LegendData=getfield(getappdata(h),'LegendData');
i=LegendData.i;
j=LegendData.j;
hh=get(gcf,'SelectionType');
handles=guidata(findobj('Name','Muppet'));
i0=handles.ActiveFigure;
j0=handles.ActiveSubplot;
if strcmp(hh,'open')
    handles.ActiveFigure=i;
    handles.ActiveSubplot=j;
    handles=EditLegend('handles',handles);
    handles.Figure(i).Axis(j).LegendHandle=SetLegend(handles,i,j);
    handles.ActiveFigure=i0;
    handles.ActiveSubplot=j0;
    guidata(handles.Muppet,handles);
end
