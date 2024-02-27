function handles=AddSubplot(handles)

ifig=handles.ActiveFigure;

if handles.AddSubplotAnnotations==0

    % Add subplot

    if handles.Figure(ifig).NrAnnotations==0
        i0=handles.Figure(ifig).NrSubplots;
    else
        i0=handles.Figure(ifig).NrSubplots-1;
    end        

    if isfield(handles,'Pos')
        pos=handles.Pos;
    else
        pos=[3 3 6 4];
    end

%    [Name,Position]=AddSubplotWindow('NrSubplots',i0,'pos',pos);
    [Name,Position]=AddSubplotWindow('SubplotProperties',handles.Figure(ifig),'NrSubplots',i0,'ifig',ifig,'pos',pos);

    if Position(1)>=0

        handles.Figure(ifig).NrSubplots=handles.Figure(ifig).NrSubplots+1;
        nrsub=handles.Figure(ifig).NrSubplots;

        if handles.Figure(ifig).NrAnnotations==0
            i=nrsub;
        else
            % Shift annotation layer to last position
            handles.Figure(ifig).Axis(nrsub)=handles.Figure(ifig).Axis(nrsub-1);
            i=handles.Figure(ifig).NrSubplots-1;
        end
        
        handles.ActiveSubplot=i;
        
        handles.Figure(ifig).Axis(i).PlotType='unknown';
        handles.Figure(ifig).Axis(i).Name=Name;
        handles.Figure(ifig).Axis(i).Position=Position;

        handles.Figure.Axis=matchstruct(handles.DefaultSubplotProperties,handles.Figure.Axis,ifig,i);

        handles.Figure(ifig).Axis(i).Nr=0;
        handles.Figure(ifig).Axis(i).NrFreeText=0;

        handles.ActiveDatasetInSubplot=1;

        handles=RefreshSubplots(handles);
        handles=RefreshDatasetsInSubplot(handles);
        handles=RefreshAvailableDatasets(handles);
        handles=RefreshAxes(handles);
        RefreshColorMap(handles);

    end

else
    
    % Add annotation layer

    handles.Figure(ifig).NrSubplots=handles.Figure(ifig).NrSubplots+1;
    i=handles.Figure(ifig).NrSubplots;
    
    if i==1
        handles.ActiveSubplot=1;
    end
    
    handles.Figure.Axis=matchstruct(handles.DefaultSubplotProperties,handles.Figure.Axis,ifig,i);
    
    handles.Figure(ifig).Axis(i).Name='Annotations';
    handles.Figure(ifig).Axis(i).PlotType='Annotations';
    handles.Figure(ifig).Axis(i).Position=[0 0 0 0];
    
    handles.Figure(ifig).Axis(i).Nr=handles.Figure(ifig).NrAnnotations;

    handles.ActiveDatasetInSubplot=1;

    handles=RefreshSubplots(handles);
    handles=RefreshDatasetsInSubplot(handles);
    handles=RefreshAvailableDatasets(handles);
    handles=RefreshAxes(handles);
    RefreshColorMap(handles);

end

