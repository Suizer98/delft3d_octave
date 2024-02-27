function [xmin xmax ymin ymax] = xb_grid_crop(x, y, z, varargin)
%XB_GRID_CROP  Automatically crops grid minimzing the number of NaN's and specifies extent of cropped area
%
%   Returns the extent of a cropped grid within a supplied grid. The
%   cropped area can be supplied by a vector indicating the origin, width
%   and height of the area. If no area is supplied, the largest area with a
%   minimum of NaN's (approximately) is used.
%
%   TODO: optimize the auto-crop algorithm
%
%   Syntax:
%   [xmin xmax ymin ymax] = xb_grid_crop(x, y, z, varargin)
%
%   Input:
%   x           = x-coordinates of grid to be cropped
%   y           = y-coordinates of grid to be cropped
%   z           = elevations of grid to be cropped
%   varargin    = crop:     vector like [x y w h] containing the origin,
%                           width and height of the cropped area
%
%   Output:
%   xmin        = minimum x-coordinate of cropped area
%   xmax        = maximum x-coordinate of cropped area
%   ymin        = minimum y-coordinate of cropped area
%   xmax        = maximum y-coordinate of cropped area
%
%   Example
%   [xmin xmax ymin ymax] = xb_grid_crop(x, y, z)
%   [xmin xmax ymin ymax] = xb_grid_crop(x, y, z, 'crop', [x0 y0 w h])
%
%   See also xb_generate_grid, xb_grid_extent

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
% Created: 15 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_grid_crop.m 3687 2010-12-17 09:52:38Z hoonhout $
% $Date: 2010-12-17 17:52:38 +0800 (Fri, 17 Dec 2010) $
% $Author: hoonhout $
% $Revision: 3687 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_crop.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'crop', [] ...
);

OPT = setproperty(OPT, varargin{:});

%% determine crop position

if isempty(OPT.crop)
    OPT.crop = [0 0 Inf Inf];
    
    n = ~isnan(z);
    
    [cellsize xmin xmax] = xb_grid_resolution(x, y, 'maxsize', 100*1024);
    
    S_max = 0;
    for x1 = xmin:cellsize:xmax
        i = x>=x1&x<x1+cellsize&n;
        
        if ~any(any(i)); continue; end;
        
        y1 = min(y(i));
        y2 = max(y(i));
        
        j1 = y>=y1&y<y1+cellsize&n;
        j2 = y>=y2&y<y2+cellsize&n;
        
        if ~any(any(j1)) || ~any(any(j2)); continue; end;
        
        x2 = min([max(x(j1)) max(x(j2))]);
        
        x0 = min([x1 x2]);
        y0 = min([y1 y2]);
        w = abs(diff([x1 x2]));
        h = abs(diff([y1 y2]));
        
        % calculate number of non-nan's in selection
        S = sum(sum(x>=x0&x<x0+w&y>=y0&y<=y0+h&n));
        
        if S > S_max
            S_max = S;
            OPT.crop = [x0 y0 w h];
        end
    end
end

%% crop grid

xmin = OPT.crop(1);
ymin = OPT.crop(2);
xmax = OPT.crop(1)+OPT.crop(3);
ymax = OPT.crop(2)+OPT.crop(4);

