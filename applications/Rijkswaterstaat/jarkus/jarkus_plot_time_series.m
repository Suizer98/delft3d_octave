function varargout = jarkus_plot_time_series(varargin)
%JARKUS_PLOT_TIME_SERIES  3D plot with sequence of jarkus transects in time
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = jarkus_plot_time_series(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_plot_time_series
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 14 Jun 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: jarkus_plot_time_series.m 4660 2011-06-14 13:11:17Z heijer $
% $Date: 2011-06-14 21:11:17 +0800 (Tue, 14 Jun 2011) $
% $Author: heijer $
% $Revision: 4660 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_plot_time_series.m $
% $Keywords: $

%%
OPT = struct(...
    'id', 7000308,...
    'year', []);

OPT = setproperty(OPT, varargin{:});

%%
if isempty(OPT.year)
    % all years
    tr = jarkus_transects(...
        'id', OPT.id);
else
    % selected years
    tr = jarkus_transects(...
        'id', OPT.id,...
        'year', OPT.year);
end

% add missing values by linear interpolation in cross-shore direction
tr = jarkus_interpolatenans(tr);
    tr = jarkus_interpolate_landward(tr);
    tr = jarkus_interpolate_landward(tr,...
        'method2', 'nearest',...
        'extrap2', true);
% transform date info to years
years = year(tr.time + datenum(1970,1,1));

%%
altitude = squeeze(tr.altitude);
% find cross-shore points where data is available (in any of the years)
csid = sum(~isnan(altitude)) ~= 0;
altitude = altitude(:,csid)';
[years cross_shore] = meshgrid(years, tr.cross_shore(csid));

plot3(years, cross_shore, altitude)
set(gca, 'YDir', 'reverse')

xlabel('time [years]')
ylabel('cross-shore coordinate [m]')
zlabel('altitude [m]')
title(['transect ' num2str(OPT.id)])

set(gca,...
    'View', [-54.5 70])