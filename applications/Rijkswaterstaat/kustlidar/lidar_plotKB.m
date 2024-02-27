function lidar_plotKB(KB,t)
% lidar_plotKB plots lidar 'kaartblad' as surface
%
%   Input:
%     KB = name of kaarblad, including .nc
%     t  = time for which to plot (same units as used in .nc file, not in years!)
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
lidar_url = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/kustlidar/';

x = nc_varget([lidar_url KB],'x');
y = nc_varget([lidar_url KB],'y');
% expand x and y 15 m in each direction to create some overlap
x = [x(1) + (x(1)-x(2))*.75; x; x(end) + (x(end)-x(end-1))*.75];
y = [y(1) + (y(1)-y(2))*.75; y; y(end) + (y(end)-y(end-1))*.75];
    
time = nc_varget([lidar_url KB],'time');

tt = find(time==t);
if isempty(tt) %no data available for this KB at this time
    disp('-- No data for this KB at this time --');
    return
else
    for i=1:length(tt) % some KB's have multiple times that are the same
        z = nc_varget([lidar_url KB],'z',[tt(i)-1,0,0],[1,-1,-1]);
        % expand z
        z = z([1 1:end end],:);
        z = z(:,[1 1:end end]);

        surface(x,y,z)
        hold on
    end
    shading    interp
    material  ([.88 0.11 .08])
    lighting   phong
    axis equal
    axis tight
    colorbar
end