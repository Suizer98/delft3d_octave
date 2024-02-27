function ddb_shorelines_physics(varargin)

ddb_zoomOff;

if isempty(varargin)
    
    % New tab selected
    ddb_plotshorelines('update','active',1,'visible',1);

else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'testtest'}
            test_test;
            
    end
    
end

%%
function test_test

handles=getHandles;
setHandles(handles);
gui_updateActiveTab;
