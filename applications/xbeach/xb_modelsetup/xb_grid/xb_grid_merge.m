function [x y z] = xb_grid_merge(varargin)
%XB_GRID_MERGE  Merges two or more 2D grids together
%
%   Merges two or more 2D grids together by defining an output rectangular,
%   orthogonal and equidistant output grid based on the smallest grid size
%   in the input grids. The input grids are then interpolated on the output
%   grid. The first grid will end up below the others, the last grid will
%   end up on top of the others.
%
%   Syntax:
%   [x y z] = xb_grid_merge(varargin)
%
%   Input:
%   varargin  = x:          cell array with x-coordinate vectors or
%                           matrices of input grids
%               y:          cell array with y-coordinate vectors or
%                           matrices of input grids
%               z:          cell array with elevation matrices of input
%                           grids
%
%   Output:
%   x           = x-coordinates of merged grid
%   y           = y-coordinates of merged grid
%   z           = elevations in merged grid
%
%   Example
%   [x y z] = xb_grid_merge('x',{x1 x2 x3},'y',{y1 y2 y3},'z',{z1 z2 z3})
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

% $Id: xb_grid_merge.m 5617 2011-12-14 14:12:43Z hoonhout $
% $Date: 2011-12-14 22:12:43 +0800 (Wed, 14 Dec 2011) $
% $Author: hoonhout $
% $Revision: 5617 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_merge.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'x', {{}}, ...
    'y', {{}}, ...
    'z', {{}}, ...
    'maxsize', 10*1024^2 ...
);

OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.x) || ~iscell(OPT.y) || ~iscell(OPT.z)
    error('Nothing to merge!');
end

%% read grids

% determine number of full grids
n = min([length(OPT.x) length(OPT.y) length(OPT.z)]);

% determine grid extend
xmin = Inf; xmax = -Inf;
ymin = Inf; ymax = -Inf;

dd = Inf;
for i = 1:n
    if isvector(OPT.x{i}) && isvector(OPT.y{i})
        [OPT.x{i} OPT.y{i}] = meshgrid(OPT.x{i}, OPT.y{i});
    end
    
    [x1 x2 y1 y2 cellsize] = xb_grid_extent(OPT.x{i}, OPT.y{i});
    
    xmin = min(xmin, x1);
    xmax = max(xmax, x2);
    ymin = min(ymin, y1);
    ymax = max(ymax, y2);
    dd = min(dd, cellsize);
end

% maximize grid size
dd = xb_grid_resolution(xmin:dd:xmax, ymin:dd:ymax, 'maxsize', OPT.maxsize);

% create output grid
[x y] = meshgrid(xmin:dd:xmax, ymin:dd:ymax);
z = nan(size(x));

%% interpolate grids to output grid

for i = 1:n
    zi = xb_grid_interpolate(OPT.x{i}, OPT.y{i}, OPT.z{i}, x, y);
    z(~isnan(zi)) = zi(~isnan(zi));
end

%% clean up

[x y z] = xb_grid_trim(x, y, z);