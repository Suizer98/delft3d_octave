function [varargout] = abcd2rprm(a,b,c,d)
%ABCD2RPRM get phasor amplitudes from tidal ellipse parameters
%
% [    R_pos,    R_neg] = abcd2rprm(a,b,c,d)
% [  abs_pos,  abs_neg,...
%  phase_pos,phase_neg] = abcd2rprm(a,b,c,d)
%
% where u = a cos(wt) +  b sin(wt)
%       v = c cos(wt) +  d sin(wt)
%
%See also: abcd2ellipse, ep2ap, ap2ep, plot_tidalellipses, <a href="http://dx.doi.org/10.1007/s10236-005-0042-1">De Boer et al, 2006, OD</a>

R_pos = a + d + 1i.*(c - b);
R_neg = a - d + 1i.*(c + b);

if nargout==2
   varargout = {R_pos,R_neg};
elseif nargout==4
   varargout = {abs  (R_pos),abs  (R_neg),...
                angle(R_pos),angle(R_neg)};
end
