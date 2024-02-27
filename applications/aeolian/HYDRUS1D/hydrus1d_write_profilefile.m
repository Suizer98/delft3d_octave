function hydrus1d_write_profilefile(varargin)

OPT = struct( ...
    'PressureHead', -100 * ones(1,101), ...
    'ProfileDepth', -100, ...
    'ObservationNodes', [2 5 10 20 40 60 80], ...
    'version', 4, ...
    'path', pwd);

OPT = setproperty(OPT, varargin);

n = length(OPT.PressureHead);
z = linspace(0, OPT.ProfileDepth, n);

fid = fopen(fullfile(OPT.path, 'PROFILE.DAT'), 'w');
fprintf(fid, 'Pcp_File_Version=%d\n', OPT.version);
fprintf(fid, '%5d\n', 2);
fprintf(fid, '%5d %15e %15e %15e\n', 1, 0, 1, 1); % OPT.pressure_head(1)
fprintf(fid, '%5d %15e %15e %15e\n', 2, OPT.PressureHead(end), 1, 1);
fprintf(fid, '%5d %5d %5d %5d x h Mat Lay Beta Axz Bxz Dxz Temp Conc\n', n, 0, 0, 1);

for i = 1:n
    fprintf(fid, '%5d %15e %15e %5d %5d %15e %15e %15e %15e %15e\n', i, z(i), OPT.PressureHead(i), 1, 1, 0, 1, 1, 1, 10);
end

fprintf(fid, '%5d\n', length(OPT.ObservationNodes));
fprintf(fid, '%5d', OPT.ObservationNodes);
fprintf(fid, '\n');
