function val = nanmax2(varargin)
%NANMAX2 take max matrix of series of equally-sized nD matrices, ignoring NaNs
%
% maxval = nanmax2(a,b,c,...)
%
%See also: nanmax, nanmin2, nanmean2

n   = zeros(size(varargin{1}));
val = -Inf*n;

nargin = length(varargin);

for i=1:nargin
    mask      = ~isnan(varargin{i});
    val(mask) = max(val(mask),varargin{i}(mask));
    n(mask)   = n(mask)+1;
end

val(n==0)=nan;