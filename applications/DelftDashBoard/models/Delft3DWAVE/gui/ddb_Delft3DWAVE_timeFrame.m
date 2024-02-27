function ddb_Delft3DWAVE_timeFrame(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'settimelist'}
            setTimeList;
    end
end

%%
function setTimeList

handles = getHandles;
handles.model.delft3dwave.domain.listtimes={datestr(handles.model.delft3dwave.domain.selectedtime,'yyyy mm dd HH MM SS')};
setHandles(handles);
