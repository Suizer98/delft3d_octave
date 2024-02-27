function [xJ,yJ,zJ] = xb_transects2grid(transects)
%UNTITLED  Interpolate Jarkus transects on grid to efficiently setup XBeach model.
%
%   Jarkus resolution is much higher in cross shore direction than in longshore
%   direction. This script spans a grid with y-direction parallel to the
%   mean coastline and the x-axis shore normal to it. The resulting grid with 
%   course lonsghore resolution and fine crosshore resolution is used in griddata 
%   to efficiently interpolate transects measurments on a grid. 
%
%   Syntax:
%   [xJ,yJ,zJ] = xb_transects2grid(transects)
%
%   Input:
%   varargin  = transects structure 
%
%   Output:
%   varargout = gridded Jarkus data
%
%   Example
%   transects = jarkus_transects('id', [6002000:6002900],'output',{'id','time','x','y','cross_shore','altitude','angle'}); %
%   transects2 = jarkus_interpolatenans(transects);
%   transects3 = jarkus_merge(transects2,'dim','time');
%   [xJ,yJ,zJ] = xb_transects2grid(transects3)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 <COMPANY>
%       Jaap van Thiel de Vries
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 05 Jan 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: xb_transects2grid.m 5870 2012-03-22 11:02:37Z hoonhout $
% $Date: 2012-03-22 19:02:37 +0800 (Thu, 22 Mar 2012) $
% $Author: hoonhout $
% $Revision: 5870 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_transects2grid.m $
% $Keywords: $

%%
angle_m = mean_angle(transects.angle);
angle_m = 270-angle_m;
xori = min(min(transects.x));
yori = min(min(transects.y));
[xr yr] = xb_grid_world2xb(transects.x, transects.y, xori, yori, -angle_m);
[xr_n,yr_n] = meshgrid(min(min(xr)):5:max(max(xr)),min(min(yr)):100:max(max(yr)));
zr_n = griddata(xr,yr,squeeze(transects.altitude),xr_n,yr_n);
[x y] = xb_grid_xb2world(xr_n, yr_n, xori, yori, -angle_m);

xJ = x;
yJ = y;
zJ = zr_n;
