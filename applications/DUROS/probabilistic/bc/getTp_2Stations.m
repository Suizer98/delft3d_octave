function [Tp, Tp1, Tp2, Station1, Station2] = getTp_2Stations(dTp, lambda, waveHeight1, waveHeight2, Station1, Station2, varargin)
%GETTP_2SUPPORTPOINTS  Calculates peak period given sign. wave height in 2
%stations
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getTp_2SupportPoints(varargin)
%
%   Input: For <keyword,value> pairs call getTp_2SupportPoints() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getTp_2SupportPoints
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

% $Id: getTp_2Stations.m 13138 2017-01-20 15:31:34Z bieman $
% $Date: 2017-01-20 23:31:34 +0800 (Fri, 20 Jan 2017) $
% $Author: bieman $
% $Revision: 13138 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/bc/getTp_2Stations.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'HsELD',        [],     ...
    'HsBorkum',     []      ...
    );

OPT = setproperty(OPT, varargin{:});

%% Parameters per station

% Station information obtained from "Dune erosion - Product 3:
% Probabilistic dune erosion prediction method" WL|Delft
% Hydraulics/DUT/Alkyon 2007
%                           a       b  
StationInfo = {
    'Vlissingen',           3.86,   1.09;
    'Hoek van Holland',     3.86,   1.09;
    'IJmuiden',             4.67,   1.12; 
    'Den Helder',           4.67,   1.12; 
    'Eierlandse Gat',       4.67,   1.12; 
    'Steunpunt Waddenzee',  [],     [];
    'Borkum',               4.67,   1.12;
    };

% Be aware that the Tp parameters are only defined for 2 stations: Hoek van
% Holland (a = 3.86, b = 1.09) and Den Helder (a = 4.67, b = 1.12). The 
% other stations have been filled by nearest-neighbour

Station1Valid   = false;
Station2Valid   = false;

for iStation = 1:size(StationInfo,1)
    if strcmpi(StationInfo{iStation,1}, Station1)
        a1              = StationInfo{iStation,2}; 
        b1              = StationInfo{iStation,3};
        Station1Valid   = true;
    elseif strcmpi(StationInfo{iStation,1}, Station2)
        a2              = StationInfo{iStation,2}; 
        b2              = StationInfo{iStation,3};
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
    [Tp1, ~, ~] = getTp_2Stations(dTp, 0.57, waveHeight1, waveHeight2, 'Eierlandse Gat', 'Borkum');
    Tp2         = dTp + getTp_t(waveHeight2, a2, b2);
elseif strcmpi(Station2, 'Steunpunt Waddenzee')
    Tp1         = dTp + getTp_t(waveHeight1, a1, b1);
    [Tp2, ~, ~] = getTp_2Stations(dTp, 0.57, waveHeight1, waveHeight2, 'Eierlandse Gat', 'Borkum');
else
    Tp1         = dTp + getTp_t(waveHeight1, a1, b1);
    Tp2         = dTp + getTp_t(waveHeight2, a2, b2);
end

%% Interpolate

Tp  = lambda*Tp1 + (1-lambda)*Tp2;