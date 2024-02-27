function [Hs, Hs1, Hs2, Station1, Station2] = getHs_2Stations(dHs, lambda, waterLevel1, waterLevel2, Station1, Station2, varargin)
%GETHS_2STATIONS  Calculate sign. wave height given water level in two
%support stations
%
%   More detailed description goes here.
%
%   Syntax: 
%   varargout = getHs_2Stations(varargin)
%
%   Input: For <keyword,value> pairs call getHs_2Stations() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getHs_2Stations
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
% Created: 04 Mar 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: getHs_2Stations.m 13138 2017-01-20 15:31:34Z bieman $
% $Date: 2017-01-20 23:31:34 +0800 (Fri, 20 Jan 2017) $
% $Author: bieman $
% $Revision: 13138 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/bc/getHs_2Stations.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'WlELD',        [],     ...
    'WlBorkum',     []      ...
    );

OPT = setproperty(OPT, varargin{:});

%% Parameters per station

% Station information obtained from "Dune erosion - Product 3:
% Probabilistic dune erosion prediction method" WL|Delft
% Hydraulics/DUT/Alkyon 2007
%                           a       b       c           d       e
StationInfo = {
    'Vlissingen',           2.40,   0.35,   0.0008,     7,      4.67;
    'Hoek van Holland',     4.35,   0.6,    0.0008,     7,      4.67;
    'IJmuiden',             5.88,   0.6,    0.0254,     7,      2.77;
    'Den Helder',           9.43,   0.6,    0.68,       7,      1.26; 
    'Eierlandse Gat',       12.19,  0.6,    1.23,       7,      1.14;
    'Steunpunt Waddenzee',  [],     [],     [],         [],     [];
    'Borkum',               10.13,  0.6,    0.57,       7,      1.58
    };

Station1Valid   = false;
Station2Valid   = false;

for iStation = 1:size(StationInfo,1)
    if strcmpi(StationInfo{iStation,1}, Station1)
        a1              = StationInfo{iStation,2}; 
        b1              = StationInfo{iStation,3};
        c1              = StationInfo{iStation,4};
        d1              = StationInfo{iStation,5};
        e1              = StationInfo{iStation,6};
        Station1Valid   = true;
    elseif strcmpi(StationInfo{iStation,1}, Station2)
        a2              = StationInfo{iStation,2}; 
        b2              = StationInfo{iStation,3};
        c2              = StationInfo{iStation,4};
        d2              = StationInfo{iStation,5};
        e2              = StationInfo{iStation,6};
        Station2Valid   = true;
    end
end

if ~Station1Valid || ~Station2Valid
    error('Please specify valid station names!')
end

%% Calculate Hs for both stations

% Steunpunt Waddenzee doesn't have it's own set of parameters, and is
% itself an interpolation between Eierlandse Gat (Lambda = 0.57) and Borkum
% (Lambda = 0.43)
if strcmpi(Station1, 'Steunpunt Waddenzee')
    [Hs1, ~, ~] = getHs_2Stations(dHs, 0.57, waterLevel1, waterLevel2, 'Eierlandse Gat', 'Borkum');
    Hs2         = dHs + getHsig_t(waterLevel2, a2, b2, c2, d2, e2);
elseif strcmpi(Station2, 'Steunpunt Waddenzee')
    Hs1         = dHs + getHsig_t(waterLevel1, a1, b1, c1, d1, e1);
    [Hs2, ~, ~] = getHs_2Stations(dHs, 0.57, waterLevel1, waterLevel2, 'Eierlandse Gat', 'Borkum');
else
    Hs1         = dHs + getHsig_t(waterLevel1, a1, b1, c1, d1, e1);
    Hs2         = dHs + getHsig_t(waterLevel2, a2, b2, c2, d2, e2);
end

%% Interpolate

Hs  = lambda*Hs1 + (1-lambda)*Hs2;