function hydrus1d_write_projectfile(varargin)

OPT = struct( ...
    'PrintTimes', 1, ...
    'NumberOfNodes', 101, ...
    'ProfileDepth', -100, ...
    'ObservationNodes', 7, ...
    'path', pwd);

OPT = setproperty(OPT, varargin);

fid = fopen(fullfile(OPT.path, 'HYDRUS1D.DAT'), 'w');
fprintf(fid, '%s\n', ';');
fprintf(fid, '%s\n', '[Main]');
fprintf(fid, '%s\n', 'HYDRUS_Version=4');
fprintf(fid, '%s\n', 'WaterFlow=1');
fprintf(fid, '%s\n', 'SoluteTransport=0');
fprintf(fid, '%s\n', 'Unsatchem=0');
fprintf(fid, '%s\n', 'HP1=0');
fprintf(fid, '%s\n', 'HeatTransport=0');
fprintf(fid, '%s\n', 'EquilibriumAdsorption=1');
fprintf(fid, '%s\n', 'MobileImmobile=0');
fprintf(fid, '%s\n', 'RootWaterUptake=0');
fprintf(fid, '%s\n', 'RootGrowth=0');
fprintf(fid, '%s\n', 'MaterialNumbers=1');
fprintf(fid, '%s\n', 'SubregionNumbers=1');
fprintf(fid, '%s\n', 'SpaceUnit=cm');
fprintf(fid, '%s\n', 'TimeUnit=days');
fprintf(fid, 'PrintTimes=%d\n', OPT.PrintTimes);
fprintf(fid, '%s\n', 'NumberOfSolutes=0');
fprintf(fid, '%s\n', 'InitialCondition=0');
fprintf(fid, '%s\n', ';');
fprintf(fid, '%s\n', '[Profile]');
fprintf(fid, 'NumberOfNodes=%d\n', OPT.NumberOfNodes);
fprintf(fid, 'ProfileDepth=%e\n', abs(OPT.ProfileDepth));
fprintf(fid, 'ObservationNodes=%d\n', OPT.ObservationNodes);
fprintf(fid, '%s\n', 'GridVisible=1');
fprintf(fid, '%s\n', 'SnapToGrid=1');
fprintf(fid, '%s\n', 'ProfileWidth=80');
fprintf(fid, '%s\n', 'LeftMargin=40');
fprintf(fid, '%s\n', 'GridOrgX=0');
fprintf(fid, '%s\n', 'GridOrgY=0');
fprintf(fid, '%s\n', 'GridDX=5.E+00');
fprintf(fid, '%s\n', 'GridDY=5.E+00');