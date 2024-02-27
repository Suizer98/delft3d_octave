function ddb_shorelines_domain(varargin)

ddb_zoomOff;

if isempty(varargin)
    
    % New tab selected
    ddb_plotshorelines('update','active',0,'visible',1);        

else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'loadshorelinefile'}
            load_shoreline_file;
            
    end
    
end

%%
function load_shoreline_file

handles=getHandles;
[x,y]=read_xy_columns(handles.model.shorelines.domain.shoreline.filename);
handles.model.shorelines.domain.shoreline.length=length(x);
handles.model.shorelines.domain.shoreline.x=x;
handles.model.shorelines.domain.shoreline.y=y;
handles = ddb_shorelines_plot_shoreline(handles, 'plot');
setHandles(handles);

ch=get(handles.model.shorelines.domain.handle,'Children');
set(ch,'HitTest','off');

gui_updateActiveTab;

