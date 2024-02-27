function [x z] = modifySimpleProfile(varargin)
%MODIFYSIMPLEPROFILE Flips, shifts and/or adds trenches and/or bars to dune profile
%
%   Flips and/or shifts a dune profile. It is also possible to add
%   trapezoid shaped bars or trenches to the dune profile. The dune profile
%   is described by an array of x- and z-coordinates. If no explicit
%   profile is given, the default profile from the SimpleProfile routine is
%   used. Bars and trenches can be defined using a cell with four-itemed
%   arrays that successively define the starting x-position, the witdh, the
%   height and the slope of a bar or trench. A trench is defined as a bar
%   with negative height. Two arrays with respectively the new
%   x-coordinates and the z-coordinates are returned.
%
%   WARNING:    THE PURPOSE OF THIS FUNCTION IS TO CHANGE THE SHAPE OF THE
%               DUNE PROFILE. TO CHANGE THE DESCRIPTION OF THE DUNE PROFILE
%               AS PREPERATION FOR THE USE WITH A CERTAIN DUNE EROSION
%               MODEL, PLEASE USE THE FUNCTION checkCrossShoreProfile !!!
%
%   Syntax:
%   [x z] = modifySimpleProfile(varargin)
%
%   Input:
%   varargin    = 'PropertyName' PropertyValue pairs (optional)
%   
%                 'x'       = array with x-coordinates of the initial
%                               profile (default: [])
%                 'z'       = array with z-coordinates of the initial
%                               profile (default: [])
%                 'flip'    = cell with axes to be flipped (x and/or z)
%                               (default: {[]})
%                 'shift'   = array with the distances over which the
%                               profile should be shifted. The first
%                               element corresponds to the x-axis while the
%                               second corresponds to the z-axis. (default:
%                               [0 0])
%                 'bars'    = cell with definition of bars and trenches.
%                               Each item in the cell is supposed to be an
%                               array with four items respectively defining
%                               the starting x-position of the bar, the
%                               width, the height and the slope of the bar.
%                               A trench is defined using a negative
%                               height. (default: {[]})
%                 'rotate'  = Angle in degrees over which the entire
%                               profile should be rotated. Positive angle
%                               corresponds to a clockwise rotation.
%                               (default: 0)
%                 'pivot'   = Array with coordinates of point around which
%                               the profile is rotated, if requested.
%                               Again, the first item corresponds to the
%                               x-axis while the second corresponds to the
%                               z-axis (default: [0 0]).
%
%   Output:
%   x           = array with x-coordinates of resulting profile
%   z           = array with z-coordinates of resulting profile
%
%   Example
%   [x z] = approxMCDesignPoint({[500, 200, 5, 0.1]})
%
%   See also SimpleProfile checkCrossShoreProfile

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

% Created: 14 Mei 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: modifySimpleProfile.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/non_DUROS_functions/modifySimpleProfile.m $

%% settings

% get default simple profile
[x z] = SimpleProfile;

OPT = struct( ...
    'x', [], ...
    'z', [], ...
    'flip', {[]}, ...
    'shift', [0 0], ...
    'bars', {[]}, ...
    'rotate', 0, ...
    'pivot', [0 0] ...
);

OPT = setproperty(OPT, varargin{:});

if ~isempty(OPT.x); x = OPT.x; end;
if ~isempty(OPT.z); z = OPT.z; end;

%% modify profile

% add bars and trenches
if size(x, 1) > size(x, 2); x = x'; end;
if size(z, 1) > size(z, 2); z = z'; end;

for i = 1:length(OPT.bars)
    bar = OPT.bars{i};
    
    % check if bar/trench description is valid
    if max(size(bar)) == 4
        
        % read bar/trench description
        xStart = bar(1); xStop = bar(1) + bar(2);
        zInc = bar(3); slope = bar(4);
        
        zStart = interp1(x, z, xStart, 'linear', 'extrap');
        zStop = interp1(x, z, xStop, 'linear', 'extrap');
        
        % calculate crest start and end position
        xTip1 = xStart + abs(zInc) / slope; zTip1 = zStart + zInc;
        xTip2 = xStop - abs(zInc + zStart - zStop) / slope; zTip2 = zTip1;
        
        % check if no negative crest width is calculated, otherwise correct
        % and throw warning
        if xTip1 > xTip2
            xTip1 = mean([xStart xStop]);
            xTip2 = xTip1;
            
            disp('Warning: negative crest width, ignored slope');
        end
        
        % delete existing points to be overwritten with bar/trench
        delIdxs = find(x > xStart & x < xStop);
        
        x(delIdxs) = [];
        z(delIdxs) = [];
        
        % add bar/trench points
        [x, z] = addPoint(x, z, xStart, zStart);
        [x, z] = addPoint(x, z, xTip1, zTip1);
        [x, z] = addPoint(x, z, xTip2, zTip2);
        [x, z] = addPoint(x, z, xStop, zStop);
    end
end

% shift profile
x = x + OPT.shift(1);
z = z + OPT.shift(2);

% flip profile
if size(x, 1) > size(x, 2); x = x'; end;
if size(z, 1) > size(z, 2); z = z'; end;

for i = 1:length(OPT.flip)
    flip = char(OPT.flip{i});
    
    switch flip
        case 'x'
            minZ = min(z);
            z = -1 * z;
            z = z - min(z) + minZ;
            
            x = flipdim(x, 2);
            z = flipdim(z, 2);
        case 'z'
            minX = min(x);
            x = -1 * x;
            x = x - min(x) + minX;
            
            x = flipdim(x, 2);
            z = flipdim(z, 2);
    end
end

% rotate profile
if OPT.rotate ~= 0
    for i = 1:length(x)
        angle = -1 * OPT.rotate / 180 * pi;
        
        xR = OPT.pivot(1) + cos(angle) * (x(i) - OPT.pivot(1)) - sin(angle) * (z(i) - OPT.pivot(2));
        zR = OPT.pivot(2) + sin(angle) * (x(i) - OPT.pivot(1)) + cos(angle) * (z(i) - OPT.pivot(2));
        
        x(i) = xR;
        z(i) = zR;
    end
end 

% make sure x and z dimensions are the same
if size(x, 1) < size(x, 2); x = x'; end;
if size(z, 1) < size(z, 2); z = z'; end;

%% function add point
function [x z] = addPoint(x, z, xPoint, zPoint)

    % make sure x and z dimensions are the same
    if size(x, 1) > size(x, 2); x = x'; end;
    if size(z, 1) > size(z, 2); z = z'; end;
    
    % walk through existing x coordinates looking for position to add new
    % point
    for i = 1:length(x)
        if x(i) == xPoint
            % exact match, replace existing point
            x(i) = xPoint;
            z(i) = zPoint;
            break;
        elseif x(i) > xPoint
            % larger x value found, add new point before current point
            if i > 1
                x = [x(1:i - 1) xPoint x(i:end)];
                z = [z(1:i - 1) zPoint z(i:end)];
            else
                % add new point at beginning
                x = [xPoint x];
                z = [zPoint z];
            end
            break;
        elseif i == length(x)
            % new x value is larger than all existing, add new point at the
            % end
            x = [x xPoint];
            z = [z zPoint];
            break;
        end
    end