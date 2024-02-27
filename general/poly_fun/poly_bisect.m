function theta = poly_bisect(x, y, varargin)
%poly_bisect  Finds the bisects of a polygon
%
%   Bisects at end and start points of a polygon are not strictly spoken
%   not defined. However this function returns the otrthogonals at end
%   points
%
%   Syntax:
%   theta = poly_bisect(x, y)
%
%   Input:
%   x     = polygon x coordinates
%   y     = polygon y coordinates
%
%   Output:
%   theta = angles of the bisects (rad)
%
%   Example 1
%     x = [1 0 -10];
%     y = [1 0  10];
%     offset = 5;
%     theta  = poly_bisect(x,y);
%     plot(x,y,...
%        [x;x] + offset .* kron([ 1;-1],sin(theta)),...
%        [y;y] + offset .* kron([-1; 1],cos(theta)))
%     daspect([1 1 1]);
%
%   Example 2
%     x      = [1.4810 1.2333 1.2218 1.3427 nan 2.3278 2.4430 2.4430 2.4199 2.1665 1.9706];
%     y      = [1.1572 1.6250 2.3779 2.7800 nan 2.5826 2.4583 2.2683 2.0563 1.8662 1.6323];
%     offset = 0.5;
%     theta  = poly_bisect(x,y);
%     plot(x,y,...
%         [x;x] + offset .* kron([ 1;-1],sin(theta)),...
%         [y;y] + offset .* kron([-1; 1],cos(theta)))
%     daspect([1 1 1]);
%
%   See also: 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com	
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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

% This tool is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: poly_bisect.m 7453 2012-10-11 15:14:37Z boer_g $
% $Date: 2012-10-11 23:14:37 +0800 (Thu, 11 Oct 2012) $
% $Author: boer_g $
% $Revision: 7453 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/poly_bisect.m $
% $Keywords: $

%%
OPT.isclosed = x(1)==x(end)&&y(1)==y(end);

OPT          = setproperty(OPT,varargin{:});

%%
dx           = diff(x(:));
dy           = diff(y(:));

% weight dx and dy by their distance
distance     = (dx.^2+dy.^2).^.5;
dx           = dx./distance;
dy           = dy./distance;

if OPT.isclosed
    % average dx and dy
    dx           = nanmean([dx([end 1:end]) dx([1:end 1])],2);
    dy           = nanmean([dy([end 1:end]) dy([1:end 1])],2);
else
    % average dx and dy
    dx           = nanmean([dx([1 1:end]) dx([1:end end])],2);
    dy           = nanmean([dy([1 1:end]) dy([1:end end])],2);
end

% calculate angles
theta        = atan(dy./dx);
theta(dx<0)  = theta(dx<0)-pi();

% reshape output to input
theta        = reshape(theta,size(x));
