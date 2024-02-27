function jarkus_googleearth(transects, varargin)
%JARKUS_GOOGLEEARTH  Plots jarkus transects into google earth
%
%   Creates a KML file that can be loaded in Google Earth from a struct
%   retrieved from the jarkus_transects function. It can handle multiple
%   transects and multiple times. The fields id, time, lat, lon and
%   altitude should be present.
%   This function is based on the original function of Kees den Heijer
%   jarkus_plot_in_googleEarth.
%
%   Syntax:
%   jarkus_googleearth(varargin)
%
%   Input:
%   varargin    = key/value pairs of optional parameters
%                 file  = filename of kml file (default: jarkus.kml)
%
%   Output:
%   none
%
%   Example
%   jarkus_googleearth(transects, 'file', 'Delfland2008.kml')
%
%   See also jarkus_googleearth

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 21 Jan 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: jarkus_googleearth.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_googleearth.m $
% $Keywords$

%% settings

OPT = struct( ...
    'file', 'jarkus.kml' ...
);

OPT = setproperty(OPT, varargin{:});

%% check

if ~jarkus_check(transects, 'id', 'time', 'lat', 'lon', 'altitude')
    error('Invalid jarkus transect structure');
end

%% interpolate nan's

transects = jarkus_interpolatenans(transects);

%% reshape lat, lon and altitude

transects.lat = shiftdim(repmat(transects.lat, [1 1 length(transects.time)]),2);
transects.lon = shiftdim(repmat(transects.lon, [1 1 length(transects.time)]),2);

transects.lat = reshape(transects.lat, length(transects.time)*length(transects.id), []);
transects.lon = reshape(transects.lon, length(transects.time)*length(transects.id), []);
transects.altitude = reshape(transects.altitude, length(transects.time)*length(transects.id), []);

%% reshape time

years = repmat(round(1970+transects.time/365), 1, length(transects.id));
timein  = datenum(years, 1, 1);
timeout = datenum(years+1, 1, 1);

%% built kml file

KMLline( ...
    transects.lat', ...
    transects.lon', ...
    transects.altitude', ...
    'timeIn', timein, ...
    'timeOut', timeout, ...
    'zScaleFun', @(z) (z+20)*5, ...
    'fileName', OPT.file ...
);