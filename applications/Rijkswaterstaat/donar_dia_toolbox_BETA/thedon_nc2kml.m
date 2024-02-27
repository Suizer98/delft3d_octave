function thedon_nc2kml
%thedon_nc2kml save all netcdf files as kml
%
% wrapper for donar_nc2scatter
%
%See also: findAllFiles, kmlscatter, donar_nc2scatter

basedir = 'p:\1209005-eutrotracks\nc';

%% FerryBox
subdir         = 'FerryBox';
deltares_names = {'fluorescence','oxygen','ph','salinity','temperature','turbidity'};
ncfiles        = findAllFiles([basedir,filesep,subdir],'pattern_incl','*.nc');
for i=1:length(ncfiles)
%donar_nc2scatter(ncfiles{i},deltares_names)
end

%% FerryBox
subdir         = 'ScanFish';
deltares_names = {'conductivity','fluorescence','oxygen','ph','salinity'};
ncfiles        = findAllFiles([basedir,filesep,subdir],'pattern_incl','*.nc');
for i=1:length(ncfiles)
donar_nc2scatter(ncfiles{i},deltares_names)
end

%% CTD_casts
subdir         = 'ScanFish';
deltares_names = {'conductivity','fluorescence','oxygen','ph','radiance','salinity'};
ncfiles        = findAllFiles([basedir,filesep,subdir],'pattern_incl','*.nc');
for i=1:length(ncfiles)
donar_nc2scatter(ncfiles{i},deltares_names)
end

