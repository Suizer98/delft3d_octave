function [n, bin] = histc2(x, y, x_edges, y_edges)
%HISTC2  Bivariate histogram, simial to builtin histc
%
%   More detailed description goes here.
%
%   Syntax:
%   [n bin] = histc2(x, y, x_edges, y_edges)
%
%   See histc for explanation of vectors
%
%   Input: For <keyword,value> pairs call histc3() without arguments.
%   x       = data values
%   y       = data values
%   x_edges = N(:,k) will count the value X(i) if X_EDGES(k) <= X(i) < X_EDGES(k+1).  The
%             last bin will count any values of X that match X_EDGES(end).  Values
%             outside the values in EDGES are not counted.  Use -inf and inf in
%             EDGES to include all non-NaN values.
%   y_edges = N(k,:) will count the value Y(i) if Y_EDGES(k) <= Y(i) < Y_EDGES(k+1).  The
%             last bin will count any values of Y that match Y_EDGES(end).  Values
%             outside the values in EDGES are not counted.  Use -inf and inf in
%             EDGES to include all non-NaN values.
%
%   Output:
%   n       = matrix with counts of x and y
%   bin     = indices to bins in x and y
%
%   Example
%   x = randn(100,1);
%   y =  rand(100,1);
%   x_edges = -5:5;
%   y_edges = 0:0.2:1;
%   [n, bin] = histc2(x, y, x_edges, y_edges);
%   
%   hold all
%   pcolor(x_edges,y_edges,n)
%   plot(x,y,'.c')
%
%   See also: histc, scatter, bin2 (for bivariate histc)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Van Oord
%       Thijs Damsma
%
%       Thijs.Damsma@VanOord.com
%
%       Schaardijk 211
%       3063 NH
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
% Created: 26 Mar 2014
% Created with Matlab version: 8.3.0.532 (R2014a)

% $Id: histc2.m 11926 2015-04-29 15:18:50Z tda.x $
% $Date: 2015-04-29 23:18:50 +0800 (Wed, 29 Apr 2015) $
% $Author: tda.x $
% $Revision: 11926 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/histc2.m $
% $Keywords: $
assert(isequal(size(x),size(y)),'x and y must be equal in size');

[~,nx] = histc(x(:),x_edges);
[~,ny] = histc(y(:),y_edges);

[X,Y] = meshgrid(1:length(x_edges),1:length(y_edges));

bin = [nx ny];
n   = arrayfun(@(X,Y) sum(nx==X & ny == Y),X,Y);