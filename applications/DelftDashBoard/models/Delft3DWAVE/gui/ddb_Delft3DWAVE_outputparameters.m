function ddb_Delft3DWAVE_outputparameters(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dwave.outputparameters');
else
    opt=varargin{1};
    switch lower(opt)
        case{'editlocations'}
            editLocations;
    end
end

%%
function editLocations
handles=getHandles;
ddb_editDelft3DWAVELocations;
setHandles(handles);






