function [varargout]=cmgrotate(data,varargin)
%A function to rotate a Cartensian coordinate
% 
% [newx,newy]=cmgrotate(east,north,theta)
% 	east = east component, vector or matrix
% 	north = north component, vector or matrix
% 			or
% [newdata]=cmgrotate(data,theta)
% 	data = [east1,north1, east2,north2, ....] with an EVEN number of columns
% 
% 	theta = the angle (degrees) of ratation, positive in counterclockwise
% 
% east and north must be the same size. if matrices, rotation is performed
% columnwise.
% 
% jpx @ usgsg 01-03-01
% jpx @ usgsg 03-08-01
% 
if nargin<2 
	help(mfilename);
	return;
end;
	
if length(varargin)>1
	east=data;
	north=varargin{1};
	theta=varargin{2};
if ~isequal(length(east),length(north))
	error('The first two input arguments must have the same size.');
end;

else
	theta=varargin{1};
	[m,n]=size(data);
	if mod(n,2)>0
		error('The first input arg. must have an EVEN number of columns.');
	end;
	eindx=find(mod(1:n,2)==1);
	nindx=find(mod(1:n,2)==0);
	east=data(:,eindx);
	north=data(:,nindx);
end;
	
theta=theta*pi/180;
if isempty(theta) | length(theta)>1,
	error('The rotation angle must be a numeric!');
end;
	
east=cmgdataclean(east);
north=cmgdataclean(north);

newx = east.*cos(theta) + north.*sin(theta);
newy = -east.*sin(theta) + north.*cos(theta);

if length(varargin)>1
	varargout(1)={newx};
	varargout(2)={newy};
else
	data(:,eindx)=newx;
	data(:,nindx)=newy;
	varargout(1)={data};
end;

return;