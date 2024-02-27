function iok=ddb_check_write_extfile(handles)

iok=0;
if handles.model.dflowfm.domain.nrboundaries>0
    iok=1;
    return
end

if ~isempty(handles.model.dflowfm.domain.spiderwebfile)
    iok=1;
    return
end

if ~isempty(handles.model.dflowfm.domain.windufile)
    iok=1;
    return
end

if ~isempty(handles.model.dflowfm.domain.windvfile)
    iok=1;
    return
end

if ~isempty(handles.model.dflowfm.domain.airpressurefile)
    iok=1;
    return
end
