function ddb_shorelines_open_input(opt)

handles=getHandles;

switch lower(opt)
    case{'open'}

        [filename, pathname, filterindex] = uigetfile('shorelines.inp','Select ShorelineS file');

        if pathname~=0

            pathname=pathname(1:end-1); % Get rid of last file seperator
            if ~strcmpi(pathname,handles.workingDirectory)
                cd(pathname);
                handles.workingDirectory=pathname;
            end

            % Delete all domains
            ddb_plotshorelines('delete','domain',1);
            
            handles = ddb_initializeshorelines(handles);
            
            % Read in shorelines data here ...
            
            [S0]=readkeys(filename);
            fieldnms=fields(S0);
            for ii=1:length(fieldnms)
                handles.model.shorelines.domain.(fieldnms{ii}) = S0.(fieldnms{ii});
            end
%% Some options not specified in input file
            if ~isempty(handles.model.shorelines.domain.Waveclimfile)
                handles.model.shorelines.wave_opt='wave_climate';
            elseif ~isempty(handles.model.shorelines.domain.WVCfile)
                handles.model.shorelines.wave_opt='wave_timeseries';
            else
                handles.model.shorelines.wave_opt='mean_and_spreading';
            end
            handles.model.shorelines.domain.transport_opt=handles.model.shorelines.domain.trform;

            if ~isempty(handles.model.shorelines.domain.wavefile)
                handles.model.shorelines.wavetrans_opt='lookup_table';
                handles.model.shorelines.domain.wave_interaction=1;
            elseif ~isempty(handles.model.shorelines.domain.phif)
                handles.model.shorelines.wavetrans_opt='dynamic_profile';
            else
                handles.model.shorelines.wavetrans_opt='none';
            end
            
            if handles.model.shorelines.domain.spit_width>0
                handles.model.shorelines.spit_opt='on';
            else
                handles.model.shorelines.spit_opt='off';
            end
            
            setHandles(handles);

            if ~isempty(handles.model.shorelines.domain.LDBcoastline)
                load_shorelines
                %[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBcoastline);
                %handles.model.shorelines.domain.x_mc=x;
                %handles.model.shorelines.domain.y_mc=y;
            end
            
            if ~isempty(handles.model.shorelines.domain.LDBstructures)
                load_structures
                %[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBcoastline);
                %handles.model.shorelines.domain.x_mc=x;
                %handles.model.shorelines.domain.y_mc=y;
            end
            
            if ~isempty(handles.model.shorelines.domain.LDBnourish)
                load_nourishments
                %[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBcoastline);
                %handles.model.shorelines.domain.x_mc=x;
                %handles.model.shorelines.domain.y_mc=y;
            end
                          
            if ~isempty(handles.model.shorelines.domain.LDBchannel)
                load_channels
                %[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBcoastline);
                %handles.model.shorelines.domain.x_mc=x;
                %handles.model.shorelines.domain.y_mc=y;
            end
                          
            ddb_plotshorelines('delete');
            ddb_plotshorelines('plot','active',0,'visible',1);
            
%             handles = ddb_shorelines_plot_shoreline(handles, 'plot');
%             handles = ddb_shorelines_plot_structure(handles, 'plot');
%             handles = ddb_shorelines_plot_nourishment(handles, 'plot');
%             handles = ddb_shorelines_plot_channel(handles, 'plot');
            gui_updateActiveTab;

        end        
    otherwise
end

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
    %compute_length;
end
handles.model.shorelines.nrnourishments=nrnourishments;
handles.model.shorelines.activenourishment=1;

handles = ddb_shorelines_plot_nourishment(handles, 'plot');

setHandles(handles);

gui_updateActiveTab;

%%
function load_structures

handles=getHandles;

%[x,y]=landboundary('read',handles.model.shorelines.structure.filename);
[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBstructures);
matname=handles.model.shorelines.domain.LDBstructures;
matname(end-2:end)='mat';
load(matname);
handles.model.shorelines.structures=structures;

[xi,yi,nrstructures,i1,i2]= get_one_polygon(x,y,1);
for as=1:nrstructures
    [xi,yi,nrstructures,i1,i2]= get_one_polygon(x,y,as);
    handles.model.shorelines.structures(as).x=xi;
    handles.model.shorelines.structures(as).y=yi;
    handles.model.shorelines.structures(as).length=length(xi);
    handles.model.shorelines.structurenames{as}=['structure ',num2str(as)];
    handles.model.shorelines.structures(as).name=['structure ',num2str(as)];
end
handles.model.shorelines.nrstructures=nrstructures;
handles.model.shorelines.activestructure=1;

handles = ddb_shorelines_plot_structure(handles, 'plot');

%set(handles.model.shorelines.structure.handle,'HitTest','off');
% ch=get(handles.model.shorelines.structure.handle,'Children');
% set(ch,'HitTest','off');

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

