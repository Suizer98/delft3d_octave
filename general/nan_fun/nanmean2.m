function val = nanmean2(varargin)
%NANMEAN2 take mean matrix of series of equally-sized nD matrices, ignoring NaNs
%
% minval = nanmean2(a,b,c,...)
%
%See also: nanmean, nanmax2, nanmin2

n   = zeros(size(varargin{1}));
val = n;

nargin = length(varargin);

for i=1:nargin
    mask      = ~isnan(varargin{i});
    val(mask) = val(mask) + varargin{i}(mask);
    n(mask)   = n(mask)+1;
end

val = val./n;

val(n==0)=nan;