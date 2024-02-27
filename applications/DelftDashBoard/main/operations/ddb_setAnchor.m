function ddb_setAnchor(src, eventdata)

handles=getHandles;

if ~isempty(handles.GUIHandles.anchorhandle)
    if strcmp(get(handles.GUIHandles.toolBar.anchor,'State'),'on')
        set(handles.GUIHandles.anchorhandle,'Visible','on');
    else
        set(handles.GUIHandles.anchorhandle,'Visible','off');
    end
end
