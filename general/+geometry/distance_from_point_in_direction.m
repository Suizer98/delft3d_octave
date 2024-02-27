function [dist] = distance_from_point_in_direction(point_x,point_y,rad,x,y)
%DISTANCE_FROM_POINT_IN_DIRECTION calculates the distance
%
%   More detailed description goes here.
%
%   Syntax:
%   [distance,xD,yD,segmentInd,type] = distance_from_polyline(x,y,xv,yv)
%
%   Input: For <keyword,value> pairs call DISTANCE_FROM_POLYLINE() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%     %% Example 1
%
%         point_x = 3;
%         point_y = 7;
%         x = 10*rand(20);
%         y = 10*rand(20);
%         rad = 0;
%         d = geometry.distance_from_point_in_direction(point_x,point_y,rad,x,y);
%         hs = scatter(x(:),y(:),10,d(:));
%         line('xdata',point_x,'ydata',point_y,'markersize',30,'marker','o');
%         hl = line('xdata',point_x + [-10 10] * sin(rad),'ydata',point_y + [-10 10] * cos(rad));
%         colorbar;
%         clim([-8 8])
%         axis([0 10 0 10])
%         for rad = (0:1/24:6)*pi
%             d = geometry.distance_from_point_in_direction(point_x,point_y,rad,x,y);
%             set(hs,'cdata',d(:))
%             set(hl,'xdata',point_x + [-10 10] * sin(rad),'ydata',point_y + [-10 10] * cos(rad));
%             drawnow
%         end

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

% $Id: distance_from_point_in_direction.m 7543 2012-10-19 14:58:52Z boer_g $
% $Date: 2012-10-19 22:58:52 +0800 (Fri, 19 Oct 2012) $
% $Author: boer_g $
% $Revision: 7543 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+geometry/distance_from_point_in_direction.m $
% $Keywords: $

%% input check

assert(isequal(size(x),size(y)));
assert(numel(point_x) == 1);

% http://www.topcoder.com/tc?d1=tutorials&d2=geometry1&module=Static#dot_product
vnorm         = @(A)   sqrt(A(1)^2 + A(2)^2);
vdot          = @(A,B) A(1).*B(1) + A(2).*B(2);

A = [sin(rad) cos(rad)];

dist = arrayfun(@(Bx,By) vdot(A,[Bx,By])/vnorm(A),x - point_x,y - point_y);