function smoothed=cmgsmoothie(vari,fsize);
%It smoothes the vari using Matlab function conv.m
% syntax:
% 	smoothed=cmgsmoothie(vari,[fsize]);
% 
% 	fsize: size of a kernel, optional, (default = 3);
% 	vari: variable to be smoothed, vector or matrix; if a matrix, convolution
% 		performed on each column.
% 	smoothed: need explanation?
% coded by jpx on 6-7-1999
% modified on 12-14-00

if nargin<1
	help(mfilename);
	return;
end;
dum=inputname(1);
if nargin<2
	fsize=3;
end;

f=ones(1,fsize)/fsize;
if size(vari,1)==1
	vari=vari(:);
end;
[m,n]=size(vari);
if m<2*f
	fprintf('Record of %s is too short.\n',dum);
	return;
end;
if ~mod(fsize,2)
	fprintf('fsize must be an odd number\n');
	return;
end;

for i=1:n
	temp=vari(:,i);
	indx=(fsize-1)/2;
	y=conv(vari(:,i),f);
	temp(indx+1 : m-indx,1)=y(fsize:m);
	smoothed(:,i)=temp;
end;