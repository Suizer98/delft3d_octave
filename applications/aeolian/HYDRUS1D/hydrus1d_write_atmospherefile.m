function hydrus1d_write_atmospherefile(varargin)

OPT = struct( ...
    'time', 1, ...
    'Prec', 0, ... % precipation + evaporation
    'hCritS', 0, ...
    'hCritA', 1e5, ...
    'rSoil', -1, ... % switch between FluxTop (-1) and hTop (+1)
    'rRoot', 0, ...
    'rB', 0, ...
    'hB', 0, ... % pressure head at bottom layer
    'hT', 0, ... % pressure head at top layer
    'tTop', 0, ... % temperature at top layer
    'tBot', 0, ... % temperature at bottom layer
    'version', 4, ...
    'path', pwd);

OPT = setproperty(OPT, varargin);

% make sure time series are of equal length
ts = {'time', 'Prec', 'hCritA', 'rSoil', 'rRoot', 'rB', 'hB', 'hT', 'tTop', 'tBot'};
ts_lengths = cellfun(@(x) length(OPT.(x)), ts);

n = max([1,min(ts_lengths(ts_lengths>1))]);

if n > 1
    for i = 1:length(ts)
        if length(OPT.(ts{i})) == 1
            OPT.(ts{i}) = OPT.(ts{i}) * ones(n,1);
        else
            OPT.(ts{i}) = OPT.(ts{i})(1:n);
        end
    end
end

fid = fopen(fullfile(OPT.path, 'ATMOSPH.IN'), 'w');
fprintf(fid, 'Pcp_File_Version=%d\n', OPT.version);
fprintf(fid, '%s\n', '*** BLOCK I: ATMOSPHERIC INFORMATION  **********************************');
fprintf(fid, '%s\n', '   MaxAL                    (MaxAL = number of atmospheric data-records)');
fprintf(fid, '%5d\n', n);
fprintf(fid, '%s\n', ' DailyVar  SinusVar  lLay  lBCCycles lInterc lDummy  lDummy  lDummy  lDummy  lDummy');
fprintf(fid, '%s\n', '       f       f       f       f       f       f       f       f       f       f');
fprintf(fid, '%s\n', ' hCritS                 (max. allowed pressure head at the soil surface)');
fprintf(fid, '%5d\n', OPT.hCritS);
fprintf(fid, '%s\n', '       tAtm        Prec       rSoil       rRoot      hCritA          rB          hB          ht        tTop        tBot        Ampl   RootDepth');

for i = 1:n
    fprintf(fid, '%15f %15f %5d %15f %5d %15f %15f %15f %15f %15f 0\n', OPT.time(i), OPT.Prec(i), OPT.rSoil(i), OPT.rRoot(i), OPT.hCritA(i), OPT.rB(i), OPT.hB(i), OPT.hT(i), OPT.tTop(i), OPT.tBot(i));
end

fprintf(fid, '%s\n', 'end*** END OF INPUT FILE ''ATMOSPH.IN'' **********************************');
