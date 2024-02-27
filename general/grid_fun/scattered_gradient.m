function [dx,dy] = scattered_gradient(x,y,z,L)
%SCATTERED_GRADIENT calculate spatial gradients on scattered data
%
%   Function to calculate spatial gradients on a scattered dataset.
%
%   Syntax:
%   [dx,dy] = scattered_gradient(x,y,z,L)
%
%   Input:
%   x  = m x 1 vector with x coordinates of scattered datapoints
%   y  = m x 1 vector with y coordinates of scattered datapoints
%   z  = m x 1 vector with target variable to calculate gradients on
%   L  = scalar, length scale at which to search for surrounding
%        datapoints. The gradient is averaged over all datapoints within
%        distance L from the analysis location.
%
%   Output:
%   dx = gradient in x direction
%   dy = gradient in y direction
%
%   Example
%   [dx,dy] = scattered_gradient(x,y,z,30);
%   figure;
%   scatter(x,y,20,z,'filled');
%   hold on;
%   axis equal;
%   quiver(x,y,dx,dy,'k-');
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Delft University of Technology
%       Max Radermacher
%       m.radermacher@tudelft.nl
%       Stevinweg 1
%       2628CN Delft
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
% Created: 01 Mar 2017
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: scattered_gradient.m 13194 2017-03-01 09:55:38Z m.radermacher.x $
% $Date: 2017-03-01 17:55:38 +0800 (Wed, 01 Mar 2017) $
% $Author: m.radermacher.x $
% $Revision: 13194 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/scattered_gradient.m $
% $Keywords: $

%% code

dx = nan(size(x));
dy = nan(size(y));

for i = 1:length(x)
    dst = sqrt((x-x(i)).^2+(y-y(i)).^2);
    ind = find(dst <= L & dst > 0);
    
    if length(ind) < 3
        continue
    end
    
    dxi = nan(length(ind),1);
    dyi = nan(length(ind),1);
    for j = 1:length(ind)
        gr = (z(ind(j))-z(i))/dst(ind(j));
        ang = atan2(y(ind(j))-y(i),x(ind(j))-x(i));
        dxi(j) = gr*cos(ang);
        dyi(j) = gr*sin(ang);
    end
    
    dx(i) = mean(dxi);
    dy(i) = mean(dyi);
end
