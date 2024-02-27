function w=get_weights_scalable(z, varargin)
% GET THE WEIGHTS FROM THE Z VALUE

%% Read Settings
OPT = struct(...
    'MinimumWeight', 1, ...             % Minimum Weight (absolute)
    'PeakOverMinimum', 100, ...         % Weight of Z=0 relative to the minimum weight
    'RelativeOriginVsPeak', 0.2);       % Weight of the origin (and other points with Z_normalised = 1) relative to Weight Z=0

OPT = setproperty(OPT, varargin{:});

a               = (OPT.PeakOverMinimum*OPT.MinimumWeight-OPT.MinimumWeight);
WeightOrigin    = OPT.RelativeOriginVsPeak*OPT.PeakOverMinimum*OPT.MinimumWeight; 

% make sure the weight at Z=1 isn't smaller than the minimum weight (if it
% is, make it (almost) equal to MinimumWeight
if WeightOrigin <= OPT.MinimumWeight
    b           = -log(0.1*OPT.MinimumWeight/a);
else
    b           = -log((WeightOrigin-OPT.MinimumWeight)/a);
end

w = OPT.MinimumWeight+a*exp((-b*z.^2));
% w = OPT.MinimumWeight+a*exp((-b*abs(z)));

plot(z,w,'k*')
ylim ([0, max(w)+min(w)])
xlabel ('Z value')
ylabel('weight')
title('Z-value dependent weights')