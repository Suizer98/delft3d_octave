function handles=RefreshAll(handles)

% Refreshes entire GUI
i=handles.ActiveFigure;

if handles.NrAvailableDatasets>0
    handles.ActiveAvailableDataset=1;
end

if handles.Figure(i).NrSubplots>0
    handles.ActiveSubplot=1;
    if handles.Figure(i).Axis(1).Nr>0
        handles.ActiveDatasetInSubplot=1;
    end
end
handles=RefreshAvailableDatasets(handles);
handles=RefreshActiveAvailableDatasetText(handles);
handles=RefreshSubplots(handles);
handles=RefreshDatasetsInSubplot(handles);
handles=RefreshAxes(handles);
handles=RefreshFigureProperties(handles);
handles=RefreshColorMap(handles);
