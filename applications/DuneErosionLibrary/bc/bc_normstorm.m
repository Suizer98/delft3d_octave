function [h Hs Tp] = bc_normstorm(varargin)
%BC_NORMSTORM  Returns normative storm conditions for the Dutch coast (WL|Delft Hydraulics, 2007, project H4357, product 3)
%
%   Returns normative storm conditions for the Dutch coast (WL|Delft
%   Hydraulics, 2007, project H4357, product 3) given a certain frequency
%   of occurrence and a location. Locations can be provided by an RD
%   coordinate or WGS84 coordinate or JARKUS id. Strings are interpreted as
%   location names and translated to coordinates using Google Maps. Data is
%   interpolated over the lines connecting the points with known data. The
%   point on the line nearest to the requested point is used. If no
%   location is provided, results for all known point is given.
%
%   Syntax:
%   [h Hs Tp] = bc_normstorm(varargin)
%
%   Input:
%   varargin  = freq:       Normative frequency of occurrence
%               loc:        Location along Dutch coast (RD/WGS84
%                           coordinates, jarkus id or location name)
%               loc_type:   Type of coordinates to use (RD/WGS84)
%               threshold:  Threshold interpolation distance to show
%                           warning
%               plot:       Boolean indicating whether interpolation result
%                           should be plotted
%
%   Output:
%   h         = Normative surge level above MSL
%   Hs        = Normative wave height
%   Tp        = Normative wave period
%
%   Example
%   [h Hs Tp] = bc_normstorm()
%   [h Hs Tp] = bc_normstorm('freq', 1/4000)
%   [h Hs Tp] = bc_normstorm('loc', [68780 443840])
%   [h Hs Tp] = bc_normstorm('loc', [4.1323 51.9763], 'loc_type', 'WGS84')
%   [h Hs Tp] = bc_normstorm('loc', 'Hoek van Holland')
%   [h Hs Tp] = bc_normstorm('loc', 'Den Hoorn, Terschelling', 'freq', 1/4000)
%
%   See also bc_stormsurge, str2coord, interp2line

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
% Created: 24 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: bc_normstorm.m 11788 2015-03-06 08:41:13Z geer $
% $Date: 2015-03-06 16:41:13 +0800 (Fri, 06 Mar 2015) $
% $Author: geer $
% $Revision: 11788 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/bc/bc_normstorm.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'freq', 1e-4, ...
    'loc_type', 'RD', ...
    'loc', [], ...
    'threshold', 5e4, ...
    'plot', false ...
);

OPT = setproperty(OPT, varargin{:});

%% maximum surge level

            % HvH       % IJ        % DH        % Eierland  % Borkum       
x       = [ 4.120131    4.555134    4.745326    4.798470    6.745590    ];
y       = [ 51.978539   52.463348   52.965441	53.190799   53.548319   ];

omega   = [ 1.95        1.85        1.60        2.25        1.85        ];
rho     = [ 7.237       5.341       3.254       0.500       5.781       ];
alpha   = [ 0.57        0.63        1.60        1.86        1.27        ];
sigma   = [ 0.0158      0.0358      0.9001      1.0995      0.5350      ];

Fe = OPT.freq*ones(1,length(omega));

h = sigma.*((omega./sigma).^alpha-log(Fe./rho)).^(1./alpha);

if any(h < omega)
    warning('Maximum surge level is outside validity range of probabilitic formulation');
end

%% maximum wave height
    
a       = [ 4.35        5.88        9.43        12.19       10.13       ];
b       = [ 0.6         0.6         0.6         0.6         0.6         ];
c       = [ 0.008       0.0254      0.68        1.23        0.57        ];
d       = [ 7           7           7           7           7           ];
e       = [ 4.67        2.77        1.26        1.14        1.58        ];
    
Hs = a+b.*h-c.*max(0, d-h).^e; 

%% maximum wave period

            % HvH       % DH
alpha   = [ 3.86        4.67    ];
beta    = [ 1.09        1.12    ];
    
Tp = alpha+beta.*Hs([1 3]); % This is a simplification of the actual relationship as indicated in the report. Use getTp_2Stations or getTp_2Stations2011 for a better approximation

%% interpolate to specific location

% convert coordinates
switch OPT.loc_type
    case 'RD'
        [x y] = convertCoordinates(x,y,'CS1.code',4326,'CS2.code',28992);
    case 'WGS84'
        % do nothing
    otherwise
        warning(['Coordinate type unknown, using WGS84 [' OPT.loc_type ']']);
end

% determine location
if ischar(OPT.loc)
    
    % translate with Google Maps
    name = [OPT.loc ', Nederland'];
    OPT.loc = str2coord([name ', Nederland']);
    OPT.loc_type = 'RD';
    if isempty(OPT.loc)
        warning(['Location not found [' name ']']);
    end
    
elseif length(OPT.loc) == 1 && all(OPT.loc > 1e6)
    
    % translate with jarkus data
    j = jarkus_transects('id', OPT.loc, 'output', {'x' 'y' 'cross_shore'});
    [m i] = min(abs(j.cross_shore));
    OPT.loc = [j.x(i) j.y(i)];
    OPT.loc_type = 'RD';
    
end

if OPT.plot
    figure; hold on;
    plot3(x, y, h, '-or');
    plot3(x, y, Hs, '-og');
    plot3(x([1 3]), y([1 3]), Tp, '-ob');
    
    hl = nc_plot_coastline;
    set(hl, 'Color', [.8 .8 .8]);
    
    plot(x, y, '-k');
    plot(x, y, '-k');
    plot(x([1 3]), y([1 3]), '-k');
    
    grid on; box on;
    view(10,80);
    legend({'Water level' 'Significant wave height' 'Peak wave period'},'Location','NorthEast');
end

if ~isempty(OPT.loc) && length(OPT.loc) == 2
    
    % interpolate data
    [h xc1 yc1 d1] = interp2line(x, y, h, OPT.loc(1), OPT.loc(2));
    [Hs xc2 yc2 d2] = interp2line(x, y, Hs, OPT.loc(1), OPT.loc(2));
    [Tp xc3 yc3 d3] = interp2line(x([1 3]), y([1 3]), Tp, OPT.loc(1), OPT.loc(2));
    
    if OPT.plot
        plot3([OPT.loc(1) xc1 xc1], [OPT.loc(2) yc1 yc1], [0 0 h], '-ok');
        plot3([OPT.loc(1) xc2 xc2], [OPT.loc(2) yc2 yc2], [0 0 Hs], '-ok');
        plot3([OPT.loc(1) xc3 xc3], [OPT.loc(2) yc3 yc3], [0 0 Tp], '-ok');
    end

    if any([d1 d2 d3] > OPT.threshold)
        warning(['Requested location exceeded the threshold distance from the known data [' ...
            num2str(max([d1 d2 d3])) ' > ' num2str(OPT.threshold) ']']);
    end
end
