function ind = getGridpointsNearPolygon(x,y,polygon)
%GETGRIDPOINTSNEARPOLYGON  Returns indices of grid points near/inside polygon
%
%   GETGRIDPOINTSNEARPOLYGON returns indices of the input grid specified by
%   matrices x and y of the grid points that are in the area of interest
%   specified by a polygon. It returns not only indices of points inside
%   the polygon, but also around (about 1 cell) the polygon. It works also 
%   for lines, or tracks. This function is very useful when performing 
%   interpolations of 2D-data to a line to limit the amount of data that 
%   goes into the interpolation function.
%
%   Syntax:
%   ind = getGridPointsNearPolygon(x,y,polygon)
%
%   Input:
%   x,y     = matrices with x and y coordinates
%   polygon = Nx2 matrix with x,y coordinates of polygon
%
%   Output:
%   ind = indices of found grid points
%
%   Example 1 (for a polygon):
%   [x,y] = meshgrid(1:50, 1:50);
%   polygon = [10 10; 40 20; 20 40; 10 10];
%   ind = getGridPointsNearPolygon(x,y,polygon);
%   figure; grid_plot(x,y,'k'); hold on;
%   plot(polygon(:,1),polygon(:,2),'b');
%   plot(x(ind),y(ind),'xr');
% 
%   Example 2 (for a line):
%   [x,y] = meshgrid(1:50, 1:50);
%   line = [10 10; 40 40.1]
%   ind = getGridPointsNearPolygon(x,y,line);
%   figure; grid_plot(x,y,'k'); hold on;
%   plot(line(:,1),line(:,2),'b');
%   plot(x(ind),y(ind),'xr');
% 
%   See also INPOLYGON, NC_VARGET_RANGE2D

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl	
%
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
% Created: 28 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: getGridpointsNearPolygon.m 3760 2010-12-28 14:55:04Z mol $
% $Date: 2010-12-28 22:55:04 +0800 (Tue, 28 Dec 2010) $
% $Author: mol $
% $Revision: 3760 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/getGridpointsNearPolygon.m $
% $Keywords: $

%% Input checks
if nargin~=3
    error('Not enough input arguments specified.');
end

if ~isequal(size(x),size(y))
    error('x and y must be matrices of equal size.');
end

if size(polygon,2)~=2
    error('Polygon must be a 2xN matrix, i.e. [x1 y1; x2 y2; etc]');
end

%% Find closest grid point for each point of the polygon
for ii = 1:size(polygon,1)
    dists=sqrt( (x(:)-polygon(ii,1)).^2 + (y(:)-polygon(ii,2)).^2 );
    [dum,closestID(ii)]=min(dists);
end
closestID=unique(closestID);

%% Find m,n indices and extend with the 8 surround grid points
[m,n] = ind2sub(size(x),closestID);
m = [m m   m   m-1 m-1 m-1 m+1 m+1 m+1];
n = [n n-1 n+1 n-1 n   n+1 n-1 n   n+1];

%% Check if m,n indices are not beyond grid size
m = min(m, repmat(size(x,1),1,length(m)));
m = max(m, repmat(1,1,length(m)));
n = min(n, repmat(size(x,2),1,length(n)));
n = max(n, repmat(1,1,length(n)));

%% Create list of the unique indices
ind = unique(sub2ind(size(x),m(:),n(:)));

%% Find convex hull of these points
ind2 = convhull(double(x(ind)),double(y(ind)));

%% Find the grid points that are inside the convex hull
ind = find(inpolygon(x,y,x(ind(ind2)),y(ind(ind2))));