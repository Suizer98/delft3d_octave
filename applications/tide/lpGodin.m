function data = lpGodin(data,times,varargin)

%% Bridge to call the oetsettings function godin_filter
if length(data(isnan(data))) == length(times)
    data(1:length(times)) = NaN;
else
    data = godin_filter(data,times,'full',true)';
end
