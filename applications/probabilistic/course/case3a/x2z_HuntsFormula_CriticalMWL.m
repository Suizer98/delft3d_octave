function Z = x2z_HuntsFormula_CriticalMWL(varargin)

% load sample values
samples = struct(varargin{:});

% quick and dirty trick to get rid of negative values in wave height and
% period
samples.H = max(0,samples.H);
samples.T = max(0,samples.T);

% gravitational acceleration
g = 9.81;

% resistance
R = samples.h_crest;

% load according to Hunt's formula
S = samples.MWL + samples.H .* samples.tanalpha ./ sqrt(2.*pi.*samples.H./(g.*samples.T.^2));

% failure due to runup
Z1 = R - S;

% failure due to low water levels
Z2 = samples.MWL - samples.h_critical;

% z value
Z = min(Z1,Z2);

