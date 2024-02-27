function [xmin xmax ymin ymax cellsize] = xb_grid_extent(x, y, varargin)
%XB_GRID_EXTENT  Determines the extent and minimum cellsize of a specified grid
%
%   Determines the minimum and maximum values of the x and y coordinates of
%   a specified grid and the minimum cell size as well.
%
%   Syntax:
%   [xmin xmax ymin ymax cellsize] = xb_grid_extent(x, y, varargin)
%
%   Input:
%   x           = x-coordinates of grid to be cropped
%   y           = y-coordinates of grid to be cropped
%   varargin    = none
%
%   Output:
%   xmin        = minimum x-coordinate of grid
%   xmax        = maximum x-coordinate of grid
%   ymin        = minimum y-coordinate of grid
%   xmax        = maximum y-coordinate of grid
%   cellsize    = minimum cellsize in grid
%
%   Example
%   [xmin xmax ymin ymax cellsize] = xb_grid_extent(x, y)
%
%   See also xb_grid_resolution

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

% $Id: xb_grid_extent.m 8287 2013-03-06 16:31:46Z bieman $
% $Date: 2013-03-07 00:31:46 +0800 (Thu, 07 Mar 2013) $
% $Author: bieman $
% $Revision: 8287 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_extent.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% determine grid extent and minimum grid size

% if isvector(x) && isvector(y)
%     [x y] = meshgrid(x, y);
% end
    
xmin = min(x(:));
xmax = max(x(:));
ymin = min(y(:));
ymax = max(y(:));

alldiff = [diff(x(:)); diff(y(:))];

cellsize = min(abs(alldiff(abs(alldiff)>0)));