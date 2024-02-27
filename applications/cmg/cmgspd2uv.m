function [east,north]=cmgspd2uv(spd,direc)

%Create speed direction in a cartesian coordinate.
% 
% [east,north]=cmgspd2uv(spd,direc)
% 
% spd = speed
% direc = direction (degrees) in true north
% east = east component, vector or matrix
% north = north component, vector or matrix
% 
% spd and direc must be the same size. if matrices, calculation is performed
% columnwise.
% 
% jpx @ usgs 01-03-01
% 
if nargin<2 help(mfilename);return;end;
if any(size(spd) - size(direc))
	fprintf('\nTwo input arguments must be the same size.\n');
	return;
end;
spd=cmgdataclean(spd);
direc=cmgdataclean(direc);

[north,east]=pol2cart(direc*pi/180,spd);
return;