function [xstr,ystr]=cmgwindstress(wspd,wdir,height)

%A function to compute wind shear stress based on given speed,
% direction, and sensor height.
% 
% [ustr,vstr]=cmgwindstress(wspd,wdir,[height])
% 
% wspd = wind speed vector in m/s
% wdir = wind direction vector in degrees (true North)
% height = height of measurement in m above sea level. if omitted, height=10 m.
% 
% jpx @  usgs, 01-03-01
% 
if nargin<1 help(mfilename);return;end;
if nargin<3
	height=10; %meters
end;
if length(height)>1
	fprintf('\nheight must be a single value.\n');
	return;
end;
wspd=cmgdataclean(wspd(:));
wdir=cmgdataclean(wdir(:));

w10=speed10(wspd,height);

uew=w10.*sin(wdir.*pi/180);
uns=w10.*cos(wdir.*pi/180);
xstr = ((0.8 + (.065*w10))*.012).*w10.*uew;
ystr = ((0.8 + (.065*w10))*.012).*w10.*uns;

return;


function newspd=speed10(spd,ht)

% m file adjusts wind speed to 10-m height, 
% based on Large and Pond, J.P.O, 11, 324-336, 1981. 
% drag coefficient is function of 10-m height wind, 
% iteration used to arrive at 10-m wind, 
% jpx @ usgs 01-03-01

if(ht==10)
	newspd=spd;
	return
end

newspd=5*ones(size(spd)); %	guess at wind speed at 5 m
for i=1:20;
	wind10=newspd;
	coefdrag=(0.49+(0.065*wind10))*1.0e-03;
    indx=find(wind10<11.0);
	coefdrag(indx)=1.205e-03;
	dragadj=1+log(ht/10.0)*sqrt(coefdrag)/0.41;
	newspd=spd./dragadj;
	err=abs(wind10-newspd);
	if isempty(find(err>=0.02))
		return
	end
end
return;