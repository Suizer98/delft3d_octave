function varargout = nourishment_cross_shore(x, z, volume, varargin)
%NOURISHMENT_CROSS_SHORE  Create cross-shore nourishment profile.
%
%   Function to modify a cross-shore profile by adding a predefined
%   nourishment volume width a maximum height and closure slope. The x-grid
%   of the initial profile is maintained.
%
%   Syntax:
%   varargout = nourishment_cross_shore(varargin)
%
%   Input: For <keyword,value> pairs call nourishment_cross_shore() without arguments.
%   varargin  =
%
%   Output:
%   varargout = [Volume, z2, xrange, zrange]
%
%   Example
%   nourishment_cross_shore
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       kees.denheijer@deltares.nl
%
%       P.O. Box 177
%       2600 MH  DELFT
%       The Netherlands
%       Rotterdamseweg 185
%       2629 HD  DELFT
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
% Created: 15 May 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: nourishment_cross_shore.m 8671 2013-05-24 08:35:26Z werf_je $
% $Date: 2013-05-24 16:35:26 +0800 (Fri, 24 May 2013) $
% $Author: werf_je $
% $Revision: 8671 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/nourishment/nourishment_cross_shore.m $
% $Keywords: $

%%
OPT = struct(...
    'upper_boundary', 3,...
    'slope', 1/27);
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

%% code
cov_xz = cov(x,z);
pos_landward = cov_xz(1,2)>0;
fnx = abs(diff(x([1 end]))) * [-1 0 1];

xcr = findCrossings(x, z, x([1 end]), [1;1]*OPT.upper_boundary);
if pos_landward
    % the anchor point of the nourishment profile is the last point (in landward direction) at or
    % just below the upper boundary
    anchor_x = min(xcr);
    % NOTE: the getVolume function assumes a positive seaward profile,
    % meaning that the boundaries here have confusing names
    SeawardBoundary = anchor_x;
    LandwardBoundary = min(x);
    fnz = OPT.slope * fnx .* [1 0 0];
else
    % the anchor point of the nourishment profile is the first point (in
    % seaward direction) that is at or just below the upper boundary
    anchor_x = max(xcr);
    SeawardBoundary = max(x);
    LandwardBoundary = anchor_x;
    fnz = OPT.slope * fnx .* [0 0 -1];
end

z2 = fnz + OPT.upper_boundary;

% iteratively derive the position of the nourishment
anchor_x = fminbnd(@(xa) abs(get_nour_vol(x, z, OPT.upper_boundary, LandwardBoundary, SeawardBoundary, fnx+xa, z2)-volume), min([LandwardBoundary, SeawardBoundary]), max([LandwardBoundary, SeawardBoundary]));

% obtain the final volume and its profile
[Volume, z2] = get_nour_vol(x, z, OPT.upper_boundary, LandwardBoundary, SeawardBoundary, fnx + anchor_x, z2);

% derive vertical and horizontal coverage of nourishment
nouridx = z2 ~= z;
nouridx = nouridx | [false; nouridx(1:end-1)] | [nouridx(2:end); false];
xrange = minmax(x(nouridx)');
zrange = minmax(z2(nouridx)');

varargout = {Volume, z2, xrange, zrange};

function [V, z2] = get_nour_vol(x, z, upperboundary, LandwardBoundary, SeawardBoundary, x2, z2)
% apply base xgrid to z2
z2 = interp1(x2, z2, x);
% replace z2 by z where z is larger than z2
z2(z>z2) = z(z>z2);
% replace z2 by z outside the predefined boundaries
z2(x<LandwardBoundary | x>SeawardBoundary) = z(x<LandwardBoundary | x>SeawardBoundary);
[V, res] = getVolume(x, z, upperboundary, [], min(x), max(x), x, z2);
