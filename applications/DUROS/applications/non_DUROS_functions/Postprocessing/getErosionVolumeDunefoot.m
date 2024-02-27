function A = getErosionVolumeDunefoot(x1 , z1 , x2 , z2 , WL)
% getErosionVolumeDunefoot calculates an erosion volum between two profiles
%
% The boundaries for volume calculation are related to the water level
% (WL). This routine calculates the surface area between the first crossings
% between two lines that can be found above and below a reference level (WL).
%
%syntax: 
%           A = getErosionVolumeDunefoot(x1 , z1 , x2 , z2 , WL)
%
%input:
%   x1,z1,x2,z2     -   x and z coordinates of the two profiles.
%   WL              -   vertical level of the water surface
%
% See also findCrossings
%
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY
% Version: Version 1.0, March 2008 (Version 1.0, March 2008)
% By: <Pieter van Geer (email: pieter.vangeer@deltares.nl)>
% --------------------------------------------------------------------------

%% crossings of both profiles with water line
x1(isnan(z1))=[];z1(isnan(z1))=[];
x2(isnan(z2))=[];z2(isnan(z2))=[];
[x1cr z1cr x1 z1]= findCrossings(x1,z1,[min(x1) max(x1)],[WL WL]);
[x2cr z2cr x2 z2]= findCrossings(x2,z2,[min(x2) max(x2)],[WL WL]);

%% find first crossing under and above sealevel
[xcr zcr x1,z1,x2,z2] = findCrossings(x1,z1,x2,z2);

xcrbl = min(xcr(xcr>max(x1cr)));
xcrab = max(xcr(xcr<max(x1cr)));

%% create new grid of part of which the volume has to be calculated
z1(x1<xcrab | x1>xcrbl)=[];
x1(x1<xcrab | x1>xcrbl)=[];
z2(x2<xcrab | x2>xcrbl)=[];
x2(x2<xcrab | x2>xcrbl)=[];

xcomb = unique(sort([x1;x2]));
z1comb = interp1(x1,z1,xcomb);
z2comb = interp1(x2,z2,xcomb);

%% Determine cell widths of x-grid
diffx = diff(xcomb);

%% Interpolate z-value differences to the middle of the grid-cell (linear)
dz = z1comb - z2comb;
meandzz = mean([dz(1:end-1),dz(2:end)],2);

%% Volume = sum(z-value_i * cell-width_i)
A = sum(meandzz(~isnan(meandzz)).*diffx(~isnan(meandzz)));