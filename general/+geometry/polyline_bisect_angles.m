function theta_bisect = polyline_bisect_angles(x,y)
%POLYLINE_BISECT_ANGLES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = polyline_bisect_angles(varargin)
%
%   theta is in radians and ranges from 0 - 2pi with 0 being up/north and
%   clockwise positive:
%     12 O'Clock:   0 pi
%      3 O'Clock: 1/2 pi
%      6 O'Clock:   1 pi
%      9 O'Clock: 3/2 pi
%
%   Example
%     x = [...
%         0.55 0.40 0.35 0.31 0.29 0.25 0.22 0.17 0.14 0.13 0.12 0.13 0.16...
%         0.18 0.20 0.22 0.25 0.27 0.28 0.28 0.30 0.33 0.36 0.42 0.54 0.57...
%         0.58 0.58 0.57 0.51 0.46 0.45 0.45 0.48 0.52 0.56 0.65 0.69 0.76...
%         0.80 0.81 0.80 0.79 0.80 0.77 0.74 0.69 0.60 0.55 0.50 0.45 0.40];
%     y = [...
%         0.16 0.13 0.14 0.21 0.29 0.40 0.48 0.49 0.49 0.48 0.45 0.42 0.42...
%         0.42 0.42 0.42 0.44 0.46 0.49 0.53 0.60 0.63 0.64 0.65 0.64 0.63...
%         0.60 0.58 0.56 0.55 0.56 0.59 0.61 0.65 0.69 0.72 0.73 0.73 0.69...
%         0.65 0.60 0.55 0.50 0.45 0.40 0.35 0.31 0.23 0.22 0.23 0.24 0.23];
% 
%     theta_segment = geometry.polyline_segment_angles(x,y);
%     theta_bisect  = geometry.polyline_bisect_angles (x,y);
% 
%     offset = 0.01;
% 
%     h1 = plot(x,y,'g-o');
%     hold on
%     h2 = plot(...
%         [x(1:end-1); x(1:end-1) + offset * sin(theta_segment)],...
%         [y(1:end-1); y(1:end-1) + offset * cos(theta_segment)],'r-',...
%         'lineWidth',2);
%     h3 = plot(...
%         [x;  x + offset * sin(theta_bisect)],...
%         [y;  y + offset * cos(theta_bisect)],'k-',...
%         'lineWidth',2);
%     text(x,y,cellfun(@num2str,num2cell(1:length(x)),'UniformOutput',false))
%     axis equal
%     legend([h1(1),h2(1),h3(1)],'polyline','segment angle','bisect')
%
%   See also: polyline_segment_angles
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
% Created: 01 Oct 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: polyline_bisect_angles.m 7470 2012-10-12 11:12:30Z tda.x $
% $Date: 2012-10-12 19:12:30 +0800 (Fri, 12 Oct 2012) $
% $Author: tda.x $
% $Revision: 7470 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+geometry/polyline_bisect_angles.m $
% $Keywords: $

%% code
theta_segment             = geometry.polyline_segment_angles(x,y);
theta_1                   = mod(theta_segment([1   1:end]) - pi,2*pi);
theta_2                   =     theta_segment([1:end end]);
theta_2(theta_2<theta_1)  = theta_2(theta_2<theta_1) + 2*pi;
theta_bisect              = (theta_1 + theta_2)/2;
