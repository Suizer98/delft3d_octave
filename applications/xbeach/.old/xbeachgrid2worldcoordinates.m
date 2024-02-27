function [xworld yworld] = xbeachgrid2worldcoordinates(x,y,alfa,xori,yori)
%XBEACHGRID2WORLDCOORDINATES  Convert XBeach grid to world coordinates.
%
%   Convert x and y values on the XBeach calculation grid to world
%   coordinates (using the same alfa, xori and yori as defined in
%   params.txt).
%   Use worldcoordinates2xbeachgrid if you want to convert world
%   coordinates to grid coordinates.
%
%   The computation is a simple matrix calculation A*b = c where
%   A = [cos(alpha) sin(alpha);-sin(alpha) cos(alpha)]
%   b = [x; y]
%   c = [xworld; yworld]
%
%   Syntax:
%   [xworld yworld] = xbeachgrid2worldcoordinates(x,y,alfa,xori,yori)
%
%   Input:
%   x      = scalar, vector or array with XBeach x coordinates
%   y      = scalar, vector or array with XBeach y coordinates
%   alfa   = rotational angle of the XBeach grid (in degrees)
%   xori   = origin's x coordinate of XBeach grid in world coordinates
%   yori   = origin's y coordinate of XBeach grid in world coordinates
%
%   Output:
%   xworld = scalar, vector or array with corresponding x world coordinates
%   yworld = scalar, vector or array with corresponding y world coordinates
%
%   Example
%   x = 0:5:200; y = (0:10:300)';
%   x = repmat(x,length(y),1); y = repmat(y,1,length(x));
%   alfa = 10;
%   xori = 1000; yori = 1000;
%   [xw,yw] = xbeachgrid2worldcoordinates(x,y,alfa,xori,yori);
%
%   See also WORLDCOORDINATES2XBEACHGRID, CONVERTCOORDINATES

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Arend Pool
%
%       arend.pool@gmail.com	
%
%       
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

% Created: 08 Jun 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: xbeachgrid2worldcoordinates.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/xbeachgrid2worldcoordinates.m $
% $Keywords: $

%% Main function
% Convert alfa to radians
alpha = (alfa*pi)/180;

% Compose A
A  = [cos(alpha) sin(alpha); -sin(alpha) cos(alpha)];

% Create vectors of size (1,x) from x and y data
b(1,:) = reshape(x,1,numel(x));
b(2,:) = reshape(y,1,numel(y));

% Compute x and y coordinates for every gridpoint (and every timestep)
c =A*b;

% Reshape array b to xworld and yworld, which have the same size as x and y
% add xori and yori to get real world coordinates
xworld = reshape(c(1,:),size(x)) + xori;
yworld = reshape(c(2,:),size(y)) + yori;
