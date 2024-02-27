function handles = ddb_initializeshorelines(handles, varargin)

% This is where all the ShorelineS data is initialized
% Actual ShorelineS input is initialized in ddb_shorelines_initialize_domain.m

handles.model.shorelines.menuview.shoreline=1;

% Just as an example ... (see Physics tab)
handles.model.shorelines.wave_opts_long ={'Mean and spreading','Wave climate','Wave time series'};
handles.model.shorelines.wave_opts_short={'mean_and_spreading','wave_climate','wave_time_series'};

handles.model.shorelines.wavetrans_opts_long ={'None','Dynamic profile','Wave lookup table'};
handles.model.shorelines.wavetrans_opts_short={'none','dynamic_profile','lookup_table'};

handles.model.shorelines.transport_opts_long ={'CERC','CERC 3','Kamphuis','Mil-Homens','van Rijn 2014'};
handles.model.shorelines.transport_opts_short={'CERC','CERC3','KAMP','MILH','VR14'};

handles.model.shorelines.spit_opts_long ={'Off','On'};
handles.model.shorelines.spit_opts_short={'off','on'};

handles.model.shorelines.status='waiting';
handles.model.shorelines.current_time_string=datestr(floor(now));
handles.model.shorelines.time_remaining_string='0';

handles=ddb_shorelines_initialize_domain(handles);
