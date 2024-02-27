function xRPoint = mpa_durosplusfast(xInitial, zInitial, D50, waterLevel, significantWaveHeight, peakPeriod)
%MPA_DUROSPLUSFAST  This function calculates a Duros+ profile with MorphAn fast
%
%   A simple and fast calculation with the Duros+ function in MorphAn. This
%   function only returns the location of the erosion point (R-point). It
%   is therefore much faster than the equivalent (mpa_durosplus) which also
%   outputs all calculated profiles.
%
%   Syntax:
%   xRPoint = mpa_durosplusfast(xInitial, zInitial, D50, waterLevel, significantWaveHeight, peakPeriod, coastalBend)
%
%   Input:
%   xInitial    = x coordinates of the initial profile
%   zInitial    = z coordinates of the initial profile
%   D50         = Grain size (m)
%   waterLevel  = Maximum storm surge level level (m + N.A.P.)
%   significantWaveHeight = Significant wave height at the maximum of the storm (m)
%   peakPeriod  = Peak period at the maximum of the storm (s)
%   coastalBend = Coastal bend in longshore direction (degrees / 1000 meter)
%
%   This function also takes into account the DuneErosionSettings
%
%   Output:
%   xRPoint     = x value of the retreat point (also retreat distance)
%
%   Example
%   mpa_loadcsharp;
%   [x,z] = referenceprofile;
%   xR = mpa_durosplusfast(x,z,0.000250,5,9,16);
%   disp(['xR = ' num2str(xR)]);
%
%   See also mpa_durosplus DUROS DuneErosionSettings

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
% Created: 09 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: mpa_durosplusfast.m 11497 2014-12-02 09:26:28Z geer $
% $Date: 2014-12-02 17:26:28 +0800 (Tue, 02 Dec 2014) $
% $Author: geer $
% $Revision: 11497 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/MorphAn/mpa_durosplusfast.m $
% $Keywords: $

%% Run MorphAn
morphAnInput = DeltaShell.Plugins.MorphAn.TRDA.Calculators.TRDAInputParameters;

morphAnInput.D50 = D50;
morphAnInput.SignificantWaveHeight = significantWaveHeight;
morphAnInput.UsePeakPeriod = true; % Can also use spectral wave period Tm-1,0
morphAnInput.PeakPeriod = peakPeriod;
morphAnInput.MaximumStormSurgeLevel = waterLevel;
morphAnInput.MaximumRetreatDistance = DuneErosionSettings('get','maxRetreat'); % To work similar to the matlab implementation
morphAnInput.AutoCorrectPeakPeriod = DuneErosionSettings('get','TP12slimiter');
morphAnInput.MaximumNumberOfIterations = DuneErosionSettings('get','maxiter');
morphAnInput.DurosMethod = DeltaShell.Plugins.MorphAn.TRDA.Calculators.DurosMethod.DurosPlus;

% This takes some time. To optimize probabilistics do this once...
morphAnInput.InputProfile = DeltaShell.Plugins.MorphAn.Domain.Transect(...
    NET.convertArray(xInitial, 'System.Double'),...
    NET.convertArray(zInitial, 'System.Double'));

TVolumeFunction = DuneErosionSettings('get','AdditionalVolume'); % function should accept a double as input (A volume) and a double (T volume) as output

if ~ischar(TVolumeFunction)
    morphAnResult = DeltaShell.Plugins.MorphAn.TRDA.CoastalSafetyAssessment.AssessDuneProfile(morphAnInput,TVolumeFunction);
else
    % assume default and use default factor. It is also possible to
    % specify a factor that differs from 0.25. Use the input property
    % TargetVolumeCalculationFactor for that purpose
    morphAnResult = DeltaShell.Plugins.MorphAn.TRDA.CoastalSafetyAssessment.AssessDuneProfile(morphAnInput);
end

xRPoint = morphAnResult.OutputPointR.X;
