function OK = clockpoly_test()
% CLOCKPOLY_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also CLOCKPOLY

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 07 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: clockpoly_test.m 3443 2010-11-26 21:28:29Z geer $
% $Date: 2010-11-27 05:28:29 +0800 (Sat, 27 Nov 2010) $
% $Author: geer $
% $Revision: 3443 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/fileio/clockpoly_test.m $
% $Keywords: $

MTestCategory.Unit;

%%
% define clockwise polygon

x = [0 0.5 1 0.5 0 -0.5 -1 -0.5];
y = [1 0.5 0 -0.5 -1 -0.5 0 0.5];

try
    rot=clockpoly(x,y);
catch
    OK = 0;
    return;
end

OK = (rot == 1);
