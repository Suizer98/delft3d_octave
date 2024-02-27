function [alpha a b dim dir] = xb_grid_rotation(x, y, z, varargin)
%XB_GRID_ROTATION  Determines rotation of a 2D grid based on the coastline
%
%   Determines the location of a 2D grid based on the coastline by
%   detecting the coastline and determining the angle of the coastline.
%
%   Syntax:
%   [alpha a b] = xb_grid_rotation(x, y, z, varargin)
%
%   Input:
%   x           = x-coordinates of bathymetric grid
%   y           = y-coordinates of bathymetric grid
%   z           = elevations in bathymetric grid
%   varargin    = units:    output units (degrees/radians)
%
%   Output:
%   alpha       = rotation of grid
%   a           = linear regression parameter of coastline (y=a+b*x)
%   b           = linear regression parameter of coastline (y=a+b*x)
%
%   Example
%   alpha = xb_grid_rotation(x, y, z)
%
%   See also xb_grid_rotate

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
% Created: 14 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_grid_rotation.m 8183 2013-02-25 17:15:47Z bieman $
% $Date: 2013-02-26 01:15:47 +0800 (Tue, 26 Feb 2013) $
% $Author: bieman $
% $Revision: 8183 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_rotation.m $
% $Keywords: $

%% read options

if ndims(z) ~= 2; error(['Dimensions of elevation matrix incorrect [' num2str(ndims(z)) ']']); end;

OPT = struct( ...
    'units', 'degrees' ...
);

OPT = setproperty(OPT, varargin{:});

if isempty(y); y = 0; end;

%% determine coastline

[xc yc dim dir] = xb_get_coastline(x, y, z);

% get linear regression line from coastline
[a b] = linreg(xc, yc);

%% determine rotation
[ix1 ix2] = find(x==max(max(x)),1,'first');
[iy1 iy2] = find(y==max(max(y)),1,'first');

alpha = 0;
if ~isnan(b)

    alpha = pi/2-atan(b);

    % correct
    if dim == 1
        alpha = alpha - sign(dir*b)*pi/2;
    else
        if (sign(dir*b) == -1 && (ix2 == size(x,2) && iy1 == size(y,1))) || (sign(dir*b) == 1 && (ix1 == size(x,1) && iy2 == size(y,2)))
            alpha = alpha + pi;
        end
    end
else
    if dir == -1
        alpha = pi;
    end
end
alpha = -alpha;

% convert units
if strcmpi(OPT.units, 'degrees')
    alpha = alpha/pi*180;
end