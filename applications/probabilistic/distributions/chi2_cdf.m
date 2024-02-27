function p = chi2cdf(x,v)
%CHI2CDF Chi-square cumulative distribution function.
%   P = CHI2CDF(X,V) returns the chi-square cumulative distribution
%   function with V degrees of freedom at the values in X.
%   The chi-square density function with V degrees of freedom,
%   is the same as a gamma density function with parameters V/2 and 2.
%
%   The size of P is the common size of X and V. A scalar input   
%   functions as a constant matrix of the same size as the other input.    
%
%   See also CHI2_INV, CHI2_PDF.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.4.
%
%   Notice that we do not check if the degree of freedom parameter is integer
%   or not. In most cases, it should be an integer. Numerically, non-integer 
%   values still gives a numerical answer, thus, we keep them.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 5087 $  $Date: 2011-08-19 17:41:47 +0800 (Fri, 19 Aug 2011) $

if   nargin < 2, 
    error('stats:chi2cdf:TooFewInputs','Requires two input arguments.');
end

[errorcode x v] = distchck(2,x,v);

if errorcode > 0
    error('stats:chi2cdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end
    
% Call the gamma distribution function. 
p = gam_cdf(x,v/2,2);
