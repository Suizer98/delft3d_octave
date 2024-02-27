function F = wggamcdf(x,a,b,c);
%WGGAMCDF Generalized Gamma cumulative distribution function
%
% CALL:  F = wggamcdf(x,a,b,c);
%
%        F = distribution function evaluated at x
%    a,b,c = parameters
%
% The generalized Gamma distribution is defined by its pdf
%
% f(x;a,b,c)=c*x^(a*c-1)/b^(a*c)*exp(-(x/b)^c)/gamma(a), x>=0, a,b,c>0
% 
% Example: 
%   x = linspace(0,7,200);
%   p1 = wggamcdf(x,1,2,1); p2 = wggamcdf(x,3,1,1);
%   plot(x,p1,x,p2)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 220 ff, Marcel Dekker.

% Tested on; Matlab 5.3
% History: 
% revised pab 23.10.2000
%  - added comnsize, nargchk+ default values on b c.
% added ms 09.08.2000


error(nargchk(2,4,nargin))
if nargin<3|isempty(b),  b=1; end
if nargin<4|isempty(c),  c=1; end
[errorcode x a b c] = comnsize(x,a,b,c);

if errorcode > 0
  error('x, a, b and c must be of common size or scalar.');
end

F = zeros(size(x));
ok= ((a >0) & (b> 0) & (c>0));


k=find(x >= 0 & ok);
if any(k),
  F(k)= gammainc((x(k)./b(k)).^c(k),a(k));
end

%   Return NaN if the arguments are outside their respective limits.
k3 = find(~ok);     
if any(k3)
  tmp = NaN;
  F(k3) = tmp(ones(size(k3)));
end





