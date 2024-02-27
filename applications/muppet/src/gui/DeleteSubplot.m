function handles=DeleteSubplot(handles)

ifig=handles.ActiveFigure;
j=handles.ActiveSubplot;
nrsub=handles.Figure(ifig).NrSubplots;

if nrsub>0
    
    if strcmp(lower(handles.Figure(ifig).Axis(j).Name),'annotations')
        handles.Figure(ifig).NrAnnotations=0;
    end
    
    if nrsub>j
        for k=j:nrsub-1
            handles.Figure(ifig).Axis(k)=handles.Figure(ifig).Axis(k+1);
        end
    else
        handles.ActiveSubplot=handles.ActiveSubplot-1;
    end

    handles.Figure(ifig).Axis=handles.Figure(ifig).Axis(1:nrsub-1);
    
    handles.Figure(ifig).NrSubplots=handles.Figure(ifig).NrSubplots-1;
    
    if handles.Figure(ifig).NrSubplots>0
        handles.ActiveDatasetInSubplot=handles.Figure(ifig).Axis(handles.ActiveSubplot).Nr;
    else
        handles.ActiveDatasetInSubplot=0;
    end
    
    handles=RefreshSubplots(handles);
    handles=RefreshDatasetsInSubplot(handles);
    handles=RefreshAxes(handles);
    RefreshColorMap(handles);
   
end
