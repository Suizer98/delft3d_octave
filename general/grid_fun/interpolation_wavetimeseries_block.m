function [OUT_hs, OUT_hs_old] = interpolation_wavetimeseries_block(IN_time, IN_Hs, OUT_time, limit_time)
% Simple function that does an interpolation, but first calculates the
% limits for which an interpolation would not be appropriate. 
% v1.0  Nederhoff   Oct-17
warning off

%% Part 0: change order of file
[id1a, id2a]           = size(IN_time);
[id1b, id2b]           = size(IN_Hs);
[id1c, id2c]           = size(OUT_time);
if (id1a ~= 1)
    IN_time = IN_time';
end
if (id1b ~= 1)
    IN_Hs = IN_Hs';
end
if (id1c ~= 1)
    OUT_time = OUT_time';
end

%% PART 1: Do standard (linear) interpolation
[IN_time    idwanted] = unique(IN_time);
IN_Hs                 = IN_Hs(idwanted);
OUT_hs                = interp1(IN_time,IN_Hs,OUT_time, 'nearest');

%% PART 2: Calculate distance (in time) and determine if this is close enough
[IND, D]    = nearestpoint(OUT_time, IN_time);
distance    = abs(OUT_time - IN_time(IND));
check       = find(distance > limit_time);

%% PART 3: skip parts that are to far
OUT_hs_old      = OUT_hs;
OUT_hs(check)   = NaN;

end

