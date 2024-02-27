function [resultMC resultFORM] = prob_vdMeer_example
%PROB_VDMEER_EXAMPLE  example of probabilistic calculation with van der Meer formula
%
%   Example of probabilistic Monte Carlo and FORM routines applied to the
%   van der Meer formula.
%
%   Syntax:
%   [resultMC resultFORM] = prob_vdMeer_example
%
%   Output:
%   resultMC   = structure with Monte Carlo results
%   resultFORM = structure with FORM results
%
%   Example
%   [resultMC resultFORM] = prob_vdMeer_example
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
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
% Created: 04 Dec 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: prob_vdMeer_example.m 4640 2011-06-08 14:05:18Z heijer $
% $Date: 2011-06-08 22:05:18 +0800 (Wed, 08 Jun 2011) $
% $Author: heijer $
% $Revision: 4640 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/prob_vdMeer_example/prob_vdMeer_example.m $
% $Keywords: $

%% define the stochasts
% create a structure with fields 'Name', 'Distr', 'Params' and 'propertyName'
stochast = struct(...
    'Name', { % define the stochastic variable names:
    'RhoS'...       % [kg/m3] RhoS density sediment
    'RhoW'...       % [kg/m3] RhoW density water
    'TanAlfa'...    % [-] TanAlfa  slope of structure
    'Steep'...      % [-] Steep    wave steepness
    'P'...          % [-] P        notional permeability
    'S'...          % [-] S        damage number
    'N'...          % [-] N        number of waves
    'H'...          % [m] H        significant wave height
    'D'...          % [m] D        stone size
    'Cpl'		    % [-] Cpl      constant in vdMeer formula
    },...
    'Distr', { % define the probability distribution functions
    @norm_inv...       % [kg/m3] RhoS density sediment
    @norm_inv...       % [kg/m3] RhoW density water
    @norm_inv...       % [-] TanAlfa  slope of structure
    @norm_inv...       % [-] Steep    wave steepness
    @logn_inv...       % [-] P        notional permeability
    @deterministic...  % [-] S        damage number
    @deterministic...  % [-] N        number of waves
    @exp_inv...        % [m] H        significant wave height
    @norm_inv...       % [m] D        stone size
    @norm_inv...	   % [-] Cpl      constant in vdMeer formula
    },...
    'Params', { % define the parameters of the probability distribution functions
    {2650 100}...   % [kg/m3] RhoS density sediment
    {1030 5}...     % [kg/m3] RhoW density water
    {0.25 0.0125}...% [-] TanAlfa  slope of structure
    {0.05 0.01}...  % [-] Steep    wave steepness
    {{@logn_moments2lambda 0.1  0.05} {@logn_moments2zeta 0.1  0.05}}...  % [-] P        notional permeability
    {2  }...        % [-] S        damage number
    {7000}...       % [-] N        number of waves
    {3.83 1}...     % [m] H        significant wave height
    {0.6 0.05}...   % [m] D        stone size
    {6.2 0.43}...	% [-] Cpl      constant in vdMeer formula
    },...
    'propertyName', { % specify here to call the z-function with propertyname-propertyvalue pairs
    true...       % [kg/m3] RhoS density sediment
    true...       % [kg/m3] RhoW density water
    true...       % [-] TanAlfa  slope of structure
    true...       % [-] Steep    wave steepness
    true...       % [-] P        notional permeability
    true...       % [-] S        damage number
    true...       % [-] N        number of waves
    true...       % [m] H        significant wave height
    true...       % [m] D        stone size
    true...	      % [-] Cpl      constant in vdMeer formula
    } ...
    );

%% main matter: running the calculation
% run the calculation using Monte Carlo
resultMC = MC(...
    'stochast', stochast,...
    'NrSamples', 3e4,...
    'x2zFunction', @prob_vdMeer_example_x2z);

% run the calculation using FORM
resultFORM = FORM(...
    'stochast', stochast,...
    'x2zFunction', @prob_vdMeer_example_x2z);