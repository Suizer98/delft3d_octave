function ddb_shorelines_shorelines(varargin)

%%

ddb_zoomOff;

if isempty(varargin)

    % New tab selected
    %ddb_refreshScreen;
    % Make shoreline visible
    ddb_plotshorelines('update','active',1,'visible',1);

else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'selectfromlist'}
            select_from_list;
        case{'drawshoreline'}
            draw_shoreline;
        case{'deleteshoreline'}
            delete_shoreline;
        case{'loadshorelines'}
            load_shorelines;
        case{'saveshorelines'}
            save_shorelines;
        case{'editname'}
            edit_name;
    end
    
end

%%
function select_from_list

handles=getHandles;

% First delete existing shoreline
%handles = ddb_shorelines_plot_shoreline(handles, 'delete');
% handles.model.shorelines.shoreline.x=[];
% handles.model.shorelines.shoreline.y=[];
% handles.model.shorelines.shoreline.length=0;

handles = ddb_shorelines_plot_shoreline(handles, 'plot');
% as=handles.model.shorelines.activeshoreline;
% xp=handles.model.shorelines.shorelines(as).x;
% yp=handles.model.shorelines.shorelines(as).y;
% gui_polyline('plot','axis',handles.GUIHandles.mapAxis,'tag','shorelines_tmp','marker','o', ...
%     'x',xp,'y',yp, ...
%     'changecallback',@modify_shoreline, ...
%     'linecolor','g','closed',1);

setInstructions({'','Click on map to draw shoreline','Use right-click to end shoreline'});

setHandles(handles);

%%
function draw_shoreline

handles=getHandles;

% First delete existing shoreline
%handles = ddb_shorelines_plot_shoreline(handles, 'delete');
% handles.model.shorelines.shoreline.x=[];
% handles.model.shorelines.shoreline.y=[];
% handles.model.shorelines.shoreline.length=0;

gui_polyline('draw','axis',handles.GUIHandles.mapAxis,'tag','shorelines_tmp','marker','o', ...
    'createcallback',@create_shoreline, ...
    'linecolor','g','closed',0);

setInstructions({'','Click on map to draw shoreline','Use right-click to end shoreline'});

setHandles(handles);

%%
function create_shoreline(h,x,y)

handles=getHandles;

% Delete temporary shoreline

delete(h);
handles.model.shorelines.nrshorelines=handles.model.shorelines.nrshorelines+1;
handles.model.shorelines.activeshoreline=handles.model.shorelines.nrshorelines;
as=handles.model.shorelines.activeshoreline;
handles.model.shorelines.shorelines(as).x=x;
handles.model.shorelines.shorelines(as).y=y;
handles.model.shorelines.shorelinenames{as}=['shoreline ',num2str(as)];
handles.model.shorelines.shorelines(as).name=['shoreline ',num2str(as)];
handles=update_shoreline_xy_mc(handles);
handles.model.shorelines.shorelines(as).length=length(handles.model.shorelines.shorelines(as).x);
handles = ddb_shorelines_plot_shoreline(handles, 'plot');

handles.model.shorelines.status='waiting';

setHandles(handles);

clearInstructions;

gui_updateActiveTab;

draw_shoreline;

%%
function delete_shoreline

handles=getHandles;

% First delete existing shoreline
as=handles.model.shorelines.activeshoreline;
nr=handles.model.shorelines.nrshorelines;
delete (handles.model.shorelines.shorelines(as).handle);
handles.model.shorelines.shorelines=handles.model.shorelines.shorelines([1:as-1,as+1:nr]);
handles.model.shorelines.nrshorelines=handles.model.shorelines.nrshorelines-1;
handles.model.shorelines.activeshoreline=handles.model.shorelines.nrshorelines;
handles=update_shoreline_names(handles);
handles=update_shoreline_xy_mc(handles);
handles.model.shorelines.activeshoreline=min(as,handles.model.shorelines.nrshorelines);
handles = ddb_shorelines_plot_shoreline(handles, 'plot');
setHandles(handles);

gui_updateActiveTab;

%%
function load_shorelines

handles=getHandles;

%[x,y]=landboundary('read',handles.model.shorelines.shoreline.filename);
[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBcoastline);
handles.model.shorelines.domain.x_mc=x;
handles.model.shorelines.domain.y_mc=y;
try
    matname=handles.model.shorelines.domain.LDBcoastline;
    matname(end-2:end)='mat';
    load(matname);
    handles.model.shorelines.shorelines=shorelines;
end
[xi,yi,nrshorelines,i1,i2]= get_one_polygon(x,y,1);
for as=1:nrshorelines
    [xi,yi,nrshorelines,i1,i2]= get_one_polygon(x,y,as);
    handles.model.shorelines.shorelines(as).x=xi;
    handles.model.shorelines.shorelines(as).y=yi;
    handles.model.shorelines.shorelines(as).length=length(xi);
    handles.model.shorelines.shorelinenames{as}=['shoreline ',num2str(as)];
    handles.model.shorelines.shorelines(as).name=['shoreline ',num2str(as)];
end
handles.model.shorelines.nrshorelines=nrshorelines;
handles.model.shorelines.activeshoreline=1;

handles = ddb_shorelines_plot_shoreline(handles, 'plot');

%set(handles.model.shorelines.shoreline.handle,'HitTest','off');
% ch=get(handles.model.shorelines.shoreline.handle,'Children');
% set(ch,'HitTest','off');

setHandles(handles);

gui_updateActiveTab;

%%
function save_shorelines

handles=getHandles;

x=handles.model.shorelines.shorelines(1).x;
y=handles.model.shorelines.shorelines(1).y;
for as=2:handles.model.shorelines.nrshorelines
    x=[x,NaN,handles.model.shorelines.shorelines(as).x];
    y=[y,NaN,handles.model.shorelines.shorelines(as).y];
end
%landboundary('write',handles.model.shorelines.shoreline.filename,x,y);
out=[x;y]';
save(handles.model.shorelines.domain.LDBcoastline,'out','-ascii');
setHandles(handles);

gui_updateActiveTab;

matname=handles.model.shorelines.domain.LDBcoastline;
matname(end-2:end)='mat';
shorelines=handles.model.shorelines.shorelines;
shorelines=rmfield(shorelines,'handle');
save(matname,'shorelines');
%%
function edit_name

handles=getHandles;
handles=update_shoreline_names(handles)
setHandles(handles);

%%
function handles=update_shoreline_names(handles)
handles.model.shorelines.shorelinenames={''};
for as=1:handles.model.shorelines.nrshorelines
    handles.model.shorelines.shorelinenames{as}=handles.model.shorelines.shorelines(as).name;
end

gui_updateActiveTab;

%%
function handles=update_shoreline_xy_mc(handles)

if handles.model.shorelines.nrshorelines>0
    handles.model.shorelines.domain.x_mc=handles.model.shorelines.shorelines(1).x;
    handles.model.shorelines.domain.y_mc=handles.model.shorelines.shorelines(1).y;
    for as=2:handles.model.shorelines.nrshorelines
        handles.model.shorelines.domain.x_mc=[handles.model.shorelines.domain.x_mc,NaN,handles.model.shorelines.shorelines(as).x];
        handles.model.shorelines.domain.y_mc=[handles.model.shorelines.domain.y_mc,NaN,handles.model.shorelines.shorelines(as).y];
    end
end

gui_updateActiveTab;
