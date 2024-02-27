function [xr yr] = xb_grid_rotate(x, y, alpha, varargin)
%XB_GRID_ROTATE  Rotates a grid around an origin
%
%   Rotates a grid around an origin. The origin can be specified.
%
%   Syntax:
%   [xr yr] = xb_grid_rotate(x, y, alpha, varargin)
%
%   Input:
%   x           = x-coordinates of bathymetric grid
%   y           = y-coordinates of bathymetric grid
%   alpha       = rotation angle
%   varargin    = origin:   origin for rotation
%                 units:    input units (degrees/radians)
%
%   Output:
%   xr          = x-coordinates of rotated grid
%   yr          = y-coordinates of rotated grid
%
%   Example
%   [xr yr] = xb_grid_rotate(x, y, alpha)
%
%   See also xb_grid_rotation

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

% $Id: xb_grid_rotate.m 3772 2010-12-30 16:56:10Z hoonhout $
% $Date: 2010-12-31 00:56:10 +0800 (Fri, 31 Dec 2010) $
% $Author: hoonhout $
% $Revision: 3772 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_rotate.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'origin', [0 0], ...
    'units', 'degrees' ...
);

OPT = setproperty(OPT, varargin{:});

if isempty(y); y = 0; end;

%% rotate grid

% convert from fector to matrix
if isvector(x) && isvector(y)
    [x y] = meshgrid(x, y);
end

% convert units
if strcmpi(OPT.units, 'degrees')
    alpha = alpha/180*pi;
end

R = [cos(alpha) sin(alpha); -sin(alpha) cos(alpha)];
xr = OPT.origin(1)+R(1,1)*(x-OPT.origin(1))+R(1,2)*(y-OPT.origin(2));
yr = OPT.origin(2)+R(2,1)*(x-OPT.origin(1))+R(2,2)*(y-OPT.origin(2));