function handles=RefreshSubplots(handles)

ifig=handles.ActiveFigure;
isub=handles.ActiveSubplot;

if handles.Figure(ifig).NrSubplots>0
    for i=1:handles.Figure(ifig).NrSubplots
        str{i}=handles.Figure(ifig).Axis(i).Name;
    end
    set(handles.ListSubplots,'String',str);
    set(handles.ListSubplots,'Value',isub);
    set(handles.DeleteSubplot,'Enable','on');
    if handles.NrAvailableDatasets==0
        set(handles.AddToSubplot,'Enable','off');
    end
    if handles.Figure(ifig).NrSubplots>1
        set(handles.SubplotUp,   'Enable','on');
        set(handles.SubplotDown, 'Enable','on');
    else
        set(handles.SubplotUp,   'Enable','off');
        set(handles.SubplotDown, 'Enable','off');
    end
else
    set(handles.ListSubplots,'String','');
    set(handles.ListSubplots,'Value',0);
    set(handles.DeleteSubplot,'Enable','off');
    set(handles.SubplotUp,    'Enable','off');
    set(handles.SubplotDown,  'Enable','off');
    set(handles.AddToSubplot, 'Enable','off');
end

if handles.Figure(ifig).NrSubplots>0
    if strcmpi(handles.Figure(ifig).Axis(isub).Name,'annotations');
        set(handles.SubplotUp,    'Enable','off');
        set(handles.SubplotDown,  'Enable','off');
        set(handles.AddToSubplot, 'Enable','off');
    end
end

