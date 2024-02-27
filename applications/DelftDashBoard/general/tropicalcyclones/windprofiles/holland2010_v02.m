function [vr,pr]=holland2010_v02(r,vms,pc,pn,rmax,dpdt,lat,vt,xn)
% Holland et al. (2010) formula to determine wind profile
% r    = radius (km) for output
% vms  = axi-symmetric max wind speed (m/s)
% pc   = central pressure (mbar)
% pn   = ambient pressure (mbar)
% rmax = radius of maximum winds (km)
% dpdt = change in air pressure over time (mbar/hr)
% lat  = latitude in degrees
% vt   = forward speed (m/s)
% xn   = Holland (2010) size exponent (use 0.5 to revert to Holland (1980))

%% 0. Reading parameters
% Calculate Holland B parameter based on Holland (2008)
% Assume Dvorak method
dp  = max(pn - pc,1);
x   = 0.6*(1-dp/215);
bs  = -4.4 * 10^-5 * dp.^2 + 0.01 * dp + 0.03 * dpdt - 0.014 * abs(lat) + 0.15*vt^x + 1;
bs  = min(max(bs, 0.5),2);  % numerical limits

%% 2. Determine wind structure
x=zeros(size(r))+xn;
x(r<=rmax)=0.5;
b=bs;
pr=pc+dp*exp(-(rmax./r).^b);
vr=vms*(((rmax./r).^bs).*exp(1.0 - (rmax./r).^bs)).^x;
