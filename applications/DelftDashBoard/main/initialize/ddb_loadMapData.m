function ddb_loadMapData
%DDB_LOADMAPDATA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_loadMapData
%
%   Input:

%
%
%
%
%   Example
%   ddb_loadMapData
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_loadMapData.m 7932 2013-01-18 21:56:06Z jay.veeramony.x $
% $Date: 2013-01-19 05:56:06 +0800 (Sat, 19 Jan 2013) $
% $Author: jay.veeramony.x $
% $Revision: 7932 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/initialize/ddb_loadMapData.m $
% $Keywords: $

%% Loading some additional map data
handles=getHandles;

% Earth colormap
load([handles.settingsDir 'colormaps' filesep 'earth.mat']);
handles.mapData.colorMaps.earth=earth;

% World coastline
load([handles.settingsDir 'geo',filesep,'worldcoastline.mat']);
handles.mapData.worldCoastLine5000000(:,1)=wclx;
handles.mapData.worldCoastLine5000000(:,2)=wcly;

% Cities
c=load([handles.settingsDir 'geo' filesep 'cities.mat']);
for i=1:length(c.cities)
    handles.mapData.cities.lon(i)=c.cities(i).Lon;
    handles.mapData.cities.lat(i)=c.cities(i).Lat;
    handles.mapData.cities.name{i}=c.cities(i).Name;
end

setHandles(handles);

