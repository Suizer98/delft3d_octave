function z = prob_vdMeer_example_x2z(varargin)
%PROB_VDMEER_EXAMPLE_X2Z  Limite state function for example with Van der Meer formula
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_vdMeer_example_x2z(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_vdMeer_example_x2z
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
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
% Created: 08 Jun 2011
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: prob_vdMeer_example_x2z.m 4640 2011-06-08 14:05:18Z heijer $
% $Date: 2011-06-08 22:05:18 +0800 (Wed, 08 Jun 2011) $
% $Author: heijer $
% $Revision: 4640 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/prob_vdMeer_example/prob_vdMeer_example_x2z.m $
% $Keywords: $

%% create samples-structure based on input arguments
samples = struct(...
    'RhoS', [],...       % [kg/m3] RhoS density sediment
    'RhoW', [],...       % [kg/m3] RhoW density water
    'TanAlfa', [],...    % [-] TanAlfa  slope of structure
    'Steep', [],...      % [-] Steep    wave steepness
    'P', [],...          % [-] P        notional permeability
    'S', [],...          % [-] S        damage number
    'N', [],...          % [-] N        number of waves
    'H', [],...          % [m] H        significant wave height
    'D', [],...          % [m] D        stone size
    'Cpl', []);		    % [-] Cpl      constant in vdMeer formula

samples = setproperty(samples, varargin{:});

%% calculate z-values
% pre-allocate z
z = nan(size(samples.RhoS));
% loop through all samples and derive z-values
for i = 1:length(samples.RhoS)
    Delta = (samples.RhoS(i) - samples.RhoW(i)) / samples.RhoW(i);    % [-] relative density
    Ksi = samples.TanAlfa(i)/sqrt(samples.Steep(i));      % [-] Iribarren number
    z(i,:) = samples.Cpl(i)*samples.P(i)^0.18*(samples.S(i)/sqrt(samples.N(i)))^0.2*Ksi^(-0.5)-samples.H(i)/Delta/samples.D(i); %[-] vdMeer
end

%{
% alternatively, the z can be calculated as matrix operation (so, no loop
% needed) as follows:
Delta = (samples.RhoS - samples.RhoW) ./ samples.RhoW;    % [-] relative density
Ksi = samples.TanAlfa ./ sqrt(samples.Steep);      % [-] Iribarren number
z = samples.Cpl .* samples.P .^0.18.*(samples.S./sqrt(samples.N)).^0.2.*Ksi.^(-0.5)-samples.H./Delta./samples.D; %[-] vdMeer
%}