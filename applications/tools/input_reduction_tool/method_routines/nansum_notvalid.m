function y = nansum(varargin)

narginchk(1,2);
y = sum(varargin{:},'omitnan');
