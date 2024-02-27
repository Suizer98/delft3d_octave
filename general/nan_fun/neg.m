function x = neg(x)
%NEG keep only negative values, set x>=0 to NaN
%
% y = neg(x)
%
%See also: pos

x(x >= 0) = nan;