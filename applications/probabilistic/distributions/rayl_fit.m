function [phat, pci] = rayl_fit(data,alpha)
%RAYLFIT Parameter estimates and confidence intervals for Rayleigh data.
%   RAYLFIT(DATA,ALPHA) returns the maximum likelihood estimates of the  
%   parameter of the Rayleigh distribution given the data in the
%   vector DATA.  
%
%   [PHAT, PCI] = RAYLFIT(DATA,ALPHA) gives the MLE and 100(1-ALPHA) 
%   percent confidence interval given the data. By default, the
%   optional parameter ALPHA is 0.05, corresponding to 95% confidence
%   intervals.
%
%   See also RAYLCDF, RAYLINV, RAYLPDF, RAYLRND, RAYLSTAT, MLE. 

%   Reference:
%      [1]  Johnson, Norman L., Kotz, Samuel, & Kemp, Adrienne W.,
%      "Univariate Discrete Distributions, Second Edition", Wiley
%      1992 p. 124-130.

%   Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 5311 $  $Date: 2011-10-07 01:19:05 +0800 (Fri, 07 Oct 2011) $

if nargin < 2, alpha = 0.05; end

[m,n] = size(data);
if (m>1 & n>1)
   error(message('stats:raylfit:InvalidData'));
end

if m == 1
   m = n;
   data = data(:);
end

% The maximum likelihood estimate has a simple form
phat = sqrt(0.5 * mean(data.^2));

% The exact confidence interval is based on chi-square
if nargout == 2
   p_int = [1-alpha/2; alpha/2];
   pci = sqrt(2 * m * phat.^2 ./ chi2inv(p_int, 2*m));
end
