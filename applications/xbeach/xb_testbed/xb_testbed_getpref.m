function pref = xb_testbed_getpref()
%XB_TESTBED_GETPREF  Read testbed preferences
%
%   Read testbed preferences
%
%   Syntax:
%   pref = xb_testbed_getpref()
%
%   Input:
%   none
%
%   Output:
%   pref    = Struct with testbed preferences
%
%   Example
%   pref = xb_testbed_getpref
%
%   See also xb_testbed_check

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 13 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_testbed_getpref.m 4457 2011-04-14 09:01:41Z hoonhout $
% $Date: 2011-04-14 17:01:41 +0800 (Thu, 14 Apr 2011) $
% $Author: hoonhout $
% $Revision: 4457 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_testbed/xb_testbed_getpref.m $
% $Keywords: $

%% read preferences

pref = struct();

if xb_testbed_check
	pref.info   = getpref('xbeach_testbed', 'info');
    pref.dirs   = getpref('xbeach_testbed', 'dirs');
end
