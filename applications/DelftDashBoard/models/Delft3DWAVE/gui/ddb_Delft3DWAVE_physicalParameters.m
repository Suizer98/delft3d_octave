function ddb_Delft3DWAVE_physicalParameters(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'togglewind'}
            toggleWind;
    end
end

%%
function toggleWind

handles=getHandles;
if ~handles.model.delft3dwave.domain.windgrowth
    handles.model.delft3dwave.domain.whitecapping='off';
    handles.model.delft3dwave.domain.quadruplets=0;
end
setHandles(handles);
