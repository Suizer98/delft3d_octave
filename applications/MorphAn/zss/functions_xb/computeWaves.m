function Hs = computeWaves(t, Hs, spinup)
%generate Hs time series based on 
%   Artificial 32-hours boundary conditions following
%   Steetzel(1993)

% storm parameters
TH = 125;    % hours   (storm duration for Hs)
tmH = 16.0;    % hours   (moment max Hs) 

% time step should start at t = 0 and is in hours
t = (t-spinup) ./ 3600;

% Calculate Tp
Hs = Hs .* (cos ( (pi .* (t-tmH)) ./ TH) .^2);

end