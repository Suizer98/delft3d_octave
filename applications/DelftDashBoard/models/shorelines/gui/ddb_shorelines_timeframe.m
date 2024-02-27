function ddb_shorelines_timeframe(varargin)

%%
ddb_zoomOff;

if isempty(varargin)

    % New tab selected
    ddb_plotshorelines('update','active',1,'visible',1);

else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'edittime'}
            edit_time;
            
    end
    
end

%%
function edit_time

handles=getHandles;

disp('Time changed');

setHandles(handles);
