function handles=RemoveDataset(handles)

ifig=handles.ActiveFigure;

if handles.Figure(ifig).NrSubplots>0

    i=handles.ActiveSubplot;
    j=handles.ActiveDatasetInSubplot;
    nr=handles.Figure(ifig).Axis(i).Nr;

    if ~strcmpi(handles.Figure(ifig).Axis(i).PlotType,'textbox')

        if nr>0
            if nr>j
                for k=j:nr-1
                    handles.Figure(ifig).Axis(i).Plot(k)=handles.Figure(ifig).Axis(i).Plot(k+1);
                    if strcmpi(handles.Figure(ifig).Axis(i).PlotType,'annotations')
                        handles.Figure(ifig).Annotation(k)=handles.Figure(ifig).Annotation(k+1);
                    end
                end
            else
                handles.ActiveDatasetInSubplot=handles.ActiveDatasetInSubplot-1;
            end
            if nr>0
                handles.Figure(ifig).Axis(i).Plot=handles.Figure(ifig).Axis(i).Plot(1:nr-1);
            else
                handles.Figure(ifig).Axis(i).Plot=[];
            end
            if strcmpi(handles.Figure(ifig).Axis(i).PlotType,'annotations')
                handles.Figure(ifig).NrAnnotations=handles.Figure(ifig).NrAnnotations-1;
            end
            handles.Figure(ifig).Axis(i).Nr=nr-1;
        end

        if handles.Figure(ifig).Axis(i).Nr==0
            if strcmpi(handles.Figure(ifig).Axis(i).PlotType,'annotations')
                handles=DeleteSubplot(handles);
            else
                handles.ActiveDatasetInSubplot=0;
                handles.Figure(ifig).Axis(i).PlotType='unknown';
                handles.Figure(ifig).Axis(i).PlotColorBar=0;
                handles.Figure(ifig).Axis(i).PlotLegend=0;
                handles.Figure(ifig).Axis(i).PlotVectorLegend=0;
                handles.Figure(ifig).Axis(i).PlotScaleBar=0;
                handles.Figure(ifig).Axis(i).PlotNorthArrow=0;
                handles.Figure(ifig).Axis(i).AdjustAxes=0;
                handles.Figure(ifig).Axis(i).AxesEqual=0;
                handles=RefreshSubplots(handles);
                handles=RefreshAxes(handles);
            end
        end

        handles=RefreshDatasetsInSubplot(handles);

    end

end
