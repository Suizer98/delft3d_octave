function xrange = jarkus_active_zone(x, z0, z1, varargin)
%JARKUS_ACTIVE_ZONE  Derive morphological active cross-shore area
%
%   Routine to derive the cross-shore morphological active area between two
%   or more profiles.
%
%   Syntax:
%   varargout = jarkus_active_zone(varargin)
%
%   Input:
%   x         = array of cross-shore coordinates
%   z0        = either array (size equal to x) or matrix (size equal to z1)
%               representing the reference height
%   z1        = array or matrix with the secondary height values
%   varargin  = propertyname propertyvalue pairs:
%           Vboundaries - volume range (normalised)
%           dim - the dimension of the cross-shore direction in z1 (and z0)
%
%   Output:
%   xrange    = 
%
%   Example
%   jarkus_active_zone
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
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
% Created: 25 Jul 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: jarkus_active_zone.m 6715 2012-06-29 11:39:34Z heijer $
% $Date: 2012-06-29 19:39:34 +0800 (Fri, 29 Jun 2012) $
% $Author: heijer $
% $Revision: 6715 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_active_zone.m $
% $Keywords: $

%%
OPT = struct(...
    'dim', 1,...
    'Vboundaries', [.025 .975]);

OPT = setproperty(OPT, varargin{:});

%%
x = x(:); % make sure that x is a column vector
if all(size(x) == size(z0(:))) && OPT.dim == 1
    % extend z0 to create a matrix
    z0 = repmat(z0(:), size(z1, OPT.dim), 1);
elseif all(size(x) == size(z0(:))) && OPT.dim == 2
    % extend z0 to create a matrix
    z0 = repmat(z0(:), 1, size(z1, 1));
elseif OPT.dim == 2
    % transpose z0
    z0 = z0';
end

if OPT.dim == 2
    % transpose z1
    z1 = z1';
end

%%
% find x-values corresponding to the middle of the grid cells
xvol = mean([x(1:end-1) x(2:end)], 2);

% determine the lowest z-level
lowerboundary = min([min(z0(:)) min(z1(:))]);

for ip = 1:size(z0,2)
    % derive the volume under the reference profile
    [V0 result0] = jarkus_getVolume(x, z0(:,ip),...
        'LowerBoundary', lowerboundary);
    % derive the volume under the secundary profile
    [V1 result1] = jarkus_getVolume(x, z1(:,ip),...
        'LowerBoundary', lowerboundary);
    % derive the volume difference
    Vdiff(ip,:) = result1.Volumes.volumes - result0.Volumes.volumes;
end

% sum the volume differences per cross-shore grid cell
Vsum = sum(abs(Vdiff));
% find the normalised cumulative sum
Vcumsum_norm = cumsum(Vsum)/sum(Vsum);
[Vcumsum_norm ix] = unique(Vcumsum_norm);
% interpolate the cross-shore range boundaries
xrange = interp1(Vcumsum_norm, xvol(ix), OPT.Vboundaries);
