%% 4. Visualising your model results
%
% The XBeach Toolbox contains basic tools to visualise model input and
% output, especially bathymetries. The purpose of these tools is not to
% provide awesome visualisations, but just to provide insight in the
% massive amount of data you will probably be dealing with soon.

%% Visualise model input
%
% Once your model setup is finished, or at least you think so, you can
% visualise your bathymetry and other data using the _xb_view_ function.
% This function basically plots any vector or matrix data from an XBeach
% structure. It provides a simple interface to select the data to be
% plotted (can be multiple) and the way it should be plotted.

% generate dummy model
xbm = xb_generate_model;

% plot model setup
xb_view(xbm);

%%
% Depending on the amount of vector and matrix data, the plotting options
% will be extended

% obtain bathymetry data
url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB121_2524.nc';
[x y z] = deal(nc_varget(url, 'x'), nc_varget(url, 'y'), nc_varget(url, 'z'));
z = squeeze(z(end,:,:));

% generate storm surge
[h Hs Tp] = bc_normstorm('loc', 'Petten', 'freq', 1e-4);
[t h duration Hs Tp] = bc_stormsurge('h_max', h, 'Hm0_max', Hs, 'Tp_max', Tp, 'nwaves',32);

% generate model setup using JARKUS bathymetry and obtained surge and wave
% confitions
xbm = xb_generate_model( ...
    'bathy',    {'x', x, 'y', y, 'z', z}, ...
    'tide',     {'time' t, 'front', h, 'back', 0}, ...
    'waves',    {'Hm0', Hs, 'Tp', Tp, 'duration', duration} ...
);

xb_view(xbm);

%% Visualise model output
%
% The _xb_view_ function also works for XBeach output structures obtained
% from the _xb_read_output_ function. Again, all vector and matrix data is
% plotted and also a slider to walk through time becomes available. The
% slider can also be animated. Difference plots can be made with a
% secondary slider, the difference between the two moments in time is
% plotted.

xbr = xb_run(generate_model);

xbo = xb_read_output(xbr);

xb_view(xbo);