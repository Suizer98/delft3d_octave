function y = log10signed(x,varargin)
%LOG10SIGNED   log10 of abs value times sign
%
% y = log10signed(x)
%
% method: log10(abs(x)).*sign(x);
%
% Only useful for sets of large (>>1) positive and negative numbers.
% All numbers between -1 and 1 are set to NaN !!
%
% logsigned(x,number) sets all values with abs(x) < 1 to number (E.g. 0).
%
%See also: LOGSIGNED, LOG, LOG10, ABS, SIGN

smaller_than_1 = (abs(x) < 1);

y = log10(abs(x)).*sign(x);

y(smaller_than_1) = nan;

if nargin==2
   dummy = varargin{1};
else
   dummy = NaN;
end

y(smaller_than_1) = dummy;