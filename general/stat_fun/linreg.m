function [a, b, r2, r, k2] = linreg(x, y)
%LINREG  Calculates linear regression through a series of points
%
%   Calculates linear regression through a series of points
%
%   Syntax:
%   [a, b, r2, r, k2] = linreg(x, y)
%
%   Input:
%   x           = x-coordinates
%   y           = y-coordinates
%
%   Output:
%   a           = linear regression parameter of coastline (y=a+b*x NOT y=a*x+b)
%   b           = linear regression parameter of coastline (y=a+b*x NOT y=a*x+b)
%   r2          = Coefficient of determination
%   r           = Coefficient of correlation (sqrt(r2))
%   k2          = Std. error of estimate
%
%   Example
%   [a b] = linreg(x, y)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 13 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: linreg.m 8284 2013-03-06 12:25:14Z boer_g $
% $Date: 2013-03-06 20:25:14 +0800 (Wed, 06 Mar 2013) $
% $Author: boer_g $
% $Revision: 8284 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/linreg.m $
% $Keywords: $

%% linear regression
x = x(:)';
y = y(:)';

% Number of known points
n = length(x);

% Initialization
j = 0; k = 0; l = 0; m = 0; r2 = 0;

% Accumulate intermediate sums
j = sum(x);
k = sum(y);
l = sum(x.^2);
m = sum(y.^2);
r2 = sum(x.*y);

% Compute curve coefficients
b = (n*r2 - k*j)/(n*l - j^2);
a = (k - b*j)/n;

% Compute regression analysis
j = b*(r2 - j*k/n);
m = m - k^2/n;
k = m - j;

% Coefficient of determination
r2 = j/m;

% Coefficient of correlation
r = sqrt(r2);

% Std. error of estimate
k2 = sqrt(k/(n-2));