function ddb_shorelines_sediment_transport(varargin)

%%
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_plotshorelines('update','active',1,'visible',1);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selecttransportoption'}
            select_transport_option;
            
    end
    
end

%%
function select_transport_option

handles=getHandles;
opt=handles.model.shorelines.domain.trform;
%ddb_giveWarning('text',['Thank you for selecting transport option ' opt]);
setHandles(handles);
