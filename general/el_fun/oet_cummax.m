function cu = oet_cummax(x)
%CUMMAX  cumulative max value
%
%   B = cummax(A)
%
% A DIM argument is not implemented yet, CUMMAX operates as if A where a vector A(:)
%
% Example:
%
%    cummax([1 2 3 2 1 0]) % = [1 2 3 3 3 3]
%
%See also: unique, cumsum, strdiff, cumunique, cummin

cu = repmat(x(1), size(x));

for i=2:length(x)
   cu(i) = max(cu(i-1),x(i));
end