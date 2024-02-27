function [x y] = xb_grid_world2xb(x, y, xori, yori, alpha, varargin)
%XB_GRID_WORLD2XB  Rotates a grid in world coordinates to XBeach coordinates
%
%   Rotates a grid in world coordinates to XBeach coordinates
%
%   Syntax:
%   [x y] = xb_grid_world2xb(x, y, xori, yori, alpha)
%
%   Input:
%   x           = x-coordinates
%   y           = y-coordinates
%   xori        = x-origin
%   yori        = y-origin
%   alpha       = grid rotation
%
%   Output:
%   x           = x-coordinates
%   y           = y-coordinates
%
%   Example
%   [x y] = xb_grid_world2xb(x, y, xori, yori, alpha)
%
%   See also xb_grid_xb2world

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

% $Id: xb_grid_world2xb.m 8277 2013-03-05 16:35:10Z bieman $
% $Date: 2013-03-06 00:35:10 +0800 (Wed, 06 Mar 2013) $
% $Author: bieman $
% $Revision: 8277 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_world2xb.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'units', 'degrees' ...
);

OPT = setproperty(OPT, varargin{:});

%% rotate grid

x = x - xori;
y = y - yori;

[x y] = xb_grid_rotate(x, y, alpha, 'units', OPT.units);

