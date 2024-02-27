function [cellsize xmin xmax ymin ymax] = xb_grid_resolution(x, y, varargin)
%XB_GRID_RESOLUTION  Determines the maximum cellsize of a regular grid of a certain size fitting the extent of the specified grid
%
%   Determines the extent of the specified grid and the maximum cellsize to
%   generate a regular grid spanning this extent without exceeding a
%   certain size (bytes).
%
%   Syntax:
%   [cellsize xmin xmax ymin ymax] = xb_grid_resolution(x, y, varargin)
%
%   Input:
%   x           = x-coordinates of grid to be cropped
%   y           = y-coordinates of grid to be cropped
%   varargin    = maxsize:  maximum grid size in bytes (default 10MB), in
%                           case the value is 'max' the maximum size in the
%                           currently available memory space is used.
%
%   Output:
%   cellsize    = maximum cellsize in regular grid
%   xmin        = minimum x-coordinate of regular grid
%   xmax        = maximum x-coordinate of regular grid
%   ymin        = minimum y-coordinate of regular grid
%   xmax        = maximum y-coordinate of regular grid
%
%   Example
%   [cellsize xmin xmax ymin ymax] = xb_grid_resolution(x, y)
%   [cellsize xmin xmax ymin ymax] = xb_grid_resolution(x, y, 'maxsize', 1024^3)
%
%   See also xb_grid_extent

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

% $Id: xb_grid_resolution.m 5617 2011-12-14 14:12:43Z hoonhout $
% $Date: 2011-12-14 22:12:43 +0800 (Wed, 14 Dec 2011) $
% $Author: hoonhout $
% $Revision: 5617 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_resolution.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'maxsize', 10*1024^2 ...
);

OPT = setproperty(OPT, varargin{:});

%% determine extent

[xmin xmax ymin ymax cellsize] = xb_grid_extent(x, y);

%% maximize resolution

if strcmpi(OPT.maxsize, 'max')
    m           = memory;
    OPT.maxsize = min(m.MaxPossibleArrayBytes, m.MemAvailableAllArrays*.01);
end

cellsize = max(cellsize, sqrt((xmax-xmin)*(ymax-ymin)/OPT.maxsize*8));
