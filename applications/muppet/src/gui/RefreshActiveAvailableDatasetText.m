function handles=RefreshActiveAvailableDatasetText(handles)
 
i=handles.ActiveAvailableDataset;

k=1;
if handles.NrAvailableDatasets>0 & size(i,2)>0
    str{1}=['Name: ' handles.DataProperties(i).Name];
    k=k+1;
    if size(handles.DataProperties(i).Parameter,2)==0 | strcmp(handles.DataProperties(i).Parameter,'unknown')
    else
        str{k}=['Parameter: ' handles.DataProperties(i).Parameter];
        k=k+1;
    end
    datestring='';
    if handles.DataProperties(i).DateTime>0
        datestring=datestr(handles.DataProperties(i).DateTime,0);
        str{k}=['Date: ' datestring];
        k=k+1;
    end
    str{k}=['Type: ' handles.DataProperties(i).Type];
    k=k+1;
    if handles.DataProperties(i).CombinedDataset==0
        str{k}=['File: ' handles.DataProperties(i).PathName handles.DataProperties(i).FileName];
        k=k+1;
    else
        str{k}='Combined dataset';
    end

    str2=get(handles.ListAvailableDatasets,'String');
    set(handles.ListAvailableDatasets,'ToolTipString',str2{i});

else
    str='';
    set(handles.ListAvailableDatasets,'ToolTipString','No Available Datasets');
end
set(handles.ActiveAvailableDatasetText,'String',str);
