function val = nanmin2(varargin)
%NANMIN2 take min matrix of series of equally-sized nD matrices, ignoring NaNs
%
% minval = nanmin2(a,b,c,...)
%
%See also: nanmin, nanmax2, nanmean2

n   = zeros(size(varargin{1}));
val = +Inf*n;

nargin = length(varargin);

for i=1:nargin
    mask      = ~isnan(varargin{i});
    val(mask) = min(val(mask),varargin{i}(mask));
    n(mask)   = n(mask)+1;
end

val(n==0)=nan;