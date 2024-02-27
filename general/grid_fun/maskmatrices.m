function [XI1m,YI1m,ZI1m,XI2m,YI2m,ZI2m] = maskmatrices(XI1,YI1,ZI1,XI2,YI2,ZI2);
%MASKMATRICES masks two matrices to their overlapping dimensions
%
%   Syntax:
%   [XI1m,YI1m,ZI1m,XI2m,YI2m,ZI2m] = maskmatrices(XI1,YI1,ZI1,XI2,YI2,ZI2);
%
%   Input: 
%   XI1,YI1,ZI1,XI2,YI2,ZI2: unmasked matrices
%
%   Output:
%   XI1m,YI1m,ZI1m,XI2m,YI2m,ZI2m: masked matrices
%
%   Example
%   [XI1m,YI1m,ZI1m,XI2m,YI2m,ZI2m] = maskmatrices(XI1,YI1,ZI1,XI2,YI2,ZI2);
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 <COMPANY>
%       grasmeijerb
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
% Created: 27 Mar 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: maskmatrices.m 8378 2013-03-27 15:26:55Z bartgrasmeijer.x $
% $Date: 2013-03-27 23:26:55 +0800 (Wed, 27 Mar 2013) $
% $Author: bartgrasmeijer.x $
% $Revision: 8378 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/maskmatrices.m $
% $Keywords: $


minx0 = minmin(XI1);
maxx0 = maxmax(XI1);
miny0 = minmin(YI1);
maxy0 = maxmax(YI1);

minx1 = minmin(XI2);
maxx1 = maxmax(XI2);
miny1 = minmin(YI2);
maxy1 = maxmax(YI2);

icol1 = XI2(1,:)<minx0 | XI2(1,:)>maxx0;
irow1 = YI2(:,1)<miny0 | YI2(:,1)>maxy0;

icol0 = XI1(1,:)<minx1 | XI1(1,:)>maxx1;
irow0 = YI1(:,1)<miny1 | YI1(:,1)>maxy1;

XI1m = XI1(~irow0,~icol0);
YI1m = YI1(~irow0,~icol0);
ZI1m = ZI1(~irow0,~icol0);

XI2m = XI2(~irow1,~icol1);
YI2m = YI2(~irow1,~icol1);
ZI2m = ZI2(~irow1,~icol1);
