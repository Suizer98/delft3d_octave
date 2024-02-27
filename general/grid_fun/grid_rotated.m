function [x y pind] = grid_rotated(xs, ys, alfa, m, n, dm, dn)
%GRID_ROTATED  Create a rotated structured grid for interpolation of scattered data.
%
%   Creates a structured grid under a user-specified rotation angle, which fits tightly around a scattered 2D dataset.
%
%   Syntax:
%   [x y pind] = grid_rotated(xs, ys, alfa, m, n)
%
%   Input: For <keyword,value> pairs call grid_rotated() without arguments.
%   xs   =  Vector of x-coordinates of scattered dataset
%   ys   =  Vector of y-coordinates of scattered dataset
%   alfa =  User-specified rotation angle of output grid (degrees clockwise)
%   m    =  Number of gridpoints in North-South direction (before rotation)
%           Set to zero if gridsize is used
%   n    =  Number of gridpoints in East-West direction (before rotation)
%           Set to zero if gridsize is used
%   dm   =  Gridsize in north-south direction (before rotation) in units of scatter data
%           Set to zero if number of gridpoints is used
%   dn   =  Gridsize in East-West direction (before rotation) in units of  scatter data 
%           Set to zero is number of gridpoints is used
% 
%   Number of gridpoints overrules gridsize !
%
% 
% %   Output:
%   x    =  Matrix of x-coordinates of rotated structured grid
%   y    =  Matrix of y-coordinates of rotated structured grid
%   pind =  Indices of gridpoints outside of the scattered data boundingbox
%
%   Example:
%   Start with scattered dataset, interpolate values zs given at
%   coordinates (xs,ys) to a rotated structured grid under an angle of 45
%   degrees, with finally 100 gridpoints from SW to NE and 50 gridpoints
%   from NW to SE. 'Interpolated' values that fall outside the bounding box
%   of the scattered dataset are set to nan.
%
%   [x,y,pind] = grid_rotated(xs,ys,45,100,50,0,0);
%   zint = scatteredInterpolant(xs,ys,zs);
%   z = zint(x,y);
%   z(~pind) = nan;
%
%   UPDATE: 
%   Option to use gridsize instead of number gridpoints
% 
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Delft University of Technology
%       Max Radermacher
%
%       m.radermacher@tudelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
%   
%   Updated by 
%       B J T van der Spek | Royal HaskoningDHV
%       Bart-jan.van.der.spek@rhdhv.com
% 
% This library is free software: you can redistribute it and/or modify
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
% Created: 28 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)
% Updated: 21 Nov 2013 with Matlab version: 8.2.0.701 (R2013b)
% 

% $Id: grid_rotated.m 9733 2013-11-21 09:14:25Z bartjan.spek.x $
% $Date: 2013-11-21 17:14:25 +0800 (Thu, 21 Nov 2013) $
% $Author: bartjan.spek.x $
% $Revision: 9733 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/grid_rotated.m $
% $Keywords: $

%% Get boundingbox corner points
alfa = alfa*pi/180;
[~,minx] = min(xs);
[~,maxx] = max(xs);
[~,miny] = min(ys);
[~,maxy] = max(ys);
c = [xs(miny) ys(miny);...
    xs(minx) ys(minx);...
    xs(maxy) ys(maxy);...
    xs(maxx) ys(maxx)];

%% Translate cornerpoints to origin and de-rotate
ct = [c(:,1)-c(1,1) c(:,2)-c(1,2)];
cr = nan(size(ct));
cr(:,1) = ct(:,1).*cos(-alfa) + ct(:,2).*sin(-alfa);
cr(:,2) = -ct(:,1).*sin(-alfa) + ct(:,2).*cos(-alfa);

%% Get rectangular boundingbox in de-rotated coordinates
cmin = min(cr);
cmax = max(cr);

%% Create structured grid
% If m,n are defined, 
if m~=0 || n~=0
    xv = linspace(cmin(1),cmax(1),n);
    yv = linspace(cmin(2),cmax(2),m);
% If no m,n is defined, gridsize is used
else 
    cmax_tmp=cmax-mod((cmax-cmin),[dm dn])+[dm dn]; % make sure scatterdata is inside grid
    xv = cmin(1):dm:cmax_tmp(1);
    yv = cmin(2):dn:cmax_tmp(2);
end

[xr,yr] = meshgrid(xv,yv);
%% Rotate and translate back to original frame of reference
x = xr.*cos(alfa) + yr.*sin(alfa);
y = -xr.*sin(alfa) + yr.*cos(alfa);
x = x + c(1,1);
y = y + c(1,2);

%% Get indices of structured grid coordinates that fall outside the scattered data boundingbox
pind = inpolygon(x,y,c(:,1),c(:,2));
end

%% EOF