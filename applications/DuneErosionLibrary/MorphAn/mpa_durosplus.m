function result = mpa_durosplus(varargin)
%MPA_DUROSPLUS  uses the MorphAn calculation kernel to calculate a Duros+ erosion profile
%
%   This function returns an erosion profile calculated with Duros+. It
%   uses the MorphAn calculation kernel.
%
%   Syntax:
%   result = mpa_durosplus(varargin)
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
% $Date: 2015-07-22 16:50:07 +0800 (Wed, 22 Jul 2015) $
% $Author: geer $
% $Revision: 12127 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/MorphAn/mpa_durosplus.m $
% $Keywords: $

%% TODO
% Implement / communicate output flags of various kinds:
%
% OutputFlagWaterLevelAboveProfile: 0
% OutputFlagNotEnoughProfileInformationLandward: 0
% OutputFlagNotEnoughProfileInformationSeaward: 0
% OutputFlagNoErosion: 0
% OutputFlagNoAdditionalErosion: 0
% OutputFlagDuneBreach: 0
% OutputFlagCorrectedForLandwardTransport: 0
% OutputFlagSolutionInfluencedByChannelSlope: 0
% OutputFlagPrecisionNotMet: 0
% OutputFlagNoSolutionPossible: 0

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
    'Tp_t', 12);

[xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t] = parseDUROSinput(OPT, varargin{:});

%% Run MorphAn

morphAnInput = DeltaShell.Plugins.MorphAn.TRDA.Calculators.TRDAInputParameters;

% boundary conditions
morphAnInput.D50 = D50;
morphAnInput.SignificantWaveHeight = Hsig_t;
morphAnInput.UsePeakPeriod = true;
morphAnInput.PeakPeriod = Tp_t;
morphAnInput.MaximumStormSurgeLevel = WL_t;
morphAnInput.G0 = getG0(DuneErosionSettings('get','Bend')); % To work similar to the matlab implementation

% Settings
morphAnInput.MaximumRetreatDistance = DuneErosionSettings('get','maxRetreat'); % To work similar to the matlab implementation
morphAnInput.AutoCorrectPeakPeriod = DuneErosionSettings('get','TP12slimiter');
morphAnInput.MaximumNumberOfIterations = DuneErosionSettings('get','maxiter');
morphAnInput.DurosMethod = DeltaShell.Plugins.MorphAn.TRDA.Calculators.DurosMethod.DurosPlus;

% Input profile (This takes some time. To optimize probabilistics do this once...)
morphAnInput.InputProfile = DeltaShell.Plugins.MorphAn.Domain.Transect(...
    NET.convertArray(xInitial, 'System.Double'),...
    NET.convertArray(zInitial, 'System.Double'));

% Depending on calculation of additional erosion volume (T Volume) call the
% main function.

TVolumeFunction = DuneErosionSettings('get','AdditionalVolume'); % function should accept a double as input (A volume) and a double (T volume) as output
if ~ischar(TVolumeFunction)
    morphAnResult = DeltaShell.Plugins.MorphAn.TRDA.CoastalSafetyAssessment.AssessDuneProfile(morphAnInput,TVolumeFunction);
else
    % assume default and use default factor. It is also possible to
    % specify a factor that differs from 0.25. Use the input property
    % TargetVolumeCalculationFactor for that purpose
    % TODO: Implement the factor and put it in the input parameters as well
    morphAnResult = DeltaShell.Plugins.MorphAn.TRDA.CoastalSafetyAssessment.AssessDuneProfile(morphAnInput);
end

result = mpa_fillresultfromcsharp(morphAnResult);
end

