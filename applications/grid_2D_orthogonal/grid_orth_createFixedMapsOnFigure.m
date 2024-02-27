function ah = grid_orth_createFixedMapsOnFigure(ah, urls, varargin)
%GRID_ORTH_CREATEFIXEDMAPSONFIGURE  Plots geographical extents of ncfiles on figure.
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

% $Id: grid_orth_createFixedMapsOnFigure.m 4356 2011-03-26 13:59:39Z m.vankoningsveld@tudelft.nl $
% $Date: 2011-03-26 21:59:39 +0800 (Sat, 26 Mar 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 4356 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_createFixedMapsOnFigure.m $
% $Keywords: $

%% make the axes to use the current one
axes(ah);

%% for each available url get the actual_range and creat a patch
for i = 1:length(urls)
    x_range = nc_getvarinfo(urls{i}, 'x');
    y_range = nc_getvarinfo(urls{i}, 'y');
    
    if any(ismember({y_range.Attribute.Name}, 'actual_range')) && any(ismember({x_range.Attribute.Name}, 'actual_range'))

        x_range = str2num(x_range.Attribute(ismember({x_range.Attribute.Name}, 'actual_range')).Value); %#ok<*ST2NM>
        y_range = str2num(y_range.Attribute(ismember({y_range.Attribute.Name}, 'actual_range')).Value);

        ph = patch([x_range(1) x_range(2) x_range(2) x_range(1) x_range(1)], ...
                   [y_range(1) y_range(1) y_range(2) y_range(2) y_range(1)], 'r');

        drawnow
    end
    
    set(ph,'tag',urls{i});
end
box on
