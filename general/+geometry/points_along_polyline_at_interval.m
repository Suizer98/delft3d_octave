function [x_regular,y_regular,theta,t] = points_along_polyline_at_interval(x,y,interval)
%POINTS_ALONG_POLYLINE_AT_INTERVAL  returns points spaced at a set inverval along a path
%
%   More detailed description goes here.
%
%   Syntax:
%   [x_regular,y_regular,theta_regular] = points_along_polyline_at_interval(x,y,interval)
%   
%
%   Output:
%   x_regular = x coordinate of regular spaced coordinates along path
%   y_regular = y coordinate of regular spaced coordinates along path
%   theta     = angle of path through point in radians
%
%   Example:
%       x = [3.9977 3.9055 4.2281 nan 5.9793 nan 6.6244 0.6106 0.9332 2.2696 3.2604]';
%       y = [2.2953 5.1901 5.5994 5.6579 5.3070 5.0146 7.0322 9.0205 8.4942 8.2310 9.0789]';    
%       [x_regular,y_regular,theta,t] = geometry.points_along_polyline_at_interval(x,y,1);
%       plot(x,y,'r-x','lineWidth',3)
%       hold on
%       plot(x_regular,y_regular,'b-o','lineWidth',2)
%       offset = 0.4;
%       plot([x_regular-offset*sin(theta) x_regular+offset*sin(theta)]',[y_regular+offset*cos(theta) y_regular-offset*cos(theta)]','g');
%       axis equal
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 28 Sep 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: points_along_polyline_at_interval.m 8783 2013-06-06 13:30:50Z tda.x $
% $Date: 2013-06-06 21:30:50 +0800 (Thu, 06 Jun 2013) $
% $Author: tda.x $
% $Revision: 8783 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+geometry/points_along_polyline_at_interval.m $
% $Keywords: $

%%
% POINTS_ALONG_POLYLINE_AT_INTERVAL 
%
% Note that the points are spaced over the original track. This does not mean
% this result is evenly spaced. eg:
% distance(x_regular,y_regular) is not constant

%% deal with nan separated lines segment
if ~(any(isnan(x)) || any(isnan(y)))
    % simple, no nan's
    [x_regular,y_regular,theta,t] = main_fun(x,y,interval);
else
    if iscolumn(x)
        dim = 2;
    elseif isrow(x)
        dim = 1;
    end
    
    cnt = cumsum(ones(size(x)));
    cnt(isnan(x)) = nan;
    cnt(isnan(y)) = nan;
    [cnt,x,y] = nansplit(cnt,x,y);
    [x_regular,y_regular,theta,t] = deal(cell(size(x)));
    for ii = 1:length(x)
        [x_regular{ii},y_regular{ii},theta{ii},t{ii}] = main_fun(x{ii},y{ii},interval);
        t{ii} = t{ii}+cnt{ii}(1)-1;
    end

    x_regular = nanjoin(x_regular,dim);
    y_regular = nanjoin(y_regular,dim);
    theta     = nanjoin(theta,dim);
    t         = nanjoin(t,dim);
end


function [x_regular,y_regular,theta,t] = main_fun(x,y,interval)
if numel(x) == 0
    x_regular = [];
    y_regular = [];
    theta     = [];
    t         = [];
    return
end

if numel(x) == 1
    x_regular = x;
    y_regular = y;
    theta     = nan;
    t         = 1;
    return
end

distance_along_polyline = distance(x,y);

xx = (0:interval:distance_along_polyline(end));
if iscolumn(x)
   xx = xx';
end
t  = nan(size(xx));
for ii = 1:length(xx);
    nn = find(xx(ii)<=distance_along_polyline,1,'first');
    if nn==1
        t(ii)         = 1;
    else
        c = (xx(ii) - distance_along_polyline(nn-1)) / ...
            (distance_along_polyline(nn) - distance_along_polyline(nn-1));
        t(ii) = nn+c-1; 
    end
end
x(end+1) = 2*x(end)-x(end-1);
y(end+1) = 2*y(end)-y(end-1);

x_regular = x(floor(t)) .* (1-rem(t,1)) + x(floor(t)+1) .* rem(t,1);
y_regular = y(floor(t)) .* (1-rem(t,1)) + y(floor(t)+1) .* rem(t,1);

dx = (x(floor(t)+1) - x(floor(t)));
dy = (y(floor(t)+1) - y(floor(t)));
theta = atan(dy./dx);
theta(dx<0) = theta(dx<0)-pi();
