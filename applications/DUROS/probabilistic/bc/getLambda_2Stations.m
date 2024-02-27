function [Lambda1, Lambda2, Station1, Station2, XIntersection, YIntersection] = getLambda_2Stations(varargin)
%GETLAMBDA_2STATIONS  Calculate lambda for profiles that are in between 2
%stations
%
%   Lambda is the relative distance to station 1 from the intersection of
%   the normal of the Jarkus profile and the line connecting the 2 stations
%
%   Be aware: a larger Lambda means a smaller distance to that station!
%
%   Syntax:
%   varargout = getLambda_2Stations(varargin)
%
%   Input: For <keyword,value> pairs call getLambda_2Stations() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getLambda_2Stations
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
% Created: 07 Mar 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: getLambda_2Stations.m 12038 2015-06-25 14:50:34Z geer $
% $Date: 2015-06-25 22:50:34 +0800 (Thu, 25 Jun 2015) $
% $Author: geer $
% $Revision: 12038 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/bc/getLambda_2Stations.m $
% $Keywords: $

%% Settings

OPT = struct(...
    'JarkusId',     [],         ...
    'Distance',     80000,      ...
    'RSPX',         [],         ...
    'RSPY',         [],         ... 
    'Angle',        [],         ...
    'JarkusURL',    jarkus_url,  ...
    'Station1',     [],         ...
    'Station2',     []          ...
    );

OPT = setproperty(OPT, varargin{:});

%% Determine Jarkus location

if ~isempty(OPT.JarkusId)
    % Get Jarkus info from NetCDF file
    IDs         = nc_varget(OPT.JarkusURL,'id');
    iLocation   = find(IDs == OPT.JarkusId)-1; % Target file is 0 based, where Matlab is 1 based
    RSPX        = nc_varget(OPT.JarkusURL,'rsp_x',iLocation,1);
    RSPY        = nc_varget(OPT.JarkusURL,'rsp_y',iLocation,1);
    Angle       = nc_varget(OPT.JarkusURL,'angle',iLocation,1);
    ExtendedX   = RSPX + OPT.Distance*cosd(90-Angle);
    ExtendedY   = RSPY + OPT.Distance*sind(90-Angle);
elseif ~isempty(OPT.RSPX) && ~isempty(OPT.RSPY) && ~isempty(OPT.Angle)
    % Use given Jarkus info
    RSPX        = OPT.RSPX;
    RSPY        = OPT.RSPY;
    ExtendedX   = RSPX + OPT.Distance*cosd(90-OPT.Angle);
    ExtendedY   = RSPY + OPT.Distance*sind(90-OPT.Angle);
else
    error('You need to specify either a Jarkus ID or a location (in RD coordinates) with an angle!')
end

%% Determine the two stations

% Station information obtained from "Dune erosion - Product 3:
% Probabilistic dune erosion prediction method" WL|Delft
% Hydraulics/DUT/Alkyon 2007
StationInfo = {
    'Vlissingen',           -7797,  380645; % SciDoc HydraRing
    'Hoek van Holland',     58748,  450830;
    'IJmuiden',             79249,  501800;
    'Den Helder',           98372,  549340; 
    'Eierlandse Gat',       106514, 587985;
    'Steunpunt Waddenzee',  150000, 621230;
    'Borkum',               221990, 621330
    };

XIntersection = [];
if (isempty(OPT.Station1) && isempty(OPT.Station2))
    [XIntersection, YIntersection] = polyintersect([StationInfo{:,2}],[StationInfo{:,3}],[RSPX, ExtendedX],[RSPY, ExtendedY]);
    if (isempty(XIntersection))
        [Lambda1, Lambda2] = deal(NaN);
        [Station1, Station2] = deal('');
        return;
    end
    [dum, distId] = sort(sqrt(([StationInfo{:,2}]-XIntersection).^2 + ([StationInfo{:,3}]-YIntersection).^2));
    station1Id = distId(1);
    availDistId = distId(sign(StationInfo{station1Id,2}-XIntersection) ~= sign([StationInfo{distId,2}]-XIntersection));
    station2Id = availDistId(1);
    
else
    [Station1Valid, station1Id] = ismember(OPT.Station1,StationInfo(:,1));
    [Station2Valid, station2Id] = ismember(OPT.Station2,StationInfo(:,1));
    
    if ~Station1Valid || ~Station2Valid
        error('Please specify valid station names!')
    end
    
end

Station1X = StationInfo{station1Id,2};
Station1Y = StationInfo{station1Id,3};
Station2X = StationInfo{station2Id,2};
Station2Y = StationInfo{station2Id,3};

if (isempty(XIntersection))
    % Interpolate both to the same grid
    XDummy      = linspace(RSPX, ExtendedX, 1000);
    JarkusLine  = interp1([RSPX ExtendedX], [RSPY ExtendedY], XDummy);
    StationLine = interp1([Station1X Station2X], [Station1Y Station2Y], XDummy);
    
    % Find intersection
    [XIntersection, YIntersection]  = intersection(XDummy, JarkusLine, StationLine);
end

Station1 = StationInfo{station1Id,1};
Station2 = StationInfo{station2Id,1};
    
% Calculate both Lambdas
Lambda1     = sqrt(sum(calculate_distance([Station2X XIntersection],[Station2Y YIntersection]).^2))/sqrt(sum(calculate_distance([Station1X Station2X],[Station1Y Station2Y]).^2));
Lambda2     = sqrt(sum(calculate_distance([Station1X XIntersection],[Station1Y YIntersection]).^2))/sqrt(sum(calculate_distance([Station1X Station2X],[Station1Y Station2Y]).^2));
end

function di = calculate_distance(x,y)
    di = sqrt(diff(x)^2 + diff(y)^2);
end
