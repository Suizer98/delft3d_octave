function handles=RefreshAvailableDatasets(handles)
 
str{1}='';
for i=1:handles.NrAvailableDatasets;
    str{i}=handles.DataProperties(i).Name;
end
set(handles.ListAvailableDatasets,'String',str);
if handles.NrAvailableDatasets>0
    set(handles.ListAvailableDatasets,'Value',handles.ActiveAvailableDataset);
    if handles.Figure(handles.ActiveFigure).NrSubplots>0
        set(handles.AddToSubplot,       'Enable','on');
    else
        set(handles.AddToSubplot,       'Enable','off');
    end
    set(handles.RemoveDataset,      'Enable','on');
    set(handles.PushCombineDatasets,'Enable','on');
else
    set(handles.ListAvailableDatasets,'Value',1);
    set(handles.AddToSubplot,       'Enable','off');
    set(handles.RemoveDataset,      'Enable','off');
    set(handles.PushCombineDatasets,'Enable','off');
end
