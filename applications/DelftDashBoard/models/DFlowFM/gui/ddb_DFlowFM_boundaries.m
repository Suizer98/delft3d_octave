function ddb_DFlowFM_boundaries(varargin)

handles=getHandles;

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_DFlowFM_plotBoundaries(handles,'update','active',1);
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectboundary'}
            ddb_DFlowFM_plotBoundaries(handles,'update');
        case{'changeboundary'}
            h=varargin{2};
            x=varargin{3};
            y=varargin{4};
            nr=varargin{5};
            changeBoundary(h,x,y,nr);
        case{'insertpoint'}
            insertPoint;
        case{'deletepoint'}
            h=varargin{2};
            x=varargin{3};
            y=varargin{4};
            nr=varargin{5};
            insertPoint(h,x,y,nr);
        case{'editname'}
            editName;
        case{'add'}
            drawBoundary;
        case{'delete'}
            deleteBoundary;
        case{'load'}
            loadBoundary;
        case{'save'}
            saveBoundary;
        case{'saveall'}
            saveAllBoundaries;
        case{'openexternalforcing'}
            openExternalForcing;
        case{'saveexternalforcing'}
            saveExternalForcing;
        case{'selecttype'}
            select_boundary_type;
    end
end

%%
function editName
handles=getHandles;
iac=handles.model.dflowfm.domain.activeboundary;
oriname=handles.model.dflowfm.domain.boundarynames{iac};
name=handles.model.dflowfm.domain.boundary(iac).boundary.name;
% Check for spaces
if isempty(find(name==' ', 1))
    handles.model.dflowfm.domain.boundary(iac).boundary.location_file=[name '.pli'];
    handles=updateNames(handles);
else
    ddb_giveWarning('text','Sorry, boundary names cannot contain spaces!');
    handles.model.dflowfm.domain.boundary(iac).boundary.name=oriname;
end
setHandles(handles);

%%
function drawBoundary
ddb_zoomOff;
setInstructions({'','','Draw boundary polyline'});
gui_polyline('draw','tag','dflowfmboundary','Marker','o','createcallback',@addBoundary,'changecallback',@changeBoundary,'closed',0, ...
    'color','g','markeredgecolor','r','markerfacecolor','r');

%%
function addBoundary(h,x,y,nr)
clearInstructions;

handles=getHandles;

nr=handles.model.dflowfm.domain.nrboundaries;
nr=nr+1;

handles.model.dflowfm.domain.nrboundaries=nr;

for ip=1:length(x)
    xb=x(ip);
    yb=y(ip);
    dst=sqrt((handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_x-xb).^2+(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_y-yb).^2);
    imin=find(dst==min(dst));
    imin=imin(1);
    x(ip)=handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_x(imin);
    y(ip)=handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_y(imin);
end

name=['bnd' num2str(nr,'%0.3i')];
handles.model.dflowfm.domain.boundary(nr).boundary=ddb_delft3dfm_initialize_boundary(name,'water_level','astronomic',handles.model.dflowfm.domain.tstart,handles.model.dflowfm.domain.tstop,x,y);

handles=updateNames(handles);

handles.model.dflowfm.domain.boundary(nr).boundary.handle=h;

handles.model.dflowfm.domain.activeboundary=nr;

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function deleteBoundary

clearInstructions;

handles=getHandles;

if handles.model.dflowfm.domain.nrboundaries>0

    iac=handles.model.dflowfm.domain.activeboundary;
    try
        delete(handles.model.dflowfm.domain.boundary(iac).boundary.handle);
    end
    handles.model.dflowfm.domain.boundary=removeFromStruc(handles.model.dflowfm.domain.boundary,iac);
    handles.model.dflowfm.domain.nrboundaries=handles.model.dflowfm.domain.nrboundaries-1;
    handles.model.dflowfm.domain.activeboundary=max(min(handles.model.dflowfm.domain.activeboundary,handles.model.dflowfm.domain.nrboundaries),1);
    handles.model.dflowfm.domain.activeboundaries=handles.model.dflowfm.domain.activeboundary;


     handles=updateNames(handles);
     
    if handles.model.dflowfm.domain.nrboundaries==0
        handles.model.dflowfm.domain.boundary(1).boundary=ddb_delft3dfm_initialize_boundary('','water_level','astronomic',handles.model.dflowfm.domain.tstart,handles.model.dflowfm.domain.tstop,0,0);
    end
    
    % Rename boundaries
    handles=updateNames(handles);
    
    setHandles(handles);
    
    gui_updateActiveTab;

    ddb_DFlowFM_plotBoundaries(handles,'update');

