function ddb_shorelines_nourishments(varargin)

%%

ddb_zoomOff;

if isempty(varargin)

    % New tab selected
    ddb_refreshScreen;
    % Make shoreline visible
    ddb_plotshorelines('update','active',1,'visible',1);
    handles=getHandles;
    
    handles = ddb_shorelines_plot_nourishment(handles, 'plot');
    
    setHandles(handles);

else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'selectfromlist'}
            select_from_list;
            edit_volume;
        case{'drawnourishment'}
            draw_nourishment;
        case{'deletenourishment'}
            delete_nourishment;
        case{'loadnourishments'}
            load_nourishments;
        case{'savenourishments'}
            save_nourishments;
        case{'editdate'}
            edit_date;
            edit_volume;
        case{'editvolume'}
            edit_volume;
        case{'editrate'}
            edit_rate;
    end
    
end

%%
function edit_date

handles=getHandles;
an=handles.model.shorelines.activenourishment;
handles.model.shorelines.nourishments(an).duration= ...
handles.model.shorelines.nourishments(an).tend- ...
handles.model.shorelines.nourishments(an).tstart

setHandles(handles);

%%
function edit_volume

handles=getHandles;

an=handles.model.shorelines.activenourishment;
handles.model.shorelines.nourishments(an).rate= round(...
handles.model.shorelines.nourishments(an).volume*1e6/ ...
handles.model.shorelines.nourishments(an).duration/ ...
handles.model.shorelines.nourishments(an).nourlength/ ...
handles.model.shorelines.domain.d*365);

setHandles(handles);

%%
function edit_rate

handles=getHandles;

an=handles.model.shorelines.activenourishment;
handles.model.shorelines.nourishments(an).volume= ...
handles.model.shorelines.nourishments(an).rate* ...
handles.model.shorelines.nourishments(an).duration* ...
handles.model.shorelines.nourishments(an).nourlength* ...
handles.model.shorelines.domain.d/365/1e6;

setHandles(handles);

%%
function select_from_list

handles=getHandles;

handles = ddb_shorelines_plot_nourishment(handles, 'plot');

setInstructions({'','Click on map to draw nourishment','Use right-click to end nourishment'});
setHandles(handles);
compute_length;

%%
function draw_nourishment

handles=getHandles;

gui_polyline('draw','axis',handles.GUIHandles.mapAxis,'tag','nourishments_tmp','marker','o', ...
    'createcallback',@create_nourishment, ...
    'linecolor','g','closed',1);

setInstructions({'','Click on map to draw nourishment','Use right-click to end nourishment'});

setHandles(handles);

%%
function create_nourishment(h,x,y)

handles=getHandles;

% Delete temporary nourishment

delete(h);
handles.model.shorelines.nrnourishments=handles.model.shorelines.nrnourishments+1;
handles.model.shorelines.activenourishment=handles.model.shorelines.nrnourishments;
as=handles.model.shorelines.activenourishment;
handles.model.shorelines.nourishments(as).x=x;
handles.model.shorelines.nourishments(as).y=y;
handles.model.shorelines.nourishmentnames{as}=['nourishment ',num2str(as)];
handles.model.shorelines.nourishments(as).name=['nourishment ',num2str(as)];
handles.model.shorelines.nourishment_transmission(as)=0;
handles.model.shorelines.nourishments(as).length=length(handles.model.shorelines.nourishments(as).x);
handles = ddb_shorelines_plot_nourishment(handles, 'plot');
handles.model.shorelines.status='waiting';

setHandles(handles);

clearInstructions;

gui_updateActiveTab;
compute_length

draw_nourishment;

%%
function delete_nourishment

handles=getHandles;

% First delete existing nourishment
as=handles.model.shorelines.activenourishment;
nr=handles.model.shorelines.nrnourishments;
delete (handles.model.shorelines.nourishments(as).handle);
handles.model.shorelines.nourishments=handles.model.shorelines.nourishments([1:as-1,as+1:nr]);
handles.model.shorelines.nrnourishments=handles.model.shorelines.nrnourishments-1;
handles.model.shorelines.activenourishment=handles.model.shorelines.nrnourishments;
handles=update_nourishment_names(handles);
handles.model.shorelines.activenourishment=min(as,handles.model.shorelines.nrnourishments);
handles = ddb_shorelines_plot_nourishment(handles, 'plot');
setHandles(handles);

gui_updateActiveTab;

%%
function load_nourishments

handles=getHandles;

%[x,y]=landboundary('read',handles.model.shorelines.nourishment.filename);
[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBnourish);
matname=handles.model.shorelines.domain.LDBnourish;
matname(end-2:end)='mat';
load(matname);
handles.model.shorelines.nourishments=nourishments;

[xi,yi,nrnourishments,i1,i2]= get_one_polygon(x,y,1);

for as=1:nrnourishments
    [xi,yi,nrnourishments,i1,i2]= get_one_polygon(x,y,as);
    handles.model.shorelines.nourishments(as).x=xi;
    handles.model.shorelines.nourishments(as).y=yi;
    handles.model.shorelines.nourishments(as).length=length(xi);
    handles.model.shorelines.nourishmentnames{as}=['nourishment ',num2str(as)];
    handles.model.shorelines.nourishments(as).name=['nourishment ',num2str(as)];
    handles.model.shorelines.activenourishment=as;
    setHandles(handles);
    compute_length;
end
handles.model.shorelines.nrnourishments=nrnourishments;
handles.model.shorelines.activenourishment=1;

handles = ddb_shorelines_plot_nourishment(handles, 'plot');

setHandles(handles);

gui_updateActiveTab;

%%
function save_nourishments

handles=getHandles;

x=handles.model.shorelines.nourishments(1).x;
y=handles.model.shorelines.nourishments(1).y;
handles.model.shorelines.domain.nourish=1;
for as=2:handles.model.shorelines.nrnourishments
    x=[x,NaN,handles.model.shorelines.nourishments(as).x];
    y=[y,NaN,handles.model.shorelines.nourishments(as).y];
end
%landboundary('write',handles.model.shorelines.nourishment.filename,x,y);
out=[x;y]';
save(handles.model.shorelines.domain.LDBnourish,'out','-ascii');
setHandles(handles);

gui_updateActiveTab;

%% Save in matfile with same root name as nourishment polygon
matname=handles.model.shorelines.domain.LDBnourish;
matname(end-2:end)='mat';
nourishments=handles.model.shorelines.nourishments;
nourishments=rmfield(nourishments,'handle');
save(matname,'nourishments');
%% Set nourishment switch on
handles.model.shorelines.domain.nourish=1;

%%
function edit_name

handles=getHandles;
handles=update_nourishment_names(handles)
setHandles(handles);

%%
function handles=update_nourishment_names(handles)
handles.model.shorelines.nourishmentnames={''};
for as=1:handles.model.shorelines.nrnourishments
    handles.model.shorelines.nourishmentnames{as}=handles.model.shorelines.nourishments(as).name;
end

gui_updateActiveTab;

function compute_length
handles=getHandles;

x_mc=handles.model.shorelines.domain.x_mc;
y_mc=handles.model.shorelines.domain.y_mc;
an=handles.model.shorelines.activenourishment;
xp=handles.model.shorelines.nourishments(an).x;
yp=handles.model.shorelines.nourishments(an).y;
P=InterX([x_mc;y_mc],[xp;yp]);
if ~isempty(P)
    xcross=P(1,:);
    ycross=P(2,:);
    handles.model.shorelines.nourishments(an).nourlength=round(hypot(xcross(2)-xcross(1),ycross(2)-ycross(1)));
end
setHandles(handles);
gui_updateActiveTab;

