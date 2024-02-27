function varargout = polygon(n,r,x,y,varargin)
%POLYGON  Plot regular polygon with variable number of sides.
%
%   Function to plot a regular polygon with a user-defined number of sides.
%
%   Syntax:
%   varargout = polygon(varargin)
%
%   Input: For <keyword,value> pairs call polygon() without arguments.
%   n         = integer, number of sides of the polygon (choose large n for circle)
%   r         = radius of the circumscribed circle
%   x         = x-coordinate(s) of center point(s), can be a vector for
%               plotting multiple polygons
%   y         = y-coordinate(s) of center point(s), can be a vector for
%               plotting multiple polygons
%   
%   Additional keywords:
%   linespec  = line specs of plotted polygon (e.g. 'b-')
%   top       = boolean, switch to place a vertex or a line segment at the
%               top side ("at 12 o'clock"), 1 = vertex (default), 0 = line
%   handle    = axis handle for plotting
%
%   Output:
%   H         = handle of the plotted polygon
%   xv        = x-coordinate(s) of vertices of polygon(s)
%   yv        = y-coordinate(s) of vertices of polygon(s)
%
%   Example 1:
%   H = polygon(6,'top',0,'linespec','r--')
%   Will plot a regular hexagon in red dashes, rotated such that a line segment is on top
%
%   Example 2:
%   H = polygon(100)
%   Will plot a polygon with 100 sides, which approximates a circle
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Delft University of Technology
%       Max Radermacher
%
%       m.radermacher@tudelft.nl
%
%       Faculty of Civil Engineering and Geosciences
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
% Created: 13 Jan 2017
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: polygon.m 13118 2017-01-13 12:41:01Z m.radermacher.x $
% $Date: 2017-01-13 20:41:01 +0800 (Fri, 13 Jan 2017) $
% $Author: m.radermacher.x $
% $Revision: 13118 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/polygon.m $
% $Keywords: $

%%
OPT.linespec='k-';
OPT.top=1;
OPT.handle=gca;
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

%% Check input consistency
if r <= 0
    error('r needs to be larger than 0');
end

if n < 3
    error('n needs to be larger than 2');
end

if ~isvector(x) || ~isvector(y)
    error('x and y need to be scalars or vectors, not matrices');
end

if length(x) ~= length(y)
    error('x and y need to have the same dimensions');
end

%% Calculate vertices
if OPT.top == 0
    astart = pi/n;
else
    astart = 0;
end
ang = linspace(astart,astart+2*pi,n+1);
xs = r*cos(ang + .5*pi);
ys = r*sin(ang + .5*pi);

%% Plot the shape(s)
xm = repmat(reshape(x,1,[]),length(xs),1) + repmat(reshape(xs,[],1),1,length(x));
ym = repmat(reshape(y,1,[]),length(ys),1) + repmat(reshape(ys,[],1),1,length(y));
H = plot(OPT.handle,xm,ym,OPT.linespec);

if nargout==1
    varargout = {H};
elseif nargout==2
    varargout = {H,xm};
elseif nargout==3
    varargout = {H,xm,ym};
end