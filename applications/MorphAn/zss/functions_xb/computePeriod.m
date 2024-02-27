function Tp = computePeriod(t, Tp, spinup)
%generate Tp time series based on 
%   Artificial 32-hours boundary conditions following
%   Steetzel(1993)

% storm parameters
TT = 125;    % hours   (storm duration for Tp)
tmT = 16.0;    % hours   (moment max Tp) 

% time step should start at t = 0 and is in hours
t = (t-spinup) ./ 3600;

% Calculate Tp
Tp = Tp .* cos( (pi .* (t-tmT)) ./ TT);

end