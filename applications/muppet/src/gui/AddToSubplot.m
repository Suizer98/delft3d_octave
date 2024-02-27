function handles=AddToSubplot(handles)

if handles.NrAvailableDatasets>0 && handles.ActiveSubplot>0

    ifig=handles.ActiveFigure;
    
    switch lower(handles.Figure(ifig).Axis(handles.ActiveSubplot).PlotType),
        case {'unknown'}
            ok=1;
        case {'2d'}
            switch lower(handles.DataProperties(handles.ActiveAvailableDataset).Type)
                case {'2dscalar','2dvector','samples','geoimage','curvedvectors','polyline','3dcrosssectionscalar', ...
                        '3dcrosssectionvector','3dcrosssectiongrid','kubint','lint','annotation','crosssections','xyseries','grid', ...
                        'freetext','freehanddrawing'}
                    ok=1;
                otherwise
                    ok=0;
            end
        case {'xy'}
            switch lower(handles.DataProperties(handles.ActiveAvailableDataset).Type)
                case {'2dscalar','2dvector','samples','geoimage','curvedvectors','polyline','3dcrosssectionscalar', ...
                        '3dcrosssectionvector','3dcrosssectiongrid','kubint','lint','annotation','crosssections','xyseries','grid', ...
                        'freetext','freehanddrawing','bar'}
%                case {'xyseries','bar','polyline','annotation'}
                    ok=1;
                otherwise
                    ok=0;
            end
        case {'timeseries'}
            switch lower(handles.DataProperties(handles.ActiveAvailableDataset).Type)
                case {'timeseries'}
                    ok=1;
                otherwise
                    ok=0;
            end
        case {'image'}
            switch lower(handles.DataProperties(handles.ActiveAvailableDataset).Type)
                case {'image'}
                    ok=1;
                otherwise
                    ok=0;
            end
        case {'rose'}
            switch lower(handles.DataProperties(handles.ActiveAvailableDataset).Type)
                case {'rose'}
                    ok=1;
                otherwise
                    ok=0;
            end
        case {'textbox'}
            ok=0;
        otherwise
            ok=1;
    end
    
    freehand=0;
    switch lower(handles.DataProperties(handles.ActiveAvailableDataset).Type),
        case{'freetext','freehandobject'}
            freehand=1;
    end
    
    if ok==1

        i=handles.Figure(ifig).Axis(handles.ActiveSubplot).Nr+1;

        handles.Figure(ifig).Axis(handles.ActiveSubplot).Nr=i;

        if i==1
            new=1;
        else
            new=0;
        end

        handles.Figure(ifig).Axis(handles.ActiveSubplot).Plot(i).Name=handles.DataProperties(handles.ActiveAvailableDataset).Name;
        handles.Figure(ifig).Axis(handles.ActiveSubplot).Plot(i).AvailableDatasetNr=handles.ActiveAvailableDataset;

        handles.ActiveDatasetInSubplot=i;

        handles=RefreshDatasetsInSubplot(handles);

%        handles=SetDefaultPlotOptions(handles);
        
        if ~freehand
            if (get(handles.ToggleAdjustAxes,'Value')==1 || new==1) && ~freehand
                handles=SetDefaultAxes(handles,new);
            end
            handles=RefreshAxes(handles);
            RefreshColorMap(handles);
        end

        handles=SetDefaultPlotOptions(handles);
        
    else
        txt=['This dataset can not be added to ' lower(handles.Figure(ifig).Axis(handles.ActiveSubplot).PlotType) ' subplot!'];
        mp_giveWarning('txt',txt);
    end
    
end
