function [x z current_Xdir z0 Shift] = checkCrossShoreProfile(x, z, varargin)
%CHECKCROSSSHOREPROFILE  derive/change x-direction/x-origin of a cross-shore profile
%
%   Routine detects whether the profile specified by x and z is positive seaward 
%   or positive landward, and derives the z-value at x=0. If specified, the 
%   positive x-direction can be changed. Furthermore can be chosen either to 
%   make the x-origin at the landward or at the seaward side.
%
%   Syntax:
%   [x z Xdir z0 Shift] = checkCrossShoreProfile(x, z, varargin)
%
%   Input:
%       x        = column array with x-coordinates
%       z        = column array with z-coordinates
%       varargin = property value pairs
%                   'poslndwrd' -  1 for positive landward
%                                 -1 for positive seaward
%                   'x_origin'  - either 'landside' or 'seaside'
%                   'Shift'     - horizontal distance to shift the profile
%
%   Output:
%       x        = column array with x-coordinates
%       z        = column array with z-coordinates
%       Xdir     = x-direction (original): 1 for positive landward and -1 for positive seaward
%       z0       = z-value at x=0 (new profile)
%       Shift    = horizontal distance over which the profile has been shifted
%
%   Example
%       checkCrossShoreProfile
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
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

% Created: 24 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: checkCrossShoreProfile.m 3516 2010-12-03 12:45:22Z heijer $
% $Date: 2010-12-03 20:45:22 +0800 (Fri, 03 Dec 2010) $
% $Author: heijer $
% $Revision: 3516 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/analysis/checkCrossShoreProfile.m $
% $Keywords:

%%
OPT = struct(...
    'poslndwrd', [],...
    'x_origin', [],...
    'Shift', 0);

OPT = setproperty(OPT, varargin{:});

[x z] = deal(x(:), z(:));

% remove NaNs
nonnanid = ~isnan(z);
[x z] = deal(x(nonnanid), z(nonnanid));

%% sort x ascending and derive current positive x-direction
[x IX]  = sort(x); % sort x ascending, get permutation vector
z       = z(IX);   % rearrange z based on permutation vector
[LandwardBoundary1 SeawardBoundary2] = deal(min(x), max(x));
[SeawardBoundary1 LandwardBoundary2] = deal(mean([LandwardBoundary1 SeawardBoundary2]));
Volume1 = getVolume(x, z,...
    'LandwardBoundary', LandwardBoundary1,...
    'SeawardBoundary', SeawardBoundary1);
Volume2 = getVolume(x, z,...
    'LandwardBoundary', LandwardBoundary2,...
    'SeawardBoundary', SeawardBoundary2);

if Volume1 > Volume2 % i.e. x-direction positive seaward
    current_Xdir = -1; % positive seaward
else
    current_Xdir = 1; % positive landward
end

%% flip x and z if required
if OPT.poslndwrd ~= current_Xdir
    x = flipud(-x); % change x-direction into positive landward, flipud to keep the x-order ascending
    z = flipud(z);
    Xdir = OPT.poslndwrd;
else
    Xdir = current_Xdir;
end

%% check whether x_origin has been specified
if ~isempty(OPT.x_origin)
    if strcmpi(OPT.x_origin, 'landside') && Xdir == 1 ||...
            strcmpi(OPT.x_origin, 'seaside') && Xdir == -1
        refX = max(x);
    else
        refX = min(x);
    end
    if refX ~= 0
        Shift = -refX; % cross-shore distance to shift the profile
        x = x + Shift; % change the x-values
    else
        Shift = 0;
    end
elseif OPT.Shift ~= 0
    Shift = OPT.Shift; % cross-shore distance to shift the profile
    x = x + Shift; % change the x-values
else
    Shift = 0;
end

z0 = interp1(x, z, 0);