function [xerosionpoint precision] = additional_erosionpoint(x, z, volume, varargin)
%ADDITIONAL_EROSIONPOINT  derive erosion point based on volume and fixed dune face slope
%
%   Routine to derive the cross-shore location of the erosion point for a
%   given erosion volume above the lower boundary assuming a constant dune
%   face slope (default 1:1).
%
%   Syntax:
%   xerosionpoint = additional_erosionpoint(x, z, volume, varargin)
%
%   Input:
%   x         = vector array with x-coordinates
%   z         = vector array with z-coordinates
%   volume    = target erosion volume above 'lowerboundary'
%   varargin  = propertyname-propertyvalue pairs:
%               - 'positive_landward': boolean to indicate the profile direction
%               - 'slope': slope of the dune face (1:slope)
%               - 'lowerboundary': lower boundary of the volume
%
%   Output:
%   xerosionpoint  = cross-shore location of erosion point
%   precision      = difference between target volume and actual enclosed
%                       volume
%
%   Example
%   additional_erosionpoint
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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
% Created: 19 Jan 2011
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: additional_erosionpoint.m 4889 2011-07-21 14:42:37Z heijer $
% $Date: 2011-07-21 22:42:37 +0800 (Thu, 21 Jul 2011) $
% $Author: heijer $
% $Revision: 4889 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/TRDA/additional_erosionpoint.m $
% $Keywords: $

%%
OPT = struct(...
    'positive_landward', true,...
    'slope', 1,... % 1:slope
    'lowerboundary', 0,...
    'verbose', true);

OPT = setproperty(OPT, varargin{:});

%% approach
% The erosion point based on a given erosion volume and dune face slope can
% be determined based on the cumulative volume in landward direction minus
% the remaining triangular volume under the dune face. Both values are
% calculated for each grid point. Based on this, simple interpolation is
% enough to get an estimation of the position of the erosion point.

%%
if ~OPT.positive_landward
    x = -x;
end

precision = 0;

% find crossings with lower boundary and project the profile relative to
% the lower boundary
[xcr zcr xn zn] = findCrossings(x(:), z(:) - OPT.lowerboundary,...
    [min(x) max(x)], zeros(1,2), 'synchronizegrids');

if isempty(xcr)
    xerosionpoint = NaN;
    return
end

% derive the grid size
diffX = diff(xn);
% derive the mean z of adjacent points
meanZ = mean([zn(2:end) zn(1:end-1)], 2);
% set the areas below the lower boundary to zero
meanZ(meanZ<0) = 0;
% derive the cumulative volume
cumV = [0; cumsum(meanZ .* diffX)];

% derive the volume of the triangle
triangleV = .5 * OPT.slope * zn.^2;
triangleV(zn < 0) = 0;

V = cumV - triangleV;
if max(V) < volume
    xerosionpoint = max(xn);
    precision = volume - max(V);
    if OPT.verbose
        warning('Target volume can not be reached')
    end
elseif any(V == volume)
    xerosionpoint = xn(V == volume);
else
    % identify grid point just seaward of the final solution
    id1 = [diff(V < volume) ~= 0; false];
    % identify grid point just landward of the final solution
    id2 = [false; id1(1:end-1)];
    % combine those two to have the identifiers of the neighbouring points
    id = id1 | id2;
    % coordinates of the grid point just seaward of the final solutation
    x1 = xn(id1);
    z1 = zn(id1);
    % slope of the profile at the final soluation
    alfa = diff(zn(id)) / diff(xn(id));
    
    check_slope_id = [xn >= min(xcr); false] & [true; V < volume];
    % check slope
    max_slope = 1/max(diff(zn(check_slope_id))./diff(xn(check_slope_id)));
    if OPT.slope > max_slope
        warning('parts of the profile are steeper than the specified slope')
    end
    
    if alfa == 0
        % horizontal dune
        dx = (volume - V(id1)) / z1;
    else
        % derive the dx between erosion point and the neighbouring point at the
        % seaward side by an analitical solution, using the abc-formula)
        a = .5*alfa * (1 - alfa);
        b = z1 * (1 - alfa);
        c = -.5 * z1^2 - volume + cumV(id1);
        D = b^2 - 4 * a * c;
        dx = (-b + sqrt(D) * [-1 1]) ./ (2*a);
        
        % choose smallest positive solution, since dx is defined as positive
        dx = min(dx(dx>0));
        
        if isempty(dx)
            dx = 0;
            precision = volume - V(id1);
            if OPT.verbose
                warning('no valid solution possible')
            end
        end
    end
    % define final resulting x-coordinate of erosion point
    xerosionpoint = x1 + dx;
end

%%
if ~OPT.positive_landward
    xerosionpoint = -xerosionpoint;
end