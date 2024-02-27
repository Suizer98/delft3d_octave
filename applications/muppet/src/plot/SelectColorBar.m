function SelectColorBar(varargin)

hh=get(gcf,'SelectionType');
if strcmp(hh,'open')
    iopt=varargin{3};
    h=get(gcf,'CurrentObject');
    ColorBarData=get(h,'UserData');
    i=ColorBarData(1);
    j=ColorBarData(2);
    handles=guidata(findobj('Name','Muppet'));
    i0=handles.ActiveFigure;
    j0=handles.ActiveSubplot;
    k0=handles.ActiveDatasetInSubplot;
    handles.ActiveFigure=i;
    handles.ActiveSubplot=j;
    if iopt==1
        handles=EditColorBar('handles',handles);
        handles.Figure(i).Axis(j).ColorBarHandle=SetColorBar(handles,i,j);
    else
        k=ColorBarData(3);
        handles.ActiveDatasetInSubplot=k;
        handles=EditColorBar('handles',handles,'iopt',2);
        handles.Figure(i).Axis(j).Plot(k).ColorBarHandle=SetColorBar(handles,i,j,k);
        handles.ActiveDatasetInSubplot=k0;
    end
    handles.ActiveFigure=i0;
    handles.ActiveSubplot=j0;
    guidata(handles.Muppet,handles);
end
