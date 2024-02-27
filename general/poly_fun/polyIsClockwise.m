function isClockwise = polyIsClockwise(x,y)
%POLYISCLOCKWISE  Determines if polygon is clockwise.
%
%   Is faster than poly_isclockwise, but can only handle non self
%   intersecting polygons. 
%
%   Syntax:
%   varargout = polyIsClockwise(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   polyIsClockwise
%
%   See also: poly_isclockwise 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
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
% Created: 25 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: polyIsClockwise.m 2479 2010-04-24 22:43:07Z thijs@damsma.net $
% $Date: 2010-04-25 06:43:07 +0800 (Sun, 25 Apr 2010) $
% $Author: thijs@damsma.net $
% $Revision: 2479 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/poly_fun/polyIsClockwise.m $
% $Keywords: $

%%
x = x(:);
y = y(:);
%ignore nan values
nans = isnan(x+y);
x(nans) = [];
y(nans) = [];
%find left most lowest coordinate

if x(end)==x(1)&&y(end)==y(1)
    x(end) = [];
    y(end) = [];
end
ind1 = find(y==min(y));
[dummy,ind2] = min(x(ind1));
ind0 = ind1(ind2);


ind_down = ind0-1;
if ind_down==0
    ind_down=numel(x);
end
ind_up = ind0+1;
if ind_up>numel(x)
    ind_up=1;
end

dx_up  = x(ind_up)    - x(ind0);
dy_up  = y(ind_up)    - y(ind0);
dx_down = x(ind_down) - x(ind0);
dy_down = y(ind_down) - y(ind0);

isClockwise = (dx_up/dy_up)>(dx_down/dy_down);

