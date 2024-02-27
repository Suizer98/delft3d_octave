function zi = xb_grid_interpolate(x, y, z, xi, yi, varargin)
%XB_GRID_INTERPOLATE  Interpolates a 2D grid on another
%
%   This function is equal to the INTERP2 function in case of an not
%   rotated orthogonal input grid. However, if the input grid is rotated,
%   the INTERP2 function fails. This function rotates both the input as the
%   output grid in that situation, such that the input grid is always
%   aligned with the coordinate axes. Subsequently, the INTERP2 function is
%   used for interpolation.
%
%   Syntax:
%   zi = xb_grid_interpolate(x, y, z, zi, yi, varargin)
%
%   Input:
%   x           = x-coordinates of input grid
%   y           = y-coordinates of input grid
%   z           = elevations of input grid
%   xi          = x-coordinates of output grid
%   yi          = y-coordinates of output grid
%   varargin    = precision:    Rotation precision in case of rotated grids
%
%   Output:
%   zi          = elevations of output grid
%
%   Example
%   zi = xb_grid_interpolate(x, y, z, xi, yi)
%
%   See also xb_grid_merge, interp2

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
% Created: 15 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_grid_interpolate.m 12800 2016-07-06 06:21:37Z nederhof $
% $Date: 2016-07-06 14:21:37 +0800 (Wed, 06 Jul 2016) $
% $Author: nederhof $
% $Revision: 12800 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_interpolate.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'precision', 1e5 ...
);

OPT = setproperty(OPT, varargin{:});

%% check input

if isvector(x) && isvector(y)
    [x y] = meshgrid(x, y);
end

if isvector(xi) && isvector(yi)
    [xi yi] = meshgrid(xi, yi);
end

%% interpolate grids

if diff(x([1 end],1)) ~= 0
    angle = atan(diff(y([1 end],1))/diff(x([1 end],1)))/pi*180-90;
else
    angle = 0;
end
    
if angle == 0
    % non-rotated grid, simply interpolate
    zi = interp2(x, y, z, xi, yi);
else
    % rotated grid, rotate both input and output grid such that the
    % input grid is aligned with coordinate axes
    xori = min(min(x));
    yori = min(min(y));
    
    [xr yr] = xb_grid_world2xb(x, y, xori, yori, -angle);
    [xir yir] = xb_grid_world2xb(xi, yi, xori, yori, -angle);

    % round off to discard minor rotation errors
    xr = round(xr*OPT.precision)/OPT.precision;
    yr = round(yr*OPT.precision)/OPT.precision;
    xir = round(xir*OPT.precision)/OPT.precision;
    yir = round(yir*OPT.precision)/OPT.precision;

    % now interpolate
    zi = interp2(xr, yr, z, xir, yir);   
end