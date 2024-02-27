function crossing = getLimitCrossing(result, a, c, varargin)
% getLimitCrossing: Approximates crossing of line between two given points in u-space with the limit line
%
%   Approximates the crossing of the line between the given points a and c
%   in u-space with the limit line by bifurcation. Strictly speaking a must
%   be in the non-failure area and c in the failure area, but both points
%   are swapped if this isn't the case. Of course not both points can be
%   from the same area. The routine returns a full description of the found
%   point in both u and x-space as well as the corrsponding Z value, the
%   full line description between a and c and the number of iterations
%   needed for the approximation. The point description is in fact similar
%   to the Design Point description of the approxMCDesignPoint routine.
%
%   Syntax:
%   [crossing] = getLimitCrossing(result, a, c, varargin)
%
%   Input:
%   result      = result structure from MC routine
%   a           = non-failure point in u-space
%   c           = failure point in u-space
%   varargin    = 'PropertyName' PropertyValue pairs (optional)
%   
%                 'precision'       = precision of Desing Point
%                                       approximation, which is the maximum
%                                       Z value of approximation. (default:
%                                       0.05)
%                 'maxIteration'    = maximum number of iterations used for
%                                       approximation (default: 100)
%
%   Output:
%   result      = full point description structure of crossing
%
%   Example
%   crossing = getLimitCrossing(result, a, c)
%
%   See also approxMCDesignPoint MC

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft 
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 13 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: getLimitCrossing.m 7786 2012-12-05 10:44:39Z dierman $
% $Date: 2012-12-05 18:44:39 +0800 (Wed, 05 Dec 2012) $
% $Author: dierman $
% $Revision: 7786 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DesignPoint/getLimitCrossing.m $

%% settings

OPT = struct( ...
    'precision', 0.05, ...
    'maxIterations', 100 ...
);

OPT = setproperty(OPT, varargin{:});

%% get limit crossing

n = 0;
b = c - a;
crossing = struct('a', [], 'b', [], 'c', [], 'u', [], 'x', [], 'z', Inf);

% make sure we are walking from non-failure to failure
incC = 0.1 .* c;
z1 = getZ(result, getX(result, a));
z2 = getZ(result, getX(result, c));
while sign(z1) == sign(z2)
    c = c + incC;
    z2 = getZ(result, getX(result, c));
end

% check whether we are dealing with a point from the failure and a point
% from the non-failure area
if sign(z1) ~= sign(z2)

    if z1 < 0
        [c a] = deal(a, c);
    end

    % normalize line
    refAxis = find(c, 1, 'first');
    
    n = abs(c(refAxis) - a(refAxis));
    
    if n ~= 0
        b = (c - a) / n;
    else
        b = c - a;
    end

    % calculate scale of angle description
    scale = sqrt(sum((c - a).^2)) / sqrt(sum(b.^2));
    
    n = 0;
    j = 0;
    dz = Inf;
    jRange = [0 1];

    % search for Z = 0 along a-c line by bifurcation
    %while abs(crossing.z) > OPT.precision && n < OPT.maxIterations && dz > 0
    while (abs(crossing.z) > OPT.precision || dz > 0) && n < OPT.maxIterations 
            
        j = mean(jRange);

        % define current point along line
        lastZ = crossing.z;
        crossing.u = a + j * scale * b;
        crossing.x = getX(result, crossing.u);
        crossing.z = getZ(result, crossing.x);
        dz = abs(lastZ - crossing.z);

        % adjust range
        if crossing.z < 0
            jRange(2) = j;
        elseif crossing.z > 0
            jRange(1) = j;
        else
            break;
        end

        n = n + 1;
    end
else
    disp('WARNING: cross line entirely in non-failure area');
end

crossing.a = a;
crossing.b = b;
crossing.c = c;
crossing.iterations = n;
crossing.calculations = n;

%% get x and/or z value
function x = getX(result, u)
    x = feval( ...
        result.settings.P2xFunction, ...
        result.Input, ...
        norm_cdf(u, 0, 1) ...
    );

function z = getZ(result, x)
    z = prob_zfunctioncall(     ...
        result.settings,        ...
        result.Input,           ...
        x                       ...
    );