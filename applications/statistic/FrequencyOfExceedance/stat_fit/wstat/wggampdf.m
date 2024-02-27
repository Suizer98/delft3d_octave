function f = wggampdf(x,a,b,c);
%WGGAMPDF Generalized Gamma probability density function
%
% CALL:  f = wggampdf(x,a,b,c);
%
%        f = density function evaluated at x
%    a,b,c = parameters   (default b=1,c=1)
%
% The generalized Gamma distribution is defined by its pdf
%
% f(x;a,b,c)=c*x^(a*c-1)/b^(a*c)*exp(-(x/b)^c)/gamma(a), x>=0, a,b,c>0
% 
% Example: 
%   x = linspace(0,7,200);
%   p1 = wggampdf(x,1,2,1); p2 = wggampdf(x,3,1,1);
%   plot(x,p1,x,p2)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 220 ff, Marcel Dekker.

% Tested on; Matlab 5.3
% History:
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 09.08.2000

error(nargchk(2,4,nargin))

if nargin<3|isempty(b),  b=1; end
if nargin<4|isempty(c),  c=1; end

[errorcode x a b c] = comnsize(x,a,b,c);

if errorcode > 0
    error('x, a, b and c must be of common size or scalar.');
end

% Initialize f to zero.
f = zeros(size(x));

ok= ((a >0) & (b> 0) & (c>0));

k=find(x > 0 & ok);
if any(k),
  % old call
  %  f(k)=c(k).*x(k).^(a(k).*c(k)-1)./b(k).^(a(k).*c(k))....
  %      .*exp(-(x(k)./b(k)).^c(k))./gamma(a(k));
  
  % new call: more stable for large a
  tmp = (a(k).*c(k) - 1) .* log(x(k)) - (x(k) ./ ...
      b(k)).^c(k) - gammaln(a(k)) - a(k).*c(k) .* log(b(k));
  f(k) = c(k).*exp(tmp);
end
 
% Special cases for x==0: (this avoids warning messages)
k1 = find(x == 0 & a.*c < 1 & ok);
if any(k1),
  tmp = Inf;
  f(k1) = tmp(ones(size(k1)));
end
k2 = find(x == 0 & a.*c == 1 & ok);
if any(k2)
  f(k2) = (c(k2)./b(k2)./gamma(a(k2)));
end

%   Return NaN if the arguments are outside their respective limits.
k3 = find(~ok);     
if any(k3)
  tmp = NaN;
  f(k3) = tmp(ones(size(k3)));
end



