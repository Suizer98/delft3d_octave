function varargout = xb_gui_crop(x,y,z,varargin)
%XB_GUI_CROP  Rotate and crop bathymetry
%
%   Aligns the coastline to the y-axis and enables the used to visually rop
%   the bathymetry. The result is the rotated, cropped bathymetry.
%
%   Syntax:
%   varargout = xb_gui_crop(x,y,z,varargin)
%
%   Input:
%   x         = matrix with x-values
%   y         = matrix with y-values
%   z         = matrix with z-values
%   varargin  = none
%
%   Output:
%   varargout = rotated and cropped versions of the x, y and z matrices
%
%   Example
%   [xc yc zc] = xb_gui_crop(x,y,z)
%
%   See also xb_gui_mergebathy

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 08 Dec 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_gui_crop.m 5870 2012-03-22 11:02:37Z hoonhout $
% $Date: 2012-03-22 19:02:37 +0800 (Thu, 22 Mar 2012) $
% $Author: hoonhout $
% $Revision: 5870 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/xb_gui_crop.m $
% $Keywords: $

%% read settings

%% rotate grid

alfa = xb_grid_rotation(x,y,z);

[xr yr] = xb_grid_rotate(x,y,alfa);

%% crop grid

pobj = figure;

pcolor(xr,yr,z);

shading flat; axis equal;

uicontrol('Style', 'pushbutton', 'String', 'CROP',...
          'Position', [20 20 40 20],...
          'Callback', @crop);

set(pobj, 'UserData', {xr yr z});

xb_gui_dragselect(gca, 'fcn', @drawrect);

uiwait(pobj);

varargout = get(pobj, 'UserData');

close(pobj);

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawrect(obj, event, aobj, polx, poly)
    robj = findobj(aobj, 'Tag', 'crop');

    pos  = [min(polx) min(poly) max(polx)-min(polx) max(poly)-min(poly)];

    if ~isempty(robj)
        set(robj, 'Position', pos);
    else
        robj = rectangle('Position', pos, 'Parent', aobj, 'Tag', 'crop');
    end
end

function crop(obj, event)
    pobj = get(obj, 'Parent');
    aobj = findobj(pobj, 'Type', 'axes');

    robj = findobj(aobj, 'Tag', 'crop');

    ud = get(pobj, 'UserData');
    [xr yr z] = ud{:};

    if ~isempty(robj)
        pos     = get(robj, 'Position');

        [x1 x2 y1 y2 cellsize] = xb_grid_extent(xr, yr);

        % maximize grid size
        dd      = xb_grid_resolution(1:cellsize:pos(3), 1:cellsize:pos(4));

        % create output grid
        [xc yc] = meshgrid(pos(1)+[1:dd:pos(3)], pos(2)+[1:dd:pos(4)]);

        % interpolate grids to output grid
        zc      = xb_grid_interpolate(xr, yr, z, xc, yc);
    end

    set(pobj, 'UserData', {xc yc zc});

    uiresume(pobj);
end