end

%%
function changeBoundary(h,x,y,nr)

iac=[];
handles=getHandles;
% Find which boundary this is
for ii=1:length(handles.model.dflowfm.domain.boundary)
    if handles.model.dflowfm.domain.boundary(ii).boundary.handle==h
        iac=ii;
        break
    end
end

% if ~isempty(iac)
%     
%     % Find nearest point on circumference
%     xcir=handles.model.dflowfm.domain.circumference.x;
%     ycir=handles.model.dflowfm.domain.circumference.y;
%     
%     dst=sqrt((xcir-x(nr)).^2+(ycir-y(nr)).^2);
%     imin=find(dst==min(dst));
%     x(nr)=xcir(imin);
%     y(nr)=ycir(imin);
%     

% Find nearest grid point
xb=x(nr);
yb=y(nr);
dst=sqrt((handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_x-xb).^2+(handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_y-yb).^2);
imin=find(dst==min(dst));
imin=imin(1);
x(nr)=handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_x(imin);
y(nr)=handles.model.dflowfm.domain(ad).netstruc.node.mesh2d_node_y(imin);

handles.model.dflowfm.domain(ad).activeboundary=iac;
    handles.model.dflowfm.domain(ad).boundary(iac).boundary.x=x;
    handles.model.dflowfm.domain(ad).boundary(iac).boundary.y=y;
    handles.model.dflowfm.domain(ad).boundary(iac).boundary.activenode=nr;
%     
% end

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function loadBoundary

clearInstructions;

handles=getHandles;
nr=handles.model.dflowfm.domain.nrboundaries;
nr=nr+1;

[filename, pathname, filterindex] = uigetfile('*.pli', 'Load polyline file','');
if pathname~=0
    
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end    
%    [x,y,nodenames]=ddb_DFlowFM_readBoundaryPolygon(filename);
    [x,y]=landboundary('read',filename);
else
    return
end

handles.model.dflowfm.domain.nrboundaries=nr;
handles.model.dflowfm.domain.activeboundary=nr;

name=filename(1:end-4);

handles.model.dflowfm.domain.boundary(nr).boundary=ddb_delft3dfm_initialize_boundary(handles.model.dflowfm.domain.tstart,handles.model.dflowfm.domain.tstop,x,y);
handles.model.dflowfm.domain.boundary(nr).boundary.name=name;
handles.model.dflowfm.domain.boundary(nr).boundary.type='water_level';
handles.model.dflowfm.domain.boundary(nr).boundary.location_file=filename;

handles=updateNames(handles);

h=gui_polyline('plot','x',x,'y',y,'tag','dflowfmboundary', ...
    'changecallback',@ddb_DFlowFM_boundaries,'changeinput','changeboundary','closed',0, ...
    'Marker','o','color','g','markeredgecolor','r','markerfacecolor','r');

handles.model.dflowfm.domain.boundaries(nr).handle=h;

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function saveBoundary

clearInstructions;

handles=getHandles;

iac=handles.model.dflowfm.domain.activeboundary;

[filename, pathname, filterindex] = uiputfile('*.pli', 'Save polyline file',handles.model.dflowfm.domain.boundaries(iac).locationfile);

if pathname~=0

    % Save pli file
    handles.model.dflowfm.domain.boundary(iac).boundary.location_file=filename;
    handles.model.dflowfm.domain.boundary(iac).boundary.name=filename(1:end-4);
    handles=updateNames(handles);
    
    delft3dfm_write_boundary_polyline(handles.model.dflowfm.domain.boundary(iac).boundary);

else
    return
end

setHandles(handles);

%%
function saveAllBoundaries

clearInstructions;

handles=getHandles;

for iac=1:handles.model.dflowfm.domain.nrboundaries

    delft3dfm_write_boundary_polyline(handles.model.dflowfm.domain.boundary(iac).boundary);

end

setHandles(handles);


%%
function openExternalForcing

clearInstructions;

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.ext', 'External Forcing File',handles.model.dflowfm.domain.extforcefilenew);
if ~isempty(pathname)    
    
    handles.model.dflowfm.domain.extforcefilenew=filename;

    wb      = waitbox('Loading Boundary Conditions ...');
    
    try
        handles = ddb_delft3dfm_read_boundaries(handles);
    catch
        close(wb);
        ddb_giveWarning('text','An error occured while load the boundary conditions ...');
    end
    close(wb);

    handles = ddb_DFlowFM_plotBoundaries(handles,'delete');
    handles = ddb_DFlowFM_plotBoundaries(handles,'plot','active',1);
    setHandles(handles);
