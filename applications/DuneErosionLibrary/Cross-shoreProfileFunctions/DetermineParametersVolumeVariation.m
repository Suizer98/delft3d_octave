function [a, b, c] = DetermineParametersVolumeVariation(varargin)
%DETERMINEPARAMETERSVOLUMEVARIATION  Determines parameters for the triangular
%distibution of volume variation in cross-shore dune profiles
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = DetermineParametersVolumeVariation(varargin)
%
%   Input: For <keyword,value> pairs call DetermineParametersVolumeVariation() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   DetermineParametersVolumeVariation
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
% Created: 10 Mar 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: DetermineParametersVolumeVariation.m 10371 2014-03-10 15:38:17Z bieman $
% $Date: 2014-03-10 23:38:17 +0800 (Mon, 10 Mar 2014) $
% $Author: bieman $
% $Revision: 10371 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/Cross-shoreProfileFunctions/DetermineParametersVolumeVariation.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'TargetVolume',         [],     ...
    'TargetProbability',    0.95,   ...
    'cValue',               0,      ...
    'MaxIterations',        100,    ...
    'MaxError',             1e-2    ...
    );

OPT = setproperty(OPT, varargin{:});

%% Fit distribution to target volume

iIteration  = 0;
ErrorFit    = Inf;

% Iterate to find proper parameters for target volume
while abs(ErrorFit) > OPT.MaxError && iIteration <= OPT.MaxIterations
    if iIteration == 0
        aEstimator  = -OPT.TargetVolume;
        bEstimator  = OPT.TargetVolume;
        cEstimator  = OPT.cValue;
    else
        % Estimate parameter values based on previous error
        aEstimator  = aEstimator + ErrorFit;
        bEstimator  = bEstimator - ErrorFit;
        cEstimator  = OPT.cValue;
    end
    
    ErrorFit    = trian_inv(OPT.TargetProbability, aEstimator, bEstimator, cEstimator) - OPT.TargetVolume;
    
    iIteration  = iIteration + 1;
end

if iIteration <= OPT.MaxIterations
    a   = aEstimator;
    b   = bEstimator;
    c   = cEstimator;
else
    error('The maximum number of iterations has been reached without converging!');
end