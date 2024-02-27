function varargout = circle_of_a_sphere(lat_center,lon_center,radius,varargin)
%CIRCLE_OF_A_SPHERE coordinates on a circle defined as the intersection of a sphere and a plane
%
%   More detailed description goes here.
%
%   Syntax:
%   [lat_on_circle,lon_on_circle,OPT] = circle_of_a_sphere(lat_center,lon_center,radius,varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   circle_of_a_sphere
%     lat = 52;
%     lon = 4;
%     radius = [1:100000:1000000];
%     [lat_on_circle,lon_on_circle,OPT] = circle_of_a_sphere(lat,lon,radius);
%     KMLline(lat_on_circle',lon_on_circle')
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 12 Mar 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: circle_of_a_sphere.m 7286 2012-09-25 15:08:46Z tda.x $
% $Date: 2012-09-25 23:08:46 +0800 (Tue, 25 Sep 2012) $
% $Author: tda.x $
% $Revision: 7286 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+geometry/circle_of_a_sphere.m $
% $Keywords: $

%%
OPT.nSteps       = 16;
OPT.radius_units = 'm';

OPT = setproperty(OPT,varargin{:});

if nargin==0;
    varargout = {OPT};
    return;
end
%% code

radius_rad     = radius(:)/40075017*2*pi;

% % radius_nm      = radii'; % (jRadius);
% % % radius_deg = radius_km /111.2;
% % 
% % radius_rad    = radius /60 /360*2*pi;

lat_center    = lat_center(:)/360*2*pi;
lon_center    = lon_center(:)/360*2*pi;

azimuth       = linspace(0,2*pi,OPT.nSteps+1);
azimuth(end)  = [];
nCircles      = max(numel(radius),numel(lat_center));

if numel(lat_center) == 1;
    lat_center = repmat(lat_center,nCircles,OPT.nSteps);
    lon_center = repmat(lon_center,nCircles,OPT.nSteps);
else
    lat_center = repmat(lat_center,       1,OPT.nSteps);
    lon_center = repmat(lon_center,       1,OPT.nSteps);    
end

if numel(radius_rad) == 1;
    radius_rad = repmat(radius_rad,nCircles,OPT.nSteps);
else
    radius_rad = repmat(radius_rad,       1,OPT.nSteps);
end

azimuth       = repmat(azimuth,nCircles,1);


latRadians    = asin(sin(lat_center) .* cos(radius_rad) + cos(lat_center) .* sin(radius_rad) .* cos(azimuth));
lonRadians    = lon_center + atan2(sin(radius_rad) .* sin(azimuth), cos(lat_center) .* cos(radius_rad) - sin(lat_center) .* sin(radius_rad) .* cos(azimuth));

lat_on_circle = latRadians/2/pi*360;
lon_on_circle = lonRadians/2/pi*360;

varargout     = {lat_on_circle,lon_on_circle,OPT};