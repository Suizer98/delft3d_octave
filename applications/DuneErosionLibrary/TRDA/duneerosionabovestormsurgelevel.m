function Result = duneerosionabovestormsurgelevel(xPreStorm, zPreStorm, xPostStorm, zPostStorm, waterLevel)
%DUNEEROSIONABOVESTORMSURGELEVEL  Determines the amount of eroded sediment for two given profiles above the waterline.
%
%   Given a pre storm and post storm profile this routine calculates the amount of eroded sediment
%   above the maximum storm surge level.
%
%   Syntax:
%   Result = duneerosionabovestormsurgelevel(xPreStorm,zPreStorm,xPostStorm,zPostStorm,waterLevel)
%
%   Input:
%   xPreStorm  =  x-grid of the pre storm profile.
%   zPreStorm  =  elevation of the pre storm profile at the location of the x-grid points specified
%                   in xPreStorm.
%   xPostStorm =  x-grid of the post storm profile.
%   zPostStorm =  elevation of the post storm profile at the location of the x-grid points specified
%                   in xPostStorm.
%   waterLevel =  Maximum elevation of the water level during the storm.
%
%   Output:
%   Result     =  Dune erosion calculation result structure obtained with createEmptyDUROSResult
%
%
%   See also createEmptyDUROSResult

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: duneerosionabovestormsurgelevel.m 4334 2011-03-25 08:40:23Z geer $
% $Date: 2011-03-25 16:40:23 +0800 (Fri, 25 Mar 2011) $
% $Author: geer $
% $Revision: 4334 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/TRDA/duneerosionabovestormsurgelevel.m $
% $Keywords: $

%%

[aVolume, Result] = getVolume(...
    'x',xPreStorm,...
    'z',zPreStorm,...
    'x2',xPostStorm,...
    'z2',zPostStorm,...
    'LowerBoundary',waterLevel,...
    'suppressMessEqualBoundaries', true);

Result.VTVinfo.AVolume = aVolume;
Result.info.ID = 'Erosion above SSL';