end

%%
function saveExternalForcing

clearInstructions;

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.ext', 'External Forcing File',handles.model.dflowfm.domain.extforcefilenew);

if pathname~=0
    handles.model.dflowfm.domain.extforcefilenew=filename;
    ddb_delft3dfm_save_boundary_ext_file(handles);
    setHandles(handles);
end

%%
function handles=updateNames(handles)
% Change filename of pli file and component files
handles.model.dflowfm.domain.boundarynames=[];
for ib=1:handles.model.dflowfm.domain.nrboundaries
    name=handles.model.dflowfm.domain.boundary(ib).boundary.name;
    handles.model.dflowfm.domain.boundarynames{ib}=name;
    for ip=1:length(handles.model.dflowfm.domain.boundary(ib).boundary.x)
        handles.model.dflowfm.domain.boundary(ib).boundary.nodenames{ip}=[name '_' num2str(ip,'%0.4i')];
    end
end

%%
function insertPoint

handles=getHandles;

iac=handles.model.dflowfm.domain.activeboundary;
    
nr=handles.model.dflowfm.domain.boundary(iac).boundary.activenode;

nrnodes0=length(handles.model.dflowfm.domain.boundary(iac).boundary.nodes);

nodes=handles.model.dflowfm.domain.boundary(iac).boundary.nodes;

nodes=insert_in_structure(nodes,nr+1);
nr=nr+1;

handles.model.dflowfm.domain.boundary(iac).boundary.nodes=nodes;

if nr>nrnodes0
    % Append to end
else
    % Append in middle
    xx=0.5*(handles.model.dflowfm.domain.boundary(iac).boundary.x(nr-1)+handles.model.dflowfm.domain.boundary(iac).boundary.x(nr));
    yy=0.5*(handles.model.dflowfm.domain.boundary(iac).boundary.y(nr-1)+handles.model.dflowfm.domain.boundary(iac).boundary.y(nr));
    x=[handles.model.dflowfm.domain.boundary(iac).boundary.x(1:nr-1) xx handles.model.dflowfm.domain.boundary(iac).boundary.x(nr:end)];
    y=[handles.model.dflowfm.domain.boundary(iac).boundary.y(1:nr-1) yy handles.model.dflowfm.domain.boundary(iac).boundary.y(nr:end)];
    handles.model.dflowfm.domain.boundary(iac).boundary.nodes(nr)=handles.model.dflowfm.domain.boundary(iac).boundary.nodes(nr-1);
end

% Find nearest point on circumference
xcir=handles.model.dflowfm.domain.circumference.x;
ycir=handles.model.dflowfm.domain.circumference.y;
dst=sqrt((xcir-x(nr)).^2+(ycir-y(nr)).^2);
imin=find(dst==min(dst),1,'first');
x(nr)=xcir(imin);
y(nr)=ycir(imin);

handles.model.dflowfm.domain.activeboundary=iac;
handles.model.dflowfm.domain.boundary(iac).boundary.x=x;
handles.model.dflowfm.domain.boundary(iac).boundary.y=y;
handles.model.dflowfm.domain.boundary(iac).boundary.activenode=nr;

for ip=1:nrnodes0+1
    handles.model.dflowfm.domain.boundary(iac).boundary.nodenames{ip}=[handles.model.dflowfm.domain.boundary(iac).boundary.name '_' num2str(ip,'%0.4i')];
end

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function select_boundary_type

handles=getHandles;
iac=handles.model.dflowfm.domain.activeboundary;
tp=handles.model.dflowfm.domain.boundary(iac).boundary.type;
setHandles(handles);

switch tp
    case{'water_level'}
        handles.model.dflowfm.domain.boundary(iac).boundary.water_level.astronomic_components.active=1;
    case{'water_level_plus_normal_velocity'}
        handles.model.dflowfm.domain.boundary(iac).boundary.water_level.astronomic_components.active=1;
        handles.model.dflowfm.domain.boundary(iac).boundary.normal_velocity.astronomic_components.active=1;
    case{'water_level_plus_normal_velocity_plus_tangential_velocity'}
        handles.model.dflowfm.domain.boundary(iac).boundary.water_level.astronomic_components.active=1;
        handles.model.dflowfm.domain.boundary(iac).boundary.normal_velocity.astronomic_components.active=1;
        handles.model.dflowfm.domain.boundary(iac).boundary.tangential_velocity.astronomic_components.active=1;
    case{'riemann'}
    case{'discharge'}
end
