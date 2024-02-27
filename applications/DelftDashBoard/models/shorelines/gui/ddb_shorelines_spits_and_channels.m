function ddb_shorelines_spits_and_channels(varargin)

%%
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    % Make shoreline visible
    ddb_plotshorelines('update','active',1,'visible',1);
    handles=getHandles;
    
    handles = ddb_shorelines_plot_channel(handles, 'plot');
    
    setHandles(handles);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectspitoption'}
            select_spit_option;
        case{'selectfromlist'}
            select_from_list;
        case{'drawchannel'}
            draw_channel;
        case{'deletechannel'}
            delete_channel;
        case{'loadchannels'}
            load_channels;
        case{'savechannels'}
            save_channels;
            
    end
    
end

%%
function select_spit_option

handles=getHandles;
opt=handles.model.shorelines.spit_opt;
%ddb_giveWarning('text',['Thank you for selecting spit option ' opt]);
setHandles(handles);
%%
function select_from_list

handles=getHandles;

handles = ddb_shorelines_plot_channel(handles, 'plot');

setInstructions({'','Click on map to draw channel in seaward direction','Use right-click to end channel'});
setHandles(handles);

%%
function draw_channel

handles=getHandles;

gui_polyline('draw','axis',handles.GUIHandles.mapAxis,'tag','channels_tmp','marker','o', ...
    'createcallback',@create_channel, ...
    'linecolor','g','closed',0);

setInstructions({'','Click on map to draw channel','Use right-click to end channel'});

setHandles(handles);

%%
function create_channel(h,x,y)

handles=getHandles;

% Delete temporary channel

delete(h);
handles.model.shorelines.nrchannels=handles.model.shorelines.nrchannels+1;
handles.model.shorelines.activechannel=handles.model.shorelines.nrchannels;
as=handles.model.shorelines.activechannel;
handles.model.shorelines.channels(as).x=x;
handles.model.shorelines.channels(as).y=y;
handles.model.shorelines.channelnames{as}=['channel ',num2str(as)];
handles.model.shorelines.channels(as).name=['channel ',num2str(as)];
handles.model.shorelines.channels(as).length=length(handles.model.shorelines.channels(as).x);
handles = ddb_shorelines_plot_channel(handles, 'plot');
handles.model.shorelines.status='waiting';

setHandles(handles);

clearInstructions;

gui_updateActiveTab;

draw_channel;

%%
function delete_channel

handles=getHandles;

% First delete existing channel
as=handles.model.shorelines.activechannel;
nr=handles.model.shorelines.nrchannels;
delete (handles.model.shorelines.channels(as).handle);
handles.model.shorelines.channels=handles.model.shorelines.channels([1:as-1,as+1:nr]);
handles.model.shorelines.nrchannels=handles.model.shorelines.nrchannels-1;
handles.model.shorelines.activechannel=handles.model.shorelines.nrchannels;
handles=update_channel_names(handles);
handles.model.shorelines.activechannel=min(as,handles.model.shorelines.nrchannels);
handles = ddb_shorelines_plot_channel(handles, 'plot');
setHandles(handles);

gui_updateActiveTab;

%%
function load_channels

handles=getHandles;

%[x,y]=landboundary('read',handles.model.shorelines.channel.filename);
[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBchannel);
matname=handles.model.shorelines.domain.LDBchannel;
matname(end-2:end)='mat';
load(matname);
handles.model.shorelines.channels=channels;
[xi,yi,nrchannels,i1,i2]= get_one_polygon(x,y,1);
for as=1:nrchannels
    [xi,yi,nrchannels,i1,i2]= get_one_polygon(x,y,as);
    handles.model.shorelines.channels(as).x=xi;
    handles.model.shorelines.channels(as).y=yi;
    handles.model.shorelines.channels(as).length=length(xi);
    handles.model.shorelines.channelnames{as}=['channel ',num2str(as)];
    handles.model.shorelines.channels(as).name=['channel ',num2str(as)];
    handles.model.shorelines.activechannel=as;
    setHandles(handles);
end
handles.model.shorelines.nrchannels=nrchannels;
handles.model.shorelines.activechannel=1;

handles = ddb_shorelines_plot_channel(handles, 'plot');

setHandles(handles);

gui_updateActiveTab;

%%
function save_channels

handles=getHandles;

if handles.model.shorelines.nrchannels>0
    handles.model.shorelines.domain.channel=1;
    x=handles.model.shorelines.channels(1).x;
    y=handles.model.shorelines.channels(1).y;
    for as=2:handles.model.shorelines.nrchannels
        x=[x,NaN,handles.model.shorelines.channels(as).x];
        y=[y,NaN,handles.model.shorelines.channels(as).y];
    end
    %landboundary('write',handles.model.shorelines.channel.filename,x,y);
    out=[x;y]';
    save(handles.model.shorelines.domain.LDBchannel,'out','-ascii');
    setHandles(handles);
    
    gui_updateActiveTab;
    
    matname=handles.model.shorelines.domain.LDBchannel;
    matname(end-2:end)='mat';
    channels=handles.model.shorelines.channels;
    channels=rmfield(channels,'handle');
    save(matname,'channels');
else
    handles.model.shorelines.domain.channel=0;
end
%%
function edit_name

handles=getHandles;
handles=update_channel_names(handles)
setHandles(handles);

%%
function handles=update_channel_names(handles)
handles.model.shorelines.channelnames={''};
for as=1:handles.model.shorelines.nrchannels
    handles.model.shorelines.channelnames{as}=handles.model.shorelines.channels(as).name;
end

gui_updateActiveTab;

