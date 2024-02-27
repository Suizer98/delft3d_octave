function SelectDataset(varargin)

h=get(gcf,'CurrentObject');
n=get(h,'UserData');
hh=get(gcf,'SelectionType');
handles=guidata(findobj('Name','Muppet'));
i0=handles.ActiveFigure;
j0=handles.ActiveSubplot;
k0=handles.ActiveDatasetInSubplot;
if strcmp(hh,'open') & strcmp(handles.Figure(handles.ActiveFigure).Zoom,'none')
    handles.ActiveFigure=n(1);
    handles.ActiveSubplot=n(2);
    handles.ActiveDatasetInSubplot=n(3);
    handles=EditPlotOptions(handles);
    guidata(handles.Muppet,handles);
    ObjectData=getfield(getappdata(h),'ObjectData');
    i=ObjectData.i;
    j=ObjectData.j;
    k=ObjectData.k;
    OldPlotRoutine=ObjectData.PlotRoutine;
    if strcmp(handles.Figure(i).Axis(j).Plot(k).PlotRoutine,OldPlotRoutine)
        handles=PlotDataset(handles,i,j,k,'change');
    else
        hh=findobj('UserData',[i,j,k]);
        delete(hh);
        handles=PlotDataset(handles,i,j,k,'new');
    end
    if handles.Figure(i).Axis(j).PlotLegend
        handles.Figure(i).Axis(j).LegendHandle=SetLegend(handles,i,j);
    end
    if handles.Figure(i).Axis(j).PlotVectorLegend
        handles.Figure(i).Axis(j).VectorLegendHandle=SetVectorLegend(handles,i,j);
    end
    handles.ActiveFigure=i0;
    handles.ActiveSubplot=j0;
    handles.ActiveDatasetInSubplot=k0;
    guidata(handles.Muppet,handles);
end
