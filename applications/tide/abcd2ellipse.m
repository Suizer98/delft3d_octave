function [major,minor,theta,psi] = abcd2ellipse(a,b,c,d)
%ABCD2ELLIPSE get tidal ellipse parameters from harmonic amplitudes
%
% [major,minor,theta,psi] = abcd2ellipse(a,b,c,d)
%
% where u = a cos(wt) +  b sin(wt)
%       v = c cos(wt) +  d sin(wt)
%
%See also: abcd2rprm, ep2ap, ap2ep, plot_tidalellipses, <a href="http://dx.doi.org/10.1007/s10236-005-0042-1">De Boer et al, 2006, OD</a>

major =   abs((a + d + 1i.*( c - b))./2) + ...
          abs((a - d + 1i.*( c + b))./2);

minor =   abs((a + d + 1i.*( c - b))./2) - ...
          abs((a - d + 1i.*( c + b))./2);

theta = angle((a + d + 1i.*( c - b))./2)./2 + ...
        angle((a - d + 1i.*( c + b))./2)./2;

psi   = angle((a + d + 1i.*( c - b))./2)./2 - ...
        angle((a - d + 1i.*( c + b))./2)./2;
