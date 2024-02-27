function [ndZ, dZM, dZS] = jarkus_volumeperarea(b,e,depth1,depth2,j,J)
% jarkus_volumeperarea calculates average change in bed level for a defined
%  area
%    Changes are determined relative to year j for the area between 
%    transects b and e and depths depth1 and depth2 (determined for year j). 
%    For each year in vector J this relative change is calculated for all 
%    measurement-locations that occur both in year J(x) and j. 
%
%   Input:
%     b        = transect-id of alongshore begin-position
%     e        = transect-id of alongshore end-position
%     depth1   = upper boundary (smaller depth)
%     depth2   = lower boundary (larger depth)
%     j        = the reference year
%     J        = years from which the data is used
%
%   Output:
%     ndZ     = number of measurement points used, for each year in J
%     dZM     = average change in bed level relative to year j, for each year in J
%     dZS     = standard deviation of change in bed level relative to year
%               j, for each year in J
% 
%   Example: 
%     J             = [1965 1970 1975 1980 1985:2008];
%     [ndZ dZM dZS] = jarkus_volumeperarea(6000416,6003452,-3,-8,1990,J);
%

% !! NB: change in bed level is only realistic for area's with uniform
% morphological behavior, if both substantial erosion and
% substantial sedimentation occurs in the defined area the method
% is not reliable ! NB
%
% See also: JARKUS, snctools
%
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Tommer Vermaas
%
%       tommer.vermaas@gmail.com
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------
%
%% load variables from nc file
url = jarkus_url;
id  = nc_varget(url,'id');
bi  = find(id==b);
ei  = find(id==e);
as  = nc_varget(url,'alongshore',bi-1,ei-bi+1);
X   = nc_varget(url,'cross_shore');
[y, m, d, h, mn, s] = datevec(nc_cf_time(url,'time'));

DL1  = jarkus_getdepthline(b,e,depth1,j); 
DL2  = jarkus_getdepthline(b,e,depth2,j); 
DL1i = interp1(as(~isnan(DL1)),DL1(~isnan(DL1)),as);
DL2i = interp1(as(~isnan(DL2)),DL2(~isnan(DL2)),as);

nref = find(y==j);
zref = nc_varget(url,'altitude',[nref-1,bi-1,0],[1,ei-bi+1,-1]);
Zref = repmat(NaN,length(X),ei-bi+1);

% interpolate zref in cross-shore direction to new matrix Zref
for i=1:length(zref(:,1))
    z2=zref(i,~isnan(zref(i,:))); x=X(~isnan(zref(i,:)));
    if length(z2)>1
        Zref(:,i)=interp1(x,z2,X,'linear');
    end
    ma=max(find(X<=DL1i(i)));
    mt=min(find(X>=DL2i(i)));
    Zref(1:ma,i)=NaN;
    Zref(mt:length(Zref(:,i)),i)=NaN;
end

% calculate delta-z for each year
dZM = repmat(NaN,1,length(J));
dZS = repmat(NaN,1,length(J));
ndZ = repmat(NaN,1,length(J));
c=1;
for t=J
    n    = find(y==t);
    z    = nc_varget(url,'altitude',[n-1,bi-1,0],[1,ei-bi+1,-1]);
    Z=z';
    Z(isnan(Zref))=NaN;
    
    dZ     = Z-Zref;
    dZM(c) = nanmean(nanmean(dZ));
    dZS(c) = nanstd (nanstd (dZ));
    ndZ(c) = length(find(~isnan(dZ)));
    c=c+1;
end