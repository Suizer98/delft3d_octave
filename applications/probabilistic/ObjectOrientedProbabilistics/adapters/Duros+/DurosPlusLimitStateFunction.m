function z = DurosPlusLimitStateFunction(varargin)
%DUROSPLUSLIMITSTATEFUNCTION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = DurosPlusLimitStateFunction(varargin)
%
%   Input: For <keyword,value> pairs call DurosPlusLimitStateFunction() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   DurosPlusLimitStateFunction
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
%
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
% Created: 24 Feb 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: DurosPlusLimitStateFunction.m 11147 2014-09-29 09:58:35Z bieman $
% $Date: 2014-09-29 17:58:35 +0800 (Mon, 29 Sep 2014) $
% $Author: bieman $
% $Revision: 11147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/adapters/Duros+/DurosPlusLimitStateFunction.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'Ph',               [],         ...
    'PHm0',             [],         ...
    'PTp',              [],         ...
    'D50',              225e-6,     ...
    'JarkusID',         [],         ...
    'MaxErosionPoint',  30,         ...
    'ModelSetupDir',    'd:\ADIS_XB_testing\ModelSetup\ReferenceProfile');

OPT = setproperty(OPT, varargin{:});

%% Read input

xInitial    = load(fullfile(OPT.ModelSetupDir, 'xDuros+.grd'));
zInitial    = load(fullfile(OPT.ModelSetupDir, 'bedDuros+.dep'));

xInitial    = fliplr(xInitial);
zInitial    = fliplr(zInitial);

xInitial    = -xInitial;

[Lambda, ~, Station1, Station2] = getLambda_2Stations('JarkusId', OPT.JarkusID);     

[h, h1, h2, Station1, Station2, Lambda]     = getWl_2Stations(norm_cdf(OPT.Ph, 0, 1), Lambda, Station1, Station2);
[Hs, Hs1, Hs2, Station1, Station2]          = getHs_2Stations(OPT.PHm0, Lambda, h1, h2, Station1, Station2);
[Tp, Tp1, Tp2, Station1, Station2]          = getTp_2Stations(OPT.PTp, Lambda, Hs1, Hs2, Station1, Station2);

%% Duros+ settings

DuneErosionSettings('set', 'AdditionalErosion', false);

MaxErosionPoint = OPT.MaxErosionPoint;
D50             = OPT.D50*ones(size(OPT.Ph));
Duration        = zeros(size(OPT.Ph));
Accuracy        = zeros(size(OPT.Ph));

%% run Duros+
[zTemp, Volume, ErosionResult]   = x2z_DUROS(        ...
    'Resistance',   MaxErosionPoint,        ...
    'xInitial',     xInitial,               ...
    'zInitial',     zInitial,               ...
    'WL_t',         h',                     ...
    'Hsig_t',       Hs',                    ...
    'Tp_t',         Tp',                    ...
    'D50',          D50',                   ...
    'Duration',     Duration',              ...
    'Accuracy',     Accuracy',              ...
    'zRef',         max(zInitial)           ...
    );

%% Limit State Function


if numel(ErosionResult) == 2
    ErosionPoint = DetermineErosionPoint(ErosionResult(1).VTVinfo.Xr, h, MaxErosionPoint, zTemp, ErosionResult(1).info.precision, xInitial, zInitial);

    z               = MaxErosionPoint - ErosionPoint;
    display(['The current exact Z-value is ' num2str(z) '(h = ' num2str(OPT.Ph), ...
        ', Hm0 = ' num2str(OPT.PHm0) ', Tp = ' num2str(OPT.PTp) ')']) %DEBUG
else
    for iResult = 1:numel(ErosionResult)
        ErosionPoint = DetermineErosionPoint(ErosionResult{iResult}(1).VTVinfo.Xr, h(iResult), MaxErosionPoint, zTemp(iResult), ErosionResult{iResult}(1).info.precision, xInitial, zInitial);
        z(iResult)      = MaxErosionPoint - ErosionPoint;
        
        display(['The current exact Z-value is ' num2str(z(iResult)) '(h = ' num2str(OPT.Ph(iResult)), ...
            ', Hm0 = ' num2str(OPT.PHm0(iResult)) ', Tp = ' num2str(OPT.PTp(iResult)) ')']) %DEBUG
    end
end
end

function ErosionPoint = DetermineErosionPoint(Rx, hWaterLevel, MaxErosionPoint, Zvalue, Precision, xProfile, zProfile)

if hWaterLevel > max(zProfile)
    % Waterlevel higher than dune crest, use intersection of 1/100 slope
    % with dune crest level from water height as ErosionPoint
    zReference      = 0;
    xReference      = -min(findCrossings(xProfile,zProfile,[min(xProfile),max(xProfile)],zReference*ones(1,2)));
    if isempty(xReference) || xReference < max(findCrossings(xProfile,zProfile,[min(xProfile),max(xProfile)],max(zProfile)*ones(1,2)))
        xReference  = -min(xProfile);
    end
    Slope           = 1/100;
    ErosionPoint    = -xReference + (hWaterLevel-max(zProfile))/Slope;
else
    if isempty(Rx) && Zvalue == MaxErosionPoint - 1000
        ErosionPoint    = -min(xProfile);
    elseif Precision > 1
        % Eroded volume can't be fit completely in the available volume
        % above waterlevel, add remainder as the distance it takes to
        % erode the mean volume above waterlevel
        ErosionPoint    = -Rx + Precision/(mean(zProfile(zProfile>hWaterLevel))-hWaterLevel);
    else
        ErosionPoint    = -Rx;
    end
end
end