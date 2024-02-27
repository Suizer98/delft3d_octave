function cu = cumunique(x)
%CUMUNIQUE  cumulative count of unique values
%
%   B = cumunique(A)
%
%See also: unique, cumsum, strdiff, cummax, cummin

[~,j]=unique(x);
u = repmat(0,size(x));
u(j) = 1;
cu = cumsum(u);