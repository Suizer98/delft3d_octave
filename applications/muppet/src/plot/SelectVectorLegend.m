function SelectVectorLegend(varargin)

h=get(gcf,'CurrentObject');
VectorLegend=get(h,'UserData');
i=VectorLegend(1);
j=VectorLegend(2);
hh=get(gcf,'SelectionType');
handles=guidata(findobj('Name','Muppet'));
i0=handles.ActiveFigure;
j0=handles.ActiveSubplot;
if strcmp(hh,'open')
    handles.ActiveFigure=i;
    handles.ActiveSubplot=j;
    handles=EditVectorLegend('handles',handles);
    handles.Figure(i).Axis(j).VectorLegendHandle=SetVectorLegend(handles,i,j);
    handles.ActiveFigure=i0;
    handles.ActiveSubplot=j0;
    guidata(handles.Muppet,handles);
end
