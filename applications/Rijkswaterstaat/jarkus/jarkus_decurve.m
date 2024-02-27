function transects_decurved = jarkus_decurve(transects, varargin)
%JARKUS_DECURVE  Removes spatial curvatures from a JARKUS results struct
%
%   Aligns all transects in a JARKUS results struct, resulting from the
%   jarkus_transect function, on the most seaward crossing of a certain
%   altitude. The x and y grids provided in the struct are modified
%   according to the alignment. The entire resulting profile can be turned
%   so it faces a certain direction (nautical convention).
%
%   Syntax:
%   transects_decurved = jarkus_decurve(transects, varargin)
%
%   Input:
%   transects   = struct with JARKUS transects resulting from the
%                   jarkus_transects function
%   varargin    = key/value pairs of optional parameters
%                 z         = altitude based on which aligning should take
%                               place (default: 0)
%                 angle     = angle over which result should be turned,
%                               nautical convention (default: 0)
%
%   Output:
%   transects   = struct with modified JARKUS data
%
%   Example
%   transects = jarkus_decurve(transects, 'z', 5, 'angle', 270)
%
%   See also jarkus_transects findCrossings

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Bas Hoonhout
%
%       bas@hoonhout.com
%
%       Stevinweg 1
%       2628CN Delft
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
% Created: 21 Dec 2009
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id: jarkus_decurve.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_decurve.m $
% $Keywords$

%% settings

OPT = struct( ...
    'z', 5, ...
    'angle', 0 ...
);

OPT = setproperty(OPT, varargin{:});

% allocate result variable
transects_decurved = transects;

%% check

if ~jarkus_check(transects, 'id', 'x', 'y', 'cross_shore', 'altitude')
    error('Invalid jarkus transect structure');
end

%% align transects

% allocate new grid
x = zeros(1,length(transects.id));
y = zeros(1,length(transects.id));
distances = zeros(1,length(transects.id));

% set time counter (not used)
it = 1;

% loop through transects
for i = 1:length(transects.id)
    
    % select transect and squeeze data
    altitude = squeeze(transects.altitude(it,i,:))';
    cross_shore = squeeze(transects.cross_shore(it,:));
    xgrid = squeeze(transects.x(i,:));
    ygrid = squeeze(transects.y(i,:));
    
    % skip nan's
    notnan = ~isnan(altitude);
    
    if any(notnan)
        
        % determine alignment point
        crossing = max(findCrossings( ...
            cross_shore(notnan), ...
            altitude(notnan), ...
            [   min(cross_shore(notnan)) ...
                max(cross_shore(notnan))    ], ...
            [   OPT.z OPT.z     ] ...
        ));

        if ~isempty(crossing)

            % shift altitudes to fit cross-shore grid such that alignment
            % point is located at origin
            cross_shore_shift = cross_shore+crossing;
            altitude_shift = interp1(cross_shore(notnan), altitude(notnan), cross_shore_shift(notnan), 'linear');
            transects_decurved.altitude(it,i,notnan) = altitude_shift;
            
            % calculate spacial alignment point location
            x(i) = interp1(cross_shore(notnan), xgrid(notnan), crossing, 'linear');
            y(i) = interp1(cross_shore(notnan), ygrid(notnan), crossing, 'linear');
            
            % calculate distance between transects
            if i > 1
                if x(i-1) == 0 || y(i-1) == 0
                    distances(i) = 0;
                else
                    distances(i) = sqrt(diff(x(i-1:i))^2+diff(y(i-1:i))^2);
                end
            end
        end
    end
end

% define new local grid
xgrid = meshgrid(cumsum(distances),transects_decurved.cross_shore)'-mean(cumsum(distances));
ygrid = meshgrid(transects_decurved.cross_shore,cumsum(distances))-mean(transects_decurved.cross_shore);

angle = OPT.angle./180.*pi;

if angle ~= 0
    
    % translate to radial coordinates
    rgrid = sqrt(xgrid.^2+ygrid.^2);
    agrid = sign(asin(xgrid./rgrid)).*acos(ygrid./rgrid);

    % turn
    agrid = agrid-angle;

    % translate back to cartasian coordinates
    xgrid = rgrid.*sin(agrid);
    ygrid = rgrid.*cos(agrid);
    
end

% create new global grid
transects_decurved.x = mean(mean(transects.x))-xgrid;
transects_decurved.y = mean(mean(transects.y))+ygrid;