function [pmax_out,pr] = rain_radii_bader(meas_vmax, rmax, radius, probability, rain_info)
% Function to calculate pmax (maximum rainfall intensity)
% and the radial distribution of the rain (pr)
% Input meas_vmax in m/s and 10 minute averaged (Daan to check)
% Input rmax and radius in km
% Probability is 0, means you will get the most probably pmax and pr
% Probability is 1, means you will get a 10,000 random realisations
% v1.0  Nederhoff   Jul-19
if ~isfield(rain_info,'perc') && probability == 2
   rain_info.perc = 50; %if not provided
end

%% 0. Coefficients of copula's (needed for pmax)
% maximum wind speed (vmax) - generalized extreme value distribution
% is used to convert the input maximum sustained wind speed in [m/s] from the original dataspace to the copula dataspace [0,1]
vmax.k          = 0.346;
vmax.sigma      = 8.0676;
vmax.mu         = 17.3637;

% maximum rainfall intensity (pmax) - generalized pareto distribution
% is used to convert copula samples [0,1] back to samples from the original dataspace
pmax.k          = -0.0686; 
pmax.sigma      = 45.2829;
pmax.theta      = 10.002;

%% 1 Sample from Copula
theta           = 3.5782;           % copula coefficient
n               = 10000;            % number of samples
pmax_samples    = frankcopula(meas_vmax, theta, n, vmax, pmax);

% assess samples
values      = sort(pmax_samples);
median50    = values(round(length(values)*0.50));
perc   = values(round(length(values) * rain_info.perc / 100));

if probability == 1
    pmax_out = pmax_samples;
elseif probability == 2
    pmax_out = perc;    
else
    pmax_out = median50;            % or should we do mode?
end

%% 2. Fit on distribution 
% Fit with radius according to Holland, 2010
inp.pmax    = pmax_out;
[id1, id2] = size(radius);
if id1 == 1
    inp.radius  = radius';
else
    inp.radius  = radius;
end
inp.rmax    = rmax;

% Coefficients
a           = 1.5.*pmax_out.^-0.031;     % similar to the Holland x parameters
b           = 0.22.*pmax_out.^0.33;      % similar to the Holland B parameter

% Rainfall in which we assume maximum rainfall
% occurs at the location of the maximum winds speed. Correct?
pr          = ((inp.pmax.*(inp.rmax./inp.radius).^b)./(exp((inp.rmax./inp.radius).^b))).^a;

end

%% Subfunction Frank Copula
function pmax_samples = frankcopula(vmax_input, theta_frank, n, vmax, pmax)
% vmax_input    = maximum sustained wind speed in [m/s]
% theta_frank   = the copula parameter value
% n             = number of samples
% vmax          = the list of marginal distribution parameters for vmax
% pmax          = the list of marginal distribution parameters for pmax

% create a list of the input vmax, use CDF function to convert the input
% vmax to a value in the copula dataspace [0,1]. Result is a list of n
% (equal) values which represent the input vmax in the copula space
% u(1,1:n) = cdf('GeneralizedExtremeValue', vmax_input, vmax.k, vmax.sigma, vmax.mu);
u(1,1:n) = gevdist_cdf(vmax_input, vmax);

% create a list of n random samples between 0 and 1 (the copula dataspace)
% this is used to get pmax samples from the copula
y = rand(1,n);

% use the formula for conditional sampling of a frank copula to produce a
% list of n maximum rainfall intensity values within the copula dataspace
v = -(1./theta_frank).* log( 1 + (y.*(exp(-theta_frank) - 1)) ./ (exp(-theta_frank.*u) - y.*(exp(-theta_frank.*u) - 1)));
% v = -(1./theta_frank).* log( 1 + ( y.*(1 - exp(-theta_frank))) ./ (y.*(exp(-theta_frank.*u) - 1  ) - exp(-theta_frank.*u))); % alternative derivation in some literature
% e.g.: https://support.sas.com/documentation/onlinedoc/ets/132/copula.pdf#page=51&zoom=100,60,749

% convert the acquired samples back to its original dataspace with the
% given marginal distribution parameters for pmax. 
pmax_samples = icdf_gp(v, pmax);
end

%% 
function vmax_sample = gevdist_cdf(x, vmax)
% function to use cdf of the generalized extreme value distribution (GEV) without statistical toolbox
% x is the input vmax in [m/s]
% vmax contains the information about the marginal distribution fitted to vmax

% calculating the standardized variable
s = (x-vmax.mu)./(vmax.sigma);

% converting the input vmax from its orginal dataspace to the copula
% dataspace [0,1]
vmax_sample = exp(-(1+vmax.k.*s).^(-1./vmax.k));
end

%%
function pmaxsample = icdf_gp(v, pmax)
% inverse cdf for the generalized pareto distribution without the
% statistical toolbox

pok = (0<v) & (v<1);
j = (abs(v) < eps) & pok;
z(j) = -log1p(-v(j));

j = (abs(pmax.k) >= eps) & pok;
z(j) = expm1(-pmax.k.*log1p(-v(j))) ./ pmax.k; % ((1-p).^(-k) - 1) ./ k;

if ~all(pok(:))
    % When k<0, the support is 0 <= (x-theta)/sigma <= -1/k
    z(v==0) = 0;
    jj = (v==1 & pmax.k<0);
    z(jj) = -1./pmax.k;
    z(v==1 & pmax.k>=0) = Inf;
end
pmaxsample = pmax.theta + pmax.sigma.*z;
end

