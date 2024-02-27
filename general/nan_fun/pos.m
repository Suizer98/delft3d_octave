function x = pos(x)
%POS keep only positive values, set x<=0 to NaN
%
% y = pos(x)
%
%See also: neg

x(x <= 0) = nan;