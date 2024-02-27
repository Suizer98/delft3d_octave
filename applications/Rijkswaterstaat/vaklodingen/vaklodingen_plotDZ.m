function vaklodingen_plotKB(KB,tref,t)
% vaklodingen_plotKB plots vaklodingen difference in z of 'kaartblad' as surface
%
%   Input:
%     KB = name of kaarblad, including .nc
%     tref = time where z is substracted from z_t (same units as used in .nc file, not in years!)
%     t    = time where z_tref is substracted from (same units as used in .nc file, not in years!)
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Tommer Vermaas
%
%       tommer.vermaas@deltares.nl
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
%%
vaklodingen_url = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/';

x = nc_varget([vaklodingen_url KB],'x');
y = nc_varget([vaklodingen_url KB],'y');
% expand x and y 15 m in each direction to create some overlap
x = [x(1) + (x(1)-x(2))*.75; x; x(end) + (x(end)-x(end-1))*.75];
y = [y(1) + (y(1)-y(2))*.75; y; y(end) + (y(end)-y(end-1))*.75];
    
time = nc_varget([vaklodingen_url KB],'time');

tt = find(time==t);
ttref = find(time==tref);
if isempty(tt) %no data available for this KB at this time
    disp('-- No data for this KB at this time --');
    return
else
    zref = nc_varget([lidar_url KB],'z',[ttref-1,0,0],[1,-1,-1]);
    Z = nc_varget([vaklodingen_url KB],'z',[tt-1,0,0],[1,-1,-1]);
    z = Z-zref;
    % expand z
    z = z([1 1:end end],:);
    z = z(:,[1 1:end end]);

    surface(x,y,z)

    shading    interp
    material  ([.88 0.11 .08])
    lighting   phong
    axis equal
    axis tight
    colorbar
end