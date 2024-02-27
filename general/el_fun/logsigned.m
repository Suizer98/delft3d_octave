function y = logsigned(x,varargin)
%LOGSIGNED   log of abs value times sign
%
% y = logsigned(x)
%
% method: log(abs(x)).*sign(x);
%
% Only useful for sets of large (>>1) positive and negative numbers.
% All numbers between -1 and 1 are set to NaN !!
%
% logsigned(x,number) sets all values with abs(x) < 1 to number (E.g. 0).
%
%See also: LOG10SIGNED, LOG, LOG10, ABS, SIGN

smaller_than_1 = (abs(x) < 1);

y  = log(abs(x)).*sign(x);

if nargin==2
   dummy = varargin{1};
else
   dummy = NaN;
end

y(smaller_than_1) = dummy;