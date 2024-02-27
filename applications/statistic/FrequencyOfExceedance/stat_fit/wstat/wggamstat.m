function [m,v]= wggamstat(a,b,c);
%WGGAMSTAT Mean and variance for the Generalized Gamma distribution.
% 
% CALL:  [m,v] = wggamstat(a,b,c)
%
%   m, v = the mean and variance, respectively 
%  a,b,c = parameters of the Generalized Gamma distribution. (see wggampdf)
%
%  Mean (m) and variance (v) for the Generalized Gamma distribution is
%
%  m=c*gamma(a+1/b)/gamma(a)  and
%  v=c^2*(gamma(a+2/b)/gamma(a)-gamma(a+1/b)^2/gamma(a)^2);
%
% Example:
%   [m,v] = wggamstat(1,2,4)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 220 ff, Marcel Dekker.

% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk + default value for b and c
% added ms 09.08.2000
error(nargchk(1,3,nargin))
if nargin<2,  b=1;end
if nargin<3,  c=1;end
[errorcode a b c] = comnsize(a,b,c);
if errorcode > 0
    error('a b and c must be of common size or scalar.');
end

% Initialize  m  and v to zero.
m = zeros(size(a));
v=m;
ok = (a > 0 & b>0 & c>0);
k=find(ok);
if any(k),
  m(k) = b(k).*gamma(a(k)+1./c(k))./gamma(a(k));
  v(k) = b(k)^2.*gamma(a(k)+2./c)./gamma(a(k))-m(k).^2;
end

k3 = find(~ok);     
if any(k3)
  tmp = NaN;
  m(k3) = tmp(ones(size(k1)));
  v(k3)=m(k3);
end





