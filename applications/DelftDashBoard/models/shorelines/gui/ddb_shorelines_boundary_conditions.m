function ddb_shorelines_boundary_conditions(varargin)

%%
ddb_zoomOff;


if isempty(varargin)
    % New tab selected
    ddb_plotshorelines('update','active',1,'visible',1);        
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'loadboundaryfile'}
            load_boundary_file;            
    end
    
end

%%
function load_boundary_file

handles=getHandles;

% Load boundary file here
fname=handles.model.shorelines.domain.boundary.file;

%fid=fopen(fname,'r');
%fclose(fid);

setHandles(handles);
