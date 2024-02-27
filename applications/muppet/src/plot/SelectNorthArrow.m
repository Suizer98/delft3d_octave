function SelectNorthArrow(varargin)

h=get(gcf,'CurrentObject');
NorthArrowData=get(h,'UserData');
i=NorthArrowData(1);
j=NorthArrowData(2);
hh=get(gcf,'SelectionType');
handles=guidata(findobj('Name','Muppet'));
i0=handles.ActiveFigure;
j0=handles.ActiveSubplot;
if strcmp(hh,'open')
    handles.ActiveFigure=i;
    handles.ActiveSubplot=j;
    handles=EditNorthArrow('handles',handles);
    handles.Figure(i).Axis(j).NorthArrowHandle=SetNorthArrow(handles,i,j);
    handles.ActiveFigure=i0;
    handles.ActiveSubplot=j0;
    guidata(handles.Muppet,handles);
end
