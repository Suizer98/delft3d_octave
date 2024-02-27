function [lon2,lat2] = ddb_det_nxtvrtx(lon1,lat1,bearing1,dist1)
%
% ------------------------------------------------------------------------------------
%
%
% Function:     ddb_det_nxtvrtx.m
%               determine next geogr. coordinates of a fault vertex given
%               a starting point coord. , bearing and distance
%               coorinates and bearing in decimal degrees
%               distance in km.
% Version:      Version 1.0, March 2007
% By:           Deepak Vatvani
% Summary:
%
% Copyright (c) WL|Delft Hydraulics 2007 FOR INTERNAL USE ONLY
%
% ------------------------------------------------------------------------------------
%
% Syntax:       output = function(input)
%
% With:
%               variable description
%
% Output:       Output description
%
% global mu    raddeg   degrad  rearth
%

degrad=pi/180;
raddeg=180/pi;
rearth= 6378137.0;

d1 = dist1*1000/rearth;
lt1= lat1*degrad ;
ln1= lon1*degrad ;
tc = bearing1*degrad;
lat2= asin(sin(lt1)*cos(d1)+cos(lt1)*sin(d1)*cos(tc));
dlon= atan2(sin(tc)*sin(d1)*cos(lt1),cos(d1)-sin(lt1)*sin(lat2));
lon2= mod(ln1+dlon +pi,2*pi )-pi;
lat2=lat2*raddeg;
lon2=lon2*raddeg;
