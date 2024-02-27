function [X, Y, Z] = grid_orth_getBathymetryForBackground(OPT)

if ~exist(fullfile(tempdir, 'background'))
    mkpath(fullfile(tempdir, 'background'));
else
    try
        load(fullfile(tempdir, 'background','background.mat'));
        if strcmp(background.dataset, OPT.dataset) && background.datenum == OPT.inputtimes(end)
            disp('Using cached results for background')
            return
        end
    end
end

catalog         =  nc2struct(OPT.dataset);
minx            =  min(min(catalog.projectionCoverage_x));
maxx            =  max(max(catalog.projectionCoverage_x));
miny            =  min(min(catalog.projectionCoverage_y));
maxy            =  max(max(catalog.projectionCoverage_y));

polygon         = [minx maxx maxx minx minx; miny miny maxy maxy miny]';
cellsize        =  median(diff(catalog.x(1,:)));

% determine thinning factor to use
nrofpoints      = ((maxx - minx)/cellsize) * ((maxy - miny)/cellsize);
targetpoints    = 50000;
thinning        = min([ceil(nrofpoints / targetpoints) 20]);

% get data
[X, Y, Z, ~]    = grid_orth_getDataInPolygon(...
    'dataset',        OPT.dataset, ...
    'starttime',      OPT.inputtimes(end), ...
    'searchinterval', OPT.searchinterval, ...
    'datathinning',   thinning, ...
    'polygon',        polygon, ...
    'plotresult',     0);

% prepare to save for cache purposes
background.dataset = OPT.dataset;
background.datenum = OPT.inputtimes(end);
save(fullfile(tempdir, 'background','background.mat'), 'X', 'Y', 'Z', 'background');