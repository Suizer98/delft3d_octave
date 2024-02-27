%% JarKus tutorial for extending profiles (profielen aanvullen)

%% Read data
transectid = [7004875:7004900];
transects = jarkus_transects(...
    'id', transectid,...
    'year', 2009:2010,...
    'output', {'id' 'time' 'cross_shore' 'altitude'});

%% interpolate/extrapolate to extend the profile
% first linear interpolate in cross-shore and time dimension without
% extrapolation
transectsi = jarkus_interpolate_landward(transects);

% then extrapolate in time using the nearest neighbour method
transectsn = jarkus_interpolate_landward(transectsi,...
    'method2', 'nearest',...
    'extrap2', true);

%% plot
yyyy = year(transects.time+datenum(1970,1,1));

jarkus_plot_transect(transects)
figure
jarkus_plot_transect(transectsn)