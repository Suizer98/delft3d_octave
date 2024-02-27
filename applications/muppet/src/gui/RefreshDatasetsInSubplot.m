function handles=RefreshDatasetsInSubplot(handles)

ifig=handles.ActiveFigure;
isub=handles.ActiveSubplot;

if isub>0
    if strcmpi(handles.Figure(ifig).Axis(isub).PlotType,'textbox')
        str{1}='Manual Text';
        set(handles.ListDatasetsInSubplot,'String',str);
        set(handles.ListDatasetsInSubplot,'Value',1);
        set(handles.EditPlotOptions,'Enable','on');
        set(handles.DeleteDataset,  'Enable','off');
        set(handles.DatasetUp,      'Enable','off');
        set(handles.DatasetDown,    'Enable','off');
    else
        if handles.Figure(ifig).Axis(isub).Nr>0
            for i=1:handles.Figure(ifig).Axis(isub).Nr
                str{i}=handles.Figure(ifig).Axis(isub).Plot(i).Name;
            end
            set(handles.ListDatasetsInSubplot,'String',str);
            set(handles.ListDatasetsInSubplot,'Value',handles.ActiveDatasetInSubplot);
            set(handles.EditPlotOptions,'Enable','on');
            set(handles.DeleteDataset,  'Enable','on');
            if handles.Figure(ifig).Axis(isub).Nr>1
                set(handles.DatasetUp,      'Enable','on');
                set(handles.DatasetDown,    'Enable','on');
            else
                set(handles.DatasetUp,      'Enable','off');
                set(handles.DatasetDown,    'Enable','off');
            end
            set(handles.ListDatasetsInSubplot,'ToolTipString',str{handles.ActiveDatasetInSubplot});
        else
            set(handles.ListDatasetsInSubplot,'String','');
            set(handles.ListDatasetsInSubplot,'Value',0);
            set(handles.ListDatasetsInSubplot,'ToolTipString','No Datasets in Subplot');
            set(handles.EditPlotOptions,'Enable','off');
            set(handles.DeleteDataset,  'Enable','off');
            set(handles.DatasetUp,      'Enable','off');
            set(handles.DatasetDown,    'Enable','off');
        end
    end
else
    set(handles.ListDatasetsInSubplot,'String','');
    set(handles.ListDatasetsInSubplot,'Value',0);
    set(handles.ListDatasetsInSubplot,'ToolTipString','No Datasets in Subplot');
    set(handles.EditPlotOptions,'Enable','off');
    set(handles.DeleteDataset,  'Enable','off');
    set(handles.DatasetUp,      'Enable','off');
    set(handles.DatasetDown,    'Enable','off');
end
