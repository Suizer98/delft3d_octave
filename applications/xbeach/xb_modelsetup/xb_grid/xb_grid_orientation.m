function [dim dir] = xb_grid_orientation(x, y, z, varargin)
%XB_GRID_ORIENTATION  Determines the orientation of a 2D bathymetric grid
%
%   Determines the dimension and direction which runs from sea landward in
%   a 2D bathymetric grid. Based on the maximum mean minimum slope, the
%   dimension which runs cross-shore is chosen. Subsequently, the direction
%   is determined. If the grid runs from sea landward in negative
%   direction, the direction is negative, otherwise positive.
%
%   Syntax:
%   [dim dir] = xb_grid_orientation(x, y, z, varargin)
%
%   Input:
%   x           = x-coordinates of bathymetric grid
%   y           = y-coordinates of bathymetric grid
%   z           = elevations in bathymetric grid
%   varargin    = none
%
%   Output:
%   dim         = corss-shore dimension in bathymetric grid (1/2)
%   dir         = direction in bathymetric grid that runs from sea landward
%                 (1/-1)
%
%   Example
%   [dim dir] = xb_grid_orientation(x, y, z)
%
%   See also xb_generate_grid

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 13 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_grid_orientation.m 8084 2013-02-15 11:19:49Z bieman $
% $Date: 2013-02-15 19:19:49 +0800 (Fri, 15 Feb 2013) $
% $Author: bieman $
% $Revision: 8084 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_orientation.m $
% $Keywords: $

%% read options

if ndims(z) ~= 2; error(['Dimensions of elevation matrix incorrect [' num2str(ndims(z)) ']']); end;

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

if isempty(y); y = 0; end;

%% create dummy grid

% convert from fector to matrix
if isvector(x) && isvector(y)
    [x y] = meshgrid(x, y);
end

[cellsize xmin xmax ymin ymax] = xb_grid_resolution(x, y);

xd = xmin:cellsize:xmax;
yd = ymin:cellsize:ymax;

[xd yd] = meshgrid(xd, yd);

if x(end,1) == xmax &&  y(1,end) == ymax
    xd = xd';
    yd = yd';
end

zd = xb_grid_interpolate(x, y, z, xd, yd);

[x y z] = deal(xd, yd, zd);

%% determine orientation

dz = zeros(1,2);
for i = 1:size(zd, 1)
    i1 = find(~isnan(z(i, :)), 1, 'first');
    i2 = find(~isnan(z(i, :)), 1, 'last');
    
    if isempty(i1) || isempty(i2) || i1==i2
        continue;
    end
    
    dx = abs(diff(x(i,[i1 i2])));
    if dx == 0
        dx = abs(diff(y(i,[i1 i2])));
    end
    dz(2) = dz(2) + diff(z(i,[i1 i2]))/dx/size(z, 1);
end

for i = 1:size(z, 2)
    i1 = find(~isnan(z(:, i)), 1, 'first');
    i2 = find(~isnan(z(:, i)), 1, 'last');
    
    if isempty(i1) || isempty(i2) || i1==i2
        continue;
    end
    
    dy = abs(diff(y([i1 i2],i)));
    if dy == 0
        dy = abs(diff(x([i1 i2],i)));
    end
    dz(1) = dz(1) + diff(z([i1 i2],i)')/dy/size(z, 2);
end

% determine axis and direction
[mx dim] = max(abs(dz));
dir = sign(dz(dim));
