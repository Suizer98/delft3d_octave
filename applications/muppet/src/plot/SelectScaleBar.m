function SelectScaleBar(varargin)

h=get(gcf,'CurrentObject');
ScaleBarData=get(h,'UserData');
i=ScaleBarData(1);
j=ScaleBarData(2);
hh=get(gcf,'SelectionType');
handles=guidata(findobj('Name','Muppet'));
if strcmp(hh,'open')
    handles.ActiveFigure=i;
    handles.ActiveSubplot=j;
    handles=EditScaleBar('handles',handles);
    handles.Figure(i).Axis(j).ScaleBarHandle=SetScaleBar(handles,i,j);
    guidata(handles.Muppet,handles);
end
