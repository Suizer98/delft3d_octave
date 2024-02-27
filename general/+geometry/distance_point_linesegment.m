function [E,CE,D,CD] = distance_point_linesegment(A,B,C)
%DISTANCE_POINT_LINESEGMENT  Euclidian distance between a point and a line segment
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = distance_point_linesegment(varargin)
%
%   Input: For <keyword,value> pairs call distance_point_linesegment() without arguments.
%   A = start of line [x,y] or [x,y,z]
%   B = end   of line [x,y] or [x,y,z]
%   C = point(s) to evaluate [x,y] or [x,y,z]
%
%   Output:
%   D  = point on infinite line through A and B closest to C
%   E  = point on line segment closest to C
%   CD = distance C-D
%   CE = distance C-E
%
%   Example
%     A = [2 2 0];
%     B = [6 6 3];
%     [X,Y,Z] = meshgrid(0:10,0:10,0);
%     C = [X(:) Y(:) Z(:)];
%     [E,CE,D,CD] = geometry.distance_point_linesegment(A,B,C);
% 
%     plot3([A(1) B(1)],[A(2) B(2)],[A(3) B(3)])
%     hold all
%     daspect([1 1 1])
%     grid on
% 
%     plot3([C(:,1) E(:,1)]',[C(:,2) E(:,2)]',[C(:,3) E(:,3)]','k')
%     scatter3(C(:,1),C(:,2),C(:,3),1250,CE,'.')
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 <COMPANY>
%       TDA
%
%       <EMAIL>
%
%       <ADDRESS>
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
% Created: 13 May 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: distance_point_linesegment.m 8928 2013-07-22 16:01:03Z tda.x $
% $Date: 2013-07-23 00:01:03 +0800 (Tue, 23 Jul 2013) $
% $Author: tda.x $
% $Revision: 8928 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/+geometry/distance_point_linesegment.m $
% $Keywords: $


%% code
dimensions = size(A,2);

switch dimensions
    case 2; dist2 = @(a,b) ((a(:,1)-b(:,1)).^2+(a(:,2)-b(:,2)).^2);
    case 3; dist2 = @(a,b) ((a(:,1)-b(:,1)).^2+(a(:,2)-b(:,2)).^2+(a(:,3)-b(:,3)).^2);
end
AC2 = dist2(A,C);
BC2 = dist2(B,C);
AB2 = dist2(A,B);
AB  = sqrt(AB2);
BD  = (BC2+AB2-AC2)/(2*AB);
AD  = AB-BD;
CD  = sqrt(AC2-AD.^2);
D   = repmat(B-A,size(C,1),1) .* repmat(AD/AB,1,dimensions) + repmat(A,size(C,1),1);
E   = D;
E(AD<0,:) = repmat(A,sum(AD<0),1);
E(BD<0,:) = repmat(B,sum(BD<0),1);

CE = sqrt(dist2(C,E));

