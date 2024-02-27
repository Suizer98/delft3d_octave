function handles=DeleteDataset(handles)

iactive=handles.ActiveAvailableDataset;

ifig0=handles.ActiveFigure;
isub0=handles.ActiveSubplot;

if handles.NrAvailableDatasets>0

    for j=1:handles.NrCombinedDatasets
        NameA=handles.CombinedDatasetProperties(j).DatasetA.Name;
        NameB=handles.CombinedDatasetProperties(j).DatasetB.Name;
        NameActive=handles.DataProperties(iactive).Name;
        if strcmp(NameActive,NameA) || strcmp(NameActive,NameB)
            txt='Dataset is used in combined dataset!';
            mp_giveWarning('WarningText',txt);
            return
        end
    end
    
    for ifig=1:handles.NrFigures
        handles.ActiveFigure=ifig;
        for i=1:handles.Figure(ifig).NrSubplots
            handles.ActiveSubplot=i;
            nr=handles.Figure(ifig).Axis(i).Nr;
            for j=nr:-1:1
                if strcmp(handles.Figure(ifig).Axis(i).Plot(j).Name,handles.DataProperties(iactive).Name)
                    handles.ActiveDatasetInSubplot=j;
                    handles=RemoveDataset(handles);
                    if handles.Figure(ifig).Axis(i).Nr==0
                        handles.Figure(ifig).Axis(i).PlotType='unknown';
                        if handles.ActiveSubplot==i
                            handles.ActiveDatasetInSubplot=0;
                            handles.Figure(ifig).Axis(i).PlotColorBar=0;
                            handles.Figure(ifig).Axis(i).PlotLegend=0;
                            handles.Figure(ifig).Axis(i).PlotVectorLegend=0;
                            handles.Figure(ifig).Axis(i).PlotScaleBar=0;
                            handles.Figure(ifig).Axis(i).PlotNorthArrow=0;
                            handles.Figure(ifig).Axis(i).AdjustAxes=0;
                            handles.Figure(ifig).Axis(i).AxesEqual=0;
                        end
                    end
                    
                end
            end
        end
    end
    handles.ActiveFigure=ifig0;
    handles.ActiveSubplot=isub0;
    
    if handles.Figure(ifig).Axis(i).Nr==0
        handles=RefreshSubplots(handles);
        handles=RefreshAxes(handles);
    end
    
    if handles.DataProperties(iactive).CombinedDataset==1
        for i=1:handles.NrCombinedDatasets
            if strcmp(handles.CombinedDatasetProperties(i).Name,handles.DataProperties(iactive).Name)
                icomb=i;
            end
        end
        for i=icomb:handles.NrCombinedDatasets-1;
            handles.CombinedDatasetProperties(i)=handles.CombinedDatasetProperties(i+1);
        end
        clear handles.CombinedDatasetProperties(handles.NrCombinedDatasets);
        handles.NrCombinedDatasets=handles.NrCombinedDatasets-1;
    end
    
    for i=handles.ActiveAvailableDataset:handles.NrAvailableDatasets-1;
        handles.DataProperties(i)=handles.DataProperties(i+1);
    end

    handles.DataProperties=handles.DataProperties(1:handles.NrAvailableDatasets-1);
    
    if handles.ActiveAvailableDataset==handles.NrAvailableDatasets && handles.NrAvailableDatasets>1
        handles.ActiveAvailableDataset=handles.ActiveAvailableDataset-1;
    end    
    handles.NrAvailableDatasets=handles.NrAvailableDatasets-1;

    handles=RefreshAvailableDatasets(handles);
    handles=RefreshActiveAvailableDatasetText(handles);
    handles=RefreshDatasetsInSubplot(handles);

end
