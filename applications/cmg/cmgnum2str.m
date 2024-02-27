function varargout=cmgnum2str(num,varargin)
% Add leading 0s to an integer string. I wrote this file mainly for
% delaing with filenames in FOR loops
% 
% jpx @ usgs, 2002-11-15
% 

str=num2str(num);
if ~isempty(varargin)
	dif=varargin{1}-length(str);
	for i=1:dif
		str=['0' str];
	end;
end;
varargout={str};

return;