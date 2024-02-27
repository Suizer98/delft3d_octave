function xb = xb_grid_add(varargin)
%XB_GRID_ADD  Finalise grid and determine properties
%
%   Finalizes a given grid and determines dimensions and other properties.
%   The result is stored in an XBeach structure that can be used as model
%   input.
%
%   Syntax:
%   xb = xb_grid_add(varargin)
%
%   Input:
%   varargin  = x:          x-coordinates of bathymetry
%               y:          y-coordinates of bathymetry
%               z:          z-coordinates of bathymetry
%               ne:         vector or matrix of the size of z containing
%                           either booleans indicating if a cell is
%                           non-erodable or a numeric value indicating the
%                           thickness of the erodable layer on top of a
%                           non-erodable layer
%               posdwn:     boolean flag that determines whether positive
%                           z-direction is down
%               zdepth:     extent of model below mean sea level, which is
%                           used if non-erodable layers are defined
%               superfast:  boolean to enable superfast 1D mode
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_grid_add('x', x, 'y', y, 'z', z);
%
%   See also xb_generate_bathy, xb_grid_optimize

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_grid_add.m 13260 2017-04-13 12:37:27Z nederhof $
% $Date: 2017-04-13 20:37:27 +0800 (Thu, 13 Apr 2017) $
% $Author: nederhof $
% $Revision: 13260 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_add.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'x', [], ...
    'y', [], ...
    'z', [], ...
    'ne', [], ...
    'posdwn', false, ...
    'zdepth', 100, ...
    'superfast', true, ...
    'xori',NaN, ...
    'yori',NaN ...
);

OPT = setproperty(OPT, varargin{:});

%% load grid

xgrid = OPT.x;
ygrid = OPT.y;
zgrid = OPT.z;
negrid = OPT.ne;

%% determine origin
if isnan(OPT.xori)
    xori = min(min(xgrid));
else
    xori = OPT.xori;
end
if isnan(OPT.yori)
    yori = min(min(ygrid));
else
    yori = OPT.yori;
end

%% determine size

nx = size(zgrid, 2)-1;
ny = size(zgrid, 1)-1;

if OPT.superfast && ny == 2
    ny = 0;
    xgrid = xgrid(1,:);
    ygrid = ygrid(1,:);
    zgrid = zgrid(1,:);
    if ~isempty(negrid)
        negrid = negrid(1,:);
    end
end

if OPT.posdwn
    zgrid = -zgrid;
end

xgrid = xgrid - xori;
ygrid = ygrid - yori;

%% derive whether xgrid is variable or equidistant

dx = unique(diff(xgrid,1,2));
dy = unique(diff(ygrid,1,1));

vardx = ~isscalar(dx)||(~isempty(dy)&&~isscalar(dy));
vardx = 1;

%% create xbeach structures

xb = xs_empty();
xb = xs_set(xb, 'nx', nx, 'ny', ny, 'xori', xori, 'yori', yori, ...
    'vardx', vardx, 'posdwn', OPT.posdwn);

if ~vardx
    xgrid = [];
    ygrid = [];
    
    if ~isempty(dy)
        xb = xs_set(xb, 'dx', dx, 'dy', dy);
    else
        xb = xs_set(xb, 'dx', dx);
    end
end

if ~isempty(OPT.ne)
    xb = xb_bathy2input(xb, xgrid, ygrid, zgrid, negrid);
    xb = xs_set(xb, 'struct', 1);
else
    xb = xb_bathy2input(xb, xgrid, ygrid, zgrid);
end

xb = xs_meta(xb, mfilename, 'input');
