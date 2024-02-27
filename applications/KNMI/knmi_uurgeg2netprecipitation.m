function [P, M] = knmi_uurgeg2netprecipitation(fname, varargin)
%KNMI_UURGEG2NETPRECIPITATION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = knmi_uurgeg2netprecipitation(varargin)
%
%   Input: For <keyword,value> pairs call knmi_uurgeg2netprecipitation() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   knmi_uurgeg2netprecipitation
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 26 Feb 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: knmi_uurgeg2netprecipitation.m 11314 2014-11-02 13:41:52Z hoonhout $
% $Date: 2014-11-02 21:41:52 +0800 (Sun, 02 Nov 2014) $
% $Author: hoonhout $
% $Revision: 11314 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/KNMI/knmi_uurgeg2netprecipitation.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'latent_heat', 2.45, ... [MJ/kg]
    'atmospheric_pressure', 101.325, ... [kPa]
    'air_specific_heat', 1.0035e-3 ... [MJ/kg/K]
    );

OPT = setproperty(OPT, varargin);

if ~exist(fname, 'file')
    error('File does not exist [%s]', fname);
end

%% read data

S = knmi_uurgeg(fname);

columns = {'global_radiation', ...
           'air_temperature_mean', ...
           'relative_humidity', ...
           'wind_speed_vector_mean', ...
           'duration_of_sunshine', ...
           'precipitation_amount_sum'};
       
factors = [1e4*24/1e6, ...  % J/cm^2/hr -> MJ/m2/d
           1, ...           % oC -> oC
           1, ...           % % -> %
           3600*24/1e3, ... % m/s -> km/d
           1, ...           % h -> h
           1/10*24];        % mm/hr -> cm/d
       
 % get column indices
idxs = zeros(1,length(columns));
for i = 1:length(columns)
    idxs(i) = find(cellfun(@(x) ~isempty(regexp(x,['^' columns{i} ' '],'once')), S.name), 1);
end

% get data
fn = fieldnames(S.data);
keys = fn(idxs);

M = struct();
for i = 1:length(keys)
    M.(columns{i}) = S.data.(keys{i}) * factors(i);
    if ~strcmpi(keys{i}, 'air_temperature_mean')
        M.(columns{i}) = max(0,M.(columns{i}));
    end
end

% compute evaporation
m       = vaporation_pressure_slope(M.air_temperature_mean); % [kPa/K]
delta   = saturation_pressure(M.air_temperature_mean) .* (1 - M.relative_humidity); % [kPa]
gamma   = (OPT.air_specific_heat * OPT.atmospheric_pressure) / (.622 * OPT.latent_heat); % [kPa/K]
e       = max(0, (m .* M.global_radiation + gamma * 6.43 * (1 + 0.536 * M.wind_speed_vector_mean) .* delta) ./ ...
                    (OPT.latent_heat * (m + gamma)));
M.evaporation = e / 10; % conversion from mm/day to cm/day

%% compute net precipitation

P = M.precipitation_amount_sum(2:end) - M.evaporation(1:end-1);