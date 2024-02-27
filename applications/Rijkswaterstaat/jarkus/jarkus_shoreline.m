function [x y c distances] = jarkus_shoreline(transects, varargin)
%JARKUS_SHORELINE  Returns the location of the shoreline based on a set of jarkus transects
%
%   Calculates the shoreline location from a JARKUS result struct resulting
%   from the jarkus_transects function based on a certain vertical level.
%   The function returns the cross-shore coordinate of the shoreline for
%   each transect and the distances between the transects at the shoreline
%   as well.
%
%   Syntax:
%   [x y c distances] = jarkus_shoreline(transects, varargin)
%
%   Input:
%   transects   = struct with JARKUS transects resulting from the
%                   jarkus_transects function
%   varargin    = key/value pairs of optional parameters
%                   z     = altitude of shoreline (default: 0)
%
%   Output:
%   x           = x-coordinates of points at the shoreline
%   y           = y-coordinates of points at the shoreline
%   c           = cross-shore coordinate of points at the shoreline
%   distances   = distances between transects at shoreline
%
%   Example
%   [x y] = jarkus_shoreline(transects)
%
%   See also jarkus_transects

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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 28 Jan 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: jarkus_shoreline.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_shoreline.m $
% $Keywords: $

%% settings

OPT = struct( ...
    'z', 0 ...
);

OPT = setproperty(OPT, varargin{:});

%% check

if ~jarkus_check(transects, 'x', 'y', 'cross_shore', 'altitude')
    error('Invalid jarkus transect structure');
end

%% determine shoreline

% allocate result variables
x = nan(1,size(transects.altitude, 2));
y = nan(1,size(transects.altitude, 2));
c = nan(1,size(transects.altitude, 2));

% set time counter (not used)
it = 1;

% loop through transects
for i = 1:size(transects.altitude, 2)
    
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
            
            % calculate spacial alignment point location
            x(i) = interp1(cross_shore(notnan), xgrid(notnan), crossing, 'linear');
            y(i) = interp1(cross_shore(notnan), ygrid(notnan), crossing, 'linear');
            
            c(i) = crossing;
            
        end
    end
end

%% calculate distances

distances = sqrt(diff(x).^2+diff(y).^2);
