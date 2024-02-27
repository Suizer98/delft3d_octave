function cosmos_makeModelFigures(hm,m)

% dr=[hm.models(m).dir 'lastrun' filesep 'figures' filesep '*.*'];
% delete(dr);

%% Mobile app

switch lower(hm.models(m).type)
    case{'delft3dflowwave','delft3dflow'}
        try    
            disp('Making plots for app ...');
            cosmos_makeAppPlots(hm,m);
        end
end

%% Time Series
disp('Making time series plots ...');
cosmos_makeTimeSeriesPlots(hm,m);

%% ForecastPlot
switch lower(hm.models(m).type)
    case{'delft3dflowwave','delft3dflow'}
        disp('Making forecast plots ...');
        cosmos_makeForecastPlot(hm,m);
end

%% Maps
switch lower(hm.models(m).type)
    case{'delft3dflowwave','delft3dflow'}
        disp('Making map plots ...');
        cosmos_makeMapKMZs(hm,m);
    case{'ww3'}
        disp('Making map plots ...');
        cosmos_makeMapKMZs(hm,m);
    case{'xbeach'}
        disp('Making map plots ...');
        cosmos_makeMapKMZs(hm,m);
end

%% Profiles
switch lower(hm.models(m).type)
    case{'xbeachcluster'}
        disp('Making profile plots ...');
        cosmos_plotXBBeachProfiles(hm,m);
end

%% Hazards
switch lower(hm.models(m).type)
    case{'xbeachcluster'}
        disp('Making hazard KMZs ...');
        cosmos_makeXBHazardsKMZs(hm,m);
end
