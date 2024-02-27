function [a b] = xydegN2ab(x, y, degN)
%XYGRAD2AB  derive a and b in y = ax+b, given an arbitrary point and degN
%
%   This function derives a and b in y = ax+b, given an arbitrary (x,y)
%   point on the line and direction of the line in degrees (clockwise, with
%   north at degN = 0)
%
%   Syntax:
%   [a b] = xydegN2ab(x, y, degN)
%
%   Input:
%   x    = arbitrary x-coordinate on the line of concern
%   y    = y-coordinate belonging to the x
%   degN = angle in degrees, clockwise, north at degN = 0
%
%   Output:
%   a    = constant a in y = ax+b
%   b    = constant b in y = ax+b
%
%   Example
%   xydegN2ab
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 26 Oct 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: xydegN2ab.m 3187 2010-10-26 11:41:36Z heijer $
% $Date: 2010-10-26 19:41:36 +0800 (Tue, 26 Oct 2010) $
% $Author: heijer $
% $Revision: 3187 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/el_fun/xydegN2ab.m $
% $Keywords: $

%%
if degN < 90
    a = 1/tand(degN);
else
    a = xydegN2ab(x, y, degN-90);
    a = -1/a;
end

b = y(1) - a*x(1);