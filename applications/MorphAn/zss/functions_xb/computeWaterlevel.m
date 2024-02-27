function h = computeWaterlevel(t, Rp, spinUp)
%generateTide write the tide file to a txt
%   Detailed explanation goes here

h0 = 0.45; % 0.45       % m     (astrinomical tide mean water level)
ha = 1.00;              % m     (1st order amplitude astronomical tide)
hs = Rp - ha - h0;      % m     (symobilaztion of maximum storm surge effect)
Ta = 12.42;  % hours   (standard duration astronomical tide)
Ts = 45;     % hours   (storm surge duration)
tma = 16;    % hours   (moment max astronomical variation)
tms = 16;    % hours   (moment max surge level) 

% time step should start at t = 0 and is in hours
t = (t-spinUp) ./ 3600;
h = h0 + ha * cos((2*pi*(t-tma))./Ta) + hs * (cos((pi*(t-tms))./Ts)).^2;
 
end


