function y = rayl_pdf(x,b)
%RAYLPDF  Rayleigh probability density function.
%   Y = RAYLPDF(X,B) returns the Rayleigh probability density 
%   function with parameter B at the values in X.
%
%   The size of Y is the common size of X and B. A scalar input   
%   functions as a constant matrix of the same size as the other input.    
%
%   See also RAYLCDF, RAYLFIT, RAYLINV, RAYLRND, RAYLSTAT, PDF.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 134-136.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 5311 $  $Date: 2011-10-07 01:19:05 +0800 (Fri, 07 Oct 2011) $

if nargin < 1
    error(message('stats:raylpdf:TooFewInputs')); 
end
if nargin<2
    b = 1;
end

[errorcode x b] = distchck(2,x,b);

if errorcode > 0
    error(message('stats:raylpdf:InputSizeMismatch'));
end

% Initialize Y to zero.
if isa(x,'single') || isa(b,'single')
    y=zeros(size(x),'single');
else
    y=zeros(size(x));
end

% Return NaN if B is not positive.
y(b <= 0) = NaN;

k=find(b > 0 & x >= 0);
if any(k),
    xk = x(k);
    bk = b(k);
    y(k) = (xk ./ bk .^ 2) .* exp(-xk .^ 2 ./ (2*bk .^ 2));
end
