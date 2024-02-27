function data = lpMeanSeries(data,varargin)

%% Simply return a series with the mean value of the original series
data(1:length(data)) = mean(data);
