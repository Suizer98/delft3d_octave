function [mapurls, minx, maxx, miny, maxy] = grid_orth_identifyWhichMapsAreInPolygon(OPT, polygon, ah)
%GRID_ORTH_IDENTIFYWHICHMAPSAREINPOLYGON  Identifies which netcdf tiles are located inside a polygon (partly or as a whole).
%
% See also: grid_2D_orthogonal

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: grid_orth_identifyWhichMapsAreInPolygon.m 5075 2011-08-17 10:32:38Z boer_g $
% $Date: 2011-08-17 18:32:38 +0800 (Wed, 17 Aug 2011) $
% $Author: boer_g $
% $Revision: 5075 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_identifyWhichMapsAreInPolygon.m $
% $Keywords: $

 OPT.debug = 0;

%% Step 1: find all patch objects from the mapwindow and store their xdata and ydata in the variable maps
if nargin == 3
    ah   = gca;
    objs = findobj(ah, 'type', 'patch');
    maps = [get(objs, 'XData') get(objs, 'YData')];
else
    objs = OPT.urls;
    
    for i = 1:length(OPT.urls)
        maps{i,1} = [OPT.x_ranges{i}(1); OPT.x_ranges{i}(2); OPT.x_ranges{i}(2); OPT.x_ranges{i}(1); OPT.x_ranges{i}(1)];
        maps{i,2} = [OPT.y_ranges{i}(1); OPT.y_ranges{i}(1); OPT.y_ranges{i}(2); OPT.y_ranges{i}(2); OPT.y_ranges{i}(1)];
    end
end

%% Step 2: identify which of the fixed maps lie whole or partially inpolygon initialise variables
[mapurls, minx, maxx, miny, maxy] = deal([]);
include = 0;
for i = 1:length(maps)
    % include if a fixed map and polygon have an intersection
    
    
    if OPT.debug
     TMP = figure;
     plot(polygon(:,1),polygon(:,2))
     hold on
     plot(maps{i,1},maps{i,2})
     pausedisp
     try
     close(TMP)
     end
    end
    
    [xcr, zcr] = polyintersect(maps{i,1},maps{i,2},polygon(:,1),polygon(:,2)); %#ok<*NASGU>
    %[xcr, zcr] = polyintersect                   (maps{i,1},maps{i,2},polygon(:,1),polygon(:,2)); %#ok<*NASGU>
    
    if ~isempty(xcr)
        include = 1;
    end
    
    % include if a fixed map lies within the polygon
    if inpolygon(maps{i,1},maps{i,2},polygon(:,1),polygon(:,2));
        include = 2;
    end
    
    % include if a polygon lies within a fixed map
    if inpolygon(polygon(:,1),polygon(:,2),maps{i,1},maps{i,2});
        include = 3;
    end
    
    % see if based on the above there is something to include
    if include > 0 %& (~isempty(strfind(get(objs(i),'tag'),'vaklodingenKB'))|~isempty(strfind(get(objs(i),'tag'),'jarkusKB'))) %#ok<*OR2,*AND2>
        
        mapurls{end+1,1} = objs{i};
        minx    = min([minx; maps{i,1}]);
        maxx    = max([maxx; maps{i,1}]);
        miny    = min([miny; maps{i,2}]);
        maxy    = max([maxy; maps{i,2}]);
        
        include = 0;
    else
        include = 0;
    end
    
end
