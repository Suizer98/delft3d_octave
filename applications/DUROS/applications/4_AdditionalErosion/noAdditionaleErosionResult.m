function resultout = noAdditionaleErosionResult(xInitial,zInitial,result,maxRetreat,TargetVolume)
%NOADDITIONALEEROSIONRESULT  Returns a DUROS result structure for no additional erosion
%
%   Fills the empty Duros result with a result that indicates no additional
%   erosion can be calculated because the remaining DUROS profile did not
%   have any points above the waterlevel.
%
%   Syntax:
%   resultout = noAdditionaleErosionResult(xInitial,zInitial,resultin,maxRetreat,TargetVolume)
%
%   Input:
%   xInitial  = x-coordinates of the initial profile
%   zInitial  = z-coordinates of the initial profile
%   resultin  = result of the DUROS calculation
%   maxRetreat  = maximum retreat distance
%   TargetVolume  = Additional erosion volume that must be fit into the
%               profile.
%
%   Output:
%   resultout = result structure of the additional erosion "calculation".
%
%
%   See also  getDuneErosion_additional getDuneErosion

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       <ADDRESS>
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

% Created: 10 Apr 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: noAdditionaleErosionResult.m 2526 2010-05-10 08:12:52Z geer $
% $Date: 2010-05-10 16:12:52 +0800 (Mon, 10 May 2010) $
% $Author: geer $
% $Revision: 2526 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/applications/4_AdditionalErosion/noAdditionaleErosionResult.m $
% $Keywords: $

%%
% no additional erosion because DUROS solution does not have
% any point above the water level.

%% write message
writemessage(4,'No profile information above sea level after DUROS calculation');

%% create the new result structure
resultout = createEmptyDUROSResult;

%% Restricted solution in the profile?
% if we know that the additional erosion is restricted inside the ranges of
% xInitial, we also know that extentding the profile landwards will lead to
% a solution where no additional erosion will occur. We can apply this
% solution in advance and don't have to issue this message.
KnownRestrictedSolutionPossible = (result(1).info.x0 - min(xInitial)) > maxRetreat;

if KnownRestrictedSolutionPossible
    % write a message what's happening
    writemessage(45, 'Erosional length restricted within dunevalley. No additional Erosion volume determined.');
    
    % construct the land part of the profile
    resultout.xLand = xInitial(xInitial<result(1).info.x0);
    resultout.zLand = zInitial(xInitial<result(1).info.x0);
    
    % construct the active part of the profile
    resultout.xActive= result(1).info.x0;
    if any(xInitial==result(1).info.x0)
        resultout.zActive = zInitial(xInitial==result(1).info.x0);
        resultout.z2Active = zInitial(xInitial==result(1).info.x0);
    else
        % Hack, because interp1 crashes whenever tw0 x-points are closer to each other than 1e-6
        % (unique does not filter them out...)
        id = find(xInitial<result(1).info.x0,1,'last'):find(xInitial>result(1).info.x0,1,'first');
        xInitialinterp = xInitial(id);
        zInitialinterp = zInitial(id);
        resultout.zActive = interp1(xInitialinterp,zInitialinterp,result(1).info.x0);
        resultout.z2Active = interp1(xInitialinterp,zInitialinterp,result(1).info.x0);
    end
    
    % construct the sea part of the profile
    resultout.xSea = xInitial(xInitial>result(1).info.x0);
    resultout.zSea = zInitial(xInitial>result(1).info.x0);
    
    % add additional information
    resultout.Volumes.Volume = 0; %#ok<NASGU>
    resultout.info.x0 = result(1).info.x0;
    resultout.info.precision = TargetVolume;
    resultout.info.resultinboundaries = true; % We don't have boundaries at this point, but know that with boundaries the solution would be the same...
    resultout.info.ID = 'Additional Erosion';
end
