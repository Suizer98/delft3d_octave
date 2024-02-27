function cu = oet_cummin(x)
%CUMMIN  cumulative min value
%
%   B = cummin(A)
%
% A DIM argument is not implemented yet, CUMMIN operates as if A where a vector A(:)
%
% Example:
%
%    cummax([1 2 3 2 1 0]) % = [1 1 1 1 1 0]
%
%See also: unique, cumsum, strdiff, cumunique, cummax

cu = repmat(x(1), size(x));

for i=2:length(x)
   cu(i) = min(cu(i-1),x(i));
end