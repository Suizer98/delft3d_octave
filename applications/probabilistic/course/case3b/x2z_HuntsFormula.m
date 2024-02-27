function Z = x2z_HuntsFormula(varargin)

% load sample values
samples = struct(varargin{:});

samples.H = max(0,samples.H);
samples.T = max(0,samples.T);

% gravitational accaleration
g = 9.81;

% resistance
R = samples.h_crest;

% load according to Hunt's formula
S = samples.MWL + samples.H .* samples.tanalpha ./ sqrt(2.*pi.*samples.H./(g.*samples.T.^2));

% z value
Z = R - S;