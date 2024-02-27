function [gout]=cmgdataclean(gin,threshold);

%function to NAN the bad data points
% 
% [gout]=cmgdataclean(gin,threshold)
% 
% gin = input data vector or matrix
% threshold = bad data indicator. optional (default = 1.0E35)
% gout = output
% 
% jpx @ usgs on 12-14-00
% 
if nargin<1
	help(mfilename);
	return;
end;
if nargin<2
	threshold=1e34;
end;
gin(gin>=threshold)=nan;
gin(gin<= -threshold)=nan;

gout=gin;
return;
