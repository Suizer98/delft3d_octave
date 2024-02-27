function[times_new,values_new] = FillGaps(times,values,varargin)

% Fill gaps between measurements with NaN's

%% Initialize
OPT.interval = 2./24;
OPT = setproperty(OPT,varargin);

times_new  = times;
values_new = values;
max_diff   = 365;

%% For difference larger than difference speccified as interval
time_diff = times(2:end) - times(1:end-1);
add       = find (time_diff > OPT.interval);
for i_add = length(add):-1:1
    %% add NaN in between
    times  = vertcat(times (1:add(i_add)), times(add(i_add)) + OPT.interval, times (add(i_add) + 1:end));
    values = vertcat(values(1:add(i_add)), NaN                             , values(add(i_add) + 1:end));
end




