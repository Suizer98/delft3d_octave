function ddb_shorelines_numerics(varargin)

%%
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_plotshorelines('update','active',1,'visible',1);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectnumericaloption'}
            select_numerical_option;
            
    end
    
end

%%
function select_numerical_option

handles=getHandles;
opt=handles.model.shorelines.num_opt;
ddb_giveWarning('text',['Thank you for selecting numerical option ' opt]);
setHandles(handles);
