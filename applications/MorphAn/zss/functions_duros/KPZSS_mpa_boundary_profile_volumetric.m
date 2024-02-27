function result = KPZSS_mpa_boundary_profile_volumetric(varargin)
%MPA_BOUNDARY_PROFILE  uses the MorphAn calculation kernel to calculate a boundary profile profile
%
%   This function returns a boundary profile. It
%   uses the MorphAn calculation kernel.
%
%   Syntax:
%   result = KPZSS_mpa_boundary_profile(varargin)
%
%   Input:
%   varargin  = keyword value pairs. Possible keywords:
%                           xInitial    - The x-coordinates of the pre storm profile
%                           zInitial    - The z-coordinates of the pre storm profile
%                           D50         - The grain diameter. (default 225 [mu])
%                           WL_t        - The water level (default 5 [m])
%                           Hsig_t      - The significant wave height (default 9 [m])
%                           Tp_t        - The peak wave period (default 12 [s])
%  Furthermore the routine also takes into account DuneErosionSettings
%  specified with the DuneErosionSettings function. This controls the
%  additional retreat length, maximum number of iterations and other
%  optional settings.
%
%   Output:
%   result             -    a struc that contains the results for each
%                           calculation step. The result struct has fields:
%                               info:    information about the calculation
%                                           step
%                               Volumes: Cumulative volumes, erosion volume
%                                           and accretion volume
%                               xActive: x-coordinates of the area that was
%                                           changed during the calculation 
%                                           step
%                               zActive: z-coordinates of the points that
%                                           were changed prior to the change
%                               z2Active:z-coordinates of the changed
%                                           points
%                               xLand:   x-points landward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               zLand:   z-points landward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               xSea:    x-points seaward of the coordinates
%                                           that were changed during the
%                                           calculation step
%                               zSea:    z-points seaward of the coordinates
%                                           that were changed during the
%                                           calculation step
%
%   Example
%   r = mpa_durosplus();
%   plotduneerosion(r,figure);
%
%   See also DUROS DuneErosionSettings

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: mpa_durosplus.m 12127 2015-07-22 08:50:07Z geer $
% $Date: 2015-07-22 10:50:07 +0200 (Wed, 22 Jul 2015) $
% $Author: geer $
% $Revision: 12127 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/MorphAn/mpa_durosplus.m $
% $Keywords: $

%% TODO
% Implement / communicate output flags of various kinds:
%

if isempty(getappdata(0,'MorphAnCSharpLibInitialized'))
    mpa_loadcsharp;
end

%% check and inventorise input
% In this step the input is verified. If one of the input arguments is not
% defined, a default value is used:
% 
% # xInitial    - The x-coordinates of the reference profile of the Dutch
%                   coast.
% # zInitial    - The z-coordinates of the reference profile of the Dutch
%                   coast.
% # D50         - The grain diameter. (default 225 [mu])
% # WL_t        - The water level (default 5 [m])
% # Hsig_t      - The significant wave height (default 9 [m])
% # Tp_t        - The peak wave period (default 12 [s])
%
% Next to the input parameters also some settings are obtained from
% _DuneErosionSettings_.
%

OPT = struct(...
    'xInitial', [-250 -24.375 5.625 55.725 230.625 1950]',...
    'zInitial', [15 15 3 0 -3 -14.4625]',...
    'D50', 225e-6,...
    'WL_t', 5,...
    'Hsig_t', 9,...
    'Tp_t', 12,...
    'XBasePosition',0,...
    'IterateLandward',true);

[xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t] = parseDUROSinput(OPT, varargin{:});
OPT = setproperty(OPT,varargin);

%% Run MorphAn

morphAnInput = DeltaShell.Plugins.MorphAn.TRDA.Calculators.TRDAInputParameters;

% boundary conditions
morphAnInput.SignificantWaveHeight = Hsig_t;
morphAnInput.UsePeakPeriod = true;
morphAnInput.PeakPeriod = Tp_t;
morphAnInput.MaximumStormSurgeLevel = WL_t;
morphAnInput.BoundaryProfileAtBackOfFirstDune = true;
morphAnInput.XBasePosition = OPT.XBasePosition;
morphAnInput.IterateLandward = OPT.IterateLandward;
morphAnInput.BoundaryProfileGeometricHeightCheck = true;

% Settings
morphAnInput.MaximumRetreatDistance = DuneErosionSettings('get','maxRetreat'); % To work similar to the matlab implementation
morphAnInput.AutoCorrectPeakPeriod = DuneErosionSettings('get','TP12slimiter');
morphAnInput.MaximumNumberOfIterations = DuneErosionSettings('get','maxiter');
morphAnInput.DurosMethod = DeltaShell.Plugins.MorphAn.TRDA.Calculators.DurosMethod.DurosPlus;

% Input profile (This takes some time. To optimize probabilistics do this once...)
morphAnInput.InputProfile = DeltaShell.Plugins.MorphAn.Domain.Transect(...
    NET.convertArray(xInitial, 'System.Double'),...
    NET.convertArray(zInitial, 'System.Double'));

morphAnInput.TargetVolume = DeltaShell.Plugins.MorphAn.TRDA.Calculators.BoundaryProfile.BoundaryProfileCalculator.GetBoundaryProfileVolume(...
    OPT.Hsig_t, OPT.Tp_t, true);

morphAnResult = DeltaShell.Plugins.MorphAn.TRDA.Calculators.BoundaryProfile.BoundaryProfileCalculator.GetVolumetricBoundaryProfile(morphAnInput);

%% Extract results
result = createEmptyDUROSResult;
profile = crossshoreprofile2matlabprofile(morphAnResult.Profile);
preProfile = crossshoreprofile2matlabprofile(morphAnInput.InputProfile);

idInitialX = preProfile(:,1) > min(profile(:,1)) & preProfile(:,1) < max(profile(:,1)); 
result.xActive = unique([profile(:,1);preProfile(idInitialX,1)]);
result.z2Active = interp1(profile(:,1),profile(:,2),result.xActive );
result.zActive = repmat(morphAnInput.MaximumStormSurgeLevel,length(result.xActive),1);

result.xLand = xInitial(xInitial < min(result.xActive));
result.zLand = zInitial(xInitial < min(result.xActive));
result.xSea = xInitial(xInitial > max(result.xActive));
result.zSea = zInitial(xInitial > max(result.xActive));

result.Volumes.Volume = morphAnResult.Volume;
result.Volumes.Accretion = morphAnResult.AccretionVolume;
result.Volumes.Erosion = morphAnResult.ErosionVolume;
end

function profile = crossshoreprofile2matlabprofile(morphAnProfile)
profile = [double(morphAnProfile.XCoordinates)',double(morphAnProfile.ZCoordinates)'];
end