function y = gev_pdf(x,k,sigma,mu)
%GEVPDF Generalized extreme value probability density function (pdf).
%   Y = GEVPDF(X,K,SIGMA,MU) returns the pdf of the generalized extreme value
%   (GEV) distribution with shape parameter K, scale parameter SIGMA, and
%   location parameter MU, evaluated at the values in X.  The size of Y is the
%   common size of the input arguments.  A scalar input functions as a
%   constant matrix of the same size as the other inputs.
%   
%   Default values for K, SIGMA, and MU are 0, 1, and 0, respectively.
%
%   When K < 0, the GEV is the type III extreme value distribution.  When K >
%   0, the GEV distribution is the type II, or Frechet, extreme value
%   distribution.  If W has a Weibull distribution as computed by the WBLPDF
%   function, then -W has a type III extreme value distribution and 1/W has a
%   type II extreme value distribution.  In the limit as K approaches 0, the
%   GEV is the mirror image of the type I extreme value distribution as
%   computed by the EVPDF function.
%
%   The mean of the GEV distribution is not finite when K >= 1, and the
%   variance is not finite when K >= 1/2.  The GEV distribution has positive
%   density only for values of X such that K*(X-MU)/SIGMA > -1.
%
%   See also EVPDF, GEVCDF, GEVFIT, GEVINV, GEVLIKE, GEVRND, GEVSTAT, PDF.

%   References:
%      [1] Embrechts, P., C. Kl�ppelberg, and T. Mikosch (1997) Modelling
%          Extremal Events for Insurance and Finance, Springer.
%      [2] Kotz, S. and S. Nadarajah (2001) Extreme Value Distributions:
%          Theory and Applications, World Scientific Publishing Company.

%   Copyright 1993-2005 The MathWorks, Inc. 
%   $Revision: 6371 $  $Date: 2012-06-12 19:02:09 +0800 (Tue, 12 Jun 2012) $

if nargin < 1
    error(message('stats:gevpdf:TooFewInputs'));
end
if nargin < 2, k = 0;     end
if nargin < 3, sigma = 1; end
if nargin < 4, mu = 0;    end

[err,sizeOut] = statsizechk(4,x,k,sigma,mu);
if err > 0
    error(message('stats:gevpdf:InputSizeMismatch'));
end
if isscalar(k), k = repmat(k,sizeOut); end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

y = zeros(sizeOut,superiorfloat(x,k,sigma,mu));

z = (x-mu)./sigma;
z(z==-Inf) = Inf; % avoid Inf - Inf
if isscalar(z), z = repmat(z,sizeOut); end

% Find the k==0 cases and fill them in.
j = (abs(k) < eps);
y(j) = exp(-exp(-z(j)) - z(j));

% Find the k~=0 cases and fill them in.
j = ~j;
t = z.*k;

% 1 + k.*(x-mu)/sigma > 0 is the support, force 0 outside that.
jj = j & (t<=-1);
t(jj) = 0; % temporarily silence warnings from log1p

y(j) = exp(-exp(-(1./k(j)).*log1p(t(j))) - (1+1./k(j)).*log1p(t(j)));
                           % exp(-(1+k.*z).^(-1./k)) .* (1+k.*z).^(-1-1./k);
y(jj) = 0;

y = y ./ sigma;
