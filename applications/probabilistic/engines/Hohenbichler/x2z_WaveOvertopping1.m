function Z = x2z_WaveOvertopping(varargin)

% load sample values
samples = struct(varargin{:});

% parameters
g   = 9.81;
h_k = samples.h_crest - samples.MWL;
L   = g.*samples.T.^2/2/pi;
k   = samples.tanalpha./sqrt(samples.H./L);

% load according to EurOtop (overtopping)
a = .067.*sqrt(g.*samples.H.^3./samples.tanalpha).*k;
b = -4.3./samples.H./k;
S1 = a.*exp(b.*h_k);

% max. load according to EurOtop (overtopping)
a = .2.*sqrt(g.*samples.H.^3);
b = -2.3./samples.H;
S2 = a.*exp(b.*h_k);

% resistance
R2 = h_k;

% load according to EurOtop (runup)
S3 = 1.75 .* samples.H .* k;

% failure due to overtopping
%Z = R - min(S1,S2);
Z1 = R2 - S1;

Z3 = samples.h_critical - samples.MWL;

Z = min(Z1,Z3);