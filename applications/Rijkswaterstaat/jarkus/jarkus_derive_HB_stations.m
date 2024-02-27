function [stations lambda id angle_within_range transects_facing_seaward transects_in_range] = jarkus_derive_HB_stations(id, x_station, y_station, varargin)
%JARKUS_DERIVE_HB_STATIONS  Derive weight of hydraulic boundary condition stations
%
%   Function to derive the relevant boundary condition stations along the
%   coast to serve as boundary condition locations for one or more specific
%   jarkus transects. In addition, a weight factor is derived to indicate
%   the importance ratio of the two relevant stations.
%
%   Syntax:
%   [stations lambda id angle_within_range] = jarkus_derive_HB_stations(varargin)
%
%   Input:
%   id        = vector indicating the id's of the jarkus transects
%   x_station = x-coordinates of the boundary condition stations
%   y_station = y-coordinates of the boundary condition stations
%   varargin  = propertyname-propertyvalue pairs
%           'jarkus_url' : link to the netcdf file with the jarkus data
%           'virtual'    : boolean vector with same length as x_station and
%                          y_station indicating which station is virtual
%           'angle_range': maximum allowed diversion from perpendicular
%                          crossing between transect and station envelop
%   
%   Output:
%   stations           = 2-column matrix, rows correspond to the transects,
%                       columns to the two relevant stations (numbers correspond to coordinate
%                       order)
%   lambda             = factor for the weight of the first station 
%   angle_within_range = boolean vector indicating whether the
%                       transect-"station envelop" crossing is close enough
%                       to perpendicular based on the predefined angle
%                       range
%
%   Example
%   jarkus_derive_HB_stations
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
% Created: 29 Mar 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: jarkus_derive_HB_stations.m 4586 2011-05-23 14:51:15Z knipping $
% $Date: 2011-05-23 22:51:15 +0800 (Mon, 23 May 2011) $
% $Author: knipping $
% $Revision: 4586 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_derive_HB_stations.m $
% $Keywords: $

%%
OPT = struct(...
    'jarkus_url', jarkus_url,...
    'virtual', [],...
    'angle_range', 21 ...
    );

OPT = setproperty(OPT, varargin{:});

%% input check
if ~isempty(OPT.virtual)
    equaldims = sum(diff(cellfun(@length, {x_station y_station OPT.virtual}))) == 0;
    if ~equaldims
        error('The station coordinate vectors should have the same length as the boolean indicating the virtual station.')
    end
    if sum(OPT.virtual) > 1
        error('more than one virtual station is not supported')
    end
    virtual = true;
else
    OPT.virtual = true(size(x_station));
    virtual = false;
end

%%
tr = jarkus_transects(...
    'id', id,...
    'output', {'id' 'angle' 'rsp_x' 'rsp_y'});


if isempty(id)
    error('No transects found')
elseif length(tr.id) ~= length(id)
    warning('A part of the requested transects are not found.')
    id = tr.id;
end

%%
xr = [min(x_station) max(x_station)]; % x range
[a b xcr ycr] = deal(nan(size(tr.rsp_x)));
transects_in_range = true(size(xcr'));

for i = 1:length(tr.rsp_x)
    [a(i) b(i)] = xydegN2ab(tr.rsp_x(i), tr.rsp_y(i), tr.angle(i));
    try
        if ismember(tr.angle(i), [0 180])
            % north or south directed transect, no y = ax+b approach possible
            xcr(i) = tr.rsp_x(i);
            ycr(i) = interp1(x_station, y_station, xcr(i));
        else
            [xtmp ytmp] = findCrossings(xr, polyval([a(i) b(i)], xr), x_station, y_station);
            if isempty(xtmp)
                transects_in_range(i) = false;
%                 % no crossing, take closest HBC location
%                 [dummy ix] = min(sqrt((x_station - tr.rsp_x(i)).^2 + (y_station - tr.rsp_y(i)).^2));
%                 [xcr(i) ycr(i)] = deal(x_station(ix), y_station(ix));
            else
                % one or more crossings, take the one with shortest x
                % difference
                [dummy ix] = min(abs(xtmp - tr.rsp_x(i)));
                [xcr(i) ycr(i)] = deal(xtmp(ix), ytmp(ix));
            end
        end
    catch
        dbstopcurrent
    end
end

%% select only transects that face seaward
% derive angles of lines between stations
% positive clockwise 0 north
stationids = 1:length(x_station);
station_angle.station = xy2degN(x_station(1:end-1), y_station(1:end-1), x_station(2:end), y_station(2:end));
station1id = NaN(size(xcr));
station_angle.transect = NaN(size(xcr));
transects_facing_seaward = true(size(xcr'));
for i = 1:length(xcr)
    station1idtmp = find(xcr(i) - x_station > 0, 1, 'last');
    if isempty(station1idtmp)
        transects_facing_seaward(i) = false;
    else
        station1id(i) = station1idtmp;
        station_angle.transect(i) = station_angle.station(station1id(i));
    end
end
station2id = station1id + 1; % other station is the neighbouring one

%% indicate which transects are within the angle range from perpendicular
%% crossing the stations envelop
angle_within_range = ...
    (tr.angle > 270-OPT.angle_range + station_angle.transect & ...
    tr.angle < 270+OPT.angle_range + station_angle.transect | ...
    tr.angle < -90+OPT.angle_range + station_angle.transect & ...
    tr.angle < -90-OPT.angle_range + station_angle.transect)';

%% derive lambda
station_distance.station = sqrt((x_station(1:end-1) - x_station(2:end)).^2 + ((y_station(1:end-1) - y_station(2:end)).^2));
station_distance.transect = NaN(size(xcr));
lambda = NaN(size(xcr(:)));
distance1 = NaN(size(xcr));
for i = 1:length(xcr)
    if transects_facing_seaward(i)
        station_distance.transect(i) = station_distance.station(station1id(i));
        distance1(i) = sqrt((x_station(station1id(i)) - xcr(i))^2 + (y_station(station1id(i)) - ycr(i))^2);
        lambda(i) = 1 - distance1(i) / station_distance.transect(i);
    end
end

%% correct lambda in case of a virtual station
if virtual
    lambda_virtual1 = 1 - station_distance.station(OPT.virtual(2:end)) / (station_distance.station(OPT.virtual(1:end)) + station_distance.station(OPT.virtual(2:end)));
    % correct lambda for transects where the first station is virtual
    for i = find(station1id == stationids(OPT.virtual))
        rangelambda = [lambda_virtual1 0];
        station1id(i) = station1id(i) - 1;
        lambda(i) = interp1([0 station_distance.station(OPT.virtual(1:end))], rangelambda, distance1(i));
    end
    % correct lambda for transects where the second station is virtual
    for i = find(station2id == stationids(OPT.virtual))
        rangelambda = [1 lambda_virtual1];
        station2id(i) = station2id(i) + 1;
        lambda(i) = interp1([0 station_distance.station(OPT.virtual(2:end))], rangelambda, distance1(i));
    end
end

%% prepare output

stations = [station1id(:) station2id(:)];