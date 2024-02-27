function [xc yc dim dir idx] = xb_get_coastline(x, y, z, varargin)
%XB_GET_COASTLINE  Determines coastline from 2D grid
%
%   Determines coastline based on 2D grid by first determining the
%   orientation of the grid and than finding the first grid cell that
%   exceeds a certain elevation (default 0).
%
%   TODO: add interpolation option
%
%   Syntax:
%
%   varargout = xb_get_coastline(varargin)
%
%   Input:
%   x           = x-coordinates of bathymetric grid
%   y           = y-coordinates of bathymetric grid
%   z           = elevations in bathymetric grid
%   varargin    = level:        Level that needs to be exceeded
%                 interpolate:  Boolean flag to determine whether result
%                               should be interpolated to obtain a better
%                               apporximation
%
%   Output:
%   xc          = x-coordinates of coastline
%   yc          = y-coordinates of coastline
%   dim         = cross-shore dimension (1 or 2)
%   dir         = landward direction (negative or positive)
%   idx         = logical matrix of the size of z indicating whether a cell
%                 is on the coastline or not (xc = x(idx) and yc = y(idx)
%                 if x and y are matrices of size of z)
%
%   Example
%   xb_get_coastline
%
%   See also xb_grid_orientation

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

% $Id: xb_get_coastline.m 5416 2011-11-02 11:04:40Z hoonhout $
% $Date: 2011-11-02 19:04:40 +0800 (Wed, 02 Nov 2011) $
% $Author: hoonhout $
% $Revision: 5416 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_analysis/xb_get_coastline.m $
% $Keywords: $

%% read options

if ndims(z) ~= 2; error(['Dimensions of elevation matrix incorrect [' num2str(ndims(z)) ']']); end;

OPT = struct( ...
    'level', 0, ...
    'interpolate', false ...
);

OPT = setproperty(OPT, varargin{:});

if isempty(y); y = 0; end;

%% determine orientation

% convert from vector to matrix
if isvector(x) && isvector(y)
    [x y] = meshgrid(x, y);
end

[dim dir] = xb_grid_orientation(x, y, z);

%% determine coastline

if dir < 0
    match = 'last';
else
    match = 'first';
end

j = 1+mod(dim,2);
idx = false(size(z));
for i = 1:size(z, j)
    ii = {':' ':'}; ii{j} = i;
    ii{dim} = find(z(ii{:}) >= OPT.level, 1, match);
    idx(ii{:}) = true;
end

xc = x(idx);
yc = y(idx);