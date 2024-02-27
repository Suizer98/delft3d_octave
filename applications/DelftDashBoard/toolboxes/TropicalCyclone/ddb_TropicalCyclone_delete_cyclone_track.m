function handles=ddb_deleteCycloneTrack(handles)

try
    delete(handles.toolbox.tropicalcyclone.trackhandle);
end
h=findobj(gca,'Tag','cyclonetrack');
if ~isempty(h)
    delete(h);
end
handles.toolbox.tropicalcyclone.trackhandle=[];
