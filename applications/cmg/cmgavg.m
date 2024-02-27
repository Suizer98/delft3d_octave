function [gout]=cmgavg(gin,theta)
%an points-averaging function
% 
% [gout]=cmgavg(gin,theta)
% 
% 	gin=input data vector. if gin is a matrix, each column of the
% 		matrix is treated as a vector.
% 	theta=length of average.
% 	gout=output data.
% 
% e.g.   ts2=avg(ts1,4);  produce an 4-point average.
% 
% jpx @ usgs, Nov. 28 2000
% modified Dec. 13 2000

if nargin<1
	help(mfilename);
	return;
end;

[m,n]=size(gin);
if m==1
	gin=gin(:);
end;
[m,n]=size(gin);

cols=floor(size(gin,1)/theta);
gin=gin(1:theta*cols,:);
gin=gin(:);
temp=reshape(gin,theta,length(gin)/theta);
if theta>1
	temp=mean(temp);
end;
gout=reshape(temp(:),cols,n);
return;