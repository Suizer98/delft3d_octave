function wind = slamfat_wind_old(varargin)
%SLAMFAT_WIND  Generates a wind time series with varying gustiness
%
%   Generates a wind time series based on a mean wind speed and
%   corresponding standard deviation. Also the length of the gusts can
%   be influenced by a mean and standard deviation.
%   All parameters can be time-varying by defining a vector of durations
%   rather than a single duration value. The total time series will have
%   the length equal to the sum of the durations. For each block, wind
%   speed and gust length can be provided. Scalar values are reused through
%   the entire time series.
%
%   Syntax:
%   wind = slamfat_wind(varargin)
%
%   Input:
%   varargin  = f_mean:     scalar or vector with mean wind speeds
%               f_sigma:    scalar or vector with standard deviation of
%                           wind speeds
%               l_mean:     scalar or vector with mean gust lengths
%               l_sigma:    scalar or vector with standard deviation of
%                           gust lengths
%               duration:   scalar or vector with the duration of the time
%                           series or stationairy blocks in non-stationairy
%                           time series
%               dt:         time step in resulting time series
%               block:      length of blocks that result from number
%                           generator (numerical parameter)
%
%   Output:
%   wind = vector with wind speeds for each given time step dt
%
%   Example
%   wind = slamfat_wind;
%   wind = slamfat_wind('f_mean', 8.3);
%   wind = slamfat_wind('f_mean', [3 4 5 3], 'duration', 3600*ones(1,4))
%
%   See also slamfat_core

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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
% Created: 25 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: slamfat_wind_old.m 9884 2013-12-16 09:30:07Z sierd.devries.x $
% $Date: 2013-12-16 17:30:07 +0800 (Mon, 16 Dec 2013) $
% $Author: sierd.devries.x $
% $Revision: 9884 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT/slamfat_wind_old.m $
% $Keywords: $

%% read settings

OPT = struct(           ...
    'f_mean',   5,      ...
    'f_sigma',  2.5,    ...
    'l_mean',   4,      ...
    'l_sigma',  4,      ...
    'duration', 3600,   ...
    'dt',       0.05,   ...
    'block',    1000        );

OPT = setproperty(OPT, varargin);

%% prepare for non-stationairy conditions

if length(OPT.duration) > 1
    if length(OPT.f_mean)  == 1; OPT.f_mean  = repmat(OPT.f_mean, 1,length(OPT.duration)); end;
    if length(OPT.f_sigma) == 1; OPT.f_sigma = repmat(OPT.f_sigma,1,length(OPT.duration)); end;
    if length(OPT.l_mean)  == 1; OPT.l_mean  = repmat(OPT.l_mean, 1,length(OPT.duration)); end;
    if length(OPT.l_sigma) == 1; OPT.l_sigma = repmat(OPT.l_sigma,1,length(OPT.duration)); end;
end

%% generate wind

wind = zeros(sum(round(OPT.duration/OPT.dt)),1);

for i = 1:length(OPT.duration)
    n_wind  = round(OPT.duration(i)/OPT.dt);
    n_start = sum(round(OPT.duration(1:i-1)/OPT.dt)) + 1;
    
    f_series = [];
    l_series = [];

    while sum(l_series) < OPT.duration
        f_series = [f_series     normrnd(OPT.f_mean(i), OPT.f_sigma(i), OPT.block, 1)    ]; 
        l_series = [l_series max(normrnd(OPT.l_mean(i), OPT.l_sigma(i), OPT.block, 1), 0)];
    end

    n_series = round(l_series / OPT.dt);
    idx      = find(cumsum(n_series)>=n_wind,1,'first');

    f_series = f_series(1:idx);
    n_series = n_series(1:idx);
    
    n = n_start;
    for j = 1:length(n_series)
        n_next = min(n+n_series(j), n_start+n_wind);
        wind(n:n_next) = f_series(j);
        n = n_next;
    end
end

wind(wind<0) = 0;
